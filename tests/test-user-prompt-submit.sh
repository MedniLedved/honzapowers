#!/usr/bin/env bash
# Fixture tests for hooks/user-prompt-submit. Run: bash tests/test-user-prompt-submit.sh
set -uo pipefail

. "$(dirname "$0")/lib.sh"
HOOK="$REPO_ROOT/hooks/user-prompt-submit"
WRAPPER="$REPO_ROOT/hooks/run-hook.cmd"
TR="$FIXTURES/transcripts"
SENTINEL="SECRET_SENTINEL"
export CLAUDE_PLUGIN_DATA="$TEST_ROOT/data"
# The fixtures sit at ~120k; the default (150k) is tested in its own section.
export HONZAPOWERS_HANDOVER_TOKENS=100000

# make_input <session-id> <transcript-path>; prints the path of the stdin file
make_input() {
  local f="$TEST_ROOT/in-$RANDOM$RANDOM.json"
  printf '{"session_id":"%s","transcript_path":"%s","cwd":"/x","hook_event_name":"UserPromptSubmit","prompt":"hi %s"}' \
    "$1" "$(json_escape_path "$(native_path "$2")")" "$SENTINEL" >"$f"
  printf '%s' "$f"
}

# run_hook <stdin-file> [runner...]; sets OUT, CODE, MS, CTX, JSON_OK
# (JSON_OK: 0 valid note, 1 empty output, other = invalid)
run_hook() {
  local input="$1" start end
  shift
  start="$(now_ms)"
  OUT="$("${@:-bash}" "$HOOK" <"$input" 2>/dev/null)"
  CODE=$?
  end="$(now_ms)"
  MS=$((end - start))
  if [ -z "$OUT" ]; then JSON_OK=1; CTX=""; return; fi
  CTX="$(printf '%s' "$OUT" | node -e '
    let s = "";
    process.stdin.on("data", d => (s += d)).on("end", () => {
      try {
        const h = JSON.parse(s).hookSpecificOutput;
        if (!h || h.hookEventName !== "UserPromptSubmit" || typeof h.additionalContext !== "string") process.exit(2);
        process.stdout.write(h.additionalContext);
      } catch (e) { process.exit(3); }
    });' 2>/dev/null)"
  JSON_OK=$?
}

basics() {
  local name="$1"
  [ "$CODE" -eq 0 ] && pass "$name: exit 0" || fail "$name: exit $CODE"
  [ "$MS" -lt "$MAX_MS" ] && pass "$name: ${MS} ms" || fail "$name: took ${MS} ms"
  case "$OUT$CTX" in *"$SENTINEL"*) fail "$name: leaked transcript or prompt content" ;; *) pass "$name: no content leak" ;; esac
}

noted() { # <name> <needle>
  basics "$1"
  if [ "$JSON_OK" -eq 0 ] && printf '%s' "$CTX" | grep -Fq -- "$2"; then pass "$1: note has '$2'"
  else fail "$1: expected a note with '$2' (json=$JSON_OK): ${OUT:0:200}"; fi
  [ "${#CTX}" -le 300 ] && pass "$1: note ${#CTX} <= 300 chars" || fail "$1: note ${#CTX} chars"
}

silent() { # <name>
  basics "$1"
  [ "$JSON_OK" -eq 1 ] && pass "$1: silent" || fail "$1: expected no output, got: ${OUT:0:200}"
}

echo "Valid transcript crosses the (test) 100k threshold: one note, then silent"
IN="$(make_input s-valid "$TR/valid.jsonl")"
run_hook "$IN"; noted valid-first "~120k tokens"
run_hook "$IN"; silent valid-repeat

echo "Next bucket notes again; a drop and a re-crossing note again"
T="$TEST_ROOT/grow.jsonl"
cp "$TR/valid.jsonl" "$T"
IN="$(make_input s-grow "$T")"
run_hook "$IN"; noted grow-120k "~120k"
printf '{"type":"assistant","requestId":"r","message":{"usage":{"input_tokens":1,"cache_creation_input_tokens":0,"cache_read_input_tokens":155000}}}\n' >>"$T"
run_hook "$IN"; noted grow-155k "~155k"
run_hook "$IN"; silent grow-155k-repeat
printf '{"type":"assistant","requestId":"r","message":{"usage":{"input_tokens":1,"cache_creation_input_tokens":0,"cache_read_input_tokens":30000}}}\n' >>"$T"
run_hook "$IN"; silent grow-after-compact
printf '{"type":"assistant","requestId":"r","message":{"usage":{"input_tokens":1,"cache_creation_input_tokens":0,"cache_read_input_tokens":110000}}}\n' >>"$T"
run_hook "$IN"; noted grow-recross "~110k"

