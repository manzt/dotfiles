#!/usr/bin/env bash
set -euo pipefail

INSPECTOR_PORT="${MARIMO_INSPECTOR_PORT:-9229}"

# Accept expression from argument or stdin (heredoc)
if [ $# -ge 1 ]; then
  EXPR="$1"
elif [ ! -t 0 ]; then
  EXPR="$(cat)"
else
  echo "Usage: eval-ext.sh '<js expression>'" >&2
  echo "       eval-ext.sh <<'EOF'" >&2
  echo "         <multiline js>" >&2
  echo "       EOF" >&2
  exit 1
fi

# Discover the WebSocket URL from the Node inspector
WS_URL=$(curl -s "http://localhost:${INSPECTOR_PORT}/json" | node -e "
  let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
    const targets = JSON.parse(d);
    const t = targets.find(t => t.type === 'node') || targets[0];
    if (!t || !t.webSocketDebuggerUrl) { console.error('No inspector target found'); process.exit(1); }
    console.log(t.webSocketDebuggerUrl);
  });
")

if [ -z "$WS_URL" ]; then
  echo "Error: Could not discover inspector WebSocket URL on port ${INSPECTOR_PORT}" >&2
  echo "Is VS Code running with --inspect-extensions=${INSPECTOR_PORT}?" >&2
  exit 1
fi

# Evaluate the expression in the extension host via Runtime.evaluate
node -e "
  const ws = new WebSocket(process.argv[1]);
  const timer = setTimeout(() => { console.error('Timeout waiting for response'); process.exit(1); }, 15000);
  ws.onopen = () => {
    ws.send(JSON.stringify({
      id: 1,
      method: 'Runtime.evaluate',
      params: {
        expression: process.argv[2],
        returnByValue: true,
        awaitPromise: true,
        replMode: true
      }
    }));
  };
  ws.onmessage = (event) => {
    const msg = JSON.parse(event.data);
    if (msg.id !== 1) return;
    clearTimeout(timer);
    if (msg.result?.exceptionDetails) {
      const ex = msg.result.exceptionDetails;
      console.error('Error:', ex.exception?.description || ex.text);
      ws.close();
      process.exit(1);
    }
    const val = msg.result?.result?.value;
    if (val !== undefined) {
      console.log(typeof val === 'string' ? val : JSON.stringify(val, null, 2));
    } else {
      console.log(JSON.stringify(msg.result?.result, null, 2));
    }
    ws.close();
    process.exit(0);
  };
  ws.onerror = (e) => { console.error('WebSocket error:', e.message); process.exit(1); };
" "$WS_URL" "$EXPR"
