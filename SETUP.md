# Setup instructions (for Claude Code, not the human)

You're in a clone of `claude-code-starter-kit`, and the human asked you to set it
up. Follow the steps below. Ask before overwriting anything that already exists.

## 0. Preflight
- Check that `git --version` works, and that `python3 --version` or `python --version`
  reports Python 3. If either is missing, stop. Tell the human what's missing and how to install it (on macOS:
  `brew install git python3`). Don't do a partial setup.
- Check `gh --version` and `glab --version`. Neither blocks setup, but note which
  are missing. The `pr-summary` and `glab` skills call them and need
  `gh auth login` / `glab auth login` first.

## 1. Global CLAUDE.md
- If `~/.claude/CLAUDE.md` doesn't exist, copy this repo's `CLAUDE.md` there.
- If it exists, show the human a diff and ask whether to replace, merge or skip.

## 2. settings.json
- If `~/.claude/settings.json` doesn't exist, copy this repo's `settings.json` there.
- If it exists, **don't overwrite it.** Show the human this repo's `settings.json`
  and ask them to merge `enabledPlugins`, `extraKnownMarketplaces`, `env` and
  `hooks` into their file, by hand or with your help. Their file probably holds
  hooks, permissions or model overrides for their own machine, and those have
  to survive. For `hooks`, add this repo's entries as extra items under the
  matching event and matcher (`PreToolUse` → `Bash`). Don't replace an entry
  that's already there, since it may do something else.

## 3. Hooks
- `settings.json` points at `~/.claude/hooks/pretooluse-bash-filter.sh`. Copy
  both files from `hooks/` into `~/.claude/hooks/`, creating the folder if
  needed. On macOS/Linux, run `chmod +x` on them.
- If a file with the same name is already there, ask before overwriting.
- The hook needs Python 3 (as `python3` or `python`), `bash` and `awk` on `PATH`. On Windows that means
  Git Bash and a real Python install.

## 3.5. Vendored skills (graphify, pr-summary)
- For each of `skills/graphify` and `skills/pr-summary`:
  - If `~/.claude/skills/<name>` doesn't exist, copy the directory there.
  - If it exists, ask before overwriting.

## 4. External skills (cloned from their own repos)
- Read `external-skills.json` in this repo. It's a list of `{name, repo, note}`.
- For each entry:
  - Make sure `~/projects/skills/` exists.
  - If `~/projects/skills/<name>` doesn't exist, `git clone <repo>` into it.
  - Link it, unless the link or directory already exists:
    - macOS/Linux: `ln -s ~/projects/skills/<name> ~/.claude/skills/<name>`
    - Windows (Git Bash): symlinks need Developer Mode or an elevated shell, so
      use a directory junction instead:
      `cmd //c mklink /J "$(cygpath -w ~/.claude/skills/<name>)" "$(cygpath -w ~/projects/skills/<name>)"`
  - Print the entry's `note` to the human. Some skills (like `n2i-dev-cycle`) ship
    a `.env.example` the human has to fill in. Don't fill in credentials yourself.

## 4.5. n2i-dev-cycle config (interactive)
These are preferences, not secrets, and every key is optional. The skill falls
back to defaults for anything unset. Read
`~/projects/skills/n2i-dev-cycle/.n2i-dev-cycle.env.example` for the current
fields, ask the human the questions below, and write the answers to
`~/projects/skills/n2i-dev-cycle/.n2i-dev-cycle.env` (gitignored, stays local).
If they have no preference for a key, leave it out. Don't invent a value.

- **BRANCH_PREFIX**: prefix for new feature branches, e.g. `mb/` gives
  `mb/17-add-foo`. If skipped, it uses the initials from git `user.name`, else
  `dev/`.
- **DEFAULT_SCOPE**: where new work goes by default when a repo has both
  backend and frontend. `backend`, `frontend`, `both`, or unset (the skill asks
  each time).
- **FORGE**: `gitlab` or `github`. Leave it unset to detect from the git
  remote, which works for most repos.
- **MIGRATION_DOC**: only for a migration-tracked repo. The filename of its
  migration status doc, e.g. `migration-status.md`. If the human isn't sure,
  tell them to check that repo's `docs/` folder later. Don't guess a name.
  Otherwise leave it unset.

Show the human the file you wrote before moving on.

## 5. Optional: rtk, gh, glab CLIs
The kit works without these. Ask the human whether they want them. `pr-summary`
and `glab` call `gh` and `glab`, and `rtk` cuts token use on routine dev commands
through a Claude Code hook. These are system-level installs, so don't install
anything without asking.

**Check first.** Run `gh --version`, `glab --version` and `rtk --version` (step 0
already covered gh and glab). If a tool is installed, skip to its "Then:" line.
Don't reinstall, upgrade or run an installer over it. It may be pinned to a
version, managed by another package manager, or hold config and auth you'd
disturb. Only the human decides that.

- **gh** (GitHub CLI):
  - macOS: `brew install gh`
  - Linux: distro-specific, see https://github.com/cli/cli/blob/trunk/docs/install_linux.md
  - Windows: `winget install --id GitHub.cli`
  - Then: `gh auth login`
  - No skill needed. Claude Code already knows `gh`.
- **glab** (GitLab CLI):
  - macOS/Linux (Homebrew): `brew install glab`
  - Linux (other): see https://gitlab.com/gitlab-org/cli/-/blob/main/docs/installation_options.md
  - Windows: `winget install glab.glab` (or `choco install glab` / `scoop install glab`)
  - Then: `glab auth login`
  - The `glab` skill comes from step 4 (`external-skills.json`).
- **rtk** (Rust Token Killer, an optional token-saving proxy):
  - macOS/Linux (Homebrew): `brew install rtk-ai/tap/rtk`
  - macOS/Linux (script): `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh`
  - Windows: download `rtk-x86_64-pc-windows-msvc.zip` from
    https://github.com/rtk-ai/rtk/releases and put `rtk.exe` on `PATH`. Some rtk
    filters also need `rg` (ripgrep): `winget install BurntSushi.ripgrep.MSVC`.
  - Then: `rtk init --global` (adds the Claude Code hook). Check it with `rtk gain`.
  - Once it's installed, uncomment the `@RTK.md` line at the top of `~/.claude/CLAUDE.md`.

## 6. Wrap up
- Tell the human to restart Claude Code, or start a new session, so it picks up
  the new skills and plugins.
- Don't run `git add`, `commit` or `push` as part of this setup.
