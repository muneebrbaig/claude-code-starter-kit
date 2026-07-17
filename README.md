# claude-code-starter-kit

Global Claude Code config (CLAUDE.md, settings.json, skills) — a quick-start for
projects on the same stack (.NET + Angular, multi-tenant SaaS patterns).

No credentials, tokens, or MCP server configs are included. You'll add your own.

## What's in here

- `CLAUDE.md` — universal rules (before/while coding, done=verified) + skill triggers.
- `settings.json` — enabled plugins, marketplaces, effort level. No hooks, no
  statusLine, no model override — those tend to be machine-specific. Note:
  `caveman` is enabled by default, so Claude responds tersely out of the box —
  say "stop caveman" / "normal mode" if you don't want that. It also auto-drops
  out of terse mode on its own for security warnings, irreversible-action
  confirmations, and multi-step sequences where a fragment could be misread —
  writes those parts in full, plain language, then resumes caveman after. This
  is by design, so you don't lose clarity exactly when it matters most.
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
- **[rtk](https://github.com/rtk-ai/rtk)** (not a skill, an optional CLI proxy —
  see "Optional CLIs" below) — cuts token usage on routine dev commands. By
  Patrick Szymkowiak and the [rtk-ai](https://github.com/rtk-ai) team.
- **[caveman](https://github.com/JuliusBrussee/caveman)** (not a skill, a plugin
  enabled in `settings.json`) — ultra-compressed response mode, on by default in
  this kit. By [JuliusBrussee](https://github.com/JuliusBrussee).

## Setup — two ways

**Option A: let Claude do it**
Open Claude Code in this repo and say: *"read SETUP.md and set this up for me."*
It'll ask before overwriting anything you already have.

**Option B: run the script**
```
./install.sh          # macOS/Linux/WSL/git-bash
.\install.ps1          # Windows (PowerShell)
```
Windows note: skills are linked with a directory junction instead of a symlink —
junctions work without admin rights or Developer Mode, unlike `ln -s`/`mklink /D`.

## After setup

- `n2i-dev-cycle` has its own `.env` — copy `.n2i-dev-cycle.env.example` to
  `.n2i-dev-cycle.env` inside `~/projects/skills/n2i-dev-cycle` and fill in your
  own values.
- MCP servers (GitHub, Slack, Linear, etc.) aren't included — add your own via
  `claude mcp` or `/mcp`.

## Optional CLIs: rtk, gh, glab

None are required, but the `pr-summary`/`glab` skills shell out to `gh`/`glab`,
and `rtk` cuts token usage on routine dev commands via a Claude Code hook.

Check first — `gh --version` / `glab --version` / `rtk --version` — and skip the
install if already present. Don't reinstall over an existing one.

| Tool | macOS | Linux | Windows |
|------|-------|-------|---------|
| `gh` | `brew install gh` | [distro-specific](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) | `winget install --id GitHub.cli` |
| `glab` | `brew install glab` | [options](https://gitlab.com/gitlab-org/cli/-/blob/main/docs/installation_options.md) | `winget install glab.glab` |
| `rtk` | `brew install rtk-ai/tap/rtk` | `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh \| sh` | download from [releases](https://github.com/rtk-ai/rtk/releases), put `rtk.exe` on `PATH` |

Windows + rtk: some filters also need `rg` (ripgrep) — `winget install
BurntSushi.ripgrep.MSVC` if missing.

After installing: `gh auth login`, `glab auth login`, and for rtk `rtk init --global`
then uncomment the `@RTK.md` line at the top of `~/.claude/CLAUDE.md`. `gh` needs no
separate skill — Claude Code already knows to use it. The `glab` skill is handled by
`external-skills.json` (see above).
