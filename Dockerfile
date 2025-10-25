# Multi-stage build for production deployment with Cline CLI and MCP TaskMaster AI
# Stage 1: Build the frontend
# Example builder stage (adjust base image/tag to match your Dockerfile)
FROM node:20-bullseye AS frontend-builder
WORKDIR /app

# Install system build deps required for node-gyp and sqlite native modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    build-essential \
    make \
    g++ \
    libsqlite3-dev \
    pkg-config \
  && ln -sf /usr/bin/python3 /usr/bin/python \
  && rm -rf /var/lib/apt/lists/*

# Ensure node-gyp uses python3
ENV PYTHON=/usr/bin/python3
ENV npm_config_python=/usr/bin/python3

# Copy package files first to leverage Docker layer cache
COPY package*.json ./

# If you have package-lock.json, prefer 'npm ci' for reproducible installs
# --unsafe-perm ensures node-gyp can run when npm runs as root inside container
RUN npm ci --unsafe-perm --prefer-offline --no-audit --fund=false

# Copy the rest of the source and continue build steps
COPY . .

# (Continue with build steps: build, compile, etc.)

# Build the frontend with Vite
RUN npm run build

# Stage 2: Production image
FROM node:20-alpine

# Create non-root user for security
RUN addgroup -g 1001 -S appuser && \
    adduser -u 1001 -S appuser -G appuser

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Copy all node_modules from builder stage
# Note: In production environments with proper SSL certificates, 
# you can install fresh dependencies with: RUN npm install --omit=dev
# For now, we copy from builder to avoid npm issues
COPY --from=frontend-builder /app/node_modules ./node_modules

# Copy built frontend from builder stage
COPY --from=frontend-builder /app/dist ./dist

# Copy server files
COPY server ./server
COPY index.html ./

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create necessary directories with proper permissions
RUN mkdir -p /home/appuser/.cline/projects \
    /home/appuser/.mcp \
    /data \
    /app/logs && \
    chown -R appuser:appuser /home/appuser /app /data

# Clean up to reduce image size
RUN npm cache clean --force && \
    rm -rf /tmp/*

# Switch to non-root user
USER appuser

# Expose ports
EXPOSE 3000 3001

#  Health check
# HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
#    CMD node -e "require('http').get('http://localhost:3000/health', (res) => process.exit(res.statusCode === 200 ? 0 : 1))" || exit 1

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000 \
    CLINE_MODEL=gpt-4 \
    LOG_LEVEL=info

# Use entrypoint script for initialization
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["npm", "run", "server"]
