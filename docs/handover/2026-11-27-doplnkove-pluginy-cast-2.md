# Handover: doplňkové pluginy, část 2 (2026-11-27)

## 1. Identita a cíl
- Repo `MedniLedved/honzapowers`, větev `claude/sleepy-mayer-lfohlj`, fáze: plán části 2 je napsaný a zkontrolovaný, nic z něj není provedeno.
- Cíl: zjistit, jaké doplňkové pluginy a nápady obohatí HP (zapnutím, nebo převzetím nápadu).
- Způsob práce: česky, tykání, velké úkoly po fázích (jedna fáze, ověření, pak další), bez `claude` CLI v terminálu, push a merge do `main` jsou brány (G1), merge dělá uživatel.

## 2. Hotovo v této session
- Plán `docs/plans/2026-11-27-doplnkove-pluginy.md` je celý hotový a sloučený: Task 1 (`pre-done`: revizor hledá tiché chyby), Task 2 (`retro`: hookify jako volitelná podoba příčky `hard`), Task 3 (pokus), Task 4 (sekce „Doplňkové pluginy“ v `docs/pouziti.md`). Důkaz: `bash tests/run-tests.sh` ⇒ `ALL PASS`, `claude plugin validate --strict .` ⇒ `Validation passed`; sloučené PR [#16](https://github.com/MedniLedved/honzapowers/pull/16), [#21](https://github.com/MedniLedved/honzapowers/pull/21), [#22](https://github.com/MedniLedved/honzapowers/pull/22).
- Výsledky pokusu (Sonnet medium, cloud): `Context tokens: first` základ 84,1k, s pluginy 84,05k; `claude-md-management` funguje a je doporučen; `hookify` v cloudu hlásil „/hookify isn’t a command here“ a varování se neukázalo, příčina nezměřena, lokálně nevyzkoušeno.
- Nový plán `docs/plans/2026-11-27-doplnkove-pluginy-cast-2.md` (psal Opus), prošel `kontrola-planu` (4 nálezy opraveny, otázky 0). Commity `4ed2e3a` a `8795e30` jsou na větvi, **zatím bez PR**.

## 3. Rozhodnutí
- Zamítnuto: vlastní engine pravidel v HP jako náhrada hookify; `claude-mem`, `context-mode`, samoučící pluginy, druhý model na revizi plánu.
- Schváleno uživatelem: plán části 2 se třemi tasky (příčina hookify, nativní hook a `permissions.deny` v cloudu, volitelný test `pre-done` proti `pr-review-toolkit`); `episodic-memory` a `claude-hud` se nezkouší.
- Merge PR před pokusem (aby základ i varianta běžely nad stejným `main`), pokusné PR 17 až 20 uzavřeny bez merge, jejich větve a session uživatel uklízí sám.

## 4. Otevřené body a brány
- Task 1 Step 1 až 6 a Task 2 Step 2 až 4 dělá uživatel v cloudové session; na otázky o commitu, pushi a PR odpovídat **ne**.
- Push pokusných větví `pokus/hard-rule-test` a `pokus/review-test` jen po výslovném souhlasu.
- Neověřeno: syntaxe `Bash(echo deny-rule-test:*)` a podoba hooku (psáno z paměti); zda se `.claude/settings.json` z jiné větve než `main` v cloudu načte.
- Task 3 je volitelný (brána v Step 1).
- Plán `…cast-2.md` není hotový, `**Stav provedení:** hotovo` se přidá až v jeho posledním commitu.

## 5. Další krok
Vytvořit draft PR pro větev (obsahuje jen plán části 2) a začít Task 1 (pokus s hookify). Ověření: v `## Výsledky pokusu` plánu je tabulka `krok | výsledek | důkaz` a verdikt hookify.

Věta pro novou session: `Pracuj na větvi claude/sleepy-mayer-lfohlj, push tam máš povolený. Přečti docs/handover/2026-11-27-doplnkove-pluginy-cast-2.md a pokračuj Task 1 plánu docs/plans/2026-11-27-doplnkove-pluginy-cast-2.md.`

## 6. Soubory a pořadí čtení
1. Tento soubor.
2. `docs/plans/2026-11-27-doplnkove-pluginy-cast-2.md` (od `## Review Focus`, pak Task 1).
3. `docs/plans/2026-11-27-doplnkove-pluginy.md`, `## Výsledky pokusu`.
4. `docs/pouziti.md`, `## Doplňkové pluginy`.

## 7. Krátké retro
- Kontext vyrostl z 84,7k na 185k (+100k), cache reads 98 %, 44 volání nástrojů (Bash 16, `ReadNotifications` 12). Opakované Bash běhy, opakované editace a zbytečné re-runy: 0.
- Největší výsledky: `Read` 29,7kB (plán části 2), dvakrát `ReadNotifications` 22,9kB (opakovaný návod k PR při každém odběru).
- Nález 1: dvě volání `ReadNotifications` po 22,9kB za sebou při každém sledovaném PR (hlavně úvodní oznámení). Pravidlo L2/L3, třída `one-off`, jen záznam.
- Nález 2: pokusné session samy commitovaly, pushovaly a otevíraly PR (stop hook prostředí chtěl commit po každém tahu). Pravidlo G1, třída `project`, ošetřeno v plánu části 2 (odpovídat ne).
- Lessons: `žádný kandidát` (stop hook prostředí je už v plánu zachycen, druhý výskyt v jiném projektu chybí).
