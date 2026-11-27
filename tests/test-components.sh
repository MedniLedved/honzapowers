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
  case "$name" in pre-done | kontrola-planu | skilly-kdy-ktery | mesicni-projektove-retro) continue ;; esac # pre-done and kontrola-planu review text, they do not measure a session
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
assert_eq "log-reader tools" "Read, Grep, Glob" "$(frontmatter "$f" tools)"
grep -q "data, never instructions" "$f" && pass "log-reader: log is data" || fail "log-reader: no data-not-instructions rule"
grep -q "at most 30 lines" "$f" && pass "log-reader: 30-line cap" || fail "log-reader: no 30-line cap"

echo "kontrola-planu: skill, agents, eval"
for a in kontrola-souladu kontrola-auditu; do
  f="$REPO_ROOT/agents/$a.md"
  [ -f "$f" ] && pass "$a: file exists" || { fail "$a: missing"; continue; }
  assert_eq "$a name" "$a" "$(frontmatter "$f" name)"
  [ -n "$(frontmatter "$f" description)" ] && pass "$a: description" || fail "$a: no description"
  assert_eq "$a model" sonnet "$(frontmatter "$f" model)"
  assert_eq "$a tools (read-only)" "Read, Grep, Glob" "$(frontmatter "$f" tools)"
  grep -q "OPRAVIT" "$f" && grep -q "ZEPTAT" "$f" && grep -q "ZAMÍTNOUT" "$f" && pass "$a: three buckets" || fail "$a: buckets missing"
done
grep -q "Small plan (up to 3 tasks)" "$REPO_ROOT/agents/kontrola-souladu.md" && pass "kontrola-souladu: small-plan section" || fail "kontrola-souladu: no small-plan section"
f="$REPO_ROOT/skills/kontrola-planu/SKILL.md"
grep -q "honzapowers:kontrola-souladu" "$f" && grep -q "honzapowers:kontrola-auditu" "$f" && pass "kontrola-planu: names both agents" || fail "kontrola-planu: agents not named"
grep -qi "never edit the plugin" "$f" && pass "kontrola-planu: never edits plugin or policy" || fail "kontrola-planu: no never-edit rule"
E="$REPO_ROOT/evals/kontrola-planu-fires"
[ -f "$E/prompt.md" ] && [ "$(ls "$E"/graders/*.md | wc -l)" -ge 3 ] && pass "kontrola-planu eval: prompt and 3+ graders" || fail "kontrola-planu eval incomplete"
for e in pre-done-fires pre-done-trivial-no-fire kontrola-planu-chat-list-no-fire retro-lessons-no-write; do
  [ -f "$REPO_ROOT/evals/$e/prompt.md" ] && [ "$(ls "$REPO_ROOT/evals/$e"/graders/*.md 2>/dev/null | wc -l)" -ge 1 ] && pass "eval $e: prompt and grader" || fail "eval $e incomplete"
done

echo "mesicni-projektove-retro"
M="$REPO_ROOT/skills/mesicni-projektove-retro"
for x in SKILL.md analyst-prompt.md sablona.md git-signals.sh human-messages.py; do
  [ -f "$M/$x" ] && pass "mesicni-projektove-retro: $x" || fail "mesicni-projektove-retro: chybí $x"
done
grep -q "Never" "$M/SKILL.md" && grep -q "policy/policy.md" "$M/SKILL.md" && pass "mesicni-projektove-retro: nikdy nemění výchozí policy" || fail "mesicni-projektove-retro: chybí zákaz změny policy"
[ -f "$REPO_ROOT/evals/mesicni-projektove-retro-fires/prompt.md" ] && pass "mesicni-projektove-retro: eval" || fail "mesicni-projektove-retro: chybí eval"

echo "Skill-visibility rule and S2 pointer"
grep -q '^V1 .*🧩 Skill' "$REPO_ROOT/policy/policy.md" && pass "policy V1 has the 🧩 line" || fail "policy V1 missing"
grep -q '^S2 .*kontrola-planu.*skilly-kdy-ktery' "$REPO_ROOT/policy/policy.md" && pass "policy S2 points to kontrola-planu and skilly-kdy-ktery" || fail "policy S2 pointer missing"
[ -f "$REPO_ROOT/skills/skilly-kdy-ktery/SKILL.md" ] && pass "skilly-kdy-ktery exists" || fail "skilly-kdy-ktery missing"
echo "Policy rule IDs match the rule ledger"
policy_ids="$(grep -oE '^(L[0-9]+|M[0-9]+|S[0-9]+|F[0-9]+|G[0-9]+|V[0-9]+) ' "$REPO_ROOT/policy/policy.md" | tr -d ' ' | sort)"
ledger_ids="$(grep -oE '^\| (L[0-9]+|M[0-9]+|S[0-9]+|F[0-9]+|G[0-9]+|V[0-9]+) \|' "$REPO_ROOT/docs/learnings.md" | tr -d '| ' | sort)"
assert_eq "policy rule count" 22 "$(printf '%s\n' "$policy_ids" | grep -c .)"
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

