#!/usr/bin/env bash
# Runs every tests/test-*.sh; exits 1 if any fails.
set -uo pipefail
cd "$(dirname "$0")" || exit 1
status=0
for t in test-*.sh; do
  echo "== $t"
  bash "$t" || status=1
done
[ "$status" -eq 0 ] && echo "ALL PASS" || echo "SOME FAILED"
exit "$status"
