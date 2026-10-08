---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *), Bash(glab *), Bash(git *)
---

## Pull request context
- PR diff: !`if git remote -v 2>/dev/null | grep -q github; then gh pr diff 2>/dev/null || git diff HEAD~1 2>/dev/null || echo "No PR/MR context"; elif git remote -v 2>/dev/null | grep -q gitlab; then glab mr diff 2>/dev/null || git diff HEAD~1 2>/dev/null || echo "No PR/MR context"; else git diff HEAD~1 2>/dev/null || echo "No PR/MR context"; fi`
- PR comments: !`if git remote -v 2>/dev/null | grep -q github; then gh pr view --comments 2>/dev/null || echo "No comments available"; elif git remote -v 2>/dev/null | grep -q gitlab; then glab mr view --comments 2>/dev/null || echo "No comments available"; else echo "No comments available"; fi`
- Changed files: !`if git remote -v 2>/dev/null | grep -q github; then gh pr diff --name-only 2>/dev/null || git diff HEAD~1 --name-only 2>/dev/null || echo "No changed files context"; elif git remote -v 2>/dev/null | grep -q gitlab; then glab mr diff --name-only 2>/dev/null || git diff HEAD~1 --name-only 2>/dev/null || echo "No changed files context"; else git diff HEAD~1 --name-only 2>/dev/null || echo "No changed files context"; fi`

## Your task

Summarize this pull request for a code reviewer. Output:

### Summary
2-4 bullet points. What changed and why. No implementation details.

### Breaking Changes
List any breaking changes. If none, omit section.

### Changed Files
Group changed files by concern (e.g. "Auth", "Tests", "Config"). One line per group.

### Review Notes
Flag anything risky, incomplete, or needing extra scrutiny.