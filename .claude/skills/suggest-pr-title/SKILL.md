---
description: Inspect a PR and propose a clear, concise title. Avoids conventional commit prefixes.
argument-hint: "[pr-number]"
disable-model-invocation: true
---

# Suggest PR Title

Find PR `#$ARGUMENTS`. Follow these steps:

- **Inspect the PR thoroughly** — Read the title, description, and full diff. Understand the purpose and scope of the changes.
- **Propose a better title** — Suggest a clear, concise title that summarizes what the PR actually *does* (not how). Avoid jargon or fluff.
- **Do not use conventional commit format** — No prefixes like `feat:`, `fix:`, or `chore:`. Write plain-language titles.
- **Use backticks for technical terms** — If the title references code elements (e.g., `AuthSession`, `config_loader.py`), wrap them in backticks.

Read `examples.md` in this skill's directory for examples of good PR titles.
