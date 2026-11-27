# Handover 2026-11-27: přednost pravidel, připnutí, pokus s lehkou revizí

## 1. Identita a cíl
- Repo `MedniLedved/honzapowers` (plugin), větev `claude/funny-turing-jovzro`, cloudová session.
- Zdroj: porovnání HP s cizím nastavením práce (osm návrhů pro HP). Uživatel vybral body 1–4, bod 5 (práh nudge podle okna) vynechal.
- Uživatel chce práci po fázích: plán fází, pak jen jednu fázi s ověřením, další až po jeho potvrzení. Komunikace česky, tykání. `claude` CLI nespouští (jen git a web).

Fáze:
1. Plán bodů 1–3 a kontrola plánu – **hotovo**.
2. Provedení bodů 1–3 v HP, PR – **hotovo, čeká na merge**.
3. Pokus s lehkou revizí v `honzapowers-osobni` s automatickým vyhodnocením – **další krok**.
4. Vydání HP 0.6.0 (tag přes web GitHubu) – po merge PR #13.

## 2. Hotovo v této session
- Plán `docs/plans/2026-11-27-prednost-pripnuti-opravy.md`, kontrola: 8 nálezů, opraveno 7, zamítnut 1 (commit `ca9544a`).
- PR https://github.com/MedniLedved/honzapowers/pull/13 (draft), 5 commitů `6de4252..7a33f67`:
  - policy řádek 1: projekt > uživatelův `~/.claude/CLAUDE.md` a osobní pravidla > výchozí policy (2 584 z 3 200 znaků); `docs/pouziti.md` stejně;
  - README `### Připnutá verze` (`/plugin marketplace add MedniLedved/honzapowers#honzapowers--vX.Y.Z`); `docs/vydani.md` krok 4: tag přes Releases, git nebo `claude plugin tag --push`;
  - `skills/pre-done/SKILL.md`: opravy nálezů přes test, commit na opravu, nejvýš jedna opakovaná revize;
  - `.claude/kontrola-planu.md` bod 2 (doslovné fráze, žádný odkaz na budoucí tag).
- Důkaz: `bash tests/run-tests.sh` ⇒ `ALL PASS`; `claude plugin validate --strict .` ⇒ `Validation passed`; CI na `7a33f67` zelené (validate, hooks ubuntu, hooks windows), `mergeable_state: clean`.
- Revize celé větve v čistém kontextu (Sonnet): žádný Critical ani Important.

## 3. Rozhodnutí
- Bod 4 (lehká revize i u ohraničených změn kódu) **ne do výchozí policy**, ale jako pokus do osobní vrstvy, který se sám vyhodnotí (důvod: výchozí policy se mění jen vydanou verzí; přínos zatím není změřený).
- Bod 5 vynechán: uživatel pracuje s velkým oknem.
- Připnutí na claude.ai není ověřené; README tam nabízí fork.
- Tag má tvar `honzapowers--vX.Y.Z` (shodný s `claude plugin tag`); dosud v repu žádný tag není.
- Ruling při provádění: testy úkolů 1–3 přidány najednou v prvním commitu (jeden běh sady místo tří).
- Odložené drobnosti: `/plugin marketplace remove` v README není výslovně ověřený v dokumentaci; test tagu jen hledá řetězce.

## 4. Otevřené a brány
- **PR #13:** přepnout z draftu na „Ready for review“ a mergnout – dělá uživatel.
- **Vydání 0.6.0 (fáze 4):** zvýšit verzi v `plugin.json` a `marketplace.json`, CHANGELOG, PR; po merge tag `honzapowers--v0.6.0` přes Releases. Push tagu je nevratný – brána.
- **Fáze 3, návrh zatím bez souhlasu uživatele** (potvrdit na začátku):
  - pravidlo v `pravidla.md` osobního pluginu (limit 800 znaků, dnes ~280): u ohraničené změny kódu proběhne `pre-done` v lehkém režimu (jen kroky 1, 2 a 4, Sonnet, nejvýš 10 řádků, bez UI průchodu);
  - každá lehká revize přidá jeden řádek do `docs/retro/pokus-lehka-revize.md` projektu (datum, úkol, počet Critical/Important/Minor, opraveno);
  - při 10. řádku nebo po 2026-12-31 Claude pokus sám vyhodnotí a navrhne ponechat (přesun do HP vydanou verzí) nebo zrušit; nic nemění sám.
  - Otevřená otázka: má počítat řádky hook osobního pluginu (deterministicky), nebo stačí pravidlo? Výchozí: jen pravidlo (osobní hook se nemění, šablona zůstává shodná).
- Repo `MedniLedved/honzapowers-osobni` (soukromé) je dostupné přes `add_repo`; práce tam na vlastní větvi s PR.
- Starý plán `docs/plans/2026-11-25-kandidati-na-poznatek.md` má 23 nezaškrtnutých úkolů, ačkoli 0.5.0 je vydaná; hook ho dosud ukazoval jako „Next step“. Zaškrtnout nebo označit hotový – navrhnout uživateli.

## 5. Další krok
Přidat repo `MedniLedved/honzapowers-osobni`, přečíst `pravidla.md`, `hooks/session-start`, `tests/test-osobni.sh`, nechat uživatele potvrdit návrh fáze 3 (bod 4 výše), pak plán a `kontrola-planu`. Ověření: `bash tests/run-tests.sh` v osobním repu ⇒ zelené.

Věta pro novou session:
> Pokračuj fází 3 podle `docs/handover/2026-11-27-prednost-pripnuti-pokus.md` (pokus s lehkou revizí v honzapowers-osobni). Pracuj na větvi claude/funny-turing-jovzro, push tam máš povolený.

## 6. Soubory a pořadí čtení
1. Tento soubor, § 4 a § 5.
2. `skills/pre-done/SKILL.md` (kroky 1–4).
3. `docs/pouziti.md`, sekce „Na které úrovni pravidla platí“.
4. V osobním repu: `pravidla.md`, `hooks/session-start`, `tests/test-osobni.sh`.

## 7. Krátké retro
- Kontext 95k → 188k (+93k) za 50 odpovědí; cache reads 97 %.
- Opakované běhy Bash 0, opakované testy bez změny 0, celé čtení souborů nad 300 řádků 0.
- Největší výstupy: Bash 27 kB (výpis osobního hooku), notifikace 22,9 kB (dvakrát stejná pravidla odběru PR).
- Nález 1: session se obnovila po pauze s ~155k a prošlou cache (přepis ~1,24 $); handover přišel až po fázi 2. Pravidlo `L10`, třída `one-off` (uživatel výslovně chtěl pokračovat).
- Nález 2: `docs/vydani.md` předepisoval `claude plugin tag`, který uživatel bez CLI nespustí, a proto nevznikl žádný tag (`git tag` prázdné). Opraveno v PR #13; třída `project`.

**Lessons:**
- Spouštěč: commit přes `git commit -m "předmět$T"`, kde `T` začíná jen jedním `\n` → trailery `Co-Authored-By` skončí v řádku předmětu (`git log --oneline` je ukázal). Oprava: `T=$'\n\nCo-Authored-By: …'` (prázdný řádek před trailery). Důkaz: `git log --oneline -2` před opravou a `git log -1 --format=%B | tail -3` po ní. Třída `general`, `candidate` (nepotvrzeno ve druhém projektu).
