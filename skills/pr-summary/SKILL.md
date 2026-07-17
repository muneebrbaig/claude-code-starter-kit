---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *), Bash(glab *), Bash(git *)
---

## Pull request context
- PR diff: !`git remote -v 2>/dev/null | grep -q github && gh pr diff 2>/dev/null || git remote -v 2>/dev/null | grep -q gitlab && glab mr diff 2>/dev/null || git diff HEAD~1 2>/dev/null || echo "No PR/MR context"`
- PR comments: !`git remote -v 2>/dev/null | grep -q github && gh pr view --comments 2>/dev/null || git remote -v 2>/dev/null | grep -q gitlab && glab mr view --comments 2>/dev/null || echo "No comments available"`
- Changed files: !`git remote -v 2>/dev/null | grep -q github && gh pr diff --name-only 2>/dev/null || git remote -v 2>/dev/null | grep -q gitlab && glab mr diff --name-only 2>/dev/null || git diff HEAD~1 --name-only 2>/dev/null || echo "No changed files context"`

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