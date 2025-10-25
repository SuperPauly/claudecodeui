# Multi-stage build for production deployment with Cline CLI and MCP TaskMaster AI
# Stage 1: Build the frontend
FROM node:20-alpine AS frontend-builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies needed for build)
RUN npm install

# Copy source code
COPY . .

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

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => process.exit(res.statusCode === 200 ? 0 : 1))" || exit 1

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000 \
    CLINE_MODEL=gpt-4 \
    LOG_LEVEL=info

# Use entrypoint script for initialization
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["npm", "run", "server"]
