# Changelog

## 0.3.1 — 2026-11-25
- `kontrola-planu`: krok 1 odkazuje na správné kroky (6 a 7) a říká „vždy“, v souladu s 0.3.0.
- README a `docs/pouziti.md` popisují výběr plánu jako v 0.3.0 (plán z posledního handoveru, jinak nejnovější podle názvu).
- `human-messages.py` a `git-signals.sh` mají právo spuštění.
- Testy `session-start`: cesta s `..` mimo repo, handover s CRLF, handover jen v `docs/audit`, plán `docs/plan.md`.

## 0.3.0 — 2026-11-25
- `session-start`: „Repo state“ bere plán, který jmenuje nejnovější handover (pokud v repu existuje); teprve pak nejnovější plán podle názvu.
- `kontrola-planu`: chybí-li `.claude/kontrola-planu.md`, nabídka jeho založení je povinná po každém běhu, i bez nového pravidla.
- `mesicni-projektove-retro`: `SKILL.md` upozorňuje, že projekt s jinou integrační větví (např. `dev`) předá `git-signals.sh` třetí argument.

## 0.2.0 — 2026-11-21
- Plugin přejmenován z `lean-workflow` na `honzapowers` (nové repo s čistou historií).
- README česky, nový návod `docs/pouziti.md`, licence MIT.
- Proměnné prostředí `HONZAPOWERS_HANDOVER_TOKENS`, `HONZAPOWERS_HANDOVER_STEP`, `HONZAPOWERS_RESUME_TOKENS` a `HONZAPOWERS_REAL_TRANSCRIPT` mají přednost; původní `LEAN_WORKFLOW_*` dál fungují jako záloha.

## 0.1.5 — 2026-11-17
- Handover se už nikdy nespouští sám: je jen návrh, předchází mu `pre-done` (když session měnila kód) a commit/push proběhne až po souhlasu.
