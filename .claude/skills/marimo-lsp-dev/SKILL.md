---
name: marimo-lsp-dev
description: >-
  Debug and develop the marimo VS Code extension with a tight edit-build-test
  feedback loop. Launches a VS Code Extension Development Host with two debug
  channels: agent-browser for UI interaction (screenshots, clicks, commands) and
  a Node inspector WebSocket for evaluating JS in the extension host process
  (call vscode APIs, inspect Effect-TS services, query kernel/cell/variable
  state). Use this skill whenever working on the marimo-lsp extension, debugging
  extension behavior, testing UI changes, inspecting extension state at runtime,
  or reproducing user-reported issues. Trigger on: "debug the extension",
  "test this extension change", "launch dev host", "inspect extension state",
  "what does the extension do when...", or any task involving the VS Code
  extension development workflow.
user-invocable: true
hooks:
  SessionEnd:
    - hooks:
        - type: command
          command: "agent-browser --session ui close 2>/dev/null; true"
---

# marimo-lsp-dev: VS Code Extension Debug Environment

This skill gives you two channels into a running VS Code Extension Development
Host, enabling a tight edit-build-test loop for the marimo-lsp extension.

**Channel 1 — UI (agent-browser):** Connected to VS Code's Chromium renderer via
CDP. Take screenshots, click buttons, open files, interact with the command
palette, inspect the DOM.

**Channel 2 — Extension Host (eval-ext.sh):** Connected to the extension host's
Node.js inspector via WebSocket. Evaluate any JS expression in the process where
the extension actually runs. Call `vscode.workspace.*`, `vscode.window.*`,
inspect Effect-TS services, read kernel state.

## Setup — 3 steps

Scripts are at: `~/.claude/skills/marimo-lsp-dev/scripts/`

### Step 1: Launch

```bash
~/.claude/skills/marimo-lsp-dev/scripts/launch-dev.sh
```

This builds the extension, launches VS Code with `--remote-debugging-port=9223`
and `--inspect-extensions=9229`, waits for both to be ready, and connects
agent-browser.

CRITICAL: If VS Code is already running, quit it first. The CDP port must be set
at launch time. If port 9223 or 9229 is already in use, the script will error.

### Step 2: Verify

```bash
# Extension host channel
~/.claude/skills/marimo-lsp-dev/scripts/eval-ext.sh "typeof globalThis.__marimoDebug"
# Should return: object

# UI channel
agent-browser --session ui snapshot -i
# Should return: VS Code accessibility tree
```

### Step 3: Open a notebook (optional)

```bash
~/.claude/skills/marimo-lsp-dev/scripts/eval-ext.sh "
  const doc = await __marimoVsCode.workspace.openTextDocument('/path/to/notebook.py');
  await __marimoVsCode.window.showTextDocument(doc);
  doc.uri.toString()
"
```

## Edit-Build-Test Loop

1. **Edit** code in the extension source
2. **Rebuild + reload:**
   ```bash
   ~/.claude/skills/marimo-lsp-dev/scripts/rebuild-reload.sh
   ```
   This runs `pnpm build` and triggers `workbench.action.reloadWindow`.
3. **Test** — use either channel to verify the change:
   - Screenshot: `agent-browser --session ui screenshot /tmp/test.png`
   - Eval: `eval-ext.sh "..."`
4. **Repeat**

## Two Channels

### UI Channel (agent-browser)

Best for: visual verification, clicking through UI, testing user-facing workflows.

```bash
# Screenshot
agent-browser --session ui screenshot /tmp/vscode.png

# Interactive element tree
agent-browser --session ui snapshot -i

# Click an element
agent-browser --session ui click @e5

# Open command palette
agent-browser --session ui press Meta+Shift+KeyP

# Type
agent-browser --session ui keyboard type "marimo run stale"
```

### Extension Host Channel (eval-ext.sh)

Best for: calling vscode APIs, inspecting state, executing commands programmatically.

The extension exposes two globals when `MARIMO_DEBUG=1`:
- `__marimoVsCode` — the full `vscode` API module
- `__marimoDebug` — key Effect-TS service instances (controllerRegistry,
  cellStateManager, executionRegistry, variablesService, notebookEditorRegistry,
  kernelManager, sessionStateManager, plus the raw Effect context)

```bash
EVAL=~/.claude/skills/marimo-lsp-dev/scripts/eval-ext.sh

# Execute a command
$EVAL "await __marimoVsCode.commands.executeCommand('marimo.runStale')"

# Get active notebook
$EVAL "
  const nb = __marimoVsCode.window.activeNotebookEditor;
  nb ? nb.notebook.uri.toString() : 'no active notebook'
"

# List marimo commands
$EVAL "
  const cmds = await __marimoVsCode.commands.getCommands(true);
  JSON.stringify(cmds.filter(c => c.includes('marimo')))
"
```

`eval-ext.sh` supports multiline expressions via stdin/heredoc. Top-level
`await` works natively — the last expression's value is returned:

```bash
$EVAL <<'EOF'
const cmds = await __marimoVsCode.commands.getCommands(true);
JSON.stringify(cmds.filter(c => c.startsWith('marimo.')))
EOF
```

See `references/inspection-recipes.md` for more recipes.

## Guard Rails

- **WebSocket URL changes on reload.** After `rebuild-reload.sh`, the Node
  inspector gets a new WebSocket ID. `eval-ext.sh` re-discovers it automatically
  on each call, so this is transparent.
- **Ports must not conflict.** Default: 9223 (renderer CDP), 9229 (extension host
  inspector). Override with `MARIMO_CDP_PORT` and `MARIMO_INSPECTOR_PORT` env vars.
- **`MARIMO_DEBUG=1` is required.** The `launch-dev.sh` script sets this. Without
  it, `__marimoVsCode` and `__marimoDebug` are not exposed.
- **Quit VS Code before relaunching.** The `--remote-debugging-port` flag only
  takes effect at launch time.
- **The debug globals are service instances, not snapshots.** They reflect live
  state. Effect-TS service methods return `Effect` values — for simple property
  reads this is fine, but running Effects requires the runtime (advanced).

## Logs

```bash
# File-based log
tail -f /Users/manzt/github/marimo-team/marimo-lsp/extension/logs/marimo.log

# Open VS Code output panel
$EVAL "await __marimoVsCode.commands.executeCommand('workbench.action.output.toggleOutput')"
```
