#!/usr/bin/env bash
set -euo pipefail

EXT_DIR="${MARIMO_EXT_DIR:-/Users/manzt/github/marimo-team/marimo-lsp/extension}"
PROJECT_DIR="$(dirname "$EXT_DIR")"
CDP_PORT="${MARIMO_CDP_PORT:-9223}"
INSPECTOR_PORT="${MARIMO_INSPECTOR_PORT:-9229}"

# Build the extension
echo "Building extension..."
(cd "$EXT_DIR" && NODE_ENV=development pnpm build)

# Kill any existing Extension Development Host on these ports
if curl -s "http://localhost:${CDP_PORT}/json" > /dev/null 2>&1; then
  echo "Warning: port ${CDP_PORT} already in use. Kill existing VS Code instance first." >&2
  exit 1
fi

# Launch VS Code Extension Development Host with both debug ports
echo "Launching Extension Development Host..."
MARIMO_DEBUG=1 open -a "Visual Studio Code" --args \
  --remote-debugging-port="$CDP_PORT" \
  --inspect-extensions="$INSPECTOR_PORT" \
  --extensionDevelopmentPath="$EXT_DIR" \
  "$PROJECT_DIR"

# Wait for the inspector to be ready
echo "Waiting for inspector on port ${INSPECTOR_PORT}..."
for i in $(seq 1 30); do
  if curl -s "http://localhost:${INSPECTOR_PORT}/json" > /dev/null 2>&1; then
    echo "Inspector ready on port ${INSPECTOR_PORT}"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "Timeout waiting for inspector" >&2
    exit 1
  fi
  sleep 1
done

# Wait for renderer CDP
echo "Waiting for renderer on port ${CDP_PORT}..."
for i in $(seq 1 30); do
  if curl -s "http://localhost:${CDP_PORT}/json" > /dev/null 2>&1; then
    echo "Renderer ready on port ${CDP_PORT}"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "Timeout waiting for renderer" >&2
    exit 1
  fi
  sleep 1
done

# Connect agent-browser for UI interaction
echo "Connecting agent-browser to renderer..."
agent-browser --session ui connect "$CDP_PORT"

echo ""
echo "Ready! Two channels available:"
echo "  UI:     agent-browser --session ui snapshot -i"
echo "  ExtHost: $(dirname "$0")/eval-ext.sh '<expression>'"
