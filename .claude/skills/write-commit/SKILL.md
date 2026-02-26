---
description: Write a commit message for current jj changes. Diffs from @- and writes a structured commit message to commit.md.
argument-hint: "[diff-from-ref (default: @-)]"
disable-model-invocation: true
---

# Write Commit

Write a commit message for the current changes.

You are a skilled engineer who communicates clearly and concisely in prose.
No flowery language. Efficient communication only.

## Steps

1. Run `jj diff --from $ARGUMENTS --git` to see all changes (default: `@-` if no argument given)
2. Understand the motivation and scope of the changes
3. Write a commit message to `commit.md` following the format below

## Format

```
<title>

<body>
```

### Title
- Imperative mood ("Add X" not "Added X")
- Concise, ~50 chars ideally
- No period at end

### Body
- Write in prose, not bullet points or sections
- Focus on why, not what (let the diff speak for details)
- Explain motivation and context
- Note any non-obvious tradeoffs or design decisions
- Keep it sufficiently detailed but not overly long
- Include a high-level code snippet when there is a new top-level API or concept

### DO NOT
- Reiterate implementation details (those should be evident in the diff)
- Use markdown other than backticks and links (no bold or italics)
- Be too long; sufficient detail might be a few sentences

## Example

```
Add CellConfig parsing for decorator kwargs

Marimo cells support configuration via decorator kwargs like
`@app.cell(hide_code=True, disabled=True)`. Previously we only detected
the presence of the decorator but ignored any configuration.

This adds a CellConfig struct and updates the parser to extract these
values from regular cells, setup cells, and unparsable cells. The config
is needed for round-trip serialization since we need to preserve these
settings when writing notebooks back to disk.

The new API exposes config on each cell:

    cell.config.hide_code  // bool
    cell.config.disabled   // bool
    cell.config.column     // Option<u32>
```
