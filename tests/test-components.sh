#!/usr/bin/env bash
# Static checks for skills, agents, policy rule IDs and the rule ledger.
# Run: bash tests/test-components.sh
set -uo pipefail

. "$(dirname "$0")/lib.sh"

frontmatter() { # <file> <key>; prints the value of a top-level frontmatter key
  awk -v k="$2" 'NR == 1 && $0 != "---" { exit } NR > 1 && $0 == "---" { exit }
    NR > 1 { i = index($0, ":"); if (i && substr($0, 1, i - 1) == k) { v = substr($0, i + 1); sub(/^ +/, "", v); print v; exit } }' "$1"
}

echo "Skills"
for d in "$REPO_ROOT"/skills/*/; do
  name="$(basename "$d")"
  f="$d/SKILL.md"
  [ -f "$f" ] && pass "$name: SKILL.md exists" || { fail "$name: no SKILL.md"; continue; }
  assert_eq "$name: name matches dir" "$name" "$(frontmatter "$f" name)"
  desc="$(frontmatter "$f" description)"
  case "$desc" in "Use when "*) pass "$name: description starts with 'Use when'" ;; *) fail "$name: description '$desc'" ;; esac
  [ "${#desc}" -le 300 ] && pass "$name: description ${#desc} <= 300 chars" || fail "$name: description ${#desc} chars"
  words="$(wc -w <"$f" | tr -d ' ')"
  [ "$words" -le 900 ] && pass "$name: body $words <= 900 words" || fail "$name: body $words words"
  case "$name" in pre-done) continue ;; esac # pre-done reviews a diff, it does not measure a session
  grep -q 'scripts/session-metrics" --session "${CLAUDE_SESSION_ID}"' "$f" && pass "$name: runs session-metrics by session id" \
    || fail "$name: does not run session-metrics by session id"
done
assert_eq "retro model" sonnet "$(frontmatter "$REPO_ROOT/skills/retro/SKILL.md" model)"
grep -q "Never create a project \`CLAUDE.md\`" "$REPO_ROOT/skills/handover/SKILL.md" && pass "handover: CLAUDE.md guardrail" \
  || fail "handover: CLAUDE.md guardrail missing"
grep -q "Never edit" "$REPO_ROOT/skills/retro/SKILL.md" && pass "retro: never edits rules" || fail "retro: no never-edit rule"
grep -q "Never edit\|must not edit" "$REPO_ROOT/skills/pre-done/SKILL.md" && pass "pre-done: reviewer must not edit" || fail "pre-done: no must-not-edit rule"
grep -q "^L13 .*pre-done" "$REPO_ROOT/policy/policy.md" && pass "policy L13 points to pre-done" || fail "policy L13 does not mention pre-done"
# paths the skills reference relative to their own directory
for rel in scripts/session-metrics policy/policy.md docs/learnings.md; do
  [ -f "$REPO_ROOT/skills/retro/../../$rel" ] && pass "skill-relative path $rel exists" || fail "missing $rel"
done

echo "Agents"
f="$REPO_ROOT/agents/log-reader.md"
assert_eq "log-reader name" log-reader "$(frontmatter "$f" name)"
assert_eq "log-reader model" haiku "$(frontmatter "$f" model)"
assert_eq "log-reader tools" "Read, Grep, Glob, Bash" "$(frontmatter "$f" tools)"
grep -q "at most 30 lines" "$f" && pass "log-reader: 30-line cap" || fail "log-reader: no 30-line cap"

echo "Policy rule IDs match the rule ledger"
policy_ids="$(grep -oE '^(L[0-9]+|M[0-9]+|S[0-9]+|F[0-9]+|G[0-9]+) ' "$REPO_ROOT/policy/policy.md" | tr -d ' ' | sort)"
ledger_ids="$(grep -oE '^\| (L[0-9]+|M[0-9]+|S[0-9]+|F[0-9]+|G[0-9]+) \|' "$REPO_ROOT/docs/learnings.md" | tr -d '| ' | sort)"
assert_eq "policy rule count" 23 "$(printf '%s\n' "$policy_ids" | grep -c .)"
[ "$policy_ids" = "$ledger_ids" ] && pass "every policy ID has one ledger row and vice versa" \
  || fail "policy/ledger mismatch: $(diff <(echo "$policy_ids") <(echo "$ledger_ids") | tr '\n' ' ')"
dups="$(printf '%s\n' "$policy_ids" | uniq -d)"
[ -z "$dups" ] && pass "no duplicate rule IDs" || fail "duplicate rule IDs: $dups"

echo "Manifests agree"
p="$(grep -o '"description": "[^"]*"' "$REPO_ROOT/.claude-plugin/plugin.json")"
m="$(grep -o '"description": "[^"]*"' "$REPO_ROOT/.claude-plugin/marketplace.json" | tail -n 1)"
assert_eq "plugin and marketplace description" "$p" "$m"
pv="$(grep -o '"version": "[^"]*"' "$REPO_ROOT/.claude-plugin/plugin.json")"
mv="$(grep -o '"version": "[^"]*"' "$REPO_ROOT/.claude-plugin/marketplace.json")"
assert_eq "plugin and marketplace version" "$pv" "$mv"

summary components
