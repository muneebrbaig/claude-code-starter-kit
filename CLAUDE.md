# Optional: rtk (Rust Token Killer) — token-optimized CLI proxy
# Install separately (see README "Optional: rtk"), then uncomment:
# @RTK.md

# Skills
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) — any input to knowledge graph. Trigger: `/graphify`. When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
- **stop-slop** (`~/.claude/skills/stop-slop/SKILL.md`) — remove AI writing patterns from prose. Auto-invoke: apply stop-slop rules (no need to call skill tool) when writing commit messages, PR/MR descriptions, code comments, documentation, or any user-facing prose. Explicit trigger: `/stop-slop` for reviewing/rewriting existing text.

## Skill Installation Workflow
When installing a skill that requires a local clone (GitHub or other hosted repo):
1. Clone into `~/projects/skills/<skill-name>`
2. Symlink: `ln -s ~/projects/skills/<skill-name> ~/.claude/skills/<skill-name>`
All skill source stays centralized in the skills folder; symlinks make them available to Claude Code.

# Universal Rules (all projects)
- DO NOT COMMIT. User commits manually. Never run `git add/commit/push` unless explicitly asked.
- DO NOT generate Markdown documentation files unless explicitly instructed.
- ALWAYS write unit tests for new code or changes.
- Follow existing conventions and style exactly. Match surrounding code even if you'd do it differently.
- No trailing summaries. User reads the diff.

# Before Coding
- Don't assume, don't hide confusion. State assumptions explicitly; if uncertain, ask.
- Multiple valid interpretations → list them, recommend one, don't pick silently.
- Simpler approach exists → say so. Push back when warranted.
- Non-trivial task (3+ steps or an architectural decision) → plan first, then implement.
- If something goes sideways mid-task, STOP and re-plan. Don't keep pushing blindly.

# While Coding
- Simplicity first: minimum code that solves the problem. Nothing speculative — no unrequested features, abstractions, configurability, or error handling for impossible cases. If 200 lines could be 50, rewrite it.
- Surgical changes: touch only what the request requires. Don't refactor, "improve," or reformat adjacent code. Every changed line traces to the request.
- Clean up only your own orphans (imports/vars your change made unused). Mention pre-existing dead code; don't delete it.

# Done = Verified
- Never call a task done without proving it. Run tests, build, and lint.
- "Add validation" → write tests for invalid input, then make them pass.
- "Fix the bug" → write a failing test that reproduces it, then make it pass.
