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
3. Write a commit message to `commit.md` following the guidance below

## The principle

A commit message captures what is **not** in the diff. Length follows
content, not a template — if nothing load-bearing remains to say
beyond the title, the title is the whole message.

## Write about what the diff doesn't show

Body text earns its place when it captures at least one of:

- A non-obvious tradeoff or design decision — why this path and not
  the nearby alternative a reader would reach for.
- A new public interface or contract. Describe how callers use it,
  and include a small code snippet when it helps.
- A new architecture or data flow. A sentence of prose; a tiny ASCII
  diagram when it genuinely earns one.
- Why *now* — an incident, a blocker being cleared, a follow-up to a
  known-bad state — when the timing isn't self-evident.

## Skip the body when there's nothing to say

If none of the above applies, stop at the title. A typo fix, rename,
dependency bump, or a straightforward regression test is usually
title-only. Do not pad.

Never include:

- A prose retelling of the diff (`renames X to Y, moves Z into W`)
- A file-by-file summary
- A restatement of the title at length
- Throat-clearing, apologies, or `this commit` / `this PR` openers

## Voice

- Imperative title, ~50 chars, no trailing period.
- Body is prose — no bullet lists, no section headers, no bold or
  italic. Backticks and links are fine.
- Do not open a sentence with a bare `This` / `This commit` / `This
  PR` referring to the change. Name the thing (`the parser`, `the
  new hook`) or use `these changes` when a collective subject is
  genuinely needed.

## Examples

Title only — nothing in the diff needs explaining:

```
Fix typo in CellConfig docstring
```

Short body — a fix where the cause isn't obvious from the code:

```
Fall back to stdin when the tty probe fails

Windows Terminal misreports its capabilities under an MSYS shell, so
the previous probe blocked marimo from starting there entirely.
```

Longer body — a new interface; the snippet is the interface itself:

```
Add CellConfig parsing for decorator kwargs

The parser noticed kwargs like `@app.cell(hide_code=True)` but
dropped their values, so round-trip serialization silently lost any
cell configuration.

The new API exposes config on each cell:

    cell.config.hide_code  // bool
    cell.config.disabled   // bool
    cell.config.column     // Option<u32>
```
