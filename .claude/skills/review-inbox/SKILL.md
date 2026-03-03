---
description: Fetch and summarize PRs where your review is requested
argument-hint: "[owner/repo] [timeframe: 24h|3d|1w]"
disable-model-invocation: true
---

# Review Inbox

Show PRs awaiting my review and help me triage them.

## Parse Arguments

Parse `$ARGUMENTS` for two optional positional args:
- **repo** — `owner/repo` format. If omitted, detect from `git remote get-url origin` in the current working directory.
- **timeframe** — like `24h`, `3d`, `1w`. If omitted, read the timestamp from `~/.claude/state/review-inbox-last-checked.txt`. If that file doesn't exist, default to `24h`.

## Steps

1. **Determine the time filter**
   - If a timeframe arg was given → convert to a date (e.g., `3d` = 3 days ago)
   - Otherwise read `~/.claude/state/review-inbox-last-checked.txt` and use that timestamp
   - If neither exists → default to 24h ago
   - Compute the cutoff as an ISO 8601 date string

2. **Fetch PRs awaiting review**
   ```bash
   gh pr list --repo <repo> --search "review-requested:@me" --state open --json number,title,author,createdAt,updatedAt,url,body,labels,additions,deletions,files
   ```
   Filter results to only include PRs updated on or after the cutoff date.
   - If no PRs found → report "No PRs awaiting your review since <date>." and stop.
   - Save the current UTC timestamp (ISO 8601) to `~/.claude/state/review-inbox-last-checked.txt`.

3. **Get file-level details** (for each PR)
   ```bash
   gh pr view <number> --repo <repo> --json files,additions,deletions,title,author
   ```
   Collect metadata and file lists — no full diffs yet (keep it fast).

4. **Present the inbox** as a numbered list. For each PR, write a 3-5 sentence summary that covers: what area of the codebase it touches, what it's trying to accomplish, and a quick read on size/complexity. Even if the PR description is sparse, infer intent from the file list and title.

   Example:

   ```
   1. **Fix cell execution order when cells have transitive dependencies** (#4821)
      https://github.com/marimo-team/marimo/pull/4821
      @akshayka · +127/-43 · 8 files
      Touches the DAG execution engine and the runtime's cell scheduler. Fixes a bug
      where cells with transitive dependencies (A→B→C) could run out of order during
      batch execution. Adds a topological sort pass before scheduling and updates
      existing tests. Moderate size — the core change is in two files, the rest are
      test updates.

   2. **Add CSV export to data explorer** (#4819)
      https://github.com/marimo-team/marimo/pull/4819
      @mscolnick · +312/-18 · 5 files
      Adds a "Download CSV" button to the data explorer panel. New frontend component
      plus a backend endpoint that streams the current dataframe as CSV. Includes a
      new E2E test. Relatively self-contained — mostly new code, not many existing
      code paths affected.
   ```

   Then print: **"Pick a number to dive deeper, or say done."**
   **STOP and wait for my response.**

5. **Dive deeper** (when I pick a number)
   - Fetch full diff: `gh pr diff <number> --repo <repo>`
   - Fetch context: `gh pr view <number> --repo <repo> --json body,commits,comments`
   - Present:
     - **What changed** — clear summary organized by area/concern
     - **Why** — motivation from PR body, commits, or inferred from code
     - **Review focus areas** — complex logic, edge cases, API changes, test gaps
     - **Questions to consider** — specific things worth asking the author
   - **STOP and check in with me.**
