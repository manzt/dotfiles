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
hooks:
  SessionEnd:
    - hooks:
        - type: command
          command: "dev-browser close 2>/dev/null; true"
---

# marimo-dev: Live Development Environment

This skill orchestrates a full-stack dev environment for working on marimo
itself. It coordinates three services and two companion skills — marimo-pair
for the Python side and dev-browser for the frontend side.

## Setup — MANDATORY 3-step startup

You MUST start all three services every time. Do NOT skip steps or take
shortcuts (e.g., opening the browser directly, skipping Vite, using
execute-code without the browser). The full stack is: marimo → Vite → browser.

A background task "completed" notification does NOT mean the server died —
verify with curl or `discover-servers.sh`.

### Step 1: Start both servers (background)

Both servers **must** use `run_in_background: true` on the Bash tool. Start
them in parallel — they are independent.

**Marimo server** (default port 2718):

```bash
uv run marimo edit notebook.py --headless --no-token --no-skew-protection
```

- `--headless` — Vite serves the frontend, not marimo
- `--no-token` — lets Vite proxy and scripts talk to the API
- `--no-skew-protection` — required for code_mode / execute-code

<<<<<<< Updated upstream
### 2. Vite dev server (background task)
||||||| Stash base
After starting, wait a few seconds then verify it's up:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:2718
```

### 2. Vite dev server (background task)
=======
**Vite dev server** (default port 3000, proxies to marimo on 2718):

```bash
cd frontend && pnpm dev
```

After starting both, verify each is up before moving on.
>>>>>>> Stashed changes

<<<<<<< Updated upstream
**Must be started with `run_in_background: true` on the Bash tool.**

```bash
pnpm dev
```

Starts on port 3000. Proxies `/api`, `/ws`, etc. to marimo on 2718.

### 3. Browser (headed)

Only open the browser after both servers are confirmed up.
||||||| Stash base
**Must be started with `run_in_background: true` on the Bash tool.**

```bash
pnpm dev
```

Starts on port 3000. Proxies `/api`, `/ws`, etc. to marimo on 2718.

After starting, wait a few seconds then verify it's up:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
```

### 3. Browser (headed)

Only open the browser after both servers are confirmed up.
=======
### Step 2: Browser (headed) — ONLY after both servers are confirmed up
>>>>>>> Stashed changes

```bash
dev-browser --headed open http://localhost:3000
```

Point at port 3000 (Vite), NOT 2718. The browser creates the WebSocket
session — without it, execute-code and code_mode have no session to talk to.

### Restarting

Kill both background tasks (marimo + Vite), then re-run steps 1–2 in order.
The browser can stay open — just reload after Vite reconnects.

## Two Skills, Two Sides

This environment gives you two complementary skills for inspecting and
modifying the running app:

- **marimo-pair** — the Python side. Execute code in the kernel, create/edit
  cells, inspect variables, test runtime behavior. Everything runs in the live
  notebook session via `execute-code.sh` or `code_mode`.

- **dev-browser** — the frontend side. Take screenshots, inspect DOM state,
  evaluate JS, interact with UI elements. The browser is pointed at the Vite
  dev server so you see hot-reloaded changes instantly.

To bridge the two: expose React state on `window` for dev-browser to read,
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
