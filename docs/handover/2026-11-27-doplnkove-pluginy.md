# Handover 2026-11-27 – doplňkové pluginy

## 1. Identita a cíl
Repo `MedniLedved/honzapowers`, větev `claude/fervent-heisenberg-41nhnt`, draft [PR #12](https://github.com/MedniLedved/honzapowers/pull/12). Fáze: plán je napsaný a zkontrolovaný, provádění nezačalo. Cíl: převzít do HP dva levné nápady z rešerše doplňkových pluginů, nechat uživatele změřit `claude-md-management` a `hookify` a ověřené verdikty zapsat do `docs/pouziti.md`.

## 2. Hotovo v této session
- Rešerše doplňkových pluginů (A: oficiální, B: komunitní, C: nedoporučené). Výsledek je shrnutý v plánu, v sekci „Co do plánu nepatří“.
- Plán `docs/plans/2026-11-27-doplnkove-pluginy.md`, kontrola `kontrola-planu`. První kolo: 7 nálezů, 6 opraveno, 1 zamítnut. Druhé kolo: 3 nálezy, 3 opraveny. Commity `13aa547`, `93c2f92`, CI na PR #12 zelené, stav `clean`.
- Do `.claude/kontrola-planu.md` přibyl bod 2: odkazy na místa, která mění dřívější úkol, se píšou textovou kotvou, ne číslem řádku.
- Starý plán `docs/plans/2026-11-25-kandidati-na-poznatek.md` je celý odškrtnutý (`grep -c -- '- \[ \]'` ⇒ 0). Tasky 5–8 byly hotové v commitech `e260ed3`, `af1f4be`, `c5c3e9c`, `7c06bdd` a vydané v 0.5.0. Commit `8fb09b0`, `bash tests/run-tests.sh` ⇒ `ALL PASS`.

## 3. Rozhodnutí
- Uživatel schválil zápis poučení do `.claude/kontrola-planu.md` a odškrtnutí starého plánu.
- Zamítnutý nález kontroly „draft PR je navíc“: prostředí vyžaduje draft PR po pushi.
- Z rešerše se do HP převezme jen zaměření revizora v `pre-done` a volitelná podoba hookify v `retro`. Ostatní je zdůvodněně mimo plán.

## 4. Otevřené a brány
- Fáze 1 (Task 1 a 2) čeká na „ano“ uživatele.
- Fázi 2 (Task 3) dělá uživatel: zapnutí pluginů na claude.ai a měření v nových session. Fáze 3 začne až po jejích výsledcích.
- Merge PR #12 a vydání verze rozhoduje uživatel (G1, `docs/vydani.md`).
- Kontroly PR přes `send_later` jsou zastavené. Sledování aktivity PR ve staré session v nové nefunguje.

## 5. Další krok
Inline `superpowers:executing-plans`, Task 1 z `docs/plans/2026-11-27-doplnkove-pluginy.md`. Ověření: `bash tests/test-components.sh` ⇒ nejdřív `FAIL pre-done: no reviewer focus`, po úpravě `PASS`. Po Tasku 2: `bash tests/run-tests.sh` ⇒ `ALL PASS` a `claude plugin validate --strict .`.

Věta pro novou session:
> Pracuj na větvi claude/fervent-heisenberg-41nhnt, push tam máš povolený. Proveď fázi 1 (Task 1 a 2) plánu docs/plans/2026-11-27-doplnkove-pluginy.md a pak se zastav.

## 6. Soubory a pořadí čtení
1. Tento soubor.
2. `docs/plans/2026-11-27-doplnkove-pluginy.md`: Globální omezení, Review Focus, Fáze 1.
3. `skills/pre-done/SKILL.md` § 2 a `skills/retro/SKILL.md` § 2 (odrážka Rung).
4. `tests/test-components.sh` kolem testu `pre-done: reviewer must not edit`.

## 7. Krátké retro
- Kontext: na začátku 82.6k, na konci 178k (+95k). Vstupní tokeny 6.8M, z toho 96 % z cache.
- 60 volání nástrojů (Bash 21, WebSearch 11). Opakované běhy testů bez změny: 0.
- Největší výstupy: Bash 24.7kB (line:109, čtení čtyř skillů a agentů najednou), ReadNotifications 24.6kB (line:270).

Nálezy:
1. Bash 24.7kB `line:109`: celé soubory skillů a agentů jedním `cat`, `L2`. Třída `one-off`: soubory jsou krátké (24–56 řádků) a všechny byly potřeba.
2. Úpravy jednoho souboru 7× za sebou (`line:213`): opravy z kontroly plánu v jedné odpovědi, `L4` dodrženo. Třída `one-off`.
3. Kontext na začátku 82.6k, ještě před prací: systémový prompt a seznam nástrojů prostředí. Pravidlo `new`, třída `one-off`. Jen změřit znovu, až budou výsledky fáze 2.

Lessons:
- **Kandidát:** hook `SessionStart` hlásí hotový plán jako rozpracovaný („23 open tasks“), když v něm zůstanou neodškrtnuté kroky. Oprava: při dokončení tasku odškrtnout jeho kroky ve stejném commitu. Důkaz: `grep -c -- '- \[ \]' docs/plans/2026-11-25-kandidati-na-poznatek.md` ⇒ 23 u plánu vydaného v 0.5.0, po odškrtnutí 0. Třída `project`. V `docs/handover/`, `docs/retro/` ani `docs/learnings.md` zatím nic takového není, je to první výskyt.
