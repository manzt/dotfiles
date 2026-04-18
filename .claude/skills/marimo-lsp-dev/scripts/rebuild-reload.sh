#!/usr/bin/env bash
set -euo pipefail

EXT_DIR="${MARIMO_EXT_DIR:-$HOME/github/marimo-team/marimo-lsp/extension}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Building..."
(cd "$EXT_DIR" && NODE_ENV=development pnpm build)

echo "Reloading VS Code window..."
"$SCRIPT_DIR/eval-ext.sh" "await globalThis.__marimoVsCode.commands.executeCommand('workbench.action.reloadWindow')" || true

echo ""
echo "Reload triggered. The WebSocket URL has changed."
echo "Next eval-ext.sh call will auto-discover the new URL."
