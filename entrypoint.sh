#!/usr/bin/env bash
set -euo pipefail

echo "Node: $(node -v)"
echo "NPM: $(npm -v)"
if command -v cline >/dev/null 2>&1; then
  echo "Cline CLI installed"
fi
if command -v task-master-ai >/dev/null 2>&1; then
  echo "TaskMaster AI MCP installed"
fi

# Optionally start TaskMaster AI server in the background
if [ "${RUN_TASKMASTER:-0}" = "1" ]; then
  echo "Starting TaskMaster AI MCP server..."
  (task-master-ai ${TASKMASTER_ARGS:-} 2>&1 | sed -u 's/^/[taskmaster] /') &
fi

echo "Starting app: ${APP_CMD}"
exec sh -lc "${APP_CMD}"
