# claude-code-starter-kit

My global Claude Code setup: `CLAUDE.md`, `settings.json`, a hook and a few skills.
It works with any language or framework. Nothing in here is tied to one stack.

No credentials, tokens or MCP server configs are in here. Add your own.

## What's in here

- `CLAUDE.md`: universal coding rules plus skill triggers.
- `settings.json`: enabled plugins, marketplaces, effort level and one
  `PreToolUse` hook (see Hooks). No statusLine and no model override, since
  those depend on the machine.
- `hooks/`: the noisy-output filter.
- `skills/graphify`, `skills/pr-summary`: vendored copies.
- `external-skills.json`: skills the installer clones from their own repos
  (`n2i-dev-cycle`, `stop-slop`, `glab`, `token-audit`).
- `tests/`: tests for the hook (`python3 -m unittest discover -s tests`).

`caveman` is enabled by default, so Claude answers tersely out of the box. Say
"stop caveman" or "normal mode" to turn it off. It drops out of terse mode on
its own for security warnings, irreversible-action confirmations and
multi-step sequences where a fragment could be misread, then goes back.

## Hooks

`hooks/` installs to `~/.claude/hooks/`. It holds one `PreToolUse` hook on
`Bash`, wired up in `settings.json`. When a command looks noisy (`npm install`,
`pip install`, `cargo build`, `make`, `docker build`, `mvn`/`gradle`,
`xcodebuild` and similar), the hook pipes its output through a filter. The
filter keeps lines containing error, fail, warn and a few related words, plus
the last 20 lines, and drops the rest. Other commands run untouched. The
command has to start a shell command to match, so `git commit -m "make it
work"` is left alone.

If you already have a `PreToolUse`/`Bash` hook (rtk, for example), this one
sits next to it. Both run.

The hook needs Python 3 (as `python3` or `python`), `bash` and `awk` on `PATH`. On Windows that means
Git Bash and a real Python install, not the Microsoft Store stub.

## Skills and credits

Only `n2i-dev-cycle`, `token-audit` and `pr-summary` are mine. The rest belong
to their authors, so star their repos if you use them.

- **[graphify](https://github.com/safishamsi/graphify)** turns a folder of
  code or docs into a browsable knowledge graph. It wraps the `graphifyy` PyPI
  package, by [Graphify-Labs](https://github.com/Graphify-Labs).
- **[stop-slop](https://github.com/hardikpandya/stop-slop)** strips AI writing
  habits out of prose. By [Hardik Pandya](https://hvpandya.com).
- **[glab](https://github.com/henricook/claude-glab-skill)** covers the GitLab
  CLI for issues, MRs and pipelines. By [henricook](https://github.com/henricook).
- **pr-summary** summarizes a PR or MR diff for a reviewer. No upstream; it's
  vendored here.
- **[n2i-dev-cycle](https://github.com/muneebrbaig/n2i-dev-cycle)** is the
  ticket-to-shipped-code workflow I use every day.
- **[token-audit](https://github.com/muneebrbaig/token-audit-skill)** audits
  memory files, MCP tools, model and effort settings, hooks, subagents,
  scheduled jobs and cache usage for token waste. It only reports; it changes
  nothing.

Plugins enabled in `settings.json`:

- **[caveman](https://github.com/JuliusBrussee/caveman)** by
  [JuliusBrussee](https://github.com/JuliusBrussee): terse response mode.
- **[claude-mem](https://github.com/thedotmack/claude-mem)** by
  [thedotmack](https://github.com/thedotmack): persistent memory across sessions.
- **[impeccable](https://github.com/pbakaus/impeccable)** by
  [pbakaus](https://github.com/pbakaus): frontend design guidance.
- **[understand-anything](https://github.com/Egonex-AI/Understand-Anything)**
  by Egonex-AI: codebase comprehension.
- `commit-commands`, `feature-dev` and `gitlab` come from the official
  Claude Code plugin marketplace.

**[rtk](https://github.com/rtk-ai/rtk)** is an optional CLI proxy, not a skill
(see Optional CLIs). It cuts token use on routine dev commands. By Patrick
Szymkowiak and the [rtk-ai](https://github.com/rtk-ai) team.

## Setup

**Option A: let Claude do it.** Open Claude Code in this repo and say "read
SETUP.md and set this up for me." It asks before overwriting anything.

**Option B: run the script.**
```
./install.sh          # macOS, Linux, WSL, or Git Bash on Windows
```
On Windows, run it from Git Bash, which Claude Code needs anyway. Skills are
linked with a directory junction, which needs no admin rights or Developer
Mode. Symlinks do.

**Existing files are safe.** The installer never overwrites or removes anything
without asking. For `CLAUDE.md`, `settings.json` and each hook, it skips
identical files, asks y/N for changed ones, and saves a `.bak.<timestamp>` copy
before it overwrites. Skills, clones and links that already exist are left
alone, and nothing gets pulled or updated.

**Careful with settings.json:** saying yes replaces the whole file. It doesn't
merge, so your own hooks, permissions and model overrides won't carry over.
Option A offers to merge by hand instead. The `.bak` copy lets you copy them back.

## After setup

- `n2i-dev-cycle` reads its own `.env`. Copy `.n2i-dev-cycle.env.example` to
  `.n2i-dev-cycle.env` inside `~/projects/skills/n2i-dev-cycle` and fill in
  your values.
- MCP servers (GitHub, Slack, Linear and so on) aren't included. Add yours with
  `claude mcp` or `/mcp`.

## Optional CLIs: rtk, gh, glab

You don't need any of these. `pr-summary` and `glab` call `gh` and `glab`, and
`rtk` trims token use on routine dev commands through a Claude Code hook.

Run `gh --version`, `glab --version` and `rtk --version` first. If one is
already installed, leave it alone.

| Tool | macOS | Linux | Windows |
|------|-------|-------|---------|
| `gh` | `brew install gh` | [distro-specific](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) | `winget install --id GitHub.cli` |
| `glab` | `brew install glab` | [options](https://gitlab.com/gitlab-org/cli/-/blob/main/docs/installation_options.md) | `winget install glab.glab` |
| `rtk` | `brew install rtk-ai/tap/rtk` | `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh \| sh` | download from [releases](https://github.com/rtk-ai/rtk/releases), put `rtk.exe` on `PATH` |

On Windows, some rtk filters also need `rg` (ripgrep): `winget install
BurntSushi.ripgrep.MSVC`.

Afterwards, run `gh auth login` and `glab auth login`. For rtk, run `rtk init
--global`, then uncomment the `@RTK.md` line at the top of
`~/.claude/CLAUDE.md`. `gh` needs no skill because Claude Code already knows
it. The `glab` skill comes from `external-skills.json`.
