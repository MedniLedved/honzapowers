---
name: kontrola-planu
description: Use when a plan has just been written (writing-plans or any multi-step plan) and before it is executed, to check it against the spec and project rules with read-only checker agents, sort the findings into fix, ask or reject, and propose a lesson for the project's own criteria file.
---

# Kontrola plánu

Zkontroluj hotový plán dřív, než se začne provádět. Agenti jen čtou. Plán opravuješ ty, a jen v bodech, kde je oprava jednoznačná. Odpovídej česky.

## 1. Podklady
- Plán: cesta od uživatele, jinak nejnovější soubor v `docs/superpowers/plans/` nebo `docs/plans/`.
- Zdroj pravdy: zadání nebo spec, ke kterému plán patří, `AGENTS.md` / `CLAUDE.md` projektu a dotčený kód.
- Kritéria projektu: `.claude/kontrola-planu.md`. Pokud soubor existuje, načti ho. Pokud ne, kontroluj s obecnými kritérii (níže) a po prvním běhu nabídni, že soubor založíš (krok 5).

Obecná kritéria: každý úkol jmenuje soubory, kroky a ověřovací příkaz; pořadí kroků dává smysl; plán odpovídá zadání (nic navíc, nic nechybí); kroky jsou proveditelné bez dalšího ptaní; výsledek i kód jsou úsporné.

## 2. Práh a agenti
Spočítej otevřené úkoly (`- [ ]`).
- **Do 3 úkolů:** spusť jen agenta `honzapowers:kontrola-souladu`.
- **Víc než 3:** spusť `honzapowers:kontrola-souladu` a `honzapowers:kontrola-auditu` **paralelně** v jedné odpovědi.

Agentům předej cesty (plán, zadání, projektová pravidla, kritéria), ne obsah. Každý vrátí nejvýš 5 nálezů s košem `OPRAVIT|ZEPTAT|ZAMÍTNOUT`, závažností `kritický|ostatní`, místem v plánu a důvodem v jedné větě.

## 3. Roztřídění
Sluč nálezy obou agentů, odstraň duplicity a rozhodni o koších sám (agent jen navrhuje):
- **OPRAVIT:** oprava je jednoznačná a leží v plánu. Oprav ji hned.
- **ZEPTAT:** rozhodnutí patří uživateli. Všechny otázky polož **najednou**, každou s doporučením a jednou větou proč.
- **ZAMÍTNOUT:** nález neplatí nebo se míjí se zadáním. Napiš jednou větou proč.

## 4. Druhé kolo
Jen když jsi opravil **kritický** nález: spusť ještě jednou samotného `honzapowers:kontrola-souladu` nad opraveným plánem. Víc kol ne.

## 5. Poučení pro další plány
Pokud se nález bude opakovat i v dalších plánech tohoto projektu, navrhni pravidlo jako **unified diff** proti `.claude/kontrola-planu.md` projektu a nech ho odsouhlasit. Dál platí:
- nic nezapisuj bez souhlasu uživatele;
- nikdy neupravuj plugin ani `policy/policy.md`;
- nezapisuj pravidlo, které už hlídá kód, test nebo hook;
- chybí-li soubor, nabídni jeho založení a nezakládej ho sám;
- nepředepisuj pevný příkaz projektu (např. testovací), jen že plán má ověřovací příkaz uvést.

## 6. Uzávěr
Napiš nejvýš 6 řádků: počty nálezů po koších, co jsi opravil, na co čekáš (otázky), zda proběhlo druhé kolo, návrh poučení nebo nabídka založit soubor kritérií.
