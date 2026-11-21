---
name: skilly-kdy-ktery
description: Use when starting a task and deciding which skills to run and in what order, when the policy rule S2 or V1 is in play, or when unsure whether pre-done, retro or handover is due. Gives the work classes, the standard path and when each step is mandatory.
---

# Skilly: kdy který

Podrobnosti k pravidlům S2 a V1 z policy. Skilly spouštíš sám podle situace, uživatel na ně nemusí myslet. Na začátku úkolu jednou větou řekni, kterou cestu volíš, a krok, který vynecháváš, nezmiňuj. Brány a pravidla projektu v `AGENTS.md` / `CLAUDE.md` mají přednost.

## 1. Třída práce
- **Triviální** (překlep, drobná oprava, dokumentace): bez skillů, jen ověření.
- **Ohraničená** (jasný rozsah, hotové zadání): plán → kontrola plánu → provedení.
- **Architektonická** (nová část systému, změna schématu, není jasné, *co*): nejdřív `superpowers:brainstorming`, pak celá cesta.

Nejsi-li si jistý třídou, vol vyšší.

## 2. Cesta
`superpowers:brainstorming` (jen architektonická) → `superpowers:writing-plans` → `kontrola-planu` → `superpowers:executing-plans` (inline, subagenti jen u 5 a více nezávislých úkolů) → `superpowers:verification-before-completion` → `honzapowers:pre-done` → (`honzapowers:retro`) → `honzapowers:handover`.

## 3. Kdy je který krok povinný
- **`kontrola-planu`:** po každém `writing-plans`, před prvním řádkem kódu. U triviální práce ne.
- **`verification-before-completion`:** vždy před tvrzením „hotovo“, commitem a PR: ukaž příkaz a výstup. Testy, které prošly, bez nové změny znovu nepouštěj.
- **`pre-done`:** u architektonické práce a u změny, která maže nebo přepisuje data, mění sdílené rozhraní nebo jde do PR. Jinak jen na požádání. Patří před handover, pokud se měnil kód.
- **`retro`:** jen když byla session pomalá, drahá nebo se točila v kruhu, nebo na požádání. Vždy před handoverem, který ho zmiňuje.
- **`handover`:** konec session, před `/clear`, při velkém kontextu nebo po pauze přes hodinu. **Nikdy ho nespouštěj sám**: jednou větou navrhni („`pre-done` a potom handover“, pokud kód měnil) a počkej na výslovné „ano“. Commit a push handoveru až po dalším souhlasu.

## 4. Chyba nebo nečekaný výsledek
Nejdřív `superpowers:systematic-debugging`, oprava až po změření příčiny. Po dvou nepovedených opravách navrhni nový start s lepším zadáním.

## 5. Viditelnost (V1)
Použitý skill musí být v odpovědi vidět, aby ho uživatel nemusel vyžadovat znovu:
- hned na začátku odpovědi samostatný řádek `> **🧩 Skill: <název>** – <co udělal, jedna věta>`, u více skillů jeden řádek na každý;
- když na konci shrnuješ hotovou práci, přidej řádek `**Použité skilly:** …` (nebo „žádné“).
