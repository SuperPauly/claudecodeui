#!/bin/sh
set -e

echo "==================================="
echo "Claude Code UI with Cline CLI"
echo "==================================="

# Verify required environment variables
if [ -z "$JWT_SECRET" ]; then
    echo "ERROR: JWT_SECRET environment variable is required"
    exit 1
fi

if [ -z "$CLINE_API_KEY" ]; then
    echo "WARNING: CLINE_API_KEY not set. Cline CLI features may not work."
fi

# Create necessary directories
mkdir -p /home/appuser/.cline/projects
mkdir -p /home/appuser/.mcp
mkdir -p /data
mkdir -p /app/logs

# Set proper permissions
chown -R appuser:appuser /home/appuser/.cline /home/appuser/.mcp /data /app/logs 2>/dev/null || true

# Display configuration
echo "Environment Configuration:"
echo "  NODE_ENV: ${NODE_ENV:-production}"
echo "  PORT: ${PORT:-3000}"
echo "  CLINE_MODEL: ${CLINE_MODEL:-gpt-4}"
echo "  LOG_LEVEL: ${LOG_LEVEL:-info}"
echo "  MCP_TASKMASTER_ENABLED: ${MCP_TASKMASTER_ENABLED:-true}"
echo "  ENABLE_FILE_UPLOAD: ${ENABLE_FILE_UPLOAD:-true}"
echo "  ENABLE_GIT_INTEGRATION: ${ENABLE_GIT_INTEGRATION:-true}"
echo "  ENABLE_TERMINAL: ${ENABLE_TERMINAL:-true}"

# Check if Cline CLI is available
if command -v cline &> /dev/null; then
    echo "✓ Cline CLI detected"
    cline --version || true
else
    echo "⚠ Cline CLI not found in PATH"
    echo "  Install Cline CLI: https://cline-cli.example.com/docs"
fi

# Check if Claude CLI is available
if command -v claude &> /dev/null; then
    echo "✓ Claude CLI detected"
    claude --version || true
else
    echo "ℹ Claude CLI not found (optional)"
fi

# Check if Cursor CLI is available
if command -v cursor &> /dev/null; then
    echo "✓ Cursor CLI detected"
else
    echo "ℹ Cursor CLI not found (optional)"
fi

# Initialize MCP TaskMaster AI if enabled
if [ "$MCP_TASKMASTER_ENABLED" = "true" ]; then
    echo "MCP TaskMaster AI integration enabled"
    if [ -n "$TASKMASTER_API_KEY" ]; then
        echo "✓ TaskMaster API key configured"
    else
        echo "ℹ TaskMaster API key not set (optional)"
    fi
fi

# Display volume mounts
echo "Volume Mounts:"
echo "  Cline Projects: /home/appuser/.cline/projects"
echo "  MCP Config: /home/appuser/.mcp"
echo "  Data: /data"

echo "==================================="
echo "Starting Claude Code UI..."
echo "==================================="

# Execute the main command
exec "$@"