echo "Separate state per session"
run_hook "$(make_input s-other "$TR/valid.jsonl")"; noted other-session "~120k"

echo "Below the threshold and env overrides"
run_hook "$(make_input s-env1 "$TR/valid.jsonl")" env HONZAPOWERS_HANDOVER_TOKENS=200000 bash
silent env-threshold-200k
run_hook "$(make_input s-env2 "$TR/reordered.jsonl")" env HONZAPOWERS_HANDOVER_TOKENS=50000 HONZAPOWERS_HANDOVER_STEP=10000 bash
noted env-threshold-50k "~101k"
D="$TEST_ROOT/default.jsonl"
cp "$TR/valid.jsonl" "$D"
printf '{"type":"assistant","requestId":"r","message":{"usage":{"input_tokens":1,"cache_creation_input_tokens":0,"cache_read_input_tokens":255000}}}\n' >>"$D"
run_hook "$(make_input s-env3 "$D")" env HONZAPOWERS_HANDOVER_TOKENS=abc HONZAPOWERS_HANDOVER_STEP=0 bash
noted env-invalid-defaults "250k handover threshold"
run_hook "$(make_input s-leg1 "$TR/valid.jsonl")" env -u HONZAPOWERS_HANDOVER_TOKENS LEAN_WORKFLOW_HANDOVER_TOKENS=200000 bash
silent legacy-only-threshold-applies
run_hook "$(make_input s-leg2 "$TR/reordered.jsonl")" env HONZAPOWERS_HANDOVER_TOKENS=50000 LEAN_WORKFLOW_HANDOVER_TOKENS=200000 HONZAPOWERS_HANDOVER_STEP=10000 bash
noted both-set-honzapowers-wins "~101k"

echo "Default threshold is 250k, then every +50k"
run_hook "$(make_input s-def1 "$TR/valid.jsonl")" env -u HONZAPOWERS_HANDOVER_TOKENS bash
silent default-120k
DI="$(make_input s-def2 "$D")"
run_hook "$DI" env -u HONZAPOWERS_HANDOVER_TOKENS bash; noted default-255k-first "~255k"
run_hook "$DI" env -u HONZAPOWERS_HANDOVER_TOKENS bash; silent default-255k-repeat
printf '{"type":"assistant","requestId":"r","message":{"usage":{"input_tokens":1,"cache_creation_input_tokens":0,"cache_read_input_tokens":305000}}}\n' >>"$D"
run_hook "$DI" env -u HONZAPOWERS_HANDOVER_TOKENS bash; noted default-305k "~305k"

echo "Reordered usage keys"
run_hook "$(make_input s-reord "$TR/reordered.jsonl")"; noted reordered "~101k"

echo "Truncated last line uses the last complete record"
run_hook "$(make_input s-trunc "$TR/truncated.jsonl")"; noted truncated "~120k"

echo "No usage record: falls back to file size (small file stays silent)"
run_hook "$(make_input s-nousage "$TR/no-usage.jsonl")"; silent no-usage-small
run_hook "$(make_input s-nousage2 "$TR/no-usage.jsonl")" env HONZAPOWERS_HANDOVER_TOKENS=10 HONZAPOWERS_HANDOVER_STEP=1000 bash
noted no-usage-fallback "estimated from the transcript size"

echo "No usage record: the whole-file scan is remembered, not repeated on every prompt"
NS="$TEST_ROOT/nousage-big.jsonl"
cp "$TR/no-usage.jsonl" "$NS"
printf '{"type":"user","message":{"content":"%s"}}\n' "$(head -c 3000 /dev/zero | tr '\0' 'z')" >>"$NS"
run_hook "$(make_input s-noscan "$NS")" env HONZAPOWERS_HANDOVER_TOKENS=10 HONZAPOWERS_HANDOVER_STEP=1000000 USAGE_TAIL_BYTES=100 bash
noted noscan-first-estimate "estimated from the transcript size"
[ -f "$CLAUDE_PLUGIN_DATA/nousage-s-noscan" ] && pass "noscan: marker written after the full scan" || fail "noscan: no marker"
NS2="$TEST_ROOT/nousage-skip.jsonl"
cp "$TR/valid.jsonl" "$NS2"
printf '{"type":"user","message":{"content":"%s"}}\n' "$(head -c 3000 /dev/zero | tr '\0' 'z')" >>"$NS2"
run_hook "$(make_input s-noscan2 "$NS2")" env USAGE_TAIL_BYTES=100 bash
noted noscan-without-marker-finds-usage "from the transcript usage record"
mkdir -p "$CLAUDE_PLUGIN_DATA"; wc -c <"$NS2" | tr -d ' ' >"$CLAUDE_PLUGIN_DATA/nousage-s-noscan3"
run_hook "$(make_input s-noscan3 "$NS2")" env HONZAPOWERS_HANDOVER_TOKENS=10 HONZAPOWERS_HANDOVER_STEP=1000000 USAGE_TAIL_BYTES=100 bash
noted noscan-with-marker-skips-scan "estimated from the transcript size"

