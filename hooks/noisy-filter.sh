#!/usr/bin/env bash
# Streams a command's stdout/stderr: prints error/fail/warn lines immediately,
# then a trailing summary of the last N lines plus a count of what was dropped.
set -euo pipefail

awk -v n=20 '
{
  total++
  buf[((total - 1) % n) + 1] = $0
  if (tolower($0) ~ /error|fail|fatal|panic|denied|exception|traceback/) {
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
