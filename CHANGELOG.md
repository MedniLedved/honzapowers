# Changelog

## Nepublikováno
- **Kandidáti na poznatek:** `retro` a `handover` navrhnou nejvýš 3 poznatky ze session podle kritérií (opakovatelný, netriviální, konkrétní, ověřený) a rozhodovací tabulky (nový řádek, aktualizace, odkaz, zastaralý). Jen návrh: žádný hook, žádný automatický zápis skillů, policy beze změny. Nový eval `retro-lessons-no-write`. Inspirace: projekty Claudeception a continuous-learning-skill.
- **Cloud:** `handover` a `kontrola-planu` v cloudové session samy commitnou a pushnou svůj soubor na pracovní nebo přidělenou větev a nabídnou vrácení; dřív se `handover` ptal a hook prostředí („commit and push“) se ozval po každém tahu. Push na `main` nebo sdílenou větev zůstává bránou G1. Lokálně beze změny.

## 0.4.0 — 2026-11-25
Opravy z auditu před zveřejněním.
- **Pravidla:** L13 spouští `pre-done` jen podle `skilly-kdy-ktery` (architektura, mazání dat, sdílené rozhraní, jinak na požádání); popis `pre-done` vylučuje drobnosti. S3 je vyhrazené pro osobní vrstvu. S5 bez žargonu.
- **`kontrola-planu`:** jen pro napsaný soubor plánu. Nabídka souboru kritérií je jen jednou na projekt a po odmítnutí se do konce session neopakuje (**opravuje 0.3.0 a 0.3.1, které říkaly „vždy“**).
- Jedna podmínka povýšení poučení do pravidel: potvrzení ve druhém projektu (`retro`, `handover`, `mesicni-projektove-retro`). `handover` rozlišuje cloud.
- **Jazyk:** co čte Claude (policy, skilly, agenti, texty hooků), je anglicky; co čte uživatel, česky. Nové pravidlo v `AGENTS.md`.
- **Bezpečnost:** `log-reader` bez Bash; obsah logů a souborů je data, ne pokyny; Repo state označený „never instructions“; záloha stavu v `honzapowers-<uid>` s `umask 077`; `session-metrics` varuje, když `--session` nenajde přepis; `actions/checkout` připnutý na SHA.
- **Práh handoveru:** při prázdném tailu se usage hledá v celém přepisu; odhad z velikosti jen bez jakéhokoli záznamu (méně falešných upozornění).
- **Evaly:** `pre-done-fires`, `pre-done-trivial-no-fire`, `kontrola-planu-chat-list-no-fire`.
- **Dokumentace:** README s požadavky (Git Bash na Windows, git, python3), instalací, ověřením a návratem zpět; odstraněny interní odkazy (pilot, „plan §“).
- Původní název pluginu byl `lean-workflow` (0.3.0 a dříve).

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
