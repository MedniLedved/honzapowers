#!/usr/bin/env bash
# Fixture tests for hooks/session-start. Plain bash; node is used only to
# parse the hook's JSON output. Run: bash tests/test-session-start.sh
set -uo pipefail

. "$(dirname "$0")/lib.sh"
HOOK="$REPO_ROOT/hooks/session-start"
WRAPPER="$REPO_ROOT/hooks/run-hook.cmd"
POLICY_MARKER="standing rules"
MAX_CONTEXT_CHARS=3800
MAX_POLICY_CHARS=3200

# Fill __CWD__ in a fixture with a JSON-escaped native path.
render_fixture() {
  local fixture="$1" dir="$2" p
  p="$(native_path "$dir")"
  p="${p//\\/\\\\}"
  p="${p//&/\\&}"
  p="${p//|/\\|}"
  sed "s|__CWD__|${p}|" "$FIXTURES/$fixture"
}

# run_hook <stdin-file> <process-cwd> [runner...]
# Sets OUT, CODE, MS, CTX (additionalContext) and JSON_OK.
run_hook() {
  local input="$1" pcwd="$2"
  shift 2
  local start end
  start="$(now_ms)"
  OUT="$(cd "$pcwd" && "${@:-bash}" "$HOOK" <"$input" 2>/dev/null)"
  CODE=$?
  end="$(now_ms)"
  MS=$((end - start))
  CTX="$(printf '%s' "$OUT" | node -e '
    let s = "";
    process.stdin.on("data", d => (s += d)).on("end", () => {
      try {
        const o = JSON.parse(s);
        const h = o.hookSpecificOutput;
        if (!h || h.hookEventName !== "SessionStart" || typeof h.additionalContext !== "string") process.exit(2);
        process.stdout.write(h.additionalContext);
      } catch (e) { process.exit(3); }
    });' 2>/dev/null)"
  JSON_OK=$?
}

# Common checks for every case: exit 0, valid JSON, length cap, time limit.
check_basics() {
  local name="$1"
  [ "$CODE" -eq 0 ] && pass "$name: exit 0" || fail "$name: exit $CODE"
  [ "$JSON_OK" -eq 0 ] && pass "$name: valid hook JSON" || fail "$name: invalid hook JSON: ${OUT:0:200}"
  [ "${#CTX}" -le "$MAX_CONTEXT_CHARS" ] && pass "$name: context ${#CTX} <= $MAX_CONTEXT_CHARS chars" \
    || fail "$name: context ${#CTX} > $MAX_CONTEXT_CHARS chars"
  [ "$MS" -lt "$MAX_MS" ] && pass "$name: ${MS} ms < ${MAX_MS} ms" || fail "$name: took ${MS} ms"
}

has() {
  local name="$1" needle="$2"
  if printf '%s' "$CTX" | grep -Fq -- "$needle"; then pass "$name: has '$needle'"; else
    fail "$name: missing '$needle'"; printf '%s\n' "$CTX" | tail -8 | sed 's/^/      /'; fi
}

lacks() {
  local name="$1" needle="$2"
  if printf '%s' "$CTX" | grep -Fq -- "$needle"; then fail "$name: must not contain '$needle'"; else
    pass "$name: lacks '$needle'"; fi
}

# A git repo on branch feature-x with two plans (3 open tasks in the newest)
# and handovers in docs/handover and docs/audit.
make_full_repo() {
  local d="$TEST_ROOT/$1"
  mkdir -p "$d/docs/superpowers/plans" "$d/docs/handover" "$d/docs/audit"
  git init -q "$d" && git -C "$d" symbolic-ref HEAD refs/heads/feature-x
  printf '# old\n- [ ] a\n' >"$d/docs/superpowers/plans/2026-11-01-old.md"
  printf '# new\nSECRET_SENTINEL_PLAN\n- [ ] a\n  - [ ] b\n- [x] c\n- [ ] d\n' \
    >"$d/docs/superpowers/plans/2026-11-09-new.md"
  printf 'SECRET_SENTINEL_HANDOVER\n' >"$d/docs/handover/2026-11-08-topic.md"
  printf 'x\n' >"$d/docs/audit/2026-01-01-audit.md"
  printf '%s' "$d"
}

