#!/usr/bin/env bash
# Tests for scripts/session-metrics. Run: bash tests/test-session-metrics.sh
# Optional: HONZAPOWERS_REAL_TRANSCRIPT=<path> also checks a real transcript
# (never committed).
set -uo pipefail

. "$(dirname "$0")/lib.sh"
SCRIPT="$REPO_ROOT/scripts/session-metrics"
TR="$FIXTURES/transcripts"
SENTINEL="SECRET_SENTINEL"

# run <args...>; sets OUT, CODE, MS
run() {
  local start
  start="$(now_ms)"
  OUT="$(bash "$SCRIPT" "$@" 2>&1)"
  CODE=$?
  MS=$(($(now_ms) - start))
}

basics() { # <name>
  assert_eq "$1 exit" 0 "$CODE"
  [ "$MS" -lt "$MAX_MS" ] && pass "$1: ${MS} ms" || fail "$1: took ${MS} ms"
  local n
  n="$(printf '%s\n' "$OUT" | wc -l | tr -d ' ')"
  [ "$n" -le 30 ] && pass "$1: $n <= 30 lines" || fail "$1: $n lines"
  case "$OUT" in *"$SENTINEL"* | *"/p/"* | *vm107* | *"npm test"*) fail "$1: leaked transcript content" ;;
    *) pass "$1: no content leak" ;; esac
}

has() { # <name> <exact line>
  if printf '%s\n' "$OUT" | grep -Fxq -- "$2"; then pass "$1: '$2'"; else
    fail "$1: missing line '$2'"; printf '%s\n' "$OUT" | sed 's/^/      /'; fi
}

echo "Known counts (metrics.jsonl)"
run "$TR/metrics.jsonl"
basics metrics
has metrics "Responses: 7 (deduplicated by requestId)"
has metrics "Context tokens: first 10.0k, last 90.0k, max 90.0k, growth +80.0k"
has metrics "Input tokens processed: 380k (cache reads 369k, 97%); output: 650"
has metrics "Context now (hook parser): 90.0k"
has metrics "Tool calls: 13 (Bash 6, Read 3, Edit 3, Write 1)"
has metrics "Identical Bash runs >= 3 in a row (digits ignored): 1 line:3 x3"
has metrics "Edits to one file >= 3 in a row without a Bash run: 1 line:13 x3"
has metrics "Test re-runs with no change since the same run: 1 line:23"
has metrics "Whole-file reads over 300 lines: 1 line:10 (400 lines)"
has metrics "Largest tool results: Read 30.3kB line:10; Read 236B line:12; Bash 118B line:22;"
has metrics "Reply text blocks: 3, 73 chars total, max 35 (line:2)"

echo "Shared parser agrees with the hook library"
for f in valid reordered truncated metrics; do
  run "$TR/$f.jsonl"
  lib="$(bash -c '. "$1/hooks/lib/usage.sh"; last_context_tokens "$2"' _ "$REPO_ROOT" "$TR/$f.jsonl")"
  basics "$f"
  awk_last="$(printf '%s\n' "$OUT" | sed -n 's/^Context tokens: first [^,]*, last \([^,]*\),.*/\1/p')"
  now="$(printf '%s\n' "$OUT" | sed -n 's/^Context now (hook parser): //p')"
  [ -n "$lib" ] && [ "$awk_last" = "$now" ] && pass "$f: awk last $awk_last = hook parser $now" \
    || fail "$f: awk last '$awk_last' vs hook parser '$now' (lib $lib)"
done

echo "No usage records"
run "$TR/no-usage.jsonl"
basics no-usage
has no-usage "Context tokens: no usage records"
has no-usage "Tool calls: 0"

echo "Huge file (~5 MB)"
H="$TEST_ROOT/huge.jsonl"
filler="$(printf '{"type":"user","message":{"content":"%s"}}' "$(head -c 4000 /dev/zero | tr '\0' 'x')")"
for _ in $(seq 1 1250); do printf '%s\n' "$filler"; done >"$H"
cat "$TR/metrics.jsonl" >>"$H"
run "$H"
basics huge
has huge "Tool calls: 13 (Bash 6, Read 3, Edit 3, Write 1)"

