---
description: Triage a GitHub issue and draft a response for review. Never posts directly to GitHub.
argument-hint: "[issue-number-or-url]"
disable-model-invocation: true
---

# Triage Issue

Triage and draft a response for GitHub issue #$ARGUMENTS.

**IMPORTANT: NEVER post responses directly to GitHub. Always write to a file for review first.**

## Steps

1. **Fetch full issue context**
   - `gh issue view <number> --json title,body,author,labels,assignees,milestone,state,comments,reactionGroups,createdAt,updatedAt`
   - `gh issue view <number> --json timelineItems` — cross-references, linked PRs, mentioned commits
   - Classify: bug, feature request, question, or discussion

2. **Find related issues and PRs**
   - Search for related issues using keywords from the title/body: `gh search issues "<keywords>" --repo <repo> --limit 10`
   - Check for duplicate or similar past issues (open and closed)
   - Look at linked/referenced PRs: `gh pr list --search "<keywords>" --state all --limit 10`
   - Summarize findings: duplicates, prior art, related discussions

3. **Analyze issue timeline and cross-references**
   - Use `gh api repos/{owner}/{repo}/issues/{number}/timeline` to get full timeline
   - Identify: who else has been involved, any commits that reference this issue, any PRs that reference it
   - Check if any referenced PRs were merged, closed, or are still open

4. **Deep-dive into the codebase**
   - If bug: trace the relevant code paths, look at recent commits in the affected area (`git log --oneline -20 -- <relevant-paths>`), check for related test coverage
   - If feature request: search for existing functionality that might address it, check docs/examples
   - If stack trace or error message provided: search codebase for the error string, trace the call chain
   - Look at any files/functions mentioned in the issue or comments

5. **Compile context summary**
   - Write a structured context summary to `responses/context-<issue-number>.md` containing:
     - Issue classification (bug/feature/question)
     - Related issues and PRs (with links)
     - Relevant code paths identified
     - Key findings from timeline analysis
     - Potential workarounds or existing functionality
   - **STOP and check in with me** before drafting a response

6. **Draft a response**
   - Only after I've reviewed the context summary
   - Keep concise and directed
   - Reference findings from the deep dive
   - Save to `responses/response-<issue-number>.md`
   - **STOP and check in with me**
   - **NEVER post to GitHub unless explicitly directed**

## Response Guidelines

- Be brief - users appreciate concise responses
- Understand motivation first before diving into solutions
- Point to existing features/docs when applicable
- For enhancement requests: acknowledge, discuss trade-offs, brainstorm options
- For bugs: confirm repro, ask for details if needed
- Avoid over-engineering responses - start a conversation, don't write a spec
