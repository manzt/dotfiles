# Inspection Recipes

Common `eval-ext.sh` invocations for inspecting marimo-lsp extension state.

## Basics

```bash
EVAL="path/to/scripts/eval-ext.sh"

# Check debug bridge is available
$EVAL "typeof globalThis.__marimoDebug"
# → "object"

# Check vscode API is available
$EVAL "typeof globalThis.__marimoVsCode"
# → "object"
```

## VS Code Commands

```bash
# Execute any VS Code command
$EVAL "await __marimoVsCode.commands.executeCommand('workbench.action.files.newUntitledFile')"

# Open a specific file
$EVAL "
  const doc = await __marimoVsCode.workspace.openTextDocument('/path/to/file.py');
  await __marimoVsCode.window.showTextDocument(doc);
  doc.uri.toString()
"

# Get list of all registered commands (filtered to marimo)
$EVAL "
  const cmds = await __marimoVsCode.commands.getCommands(true);
  JSON.stringify(cmds.filter(c => c.includes('marimo')))
"

# Reload the window (after code changes)
$EVAL "await __marimoVsCode.commands.executeCommand('workbench.action.reloadWindow')"
```

## Notebook State

```bash
# Get active notebook URI
$EVAL "
  const nb = __marimoVsCode.window.activeNotebookEditor;
  nb ? nb.notebook.uri.toString() : 'no active notebook'
"

# Get all open notebook URIs
$EVAL "
  JSON.stringify(__marimoVsCode.workspace.notebookDocuments.map(d => d.uri.toString()))
"

# Get cell count in active notebook
$EVAL "
  const nb = __marimoVsCode.window.activeNotebookEditor;
  nb ? nb.notebook.cellCount : 0
"

# Get cell contents
$EVAL "
  const nb = __marimoVsCode.window.activeNotebookEditor;
  if (!nb) throw new Error('no active notebook');
  const cells = [];
  for (let i = 0; i < nb.notebook.cellCount; i++) {
    const cell = nb.notebook.cellAt(i);
    cells.push({ index: i, kind: cell.kind, text: cell.document.getText().slice(0, 100) });
  }
  JSON.stringify(cells)
"
```

## Extension Services (via __marimoDebug)

```bash
# List available debug services
$EVAL "JSON.stringify(Object.keys(globalThis.__marimoDebug || {}))"

# Note: These are Effect-TS service instances. Their methods return Effect values.
# For direct state reads, access the underlying SubscriptionRef/Ref if the service exposes it.
# For running Effects, you'd need to also expose the runtime (advanced).
```

## Diagnostics

```bash
# Get VS Code diagnostics for all marimo files
$EVAL "
  const all = __marimoVsCode.languages.getDiagnostics();
  const marimo = all.filter(([uri]) => uri.path.endsWith('.py'));
  JSON.stringify(marimo.map(([uri, diags]) => ({
    file: uri.path,
    count: diags.length,
    errors: diags.filter(d => d.severity === 0).length,
    warnings: diags.filter(d => d.severity === 1).length
  })))
"
```

## Configuration

```bash
# Read marimo extension config
$EVAL "
  const config = __marimoVsCode.workspace.getConfiguration('marimo');
  JSON.stringify({
    lsp: config.get('lsp'),
    runtime: config.get('runtime')
  })
"
```

## Logs

```bash
# Tail the file-based log (run from regular shell, not eval-ext)
tail -f /Users/manzt/github/marimo-team/marimo-lsp/extension/logs/marimo.log

# View VS Code Output channel (open it in the UI)
$EVAL "await __marimoVsCode.commands.executeCommand('workbench.action.output.toggleOutput')"
```

## UI Interaction (via dev-browser)

```bash
# Take a screenshot
dev-browser --session ui screenshot /tmp/vscode.png

# Get interactive elements
dev-browser --session ui snapshot -i

# Click an element by ref
dev-browser --session ui click @e5

# Open command palette
dev-browser --session ui press Meta+Shift+KeyP

# Type in command palette
dev-browser --session ui keyboard type "marimo"
```
