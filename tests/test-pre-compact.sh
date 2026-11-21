#!/usr/bin/env bash
# Tests for hooks/pre-compact. Run: bash tests/test-pre-compact.sh
set -uo pipefail

. "$(dirname "$0")/lib.sh"
HOOK="$REPO_ROOT/hooks/pre-compact"
WRAPPER="$REPO_ROOT/hooks/run-hook.cmd"

for runner in direct wrapper; do
  for input in '{"hook_event_name":"PreCompact","trigger":"auto","custom_instructions":null}' '' 'not json'; do
    name="$runner/${input:0:12}"
    start="$(now_ms)"
    if [ "$runner" = direct ]; then OUT="$(printf '%s' "$input" | bash "$HOOK" 2>/dev/null)"
    else OUT="$(printf '%s' "$input" | bash "$WRAPPER" pre-compact 2>/dev/null)"; fi
    CODE=$?
    MS=$(($(now_ms) - start))
    assert_eq "$name exit" 0 "$CODE"
    [ "$MS" -lt "$MAX_MS" ] && pass "$name: ${MS} ms" || fail "$name: took ${MS} ms"
    for needle in "verification command" "approval gate" "re-injected"; do
      printf '%s' "$OUT" | grep -Fq "$needle" && pass "$name: has '$needle'" || fail "$name: missing '$needle'"
    done
    [ "${#OUT}" -le 600 ] && pass "$name: ${#OUT} <= 600 chars" || fail "$name: ${#OUT} chars"
  done
done

summary pre-compact
