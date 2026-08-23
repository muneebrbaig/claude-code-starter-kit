#!/usr/bin/env python3
# PreToolUse hook (matcher: Bash). Rewrites noisy commands (installs, builds,
# test runs) to pipe through noisy-filter.sh so the output never reaches
# context in full. Non-noisy commands pass through unmodified.
import json
import re
import shlex
import sys

data = json.load(sys.stdin)
if data.get("tool_name") != "Bash":
    sys.exit(0)

cmd = data.get("tool_input", {}).get("command", "")

NOISY = re.compile(
    r"\b(npm|yarn|pnpm)\s+(install|ci|add|update|run\s+build|run\s+test)\b"
    r"|\bpip3?\s+install\b"
    r"|\bcargo\s+(build|test|install)\b"
    r"|\bgo\s+(build|test|install)\b"
    r"|\bmake\b"
    r"|\bdocker\s+build\b"
    r"|\b(apt|apt-get|brew)\s+install\b"
    r"|\bbundle\s+install\b"
    r"|\bcomposer\s+install\b"
    r"|\b(mvn|gradle)\s+(install|test|build|package)\b"
    r"|\bxcodebuild\b",
    re.IGNORECASE,
)

if not NOISY.search(cmd):
    sys.exit(0)

filter_script = "$HOME/.claude/hooks/noisy-filter.sh"
inner = f"{cmd} 2>&1 | {filter_script}"
wrapped = "bash -o pipefail -c " + shlex.quote(inner)

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "updatedInput": {"command": wrapped},
    }
}))