echo "Windows-style path argument"
run "$(native_path "$TR/metrics.jsonl")"
basics native-path
has native-path "Responses: 7 (deduplicated by requestId)"

echo "Auto-discovery: project slug first, then newest overall"
CFG="$TEST_ROOT/cfg"
W="$TEST_ROOT/work dir"
mkdir -p "$W"
slug="$(cd "$W" && { pwd -W 2>/dev/null || pwd; })"
slug="${slug//[^A-Za-z0-9]/-}"
mkdir -p "$CFG/projects/$slug" "$CFG/projects/other"
cp "$TR/metrics.jsonl" "$CFG/projects/$slug/a.jsonl"
cp "$TR/valid.jsonl" "$CFG/projects/other/b.jsonl"
touch -t 202601010000 "$CFG/projects/$slug/a.jsonl"
OUT="$(cd "$W" && CLAUDE_CONFIG_DIR="$CFG" bash "$SCRIPT" 2>&1)"; CODE=$?; MS=0
basics auto-slug
has auto-slug "session-metrics: a.jsonl (30 lines, 38.0k bytes)"
OUT="$(cd "$TEST_ROOT" && CLAUDE_CONFIG_DIR="$CFG" bash "$SCRIPT" 2>&1)"; CODE=$?; MS=0
basics auto-newest
has auto-newest "Responses: 2 (deduplicated by requestId)"

echo "--session finds the transcript by id"
OUT="$(cd "$TEST_ROOT" && CLAUDE_CONFIG_DIR="$CFG" bash "$SCRIPT" --session a 2>&1)"; CODE=$?; MS=0
basics session-id
has session-id "session-metrics: a.jsonl (30 lines, 38.0k bytes)"
OUT="$(CLAUDE_CONFIG_DIR="$CFG" bash "$SCRIPT" --session ../other/b 2>&1)"; CODE=$?
[ "$CODE" -ne 0 ] && pass "session-id traversal: exit $CODE" || fail "session-id traversal: exit 0"
OUT="$(CLAUDE_CONFIG_DIR="$CFG" bash "$SCRIPT" --session nope 2>&1)"; CODE=$?
[ "$CODE" -ne 0 ] && pass "session-id unknown: exit $CODE" || fail "session-id unknown: exit 0"
has session-id-unknown "session-metrics: no transcript for that session id"

echo "Missing transcript fails with a message"
OUT="$(bash "$SCRIPT" "$TEST_ROOT/none.jsonl" 2>&1)"; CODE=$?
[ "$CODE" -ne 0 ] && pass "missing: exit $CODE" || fail "missing: exit 0"
has missing "session-metrics: no transcript found at the given path"
OUT="$(cd "$TEST_ROOT" && CLAUDE_CONFIG_DIR="$TEST_ROOT/emptycfg" bash "$SCRIPT" 2>&1)"; CODE=$?
[ "$CODE" -ne 0 ] && pass "none: exit $CODE" || fail "none: exit 0"

REAL_TRANSCRIPT="${HONZAPOWERS_REAL_TRANSCRIPT:-${LEAN_WORKFLOW_REAL_TRANSCRIPT:-}}"
if [ -n "$REAL_TRANSCRIPT" ]; then
  echo "Real transcript"
  run "$REAL_TRANSCRIPT"
  assert_eq "real exit" 0 "$CODE"
  n="$(printf '%s\n' "$OUT" | wc -l | tr -d ' ')"
  [ "$n" -le 30 ] && pass "real: $n <= 30 lines" || fail "real: $n lines"
  printf '%s\n' "$OUT" | grep -q '^Responses: [1-9]' && pass "real: has responses" || fail "real: no responses"
fi

summary session-metrics