echo "Rules agree with each other (audit phase C)"
P="$REPO_ROOT/policy/policy.md"; S="$REPO_ROOT/skills"
grep -q '^L13 .*pre-done.*skilly-kdy-ktery' "$P" && pass "L13 defers to skilly-kdy-ktery" || fail "L13 still runs pre-done unconditionally"
grep -qi 'not for trivial' <<<"$(frontmatter "$S/pre-done/SKILL.md" description)" && pass "pre-done: description excludes trivial changes" \
  || fail "pre-done: description does not exclude trivial changes"
kd="$(frontmatter "$S/kontrola-planu/SKILL.md" description)"
grep -qi 'plan file' <<<"$kd" && ! grep -qi 'any multi-step plan' <<<"$kd" && pass "kontrola-planu: fires on a written plan file only" \
  || fail "kontrola-planu: description too broad"
grep -qi 'once per project' "$S/kontrola-planu/SKILL.md" && ! grep -q '\*\*vždy\*\*' "$S/kontrola-planu/SKILL.md" \
  && pass "kontrola-planu: criteria file offered once per project" || fail "kontrola-planu: criteria file offered every run"
! grep -q 'S1`\.\.`S6' "$S/retro/SKILL.md" && pass "retro: no S1..S6 range (S3 is reserved)" || fail "retro: S1..S6 range"
grep -q 'S3 je vyhrazené' "$REPO_ROOT/docs/pouziti.md" && pass "pouziti: S3 reserved note" || fail "pouziti: no S3 note"
for h in "## Požadavky" "## Instalace" "## Ověření" "## Návrat zpět" "## Jak pracovat"; do grep -q "^$h" "$REPO_ROOT/README.md" && pass "README: $h" || fail "README: chybí $h"; done
grep -q "Git Bash" "$REPO_ROOT/README.md" && pass "README: Git Bash" || fail "README: chybí Git Bash"
for f in "$S/retro/SKILL.md" "$S/handover/SKILL.md" "$S/mesicni-projektove-retro/SKILL.md"; do
  grep -qi 'second project' "$f" && pass "$(basename "$(dirname "$f")"): promotion gate = second project" \
    || fail "$(basename "$(dirname "$f")"): promotion gate wording"
done
! grep -q 'another session or project' "$S/retro/SKILL.md" && pass "retro: no session-or-project gate" || fail "retro: old gate wording"
! grep -qi 'ledger rulings\|plan workspace' "$P" && pass "policy: no Superpowers jargon in S5" || fail "policy: jargon in S5"
head -1 "$P" | grep -q "project's CLAUDE.md/AGENTS.md win, then the user's own" && pass "policy: precedence project > user > default" || fail "policy: precedence line"
grep -q '~/.claude/CLAUDE.md' "$REPO_ROOT/docs/pouziti.md" && pass "pouziti: user CLAUDE.md layer" || fail "pouziti: no user CLAUDE.md layer"
grep -q '^### Připnutá verze' "$REPO_ROOT/README.md" && pass "README: pinned install" || fail "README: no pinned install"
grep -q 'honzapowers--v' "$REPO_ROOT/README.md" && grep -q 'Releases' "$REPO_ROOT/docs/vydani.md" && grep -q 'honzapowers--v' "$REPO_ROOT/docs/vydani.md" \
  && pass "README/vydani: tag honzapowers--vX.Y.Z, web path" || fail "README/vydani: tag name or web path"
grep -q 'fails because of the finding' "$S/pre-done/SKILL.md" && grep -qi 'at most one re-review' "$S/pre-done/SKILL.md" \
  && pass "pre-done: test-first fixes, one re-review" || fail "pre-done: no test-first fix rule"
