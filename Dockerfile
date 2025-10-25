# syntax=docker/dockerfile:1.7

ARG NODE_VERSION=20

# ------------------------------
# Builder stage: install deps and build the app
# ------------------------------
FROM node:${NODE_VERSION}-bookworm-slim AS builder

# Build dependencies for native modules used by this app (e.g., better-sqlite3, sharp)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git python3 make g++ \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# ------------------------------
# Runtime stage: includes Cline CLI and TaskMaster AI MCP
# ------------------------------
FROM node:${NODE_VERSION}-bookworm-slim

ENV NODE_ENV=production \
    npm_config_python=python3

# Build deps needed because Cline CLI bundles better-sqlite3 and other native modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git python3 make g++ \
 && rm -rf /var/lib/apt/lists/*

# Install Cline CLI from a specific commit of cline/cline, cli package only
RUN git clone https://github.com/cline/cline.git /tmp/cline \
 && cd /tmp/cline \
 && git checkout 062a32f93d3082c34e87720d7d57620805bdf8e9 \
 && cd cli \
 && npm ci \
 && npm install -g . \
 && rm -rf /tmp/cline

# Install TaskMaster AI MCP server globally (can also be launched via npx)
RUN npm install -g task-master-ai

# App files from builder
WORKDIR /app
COPY --from=builder /app /app

# Entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Non-root runtime
USER node

# Expose the server port used by server/index.js
EXPOSE 3001

# Defaults; override via Coolify env if needed
ENV APP_CMD="node server/index.js" \
    RUN_TASKMASTER="0" \
    TASKMASTER_ARGS=""

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