input_for() { # fixture dir -> path of rendered input file
  local f="$TEST_ROOT/in-$1-$RANDOM.json"
  render_fixture "$1" "$2" >"$f"
  printf '%s' "$f"
}

# --- static checks ---------------------------------------------------------

echo "Static"
policy_chars="$(wc -c <"$REPO_ROOT/policy/policy.md" | tr -d ' ')"
[ "$policy_chars" -le "$MAX_POLICY_CHARS" ] && pass "policy.md $policy_chars <= $MAX_POLICY_CHARS chars" \
  || fail "policy.md $policy_chars > $MAX_POLICY_CHARS chars"
if grep -q $'\r' "$HOOK" "$WRAPPER" 2>/dev/null; then fail "hooks have CRLF line endings"; else pass "hooks use LF"; fi

# --- positive cases --------------------------------------------------------

echo "Startup in a full repo"
R="$(make_full_repo full)"
run_hook "$(input_for startup.json "$R")" "$TEST_ROOT"
check_basics startup
has startup "$POLICY_MARKER"
has startup "Branch: feature-x"
has startup "Plan: docs/superpowers/plans/2026-11-09-new.md (3 open tasks)"
has startup "Handover: docs/handover/2026-11-08-topic.md"
has startup "Next step: continue docs/superpowers/plans/2026-11-09-new.md"
lacks startup "2026-11-01-old.md"
lacks startup "SECRET_SENTINEL"

for c in clear-no-model compact unknown-source; do
  echo "Source $c"
  run_hook "$(input_for "$c.json" "$R")" "$TEST_ROOT"
  check_basics "$c"
  has "$c" "$POLICY_MARKER"
  has "$c" "Branch: feature-x"
done

for c in resume fork; do
  echo "Source $c"
  run_hook "$(input_for "$c.json" "$R")" "$TEST_ROOT"
  check_basics "$c"
  lacks "$c" "$POLICY_MARKER"
  has "$c" "Branch: feature-x"
  has "$c" "(3 open tasks)"
  lacks "$c" "/clear"
done

echo "Resume with expired cache and large context"
run_hook "$(input_for resume-expired.json "$R")" "$TEST_ROOT"
check_basics resume-expired
lacks resume-expired "$POLICY_MARKER"
has resume-expired "~120k context tokens"
has resume-expired "~\$0.45"
has resume-expired "/clear"

echo "Resume threshold override"
run_hook "$(input_for resume-expired.json "$R")" "$TEST_ROOT" env HONZAPOWERS_RESUME_TOKENS=200000 bash
check_basics resume-threshold
lacks resume-threshold "/clear"

echo "Legacy LEAN_WORKFLOW_RESUME_TOKENS still works; HONZAPOWERS_ wins when both are set"
run_hook "$(input_for resume-expired.json "$R")" "$TEST_ROOT" env LEAN_WORKFLOW_RESUME_TOKENS=200000 bash
lacks resume-legacy-only "/clear"
run_hook "$(input_for resume-expired.json "$R")" "$TEST_ROOT" env HONZAPOWERS_RESUME_TOKENS=50000 LEAN_WORKFLOW_RESUME_TOKENS=200000 bash
has resume-both-set "/clear"

echo "Fallbacks: docs/plans, docs/plan.md, docs/audit"
D="$TEST_ROOT/fallback1"
mkdir -p "$D/docs/plans" "$D/docs/audit" && git init -q "$D" && git -C "$D" symbolic-ref HEAD refs/heads/main
printf -- '- [x] done\n' >"$D/docs/plans/2026-10-01-p.md"
printf 'x\n' >"$D/docs/audit/2026-10-02-a.md"
run_hook "$(input_for startup.json "$D")" "$TEST_ROOT"
check_basics fallback1
has fallback1 "Plan: docs/plans/2026-10-01-p.md (0 open tasks)"
has fallback1 "Handover: docs/audit/2026-10-02-a.md"
has fallback1 "Next step: read docs/audit/2026-10-02-a.md"

