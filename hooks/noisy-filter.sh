#!/usr/bin/env bash
# Reads a command's output on stdin. Prints error/fail/warn lines as they
# arrive, then the last N lines and a count of how many earlier lines were dropped.
set -euo pipefail

awk -v n=20 '
{
  total++
  buf[((total - 1) % n) + 1] = $0
  if (tolower($0) ~ /error|fail|fatal|panic|denied|exception|traceback|warn/) {
    print
  }
}
END {
  if (total == 0) { exit }
  kept = (total < n) ? total : n
  start = total - kept + 1
  dropped = total - kept
  print "--- last " kept " lines (" dropped " earlier lines filtered) ---"
  for (i = start; i <= total; i++) print buf[((i - 1) % n) + 1]
}
'
