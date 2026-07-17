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
  - Symlink: `ln -s ~/projects/skills/<name> ~/.claude/skills/<name>` (skip if the
    symlink/dir already exists).
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

## 5. Optional: rtk (Rust Token Killer)
- Don't install this automatically. It's a separate CLI tool the original author
  uses. If the human wants it, tell them to check with the person who gave them
  this kit for install instructions, then uncomment the `@RTK.md` line at the top
  of their `~/.claude/CLAUDE.md`.

## 6. Wrap up
- Tell the human to restart Claude Code (or start a new session) to pick up the
  new skills/plugins.
- Do not run `git add`/`commit`/`push` anywhere as part of this setup.
