---
description: Reference guide for ast-grep structural code search and refactoring. Use ast-grep when you need pattern-based code search or safe structural refactoring across a codebase.
user-invocable: false
---

## Structural code search and replace

Use `ast-grep` to search for code patterns or perform accurate and safe
refactorings accross an entire codebase. It is the preferred tool for
automating repetitive structural code changes.


### Basic Search
```bash
# Find all console.log statements
ast-grep --pattern 'console.log($$$)'

# Search in specific files
ast-grep --pattern 'useState($$$)' src/**/*.tsx

# Multi-pattern search
ast-grep --pattern 'console.log($$$)' --pattern 'console.error($$$)'
```

### Pattern Syntax
```bash
# $$ - matches single AST node
ast-grep --pattern 'const $$ = $$'

# $$$ - matches multiple nodes
ast-grep --pattern 'function $$$($$$) { $$$ }'

# $_ - matches any single token
ast-grep --pattern 'import { $_ } from "react"'
```

### Rewrite Code
```bash
# Replace console.log with logger.debug
ast-grep --pattern 'console.log($$$)' --rewrite 'logger.debug($$$)'

# Add async to functions
ast-grep --pattern 'function $FUNC($$$) { $$$ }' --rewrite 'async function $FUNC($$$) { $$$ }'
```

## Rule Configuration

### Basic Rule (rule.yml)
```yaml
id: no-console
language: javascript
rule:
  pattern: console.log($$$)
message: Use logger instead of console.log
severity: warning
```

### Advanced Rule with Multiple Patterns
```yaml
id: no-var
language: javascript
rule:
  any:
    - pattern: var $$ = $$
    - pattern: var $$
fix:
  pattern: var $ID = $INIT
  fix: const $ID = $INIT
```

### Rule with Constraints
```yaml
id: prefer-const
language: javascript
rule:
  pattern: let $ID = $INIT
  not:
    inside:
      any:
        - kind: for_statement
        - pattern: $ID = $$
```

### Complex Rule Example
```yaml
id: no-unused-imports
language: typescript
rule:
  pattern: import { $IMPORT } from $SOURCE
  not:
    has:
      pattern: $IMPORT
      inside:
        stopBy: end
```

## Common Examples

### Find React Hooks
```bash
ast-grep --pattern 'use$_($$$)'
```

### Find Async Functions
```bash
ast-grep --pattern 'async function $$$($$$) { $$$ }'
```

### Find JSX Components
```bash
ast-grep --pattern '<$COMPONENT $$$>$$$</$COMPONENT>'
```

### Find Try-Catch Blocks
```bash
ast-grep --pattern 'try { $$$ } catch ($$$) { $$$ }'
```

### Replace Import Paths
```bash
ast-grep --pattern 'import $$$ from "@old/path"' --rewrite 'import $$$ from "@new/path"'
```

## Running Rules

```bash
# Run single rule
ast-grep scan --rule rule.yml

# Run all rules in directory
ast-grep scan --rule-dir ./rules

# Output JSON format
ast-grep scan --rule rule.yml --json

# Fix issues automatically
ast-grep scan --rule rule.yml --fix
```
