#!/usr/bin/env bash
# Testy skills/mesicni-projektove-retro/git-signals.sh na dočasných repech s vymyšlenými soubory.
# Spuštění: bash tests/test-git-signals.sh
set -uo pipefail
. "$(dirname "$0")/lib.sh"
SCRIPT="$REPO_ROOT/skills/mesicni-projektove-retro/git-signals.sh"
GIT=(git -c user.name=Test -c user.email=test@example.invalid -c init.defaultBranch=main)

mkrepo() { # <adresář> <větev>: repo s handovery a jedním commitem, bez remote
  local d="$1"
  mkdir -p "$d" && git -C "$d" init -q -b "$2"
  mkdir -p "$d/docs/handover" "$d/docs/retro"
  for f in docs/handover/2026-10-31-a.md docs/handover/2026-11-05-b.md docs/handover/README.md \
           docs/retro/2026-11-30-c.md docs/retro/2026-12-01-d.md 'docs/handover/2026-11-06 řešení a.md'; do
    echo x >"$d/$f"
  done
  git -C "$d" add . && "${GIT[@]}" -C "$d" commit -q -m 'docs: testovací soubory'
}
run() { # <adresář> <argumenty...>; nastaví OUT a CODE
  local d="$1"; shift
  OUT="$(cd "$d" && bash "$SCRIPT" "$@" 2>&1)"; CODE=$?
}

echo "Výchozí větev: main bez origin/HEAD"
mkrepo "$TEST_ROOT/r-main" main
run "$TEST_ROOT/r-main" 2000-01-01 2100-01-01
assert_eq "exit" 0 "$CODE"
grep -q 'Signály z gitu: main,' <<<"$OUT" && pass "použije main" || fail "nepoužil main: $(head -1 <<<"$OUT")"
grep -q 'Soubory měněné nejčastěji' <<<"$OUT" && pass "doběhne za sekci oprav" || fail "nedoběhl za sekci oprav"

echo "Výchozí větev: jen trunk"
mkrepo "$TEST_ROOT/r-trunk" trunk
run "$TEST_ROOT/r-trunk" 2000-01-01 2100-01-01
assert_eq "exit" 0 "$CODE"
grep -q 'Signály z gitu: trunk,' <<<"$OUT" && pass "použije aktuální větev trunk" || fail "nepoužil trunk: $(head -1 <<<"$OUT")"

echo "Výchozí větev: master, když není main"
mkrepo "$TEST_ROOT/r-master" master
run "$TEST_ROOT/r-master" 2000-01-01 2100-01-01
grep -q 'Signály z gitu: master,' <<<"$OUT" && pass "použije master" || fail "nepoužil master: $(head -1 <<<"$OUT")"

echo "Výchozí větev: origin/HEAD má přednost"
git clone -q "$TEST_ROOT/r-trunk" "$TEST_ROOT/r-clone" 2>/dev/null
run "$TEST_ROOT/r-clone" 2000-01-01 2100-01-01
grep -q 'Signály z gitu: origin/trunk,' <<<"$OUT" && pass "použije origin/trunk z origin/HEAD" || fail "nepoužil origin/HEAD: $(head -1 <<<"$OUT")"

echo "Chybějící větev a argumenty"
run "$TEST_ROOT/r-main" 2000-01-01 2100-01-01 neexistuje
[ "$CODE" -ne 0 ] && pass "neexistující větev selže" || fail "neexistující větev prošla"
run "$TEST_ROOT/r-main"
[ "$CODE" -ne 0 ] && pass "bez období selže" || fail "bez období prošlo"

echo "Náklady session"
run "$TEST_ROOT/r-main" 2026-11-01 2026-12-01
N="$(sed -n '/^## Náklady session/,$p' <<<"$OUT")"
grep -q 'docs/handover/2026-11-05-b.md' <<<"$N" && pass "handover b je v období" || fail "chybí handover b"
grep -q 'docs/retro/2026-11-30-c.md' <<<"$N" && pass "retro c je v období" || fail "chybí retro c"
grep -q 'docs/handover/2026-11-06 řešení a.md' <<<"$N" && pass "název s diakritikou a mezerou" || fail "diakritika v názvu"
grep -q 'Souborů: 3' <<<"$N" && pass "počet 3" || fail "špatný počet"
grep -q -e '-a.md' <<<"$N" && fail "prošel soubor před obdobím" || pass "soubor před obdobím neprošel"
grep -q -e '-d.md' <<<"$N" && fail "prošel soubor po období" || pass "soubor po období neprošel"
grep -q 'README.md' <<<"$N" && fail "prošel soubor bez data" || pass "soubor bez data neprošel"
run "$TEST_ROOT/r-main" 2026-01-01 2026-02-01
grep -q 'náklady session v období neznámé' <<<"$OUT" && pass "prázdné období je neznámé, ne 0" || fail "chybí hláška neznámé"

summary git-signals
