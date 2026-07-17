# claude-code-starter-kit

Global Claude Code config (CLAUDE.md, settings.json, skills) — a quick-start for
projects on the same stack (.NET + Angular, multi-tenant SaaS patterns).

No credentials, tokens, or MCP server configs are included. You'll add your own.

## What's in here

- `CLAUDE.md` — universal rules (before/while coding, done=verified) + skill triggers.
- `settings.json` — enabled plugins, marketplaces, effort level. No hooks, no
  statusLine, no model override — those tend to be machine-specific.
- `skills/graphify`, `skills/pr-summary` — vendored copies.
- `external-skills.json` — skills installed by cloning their own repo:
  `n2i-dev-cycle`, `stop-slop`, `glab`.

## Skills, and who to thank for them

None of these are ours except `n2i-dev-cycle`. Full credit to their authors —
go star their repos if you find them useful.

- **[graphify](https://github.com/safishamsi/graphify)** — turns a folder of
  code/docs/whatever into a browsable knowledge graph. Wraps the `graphifyy`
  PyPI package. By [Graphify-Labs](https://github.com/Graphify-Labs).
- **[stop-slop](https://github.com/hardikpandya/stop-slop)** — strips AI writing
  tics out of prose before it ships. By [Hardik Pandya](https://hvpandya.com).
- **[glab](https://github.com/henricook/claude-glab-skill)** — GitLab CLI
  guidance for issues/MRs/pipelines. By [henricook](https://github.com/henricook).
- **pr-summary** — small in-house helper for summarizing a PR/MR diff for a
  reviewer. No separate upstream; vendored as-is.
- **[n2i-dev-cycle](https://github.com/muneebrbaig/n2i-dev-cycle)** — the
  ticket-to-shipped-code workflow this kit's author uses day to day. Ours, and
  the one you'll actually lean on for the projects we work on together.

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
