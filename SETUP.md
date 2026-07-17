# Setup instructions (for Claude Code, not the human)

You are running inside a clone of `claude-code-starter-kit`. The human asked you to
set it up. Follow these steps. Ask before overwriting anything that already exists —
don't clobber their existing config silently.

## 0. Preflight
- Check `git --version` and `python3 --version` both work. If either is missing,
  stop here, tell the human what's missing and how to install it (e.g. `brew
  install git python3` on macOS), and don't proceed with a partial setup.
- Check `gh --version` and `glab --version`. Neither blocks setup, but note which
  are missing — the `pr-summary` and `glab` skills shell out to them at run time
  (and need their own `gh auth login` / `glab auth login` before they'll work).

## 1. Global CLAUDE.md
- Check if `~/.claude/CLAUDE.md` already exists.
  - If not: copy this repo's `CLAUDE.md` to `~/.claude/CLAUDE.md`.
  - If it exists: show the human a diff between theirs and this repo's, ask whether
    to replace, merge, or skip.

## 2. settings.json
- Check if `~/.claude/settings.json` already exists.
  - If not: copy this repo's `settings.json` to `~/.claude/settings.json`.
  - If it exists: **do not overwrite.** Show the human this repo's `settings.json`
    and ask them to merge the `enabledPlugins`, `extraKnownMarketplaces`, and `env`
    keys into their existing file by hand (or with your help), since their existing
    file likely has hooks/permissions/model overrides specific to their own machine
    that must not be lost.

## 3. Vendored skills (graphify, pr-summary)
- For each of `skills/graphify`, `skills/pr-summary` in this repo:
  - If `~/.claude/skills/<name>` doesn't exist, copy the directory there.
  - If it exists, ask before overwriting.

## 4. External skills (cloned from their own repos)
- Read `external-skills.json` in this repo — a list of `{name, repo, note}`.
- For each entry:
  - Ensure `~/projects/skills/` exists.
  - If `~/projects/skills/<name>` doesn't already exist, `git clone <repo>` into it.
  - Link it (skip if the link/dir already exists):
    - macOS/Linux: `ln -s ~/projects/skills/<name> ~/.claude/skills/<name>`
    - Windows: real symlinks need Developer Mode or an elevated shell — use a
      directory junction instead (works unelevated):
      `mklink /J "%USERPROFILE%\.claude\skills\<name>" "%USERPROFILE%\projects\skills\<name>"`
      or in PowerShell: `New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\<name>" -Target "$env:USERPROFILE\projects\skills\<name>"`
  - Print the entry's `note` to the human — some (like `n2i-dev-cycle`) have their
    own `.env.example` that needs filling in with the human's own values. Do not
    fill in credentials yourself — tell the human to do it.

## 4.5. n2i-dev-cycle config (interactive)
None of these are secrets — just preferences, and every key is optional (the skill
falls back to sane defaults if unset). Read
`~/projects/skills/n2i-dev-cycle/.n2i-dev-cycle.env.example` for the current field
list, then ask the human the questions below and write their answers to
`~/projects/skills/n2i-dev-cycle/.n2i-dev-cycle.env` (gitignored, stays local).
Skip a key entirely if they have no preference — don't invent a value.

- **BRANCH_PREFIX** — what prefix for new feature branches? (e.g. `mb/` →
  `mb/17-add-foo`). Default if skipped: derived from their git `user.name`
  initials, else `dev/`.
- **DEFAULT_SCOPE** — when a repo has both backend and frontend, default scope for
  new work? `backend` / `frontend` / `both` / leave unset (skill asks each time).
- **FORGE** — force `gitlab` or `github`, or leave unset to auto-detect from the
  git remote (recommended default — most repos won't need this set).
- **MIGRATION_DOC** — only relevant if working on a migration-tracked repo; the
  filename of that repo's migration status doc (e.g. `migration-status.md`). If
  the human isn't sure, suggest checking that repo's `docs/` folder once they're
  in it — don't guess a project-specific name here. Leave unset otherwise.

Confirm the written file back to the human before moving on.

## 5. Optional: rtk, gh, glab CLIs
These aren't required to use the kit, but ask the human if they want them — the
`pr-summary`/`glab` skills shell out to `gh`/`glab`, and `rtk` cuts token usage on
routine dev commands via a Claude Code hook. Don't install anything without asking
first; these are system-level installs, not repo files.

**Check before installing.** Run `gh --version` / `glab --version` / `rtk --version`
first (already covered for gh/glab in step 0). If a tool is already present, skip
straight to the "Then:" auth/init line for it — do not reinstall, upgrade, or run
its installer over an existing install. An existing install may be pinned to a
version, managed by a different package manager, or hold config/auth you'd disturb;
reinstalling isn't yours to decide, only the human's.

- **gh** (GitHub CLI):
  - macOS: `brew install gh`
  - Linux: distro-specific, see https://github.com/cli/cli/blob/trunk/docs/install_linux.md
  - Windows: `winget install --id GitHub.cli`
  - Then: `gh auth login`
  - No separate "skill" needed — Claude Code already knows to use `gh` for GitHub work out of the box.
- **glab** (GitLab CLI):
  - macOS/Linux (Homebrew): `brew install glab`
  - Linux (other): see https://gitlab.com/gitlab-org/cli/-/blob/main/docs/installation_options.md
  - Windows: `winget install glab.glab` (or `choco install glab` / `scoop install glab`)
  - Then: `glab auth login`
  - The `glab` skill itself is handled in step 4 (`external-skills.json`).
- **rtk** (Rust Token Killer, optional token-saving proxy):
  - macOS/Linux (Homebrew): `brew install rtk-ai/tap/rtk`
  - macOS/Linux (script): `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh`
  - Windows: download `rtk-x86_64-pc-windows-msvc.zip` from
    https://github.com/rtk-ai/rtk/releases, put `rtk.exe` on `PATH`. Some rtk
    filters also need `rg` (ripgrep) — if missing, `winget install
    BurntSushi.ripgrep.MSVC`.
  - Then: `rtk init --global` (wires the Claude Code hook), verify with `rtk gain`.
  - Once installed, uncomment the `@RTK.md` line at the top of `~/.claude/CLAUDE.md`.

## 6. Wrap up
- Tell the human to restart Claude Code (or start a new session) to pick up the
  new skills/plugins.
- Do not run `git add`/`commit`/`push` anywhere as part of this setup.
