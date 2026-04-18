#!/usr/bin/env bash
set -euo pipefail

# Launch a VS Code Extension Development Host for the marimo-lsp extension,
# with both debug channels wired up:
#   - Chromium CDP on $CDP_PORT so dev-browser can drive the UI
#   - Node inspector on $INSPECTOR_PORT so eval-ext.sh can poke the ext host
# Also exports MARIMO_DEBUG=1 so the extension exposes __marimoVsCode /
# __marimoDebug globals.

CDP_PORT="${MARIMO_CDP_PORT:-9223}"
INSPECTOR_PORT="${MARIMO_INSPECTOR_PORT:-9229}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${MARIMO_REPO_ROOT:-$(cd "$SCRIPT_DIR/../../../.." 2>/dev/null && pwd || true)}"
if [ ! -d "${REPO_ROOT:-}/extension" ]; then
  # Fall back to the well-known checkout path.
  REPO_ROOT="$HOME/github/marimo-team/marimo-lsp"
fi
EXT_DIR="${MARIMO_EXT_DIR:-$REPO_ROOT/extension}"

if [ ! -d "$EXT_DIR" ]; then
  echo "Error: extension dir not found at $EXT_DIR" >&2
  echo "Set MARIMO_EXT_DIR to override." >&2
  exit 1
fi

VSCODE_APP="$EXT_DIR/.vscode-test/vscode-darwin-arm64-insiders/Visual Studio Code - Insiders.app"
VSCODE_BIN="$VSCODE_APP/Contents/MacOS/Electron"
if [ ! -x "$VSCODE_BIN" ]; then
  echo "Error: VS Code Insiders not found at $VSCODE_BIN" >&2
  echo "Run \`pnpm test:extension\` once in $EXT_DIR to download it." >&2
  exit 1
fi

USER_DATA_DIR="$EXT_DIR/.vscode-test/dev-user-data"
WORKSPACE="${MARIMO_WORKSPACE:-$EXT_DIR/tests/sampleWorkspace}"

# Guard against double-launch — a stale host would bind one of the ports and
# leave us attached to the old process with no visible error.
for port in "$CDP_PORT" "$INSPECTOR_PORT"; do
  if lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Error: port $port already in use. Quit the existing VS Code dev host first." >&2
    exit 1
  fi
done

echo "Building extension..."
(cd "$EXT_DIR" && NODE_ENV=development pnpm build >/dev/null)

echo "Launching VS Code dev host (CDP :$CDP_PORT, inspector :$INSPECTOR_PORT)..."
MARIMO_DEBUG=1 nohup "$VSCODE_BIN" \
  --extensionDevelopmentPath="$EXT_DIR" \
  --inspect-extensions="$INSPECTOR_PORT" \
  --remote-debugging-port="$CDP_PORT" \
  --user-data-dir="$USER_DATA_DIR" \
  --disable-workspace-trust \
  "$WORKSPACE" \
  >"$EXT_DIR/.vscode-test/dev-host.log" 2>&1 &
VSCODE_PID=$!
echo "  pid=$VSCODE_PID  log=$EXT_DIR/.vscode-test/dev-host.log"

wait_for_port() {
  local port="$1" label="$2" deadline=$(( SECONDS + 45 ))
  until lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; do
    if ! kill -0 "$VSCODE_PID" 2>/dev/null; then
      echo "Error: VS Code process exited before $label port $port became ready" >&2
      tail -n 40 "$EXT_DIR/.vscode-test/dev-host.log" >&2 || true
      exit 1
    fi
    if [ "$SECONDS" -ge "$deadline" ]; then
      echo "Error: timed out waiting for $label port $port" >&2
      exit 1
    fi
    sleep 0.3
  done
}

wait_for_port "$CDP_PORT" "CDP"
wait_for_port "$INSPECTOR_PORT" "inspector"

# Wait for the extension host to finish activating — the inspector port opens
# before __marimoDebug is set. Poll for the global up to ~20s.
echo "Waiting for extension host activation..."
for _ in $(seq 1 40); do
  if "$SCRIPT_DIR/eval-ext.sh" "typeof globalThis.__marimoDebug" 2>/dev/null | grep -q object; then
    echo "  ready."
    break
  fi
  sleep 0.5
done

echo
echo "Dev host ready."
echo "  CDP       -> http://localhost:$CDP_PORT  (for dev-browser --connect)"
echo "  Inspector -> http://localhost:$INSPECTOR_PORT (for eval-ext.sh)"
