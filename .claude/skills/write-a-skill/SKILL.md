---
name: write-a-skill
description: >
  Create, write, or build new agent skills with proper SKILL.md structure,
  YAML frontmatter, progressive disclosure, decision trees, guard rails,
  and bundled resources. Use when user wants to create, design, scaffold,
  or improve a skill. Do NOT use when user wants to install an existing
  skill or manage skill configuration.
---

# Writing Skills

## Process

1. **Gather requirements** — ask user about:
   - What task/domain does the skill cover?
   - What specific use cases should it handle?
   - Does it need executable scripts or just instructions?
   - Any reference materials to include?

2. **Draft the skill** — create:
   - SKILL.md with concise instructions (<500 lines)
   - Additional reference files if content exceeds that
   - Utility scripts if deterministic operations needed

3. **Review with user** — present draft and iterate

## Skill Directory Structure

```
skill-name/
├── SKILL.md           # Main instructions (required, <500 lines)
├── reference/         # Detailed docs loaded on demand
├── examples/          # Templates and sample outputs
├── scripts/           # Utility scripts (deterministic ops)
│   └── helper.js
└── templates/         # Starting-point files for output
```

### Resource Types

| Type | Purpose | When to use |
|------|---------|-------------|
| `reference/` | Detailed API docs, schemas | Content too large for SKILL.md |
| `examples/` | Sample inputs/outputs | Agent needs concrete models to follow |
| `scripts/` | Executable tools | Deterministic ops (validation, formatting) |
| `templates/` | Starter files | Consistent output structure needed |

## Progressive Disclosure (3 Layers)

Skills load in layers to manage context window budget:

| Layer | What | Size | When loaded |
|-------|------|------|-------------|
| **1. Metadata** | `name` + `description` | ~100 tokens | Always (all skills) |
| **2. Instructions** | SKILL.md body | <5000 tokens | On activation |
| **3. Resources** | reference/, scripts/, examples/ | Unbounded | On demand |

IMPORTANT: Layer 1 is loaded for ALL installed skills simultaneously. Keep descriptions concise but keyword-dense. Layer 2 is the skill's working instructions. Layer 3 is loaded only when the agent needs it — use this for detailed docs, large code samples, and reference material.

## SKILL.md Template

```md
---
name: skill-name
description: >
  [What it does — keyword-dense]. Use when [specific triggers,
  file types, user phrases]. Do NOT use when [negative boundaries].
---

# Skill Name

## Overview

[1-2 sentence summary of what this skill does and its philosophy]

## Decision Tree

[Route between sub-tasks — use tables, if/then, or flowcharts]

| User wants... | Action |
|---------------|--------|
| Simple case   | Do X directly |
| Complex case  | Follow workflow in ## Workflows |
| Edge case     | See [REFERENCE.md](reference/REFERENCE.md) |

## Quick Start

[Minimal working example — copy-pasteable code or steps]

## Workflows

[Step-by-step processes with checklists]

## Guard Rails

CRITICAL: [Known failure mode to prevent]
NEVER: [Anti-pattern that causes bad output]

## Advanced

See [REFERENCE.md](reference/REFERENCE.md) for detailed docs.
```

Not every section is needed — include only what the skill requires. Simple skills may only need Quick Start + Workflows.

## Description Requirements

The description is **the only thing your agent sees** when deciding which skill to load. It's surfaced in the system prompt alongside all other installed skills.

**Format**:
- Max 1024 chars
- Write in third person
- Keyword-dense — include file types, action verbs, domain terms
- First part: what it does
- Include: "Use when [specific triggers]"
- Include: "Do NOT use when [negative boundaries]"

**Good examples**:

```
Extract text and tables from PDF files, fill forms, merge documents.
Use when working with PDF files or when user mentions PDFs, forms,
or document extraction. Do NOT use when user wants to create PDFs
from scratch (use a template skill instead).
```

```
Read, write, and transform Excel (.xlsx/.xls) files using Python.
Use when user needs spreadsheet operations, data import/export,
or cell-level manipulation. Do NOT trigger for CSV files (use
standard Python csv module) or Google Sheets (use Sheets API).
```

**Bad examples**:

```
Helps with documents.
```
Too vague — agent can't distinguish from other document skills.

```
A comprehensive tool for all spreadsheet needs including reading,
writing, formatting, charting, pivot tables, and macros.
```
Feature list without trigger/boundary signals — agent doesn't know *when* to use it.

## Key Patterns from Production Skills

### 1. Decision Trees for Routing

When a skill covers multiple sub-tasks, add explicit routing so the agent picks the right path. Use tables, if/then blocks, or flowcharts.

### 2. Guard Rails via CRITICAL/NEVER/IMPORTANT

Use emphatic callouts to prevent known failure modes. These stand out in the instruction text and the agent treats them with high priority.

```md
CRITICAL: Always validate input before processing. Never trust raw user input.
NEVER: Do not use deprecated API v1 endpoints — they silently drop fields.
IMPORTANT: Run the formatter script AFTER making changes, not before.
```

### 3. Examples AND Anti-patterns

Show both what to do and what NOT to do. Anti-patterns are especially valuable when failure modes are subtle.

```md
## Good
- Use `async/await` with proper error boundaries
- Return structured errors with codes

## Bad — NEVER do this
- Don't use bare `try/catch` that swallows errors
- Don't return string error messages
```

### 4. Creative Skills Define Process

For skills that produce creative output (design, writing, art), define a multi-step **process**, not just the desired end state:

1. Philosophy/intent — what aesthetic or goal?
2. Exploration — generate options
3. Implementation — build the chosen direction
4. Refinement — polish and iterate

### 5. Black-Box Script Pattern

When a skill bundles scripts, instruct the agent to run `--help` first, NOT read the source code. This saves context window and prevents the agent from second-guessing the script.

```md
## Scripts

Run `python scripts/validate.py --help` for usage.
Do NOT read the script source — treat it as a black box.
```

## When to Add Scripts

Add utility scripts when:
- Operation is deterministic (validation, formatting, conversion)
- Same code would be generated repeatedly
- Errors need explicit handling with clear messages

Scripts save tokens and improve reliability vs. generated code.

## When to Split Into Files

Split content out of SKILL.md when:
- SKILL.md exceeds 500 lines
- Content has distinct domains (finance vs. sales schemas)
- Advanced features are rarely needed
- Large code samples or API references are involved

## Review Checklist

After drafting, verify:

- [ ] Description includes positive triggers ("Use when...")
- [ ] Description includes negative boundaries ("Do NOT use when...")
- [ ] SKILL.md body under 500 lines
- [ ] Progressive disclosure: metadata → instructions → resources
- [ ] Guard rails for known failure modes (CRITICAL/NEVER)
- [ ] Decision tree if skill has multiple sub-tasks
- [ ] No time-sensitive info that will go stale
- [ ] Consistent terminology throughout
- [ ] Concrete examples included (not just abstract guidance)
- [ ] Anti-patterns shown for subtle failure modes
- [ ] Scripts use black-box pattern (--help, not read source)
- [ ] References at most one level deep
