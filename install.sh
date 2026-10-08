#!/usr/bin/env bash
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_SRC_DIR="$HOME/projects/skills"

echo "== preflight =="
missing=()
command -v git >/dev/null 2>&1 || missing+=("git")
# Try python3, then python. Each must run and be Python 3, which rules out the
# Windows Store stub and an old Python 2 `python`.
PYTHON=""
for candidate in python3 python; do
  if "$candidate" -c 'import sys; sys.exit(sys.version_info < (3,))' >/dev/null 2>&1; then
    PYTHON="$candidate"
    break
  fi
done
[ -n "$PYTHON" ] || missing+=("python3")
if [ "${#missing[@]}" -gt 0 ]; then
  echo "Missing required tool(s): ${missing[*]}"
  echo "Install them, then re-run. On macOS: brew install ${missing[*]}"
  exit 1
fi
echo "git and $PYTHON found."

optional_missing=()
command -v gh >/dev/null 2>&1 || optional_missing+=("gh")
command -v glab >/dev/null 2>&1 || optional_missing+=("glab")
if [ "${#optional_missing[@]}" -gt 0 ]; then
  echo "Note: ${optional_missing[*]} not found. The install doesn't need it, but"
  echo "pr-summary/glab do, along with its own 'auth login'."
fi

mkdir -p "$CLAUDE_DIR/skills" "$SKILLS_SRC_DIR"

# On Windows, symlinks need Developer Mode or elevation. A directory junction
# doesn't. This only matters when the script runs under git-bash/MSYS.
link_skill() {
  local src="$1" dst="$2"
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      # '//c', not '/c': MSYS would rewrite '/c' into a drive path.
      cmd.exe //c mklink /J "$(cygpath -w "$dst")" "$(cygpath -w "$src")" >/dev/null
      ;;
    *)
      ln -s "$src" "$dst"
      ;;
  esac
}

# True for anything at the path, including a broken symlink.
exists() { [ -e "$1" ] || [ -L "$1" ]; }

# Copies src to dst. Returns 0 only if it wrote the file. An existing file is
# left alone unless the answer is y, and then it's backed up first.
copy_with_confirm() {
  local src="$1" dst="$2" ans
  if exists "$dst"; then
    if [ ! -e "$dst" ]; then
      echo "$dst is a broken symlink, skipping."
      return 1
    fi
    if cmp -s "$src" "$dst"; then
      echo "$dst is already up to date."
      return 1
    fi
    read -r -p "$dst already exists. Overwrite? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "Skipped $dst"; return 1; }
    cp -p "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backed up the old file to $dst.bak.*"
  fi
  cp "$src" "$dst"
  echo "Wrote $dst"
}

echo "== CLAUDE.md =="
copy_with_confirm "$KIT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" || true

echo "== settings.json =="
if exists "$CLAUDE_DIR/settings.json"; then
  echo "NOTE: this replaces the whole file. It doesn't merge. If your"
  echo "$CLAUDE_DIR/settings.json has its own hooks, permissions or model overrides,"
  echo "merge by hand instead (see SETUP.md step 2). A backup is made if you say y."
fi
copy_with_confirm "$KIT_DIR/settings.json" "$CLAUDE_DIR/settings.json" || true

echo "== hooks =="
mkdir -p "$CLAUDE_DIR/hooks"
for hook in "$KIT_DIR/hooks/"*.sh; do
  dst="$CLAUDE_DIR/hooks/$(basename "$hook")"
  if copy_with_confirm "$hook" "$dst"; then
    chmod +x "$dst"
  fi
done

echo "== vendored skills (graphify, pr-summary) =="
for skill in graphify pr-summary; do
  dst="$CLAUDE_DIR/skills/$skill"
  if exists "$dst"; then
    echo "$dst already exists, skipping."
  else
    cp -r "$KIT_DIR/skills/$skill" "$dst"
    echo "Installed $skill"
  fi
done

echo "== external skills (cloned from their own repos) =="
while IFS=$'\t' read -r name repo note; do
  src_dir="$SKILLS_SRC_DIR/$name"
  link_dst="$CLAUDE_DIR/skills/$name"
  if exists "$src_dir"; then
    echo "$src_dir already exists, skipping clone."
  else
    git clone "$repo" "$src_dir"
  fi
  if exists "$link_dst"; then
    echo "$link_dst already exists, leaving it alone."
  else
    link_skill "$src_dir" "$link_dst"
    echo "Linked $name"
  fi
  echo "Note: $note"
done < <("$PYTHON" - "$KIT_DIR/external-skills.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
for s in data:
    print(f"{s['name']}\t{s['repo']}\t{s['note']}")
PY
)

echo "Done. Restart Claude Code to load the new skills and settings."
echo "Optional: rtk, gh and glab. Install commands are in SETUP.md step 5 and the README."
