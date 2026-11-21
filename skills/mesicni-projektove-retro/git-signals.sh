#!/usr/bin/env bash
# Objektivní signály z gitu pro retrospektivu za období. Jen čtení, výstup je markdown na stdout.
# Použití: bash git-signals.sh <od> <do> [větev]
#   <od> včetně, <do> mimo (git --since / --until), např.: bash git-signals.sh 2026-10-01 2026-11-01
# Bez [větev] se zvolí výchozí větev: origin/HEAD, jinak main, jinak master, jinak aktuální větev.
set -euo pipefail

od="${1:?Chybí <od> (RRRR-MM-DD)}"
do_="${2:?Chybí <do> (RRRR-MM-DD)}"

vychozi_vetev() {
  local b c
  if b="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)" && [ -n "$b" ]; then
    echo "$b"; return
  fi
  for b in main master; do
    for c in "origin/$b" "$b"; do
      if git rev-parse --verify --quiet "$c^{commit}" >/dev/null; then echo "$c"; return; fi
    done
  done
  git symbolic-ref --quiet --short HEAD 2>/dev/null || echo HEAD
}

vetev="${3:-$(vychozi_vetev)}"
git rev-parse --verify --quiet "$vetev^{commit}" >/dev/null || { echo "Větev $vetev neexistuje (git fetch origin?)" >&2; exit 1; }
rozsah=(--since="$od" --until="$do_" "$vetev")

celkem=$(git log "${rozsah[@]}" --format='%h' | wc -l)
echo "## Signály z gitu: $vetev, $od až $do_ (mimo)"
echo
echo "- Commity celkem: $celkem"

echo "- Podle prefixu zprávy:"
git log "${rozsah[@]}" --format='%s' \
  | sed -E 's/^(Revert) .*/revert/; s/^Merge .*/merge/; s/^([a-zA-Z]+)(\([^)]*\))?!?:.*/\1/; t; s/^.*$/jiné/' \
  | sort | uniq -c | sort -rn | sed 's/^ */  - /'

feat=$(git log "${rozsah[@]}" --format='%s' | grep -cE '^feat(\(|:)' || true)
fix=$(git log "${rozsah[@]}" --format='%s' | grep -cE '^fix(\(|:)' || true)
if [ $((feat + fix)) -gt 0 ]; then
  echo "- Podíl oprav fix/(feat+fix): $fix z $((feat + fix)) ($((100 * fix / (feat + fix))) %)"
fi

echo "- Reverty, fixup, squash:"
git log "${rozsah[@]}" --format='%h %s' | grep -iE ' (Revert |fixup!|squash!)' | sed 's/^/  - /' || true
echo "  (konec výpisu)"

echo
echo "## Commity opravující dřívější práci (fix:), s relací na session"
echo "| sha | datum | zpráva | session |"
echo "|---|---|---|---|"
git log "${rozsah[@]}" --reverse --date=format:'%d.%m %H:%M' \
  --format='%h|%ad|%s|%(trailers:key=Claude-Session,valueonly,separator=%x2C)' \
  | { grep -E '^[0-9a-f]+\|[^|]*\|fix(\(|:)' || true; } \
  | awk -F'|' '{ s=$4; sub(/.*session_/, "session_", s); gsub(/\n/, "", s); printf "| %s | %s | %s | %s |\n", $1, $2, substr($3,1,90), s }'

echo
echo "## Soubory měněné nejčastěji (kandidáti na sdílený soubor, kde se session potkávají)"
git log "${rozsah[@]}" --name-only --format='' | { grep -v '^$' || true; } | sort | uniq -c | sort -rn | head -8 | sed 's/^ */- /'

echo
echo "## Náklady session (soubory v období)"
pocet=0
while IFS= read -r soubor; do
  jmeno="${soubor##*/}"
  datum="${jmeno:0:10}"
  [[ "$datum" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue
  if [[ "$datum" == "$od" || "$datum" > "$od" ]] && [[ "$datum" < "$do_" ]]; then
    echo "- $soubor"
    pocet=$((pocet + 1))
  fi
done < <(git -c core.quotepath=false ls-tree -r --name-only "$vetev" -- docs/handover docs/retro)
if [ "$pocet" -eq 0 ]; then
  echo "- Žádný soubor: náklady session v období neznámé"
else
  echo "- Souborů: $pocet"
fi
