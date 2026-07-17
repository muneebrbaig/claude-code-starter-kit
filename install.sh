#!/usr/bin/env bash
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_SRC_DIR="$HOME/projects/skills"

echo "== preflight =="
missing=()
command -v git >/dev/null 2>&1 || missing+=("git")
command -v python3 >/dev/null 2>&1 || missing+=("python3")
if [ "${#missing[@]}" -gt 0 ]; then
  echo "Missing required tool(s): ${missing[*]}"
  echo "Install them first, then re-run this script. On macOS: brew install ${missing[*]}"
  exit 1
fi
echo "git, python3 found."

optional_missing=()
command -v gh >/dev/null 2>&1 || optional_missing+=("gh")
command -v glab >/dev/null 2>&1 || optional_missing+=("glab")
if [ "${#optional_missing[@]}" -gt 0 ]; then
  echo "Note: ${optional_missing[*]} not found. Not required for this install, but"
  echo "the pr-summary/glab skills need it (and its own 'auth login') once you use them."
fi

mkdir -p "$CLAUDE_DIR/skills" "$SKILLS_SRC_DIR"

copy_with_confirm() {
  local src="$1" dst="$2"
  if [ -e "$dst" ]; then
    read -r -p "$dst already exists. Overwrite? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "Skipped $dst"; return; }
  fi
  cp "$src" "$dst"
  echo "Wrote $dst"
}

echo "== CLAUDE.md =="
copy_with_confirm "$KIT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

echo "== settings.json =="
copy_with_confirm "$KIT_DIR/settings.json" "$CLAUDE_DIR/settings.json"

echo "== vendored skills (graphify, pr-summary) =="
for skill in graphify pr-summary; do
  dst="$CLAUDE_DIR/skills/$skill"
  if [ -e "$dst" ]; then
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
  if [ -e "$src_dir" ]; then
    echo "$src_dir already exists, skipping clone."
  else
    git clone "$repo" "$src_dir"
  fi
  if [ ! -e "$link_dst" ]; then
    ln -s "$src_dir" "$link_dst"
    echo "Symlinked $name"
  fi
  echo "Note: $note"
done < <(python3 - "$KIT_DIR/external-skills.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
for s in data:
    print(f"{s['name']}\t{s['repo']}\t{s['note']}")
PY
)

echo "Done. Restart Claude Code to pick up the new skills/settings."
echo "Optional: rtk (Rust Token Killer) — see README for adding it back to CLAUDE.md."