D="$TEST_ROOT/fallback2"
mkdir -p "$D/docs" && git init -q "$D"
printf -- '- [ ] one\n' >"$D/docs/plan.md"
run_hook "$(input_for startup.json "$D")" "$TEST_ROOT"
check_basics fallback2
has fallback2 "Plan: docs/plan.md (1 open tasks)"
has fallback2 "Handover: none found"

echo "Hook via run-hook.cmd"
run_hook "$(input_for startup.json "$R")" "$TEST_ROOT" bash "$WRAPPER" session-start
# run_hook appends $HOOK after the runner; the wrapper ignores extra args.
check_basics wrapper
has wrapper "Branch: feature-x"

# --- negative cases --------------------------------------------------------

echo "No git, no plan, no handover"
D="$TEST_ROOT/plain"; mkdir -p "$D"
run_hook "$(input_for startup.json "$D")" "$TEST_ROOT"
check_basics no-git
has no-git "$POLICY_MARKER"
has no-git "Branch: not a git repo"
has no-git "Plan: none found"
has no-git "Handover: none found"
lacks no-git "Next step"

echo "Empty stdin (falls back to process cwd)"
: >"$TEST_ROOT/empty.json"
run_hook "$TEST_ROOT/empty.json" "$R"
check_basics empty-stdin
has empty-stdin "$POLICY_MARKER"
has empty-stdin "Branch: feature-x"

echo "Malformed JSON"
run_hook "$(input_for malformed.json "$R")" "$TEST_ROOT"
check_basics malformed
has malformed "$POLICY_MARKER"

echo "Windows path that does not exist"
run_hook "$FIXTURES/windows-path.json" "$TEST_ROOT"
check_basics windows-path
has windows-path "$POLICY_MARKER"
has windows-path "Working directory not accessible"
lacks windows-path "Users"

echo "Untrusted file names are sanitized"
D="$TEST_ROOT/inject"; mkdir -p "$D/docs/superpowers/plans" && git init -q "$D"
# Only characters that are also legal in Windows file names.
git -C "$D" symbolic-ref HEAD 'refs/heads/x;echo$IGNORE'
printf -- '- [ ] t\n' >"$D/docs/superpowers/plans/zz IGNORE 'PREVIOUS'; \$(rm) {b}.md"
long="$(printf 'a%.0s' $(seq 1 150)).md"
mkdir -p "$D/docs/handover" && printf 'x\n' >"$D/docs/handover/$long"
run_hook "$(input_for startup.json "$D")" "$TEST_ROOT"
check_basics inject
has inject "Plan: docs/superpowers/plans/zzIGNOREPREVIOUSrmb.md"
has inject "Branch: xechoIGNORE"
lacks inject "IGNORE '"
lacks inject "{b}"
lacks inject ";echo"
hline="$(printf '%s\n' "$CTX" | grep '^- Handover: ')"
[ -n "$hline" ] && [ "${#hline}" -le 132 ] && pass "inject: long handover path capped (${#hline} chars)" \
  || fail "inject: handover line '${hline:0:60}...' (${#hline} chars)"

# --- plan named in the newest handover wins over the newest plan by name ---

echo "Plan named in handover"
R="$(make_full_repo handover-plan)"
printf '# h\nPlán: docs/superpowers/plans/2026-11-01-old.md (hotovo 2 z 3)\n' >"$R/docs/handover/2026-11-08-topic.md"
run_hook "$(input_for startup.json "$R")" "$TEST_ROOT"
check_basics handover-plan
has handover-plan "Plan: docs/superpowers/plans/2026-11-01-old.md (1 open tasks)"
has handover-plan "Next step: continue docs/superpowers/plans/2026-11-01-old.md"
lacks handover-plan "2026-11-09-new.md"

echo "Handover names a missing or outside path: fall back to newest plan"
R="$(make_full_repo handover-bad)"
printf 'Plán: docs/superpowers/plans/neexistuje.md a ../../etc/plans/x.md\n' >"$R/docs/handover/2026-11-08-topic.md"
run_hook "$(input_for startup.json "$R")" "$TEST_ROOT"
check_basics handover-bad
has handover-bad "Plan: docs/superpowers/plans/2026-11-09-new.md (3 open tasks)"

summary session-start
