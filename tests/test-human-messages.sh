#!/usr/bin/env bash
# Testy skills/mesicni-projektove-retro/human-messages.py na vymyšlené fixture. Spuštění: bash tests/test-human-messages.sh
set -uo pipefail
. "$(dirname "$0")/lib.sh"
SCRIPT="$REPO_ROOT/skills/mesicni-projektove-retro/human-messages.py"

out="$(python3 -I "$SCRIPT" "$FIXTURES/list-events-sample.txt" 2>&1)"
has() { grep -q -- "$2" <<<"$out" && pass "$1" || fail "$1"; }
lacks() { grep -q -- "$2" <<<"$out" && fail "$1" || pass "$1"; }

echo "Zprávy člověka a skrývání"
has   "zpráva člověka prošla" 'ne, takhle to nechci'
lacks "výstup nástroje neprošel" 'TAJNÝ VÝSTUP'
lacks "tool_result s client_platform neprošel" 'výstup s client_platform'
lacks "zpráva bez client_platform neprošla" 'TEXT BEZ client_platform'
lacks "e-mail je skrytý" 'test@example.com'
lacks "klíč je skrytý" 'sk-abcdefgh'
lacks "heslo v URL je skryté" 'hesloXYZ'
has   "stránkování" 'has_more=True before_id=abc-123'
assert_eq "počet zpráv člověka" 2 "$(grep -c ' | ' <<<"$out")"

echo "Řídicí znak v JSON"
tab="$TEST_ROOT/tab.txt"
printf '{"ccr":{"data":[{"created_at":"2026-10-30T21:00:00Z","user":{"internal_anthropic_catchall":{"client_platform":"desktop_app","session_id":"session_BBBB222222","message":{"role":"user","content":"řádek s\\ttabem a\\nzalomením"}}}}],"has_more":false,"first_id":"z"}}' \
  | sed 's/\\t/\t/' >"$tab"
python3 -I "$SCRIPT" "$tab" | grep -q 'zalomením' && pass "skript nespadne na tabulátoru" || fail "skript spadl na tabulátoru"

echo "Výstup v cp1252 (Windows): skript musí vynutit UTF-8"
# Bez -I: izolovaný režim ignoruje PYTHONIOENCODING a test by nic neověřil.
out="$(PYTHONIOENCODING=cp1252 python3 "$SCRIPT" "$FIXTURES/list-events-sample.txt" 2>&1)"
has "diakritika při cp1252 nespadne" 'has_more=True before_id=abc-123'

echo "Chybné vstupy"
python3 -I "$SCRIPT" >/dev/null 2>&1; assert_eq "bez argumentu skončí kódem 2" 2 "$?"
printf 'bez json\n' >"$TEST_ROOT/bad.txt"
python3 -I "$SCRIPT" "$TEST_ROOT/bad.txt" >/dev/null 2>&1 && fail "vstup bez JSON prošel" || pass "vstup bez JSON selže"

summary human-messages
