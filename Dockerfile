# Multi-stage build for production deployment
# Stage 1: Build the frontend
FROM node:20-alpine AS frontend-builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build the frontend
RUN npm run build

# Stage 2: Production image
FROM node:20-alpine

# Install necessary system dependencies
RUN apk add --no-cache \
    git \
    bash \
    curl \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S appuser && \
    adduser -u 1001 -S appuser -G appuser

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

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

# Switch to non-root user
USER appuser

# Expose ports
EXPOSE 3000 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Set environment
ENV NODE_ENV=production \
    PORT=3000 \
    CLINE_MODEL=gpt-4 \
    LOG_LEVEL=info

# Use entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["npm", "run", "server"]
