---
description: Find, understand, and fix a GitHub issue. Investigates the issue, implements a fix, and prepares a commit.
argument-hint: "[issue-number-or-url]"
disable-model-invocation: true
---

# Fix Issue

Find and fix issue #$ARGUMENTS. Follow these steps:

Ultrathink and use the `gh` cli to pull in as much relevant context as necessary.

1. Understand the issue described in the ticket (comments, associated PRs, etc)
2. Locate the relevant code in our codebase
3. Implement a solution that addresses the root cause
4. Come up with a plan for testing and stop to check in with me
5. Add appropriate tests (if confirmed by me)
6. Use `/write-commit` to prepare a concise commit message
