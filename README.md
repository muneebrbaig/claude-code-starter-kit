# claude-code-starter-kit

Global Claude Code config (CLAUDE.md, settings.json, skills) — a quick-start for
projects on the same stack (.NET + Angular, multi-tenant SaaS patterns).

No credentials, tokens, or MCP server configs are included. You'll add your own.

## What's in here

- `CLAUDE.md` — universal rules (before/while coding, done=verified) + skill triggers.
- `settings.json` — enabled plugins, marketplaces, effort level. No hooks, no
  statusLine, no model override — those tend to be machine-specific.
- `skills/graphify`, `skills/pr-summary` — vendored copies (no upstream repo to
  point at).
- `external-skills.json` — skills installed by cloning their own repo:
  `n2i-dev-cycle`, `stop-slop`, `glab`.

## Setup — two ways

**Option A: let Claude do it**
Open Claude Code in this repo and say: *"read SETUP.md and set this up for me."*
It'll ask before overwriting anything you already have.

**Option B: run the script**
```
./install.sh
```

## After setup

- `n2i-dev-cycle` has its own `.env` — copy `.n2i-dev-cycle.env.example` to
  `.n2i-dev-cycle.env` inside `~/projects/skills/n2i-dev-cycle` and fill in your
  own values.
- MCP servers (GitHub, Slack, Linear, etc.) aren't included — add your own via
  `claude mcp` or `/mcp`.
- Optional: rtk (Rust Token Killer) — a CLI proxy that cuts token usage on
  routine dev commands. Not included here; ask whoever gave you this kit for it,
  then uncomment the `@RTK.md` line at the top of your `~/.claude/CLAUDE.md`.