echo "Huge file (~5 MB) with the usage record near the end"
H="$TEST_ROOT/huge.jsonl"
filler="$(printf '{"type":"user","message":{"content":"%s"}}' "$(head -c 4000 /dev/zero | tr '\0' 'x')")"
for _ in $(seq 1 1250); do printf '%s\n' "$filler"; done >"$H"
tail -n 3 "$TR/valid.jsonl" >>"$H"
run_hook "$(make_input s-huge "$H")"; noted huge "~120k tokens (from"

echo "Huge last line beyond the tail window: usage read from the whole file, no estimate"
H2="$TEST_ROOT/huge2.jsonl"
cp "$TR/valid.jsonl" "$H2"
printf '{"type":"user","message":{"content":"%s"}}\n' "$(head -c 2500000 /dev/zero | tr '\0' 'y')" >>"$H2"
run_hook "$(make_input s-huge2 "$H2")"; noted huge-whole-file "~120k tokens (from"

echo "Missing transcript, malformed and empty stdin, no session id"
run_hook "$(make_input s-missing "$TEST_ROOT/nope.jsonl")"; silent missing-file
printf '{"session_id":"s-bad","transcript_path":' >"$TEST_ROOT/bad.json"
run_hook "$TEST_ROOT/bad.json"; silent malformed
: >"$TEST_ROOT/empty.json"
run_hook "$TEST_ROOT/empty.json"; silent empty-stdin
printf '{"transcript_path":"%s"}' "$(json_escape_path "$(native_path "$TR/valid.jsonl")")" >"$TEST_ROOT/nosid.json"
run_hook "$TEST_ROOT/nosid.json"; noted no-session-id "~120k"
run_hook "$TEST_ROOT/nosid.json"; silent no-session-id-repeat

echo "Hostile session id cannot escape the state dir"
run_hook "$(make_input '../../evil' "$TR/valid.jsonl")"; noted hostile-id "~120k"
if [ -e "$TEST_ROOT/evil" ] || [ -e "$TEST_ROOT/upsubmit-evil" ]; then fail "hostile-id: wrote outside state dir"
else pass "hostile-id: state stays in the state dir"; fi

echo "Unwritable state dir: still exits 0"
run_hook "$(make_input s-ro "$TR/valid.jsonl")" env CLAUDE_PLUGIN_DATA=/dev/null/x bash
basics unwritable-state

echo "No CLAUDE_PLUGIN_DATA: private per-user state dir under TMPDIR"
TD="$TEST_ROOT/tmpdir"; mkdir -p "$TD"
run_hook "$(make_input s-tmp "$TR/valid.jsonl")" env -u CLAUDE_PLUGIN_DATA TMPDIR="$TD" bash
noted tmp-fallback "~120k"
SD="$TD/honzapowers-$(id -u)"
[ -f "$SD/upsubmit-s-tmp" ] && pass "tmp-fallback: state in honzapowers-<uid>" || fail "tmp-fallback: no state in $SD"
case "$(uname -s)" in
  MINGW* | MSYS* | CYGWIN*) pass "tmp-fallback: mode check skipped on Windows" ;;
  *) m="$(stat -c %a "$SD" 2>/dev/null || stat -f %Lp "$SD" 2>/dev/null)"
     [ "$m" = 700 ] && pass "tmp-fallback: dir mode 700" || fail "tmp-fallback: dir mode $m" ;;
esac

echo "Through run-hook.cmd"
run_hook "$(make_input s-wrap "$TR/valid.jsonl")" bash "$WRAPPER" user-prompt-submit
noted wrapper "~120k"

summary user-prompt-submit