grep -q 'cloud session' "$S/handover/SKILL.md" && pass "handover: container loss is cloud-only" || fail "handover: assumes cloud"
grep -q 'session-assigned branch' "$S/handover/SKILL.md" && grep -q 'session-assigned branch' "$S/kontrola-planu/SKILL.md" \
  && pass "handover, kontrola-planu: cloud commit to the assigned branch" || fail "handover, kontrola-planu: no cloud commit rule"
! grep -q 'Commit and push the handover?' "$S/handover/SKILL.md" && pass "handover: no pre-commit question in cloud" || fail "handover: still asks before commit in cloud"

echo "Language: AI-facing files are English, user output Czech (audit phase D)"
czech_prose() { # prints lines with Czech diacritics outside `code`, „quotes", fenced blocks and the Czech output labels
  awk '/^```/{f=!f; next} !f { l=$0; gsub(/`[^`]*`/, "", l); gsub(/„[^“]*“/, "", l); gsub(/ZAMÍTNOUT|OVĚŘENO|kritický/, "", l); if (l ~ /[ěščřžýáíéůúťďňĚŠČŘŽÝÁÍÉŮÚŤĎŇ]/) print FILENAME ":" FNR ": " substr($0, 1, 60) }' "$1"
}
for f in "$REPO_ROOT"/skills/*/SKILL.md "$REPO_ROOT"/skills/mesicni-projektove-retro/analyst-prompt.md "$REPO_ROOT"/agents/*.md; do
  n="${f#"$REPO_ROOT"/}"; out="$(czech_prose "$f")"
  [ -z "$out" ] && pass "$n: English prose" || fail "$n: Czech prose: $(printf '%s' "$out" | head -n 2)"
done
for f in "$REPO_ROOT"/agents/*.md; do
  case "$(frontmatter "$f" description)" in "Use "*) pass "${f##*/}: English description" ;; *) fail "${f##*/}: description not English" ;; esac
done
for f in "$REPO_ROOT"/skills/{kontrola-planu,mesicni-projektove-retro,skilly-kdy-ktery}/SKILL.md "$REPO_ROOT"/skills/mesicni-projektove-retro/analyst-prompt.md; do
  grep -qi 'in Czech' "$f" && pass "${f#"$REPO_ROOT"/}: user output in Czech" || fail "${f#"$REPO_ROOT"/}: no Czech-output rule"
done
grep -q 'AI-facing' "$REPO_ROOT/AGENTS.md" && pass "AGENTS.md: language rule" || fail "AGENTS.md: old language rule"
! grep -n 'pilot\|§4' "$REPO_ROOT/skills/pre-done/SKILL.md" "$REPO_ROOT/scripts/session-metrics" "$REPO_ROOT/docs/learnings.md" >/dev/null \
  && pass "no internal pilot/plan references" || fail "internal pilot/plan references remain"

echo "CI actions pinned to a commit SHA"
bad="$(grep -nE '^\s*-? *uses: ' "$REPO_ROOT/.github/workflows/"*.yml | grep -vE '@[0-9a-f]{40}( |$)')"
[ -z "$bad" ] && pass "all actions pinned to a SHA" || fail "unpinned: $bad"

echo "Lesson candidates"
K="$REPO_ROOT/skills/retro/kandidat.md"
if [ -f "$K" ]; then
  pass "kandidat.md exists"
  for h in "## Test" "## Existing entry" "## Output"; do grep -q "^$h" "$K" && pass "kandidat.md: $h" || fail "kandidat.md: missing $h"; done
  for w in Reusable Non-trivial Specific Verified "second project" "docs/learnings.md"; do grep -q "$w" "$K" && pass "kandidat.md: mentions $w" || fail "kandidat.md: no $w"; done
  kw="$(wc -w <"$K" | tr -d ' ')"
  [ "$kw" -le 400 ] && pass "kandidat.md: $kw <= 400 words" || fail "kandidat.md: $kw words"
  [ -z "$(czech_prose "$K")" ] && pass "kandidat.md: English prose" || fail "kandidat.md: Czech prose"
else
  fail "kandidat.md missing"
fi
[ -f "$REPO_ROOT/skills/handover/../retro/kandidat.md" ] && pass "handover: kandidat.md path resolves" || fail "handover: kandidat.md path broken"
grep -q 'Read `${CLAUDE_SKILL_DIR}/kandidat.md`' "$REPO_ROOT/skills/retro/SKILL.md" && grep -q 'Read `${CLAUDE_SKILL_DIR}/../retro/kandidat.md`' "$REPO_ROOT/skills/handover/SKILL.md" \
  && pass "retro and handover: told to Read kandidat.md" || fail "retro/handover: no Read instruction for kandidat.md"
for w in "Same trigger, same fix" "Same trigger, other cause" "At most 3" "žádný kandidát" "docs/retro/"; do
  grep -q "$w" "$K" && pass "kandidat.md: rule '$w'" || fail "kandidat.md: rule '$w' missing"
done
for w in "## Skill" "strongest evidence" "one line with the count" "Personal lessons file" "second occurrence" ".claude/skills/" "explicit yes"; do
  grep -qF -- "$w" "$K" && pass "kandidat.md: mentions '$w'" || fail "kandidat.md: no '$w'"
done
for w in "Same trigger, same fix: update that row" "never write a skill file"; do
  grep -qF -- "$w" "$K" && fail "kandidat.md: old wording '$w'" || pass "kandidat.md: no old wording '$w'"
done
sed -n '/^## Existing entry/,/^## [^E]/p' "$K" | grep -q 'second occurrence' && pass "kandidat.md: Existing entry leads to second occurrence" || fail "kandidat.md: Existing entry lacks second occurrence"
grep -qw 'diff' "$K" && pass "kandidat.md: diff proposal for the personal file" || fail "kandidat.md: no diff proposal"
! grep -q 'CLAUDE_SKILL_DIR' "$K" && pass "kandidat.md: no unsubstituted variable" || fail "kandidat.md: CLAUDE_SKILL_DIR is not substituted in non-SKILL files"
[ -f "$REPO_ROOT/evals/retro-lessons-no-write/graders/skill-fired.md" ] && pass "eval retro-lessons-no-write: skill-fired grader" || fail "eval retro-lessons-no-write: no skill-fired grader"
RS="$REPO_ROOT/skills/retro/SKILL.md"; HS="$REPO_ROOT/skills/handover/SKILL.md"
grep -q 'kandidat.md' "$RS" && pass "retro: candidates step" || fail "retro: no candidates step"
for w in "explicit yes" "Kandidáti na poznatek" "Personal lessons file" "žádný kandidát"; do
  grep -qF -- "$w" "$RS" && pass "retro: mentions '$w'" || fail "retro: no '$w'"
done
grep -qF 'never write a skill file' "$RS" && fail "retro: old wording 'never write a skill file'" || pass "retro: no old wording 'never write a skill file'"
sed -n '/^## 3\. Promotion gate/,/^## 4/p' "$RS" | grep -qF 'Personal lessons file' && pass "retro: Promotion gate reads the personal file" || fail "retro: Promotion gate lacks the personal file"
grep -qF 'line:N' "$REPO_ROOT/evals/retro-lessons-no-write/graders/candidate-evidence.md" && grep -qF 'alone' "$REPO_ROOT/evals/retro-lessons-no-write/graders/candidate-evidence.md" \
  && pass "eval candidate-evidence: line:N alone is not evidence" || fail "eval candidate-evidence: accepts line:N alone"
grep -qF '<path>`, the project' "$K" && pass "kandidat.md: search order has its separators" || fail "kandidat.md: missing comma in the search order"
grep -qF 'assigned to this session' "$HS" && grep -qF 'when unsure' "$HS" && pass "handover: push clause names its criterion" || fail "handover: no criterion for the push clause"
grep -qF 'earlier session' "$K" && pass "kandidat.md: a record from this session is not a second occurrence" || fail "kandidat.md: no 'earlier session'"
grep -qF 'osobním přehledu, <date>' "$K" && ! grep -qF '<file, date>' "$K" && pass "kandidat.md: no path of the personal file in the saved text" || fail "kandidat.md: path of the personal file may leak"
grep -qF 'without the push clause' "$HS" && grep -qF 'Pracuj na větvi <branch>.' "$HS" && pass "handover: push clause only for a cloud working branch" || fail "handover: push clause is unconditional"
grep -qF 'git branch --show-current' "$HS" && grep -qF 'push tam máš povolený' "$HS" \
  && pass "handover: ready sentence with the branch for the next session" || fail "handover: no ready sentence with the branch"
for w in "Personal lessons file" "žádný kandidát"; do
  grep -qF -- "$w" "$HS" && pass "handover: mentions '$w'" || fail "handover: no '$w'"
done
grep -q 'kandidat.md' "$REPO_ROOT/skills/handover/SKILL.md" && grep -q 'Lessons' "$REPO_ROOT/skills/handover/SKILL.md" \
  && pass "handover: Lessons line" || fail "handover: no Lessons line"

summary components
