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

## 2. Seznam čtení
Velký plán nebo zadání agenti nečtou celé. Ty jim připrav seznam `soubor ř. X–Y`:
- `grep -n "^## \|^### "` v plánu a v zadání → jen oddíly, na které plán odkazuje;
- u kódu jen hlavičky funkcí (`grep -n "^def \|^class "` nebo obdoba) a funkce, které plán mění;
- pro `kontrola-souladu`: plán, pravidla projektu, zadání, kritéria; pro `kontrola-auditu`: plán, pravidla projektu, nejpodobnější hotový kód a navazující úkoly.

## 3. Práh a agenti
Spočítej otevřené úkoly (`- [ ]`).
- **Do 3 úkolů:** spusť jen agenta `honzapowers:kontrola-souladu`.
- **Víc než 3:** spusť `honzapowers:kontrola-souladu` a `honzapowers:kontrola-auditu` **paralelně** v jedné odpovědi.

Agentům předej seznam čtení z kroku 2 a jednu větu, co plán dělá, ne obsah souborů. Každý vrátí nejvýš 5 nálezů s košem `OPRAVIT|ZEPTAT|ZAMÍTNOUT`, závažností `kritický|ostatní`, značkou `OVĚŘENO` (s místem a citací) nebo `DOMNĚNKA`, místem v plánu a důvodem v jedné větě.

Kdyby se agenti nenačetli (plugin není aktivní), spusť obecného subagenta na modelu sonnet a jako zadání mu dej tělo souboru agenta.

## 4. Roztřídění
Sluč nálezy obou agentů, odstraň duplicity a rozhodni o koších sám (agent jen navrhuje):
- **OPRAVIT:** oprava je jednoznačná a leží v plánu. Oprav ji hned.
- **ZEPTAT:** mění dřívější rozhodnutí uživatele, je volbou mezi dvěma správnými řešeními, nebo chybí údaj, který zná jen uživatel. Všechny otázky polož **najednou**, každou s navrženou výchozí odpovědí a jednou větou proč.
- **ZAMÍTNOUT:** nález neplatí nebo se míjí se zadáním. Napiš jednou větou proč.

Ověřování šetří kontext: kritické nálezy a `DOMNĚNKY` si ověř přečtením citovaného místa, `OVĚŘENÉ` ostatní přijmi bez čtení, pokud citace sedí s plánem. Při rozporu agentů má fakt ze zadání nebo ze kódu přednost před úsporností. Text do plánu píšeš ty, ne agent.

## 5. Druhé kolo
Jen když oprava **kritického** nálezu změnila rozhraní, pořadí úkolů nebo rozsah: spusť ještě jednou samotného `honzapowers:kontrola-souladu`, který čte jen `git diff` plánu (nejvýš 5 nálezů). Jinak žádné druhé kolo.

## 6. Poučení pro další plány
Navrhni jen pravidlo, které bude platit pro aspoň dva budoucí plány. Pořadí:
1. Dá se vynutit kódem, testem nebo hookem? Pak navrhni úkol, ne text pravidla.
2. Jinak pravidlo jako **unified diff** proti `.claude/kontrola-planu.md` projektu, ke schválení. Nejdřív slouč nebo nahraď existující bod; má-li soubor víc než 15 bodů, navrhni napřed prořezání.

Dál platí:
- nic nezapisuj bez souhlasu uživatele;
- nikdy neupravuj plugin ani `policy/policy.md`;
- nezapisuj pravidlo, které už hlídá kód, test nebo hook;
- chybí-li `.claude/kontrola-planu.md`, nabídni jeho založení **vždy**, i když jsi žádné opakovatelné pravidlo nenašel (pak nabídni prázdný soubor s hlavičkou); nezakládej ho sám;
- nepředepisuj pevný příkaz projektu (např. testovací), jen že plán má ověřovací příkaz uvést.

## 7. Uzávěr
Do plánu přidej řádek `**Stav:** kontrola <datum>: N nálezů, opraveno X, otázky Y, zamítnuto Z.` Pak napiš uživateli nejvýš 6 řádků: počty nálezů po koších, co jsi opravil, na co čekáš (otázky), zda proběhlo druhé kolo, návrh poučení a, chybí-li soubor kritérií, nabídka jeho založení (povinně).
