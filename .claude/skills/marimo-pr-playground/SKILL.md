---
name: marimo-pr-playground
description: >-
  Check out a GitHub PR and spin up an interactive marimo notebook that
  summarizes the change and lets you exercise the new feature or fix live.
  Use this skill whenever the user wants to explore, test-drive, or review
  a PR interactively — e.g. "checkout PR 1234 and let me play with it",
  "set up a playground for this PR", "I want to try out PR #567",
  "explore this PR in a notebook", or even just "review PR 42" when the
  intent is hands-on exploration rather than a code-level review.
  Also trigger when the user pastes a GitHub PR URL and wants to test the
  changes, or says things like "let me try that feature" in the context of
  a PR discussion.
user-invocable: true
---

# marimo-pr-playground: Interactive PR Exploration

Check out a PR, start a marimo dev session, and build a live notebook
that lets the reviewer experience the change hands-on.

## Workflow

### 1. Check out the PR

```bash
gh pr checkout <number-or-url>
```

If the user gave a URL, extract the PR number. If they gave a branch name,
use that directly.

### 2. Understand the PR

```bash
gh pr view <number> --json title,body,author,labels,files
gh pr diff <number>
gh pr view <number> --json commits --jq '.commits[].messageHeadline'
```

Read the diff closely. Understand what changed, why, and what the
reviewer would want to try.

### 3. Launch the dev session

Start marimo with a new empty notebook — don't write a file to disk
beforehand, marimo creates it automatically.

Use the `/marimo-dev` skill to spin up the full environment. Start it
with a fresh notebook:

```bash
uv run marimo edit _pr_playground.py --headless --no-token --no-skew-protection
```

Follow the rest of the `/marimo-dev` setup (Vite, browser).

### 4. Build the notebook with marimo-pair

Use the `/marimo-pair` skill's code mode API to create cells in the
live session. Cells execute as you create them so you can iterate.

Start with a short summary cell (`mo.md()`) that orients the reviewer —
PR title, what it does, key files. Then build out cells that let the
reviewer see and interact with the change. Look closely at the PR and
think about how to best present the fix or feature in the marimo
interface so that it's reviewable and live-testable.

### 5. Hand off

Tell the user what you've set up and let them drive. They can keep
using marimo-pair to extend the notebook.

## Cleanup

`_pr_playground.py` is disposable. Remind the user to switch back to
their original branch when done.
