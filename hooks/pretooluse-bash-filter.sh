#!/usr/bin/env python3
# PreToolUse hook (matcher: Bash). Rewrites noisy commands (installs, builds,
# test runs) so their output goes through noisy-filter.sh and only a trimmed
# version reaches context. Everything else passes through untouched.
import json
import re
import shlex
import sys

data = json.load(sys.stdin)
if data.get("tool_name") != "Bash":
    sys.exit(0)

cmd = data.get("tool_input", {}).get("command", "")

# The command has to start a shell command (line start, or after ; & | or an
# opening paren), so "git commit -m 'make it work'" or "grep make" don't match.
NOISY = re.compile(
    r"(?:^|[;&|(]\s*)(?:sudo\s+)?(?:"
    r"(?:npm|yarn|pnpm)\s+(?:install|ci|add|update|run\s+build|run\s+test)\b"
    r"|pip3?\s+install\b"
    r"|cargo\s+(?:build|test|install)\b"
    r"|go\s+(?:build|test|install)\b"
    r"|make\b"
    r"|docker\s+build\b"
    r"|(?:apt|apt-get|brew)\s+install\b"
    r"|bundle\s+install\b"
    r"|composer\s+install\b"
    r"|(?:mvn|gradle)\s+(?:install|test|build|package)\b"
    r"|xcodebuild\b"
    r")",
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
