---
name: enrich-jupyter-to-marimo
description: Add migration reference guides to the jupyter-to-marimo skill when a Jupyter feature has known conversion gotchas.
---

# Enriching the jupyter-to-marimo skill

Use this when a Jupyter feature has known conversion gotchas worth codifying (e.g., LaTeX, ipywidgets, magics, plotting libraries). The skill lives at `skills/jupyter-to-marimo/` in the marimo-team/skills repo.

## Process

### 1. Trigger

The human identifies the pain point: "ipywidgets don't map cleanly to marimo" or "LaTeX breaks when converting." One sentence is enough. The agent takes it from here.

### 2. Exhaustive parallel research (agent-only)

Launch parallel subagents:

- **Agent A — Jupyter/source side**: Catalog every variant, option, and usage pattern of feature X from official docs.
- **Agent B — marimo/target side**: Catalog every relevant `mo.ui.*` element, layout helper, or API from marimo's official docs and examples.

The agent now knows more about both sides than the human does. This is the agent's superpower — hold two complete API surfaces in context simultaneously.

### 3. Surface decision points (human in the loop)

This is the critical step. The agent does NOT present a draft or a full mapping table. The agent presents **only the 3-5 focused decisions where human taste matters**:

- **Ambiguous mappings**: "For `Stack`, I see `mo.ui.tabs` and `mo.carousel`. Which captures the intent better?"
- **Teaching examples**: "For bidirectional sync, should the example show two widgets with the same value, or a derived relationship like `x` and `x+1`?"
- **Paradigm framing**: "Should this section be framed as 'replacing observe callbacks' or 'lifting state up'?"
- **Experiential caveats**: "Does this pattern work with anywidgets, or is there a caveat I should note?"
- **Cell structure**: "Should the state, widgets, and display each be in their own cell?"

Each is a 10-second decision for the human. The mechanical mappings (`IntSlider` → `mo.ui.slider`) are not questions — the agent just handles those.

**How the agent identifies what to surface**: During research, flag anything where:
- Two valid marimo approaches exist for the same Jupyter feature
- The conversion is a paradigm shift, not a 1:1 swap (the teaching example matters)
- Something works differently than docs suggest (the agent may not always catch these, but should flag paradigm boundaries where caveats are likely)

### 4. Draft the reference (agent-only)

Create `references/<topic>.md` incorporating the human's decisions:

- One-line framing of the key paradigm shift
- Mapping table — exhaustive, every variant mapped or marked as no-equivalent
- Pattern sections — idiomatic marimo examples reflecting the human's choices
- Migration checklist

Keep it concise. This is a reference, not a tutorial.

### 5. Fact-check with parallel subagents (agent-only)

Launch subagents to verify the draft:

- **Source completeness**: Every item in the official X docs appears in the mapping table
- **Target accuracy**: Every marimo API claim (parameters, function names, behaviors) is correct
- **Pattern correctness**: Recommended patterns match marimo's documented best practices

Fix any issues found.

### 6. Lightweight review (human)

Present the finished, fact-checked artifact. The human scans it — but the heavy decisions were already made in Step 3, so this is a quick pass for anything that feels off, not a line-by-line review.

### 7. Update SKILL.md (agent-only)

Add a reference in the "Review and clean up" section:
```
- If the notebook uses X, see `references/<topic>.md` for ...
```

## Principles

- **Separate mechanical work from taste work.** The mapping table is mechanical — the agent handles it. The teaching examples and paradigm framing are taste — the human decides. Don't mix them.
- **Focused questions, not draft reviews.** A 200-line draft buries taste decisions in correct-but-obvious content. Surface the 3-5 real decisions as direct questions.
- **Agent-first for correctness, human-first for framing.** Subagents verify API claims more reliably than humans. Humans know which example will make a Jupyter user actually understand the paradigm shift.
- **Progressive disclosure.** Each reference only loads when relevant. One topic per file.
- **Pain-point driven.** Start from what users actually stumble on, not from an abstract taxonomy.
