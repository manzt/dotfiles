---
name: marimo-dev
description: >-
  Live development environment for working on marimo itself — both the Python
  runtime and the React frontend. Spins up the marimo server, Vite dev server,
  and a headed browser so you can edit code, see changes live, and inspect
  state from both sides. Use this skill when the user wants to debug marimo
  internals, develop a frontend feature, test runtime behavior visually,
  iterate on the UI, or do any hands-on development on the marimo codebase.
  Trigger on: "debug marimo", "dev environment", "start the frontend",
  "I want to see what this looks like", "visual test", "inspect the DOM",
  or any task that requires running marimo + Vite together for development.
user-invocable: true
---

# marimo-dev: Live Development Environment

This skill orchestrates a full-stack dev environment for working on marimo
itself. It coordinates three services and two companion skills — marimo-pair
for the Python side and agent-browser for the frontend side.

## Setup

Start all three services from the marimo repo root. Order matters — the marimo
server must be up before Vite (which proxies to it), and the browser points at
Vite.

**CRITICAL: Always use `run_in_background` on the Bash tool for both the
marimo server and the Vite dev server.** These are long-running processes —
launching them in the foreground blocks the conversation. Background tasks are
automatically cleaned up when the session ends. A background task "completed"
notification does NOT mean the server died — check the output or use
`discover-servers.sh` / `curl` to verify.

### 1. Marimo server (background task)

**Must be started with `run_in_background: true` on the Bash tool.**

```bash
uv run marimo edit notebook.py --headless --no-token --no-skew-protection
```

- `--headless` — don't open a browser (Vite serves the frontend instead)
- `--no-token` — required so Vite proxy and scripts can talk to the API
- `--no-skew-protection` — required for marimo-pair's execute-code to work
- Default port: 2718

After starting, wait a few seconds then verify it's up:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:2718
```

### 2. Vite dev server (background task)

**Must be started with `run_in_background: true` on the Bash tool.**

```bash
cd frontend && pnpm dev
```

Starts on port 3000. Proxies `/api`, `/ws`, etc. to marimo on 2718.

After starting, wait a few seconds then verify it's up:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
```

### 3. Browser (headed)

Only open the browser after both servers are confirmed up.

```bash
agent-browser --headed open http://localhost:3000
```

Point at port 3000 (Vite), not 2718 (marimo directly).

### Cleanup

Set up a SessionEnd hook so the browser closes when the session ends:

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [{ "type": "command", "command": "agent-browser close" }]
      }
    ]
  }
}
```

## Two Skills, Two Sides

This environment gives you two complementary skills for inspecting and
modifying the running app:

- **marimo-pair** — the Python side. Execute code in the kernel, create/edit
  cells, inspect variables, test runtime behavior. Everything runs in the live
  notebook session via `execute-code.sh` or `code_mode`.

- **agent-browser** — the frontend side. Take screenshots, inspect DOM state,
  evaluate JS, interact with UI elements. The browser is pointed at the Vite
  dev server so you see hot-reloaded changes instantly.

To bridge the two: expose React state on `window` for agent-browser to read,
or use marimo-pair to push data into the kernel that triggers UI updates.

```typescript
// In a React component (dev only)
window.__debug = { store, state };
```

## What Needs a Restart

**Frontend (never restart):** Vite hot-reloads all changes under `frontend/src/`
automatically. Edit, save, and the browser reflects it within seconds.

**Python runtime (sometimes restart):** Changes to marimo's Python code take
effect depending on when that code path runs:

- *No restart needed:* Logic called on each cell execution, formatters,
  renderers, `_code_mode` — these re-import or re-enter on the next action.
- *Restart needed:* Server startup, route handlers, WebSocket protocol,
  anything in the initialization path.

To restart marimo: stop both the marimo server and Vite background tasks, then
re-run both in order (marimo first, then Vite). Restarting both avoids stale
proxy connections. The browser can stay open — just reload the page or wait for
Vite to reconnect.

**code_mode specifically:** If you're iterating on `marimo._code_mode`, you
don't need to restart anything. Update the source, then test via marimo-pair's
execute-code — it runs in the live kernel and picks up changes immediately.
