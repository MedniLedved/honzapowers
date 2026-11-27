# Doplňkové pluginy – plán

> **Pro prováděcího agenta:** inline `superpowers:executing-plans` (S1, 4 úkoly). Kroky mají checkboxy. Fáze 2 je na uživateli; fáze 3 začne až po jejích výsledcích.

**Cíl:** Převzít do HP dva levné nápady z rešerše doplňkových pluginů, ověřit dva oficiální pluginy v praxi a výsledek zapsat do `docs/pouziti.md` jako doporučení vedle HP.

**Přístup:** Žádná nová komponenta. Fáze 1 upraví text dvou existujících skillů (`pre-done`, `retro`). Fáze 2 je měřený pokus uživatele s pluginy `claude-md-management` a `hookify`, měřený přes `session-metrics` (řádek `Context tokens: first`). Fáze 3 zapíše do `docs/pouziti.md` jen ověřené verdikty.

**Zdroj:** rešerše doplňkových pluginů v této konverzaci (části A a B).

**Stav:** kontrola 2026-11-27: 7 nálezů (po sloučení), opraveno 6, otázky 0, zamítnuto 1; druhé kolo: 3 nálezy, opraveno 3.

## Globální omezení
- `policy/policy.md` se nemění (max 3 200 znaků, výchozí policy mění jen ručně vydaná verze).
- AI-facing text (skilly) anglicky; `docs/`, CHANGELOG česky.
- Skill nevynucuje pevný příkaz projektu; hookify je jen volitelná varianta.
- Tělo skillu nejvýš 900 slov (test v `tests/test-components.sh:22-23`).
- Žádná data z konkrétních projektů ani uživatelů; v docs žádná převzatá čísla instalací.
- Instalace pluginu je na uživateli (claude.ai → Customize → Plugins), ne v tomto plánu.
- `bash tests/run-tests.sh` ⇒ `ALL PASS` a `claude plugin validate --strict .` před pushem.
- Vydání verze není součástí plánu (postup `docs/vydani.md`, ručně).

## Review Focus
- `pre-done` s novým zaměřením: odpověď revizora zůstává nejvýš 20 řádků.
- `retro` bez nainstalovaného hookify: návrh na příčce `hard` zůstává hook nebo skript, hookify se nenabízí.
- Plugin se v cloudové session nenačte: verdikt `jen lokálně`, ne chyba plánu.
- Pokus s hookify nesmí spustit nic destruktivního: testovací vzor je neškodný `echo`.
- Docs uvádějí jen to, co pokus ověřil; neověřené zůstává „nevyzkoušeno“.

## Co do plánu nepatří (rozhodnuto v rešerši)
- Kontrolní seznam `spectre-plan_review`: existenci souborů a příkazů už kontroluje `agents/kontrola-souladu.md:13`, zbytečnou práci `agents/kontrola-auditu.md:12`.
- Hooky komprimující výstup (compressor, RTK, token-optimizer): pokrývá je L3 a `log-reader`; vlastní benchmark compressoru ukazuje u kódu ztrátu.
- `claude-mem`, `context-mode`: zdvojují vkládání kontextu na startu session a PreCompact.
- Samoučící pluginy (claude-smart a podobné): mění pravidla bez souhlasu.
- Revize plánu druhým modelem (Codex, Gemini): potřebuje další účet nebo klíč (G1, L6).
- `episodic-memory`, `claude-hud`: fungují jen lokálně; ve fázi 3 jen zmínka, bez pokusu.
- `plugin-dev`, `skill-creator`: HP už má `claude plugin eval` a případy v `evals/`; nic nepřidávají.
- `code-review`, `pr-review-toolkit`: z nich je převzaté jen zaměření revizora (Task 1); ve fázi 3 zmínka „nevyzkoušeno“.

---

## Fáze 1 – úpravy HP

### Task 1: Zaměření revizora v `pre-done`

**Files:**
- Modify: `skills/pre-done/SKILL.md` (sekce `## 2. Review in a fresh context`, za větu „It must not edit.“)
- Test: `tests/test-components.sh` (za řádek 32)

**Interfaces:** nic dalšího nepotřebuje ani neposkytuje.

- [x] **Step 1: Test.** Za řádek 32 přidat: `grep -qi 'silent failure' "$REPO_ROOT/skills/pre-done/SKILL.md" && grep -qi 'no test exercises' "$REPO_ROOT/skills/pre-done/SKILL.md" && pass "pre-done: reviewer focus" || fail "pre-done: no reviewer focus"`.
- [x] **Step 2:** `bash tests/test-components.sh` ⇒ `FAIL pre-done: no reviewer focus`.
- [x] **Step 3: Text.** Za „It must not edit.“ vložit větu: `Ask it to look first for silent failures (a swallowed error, a broad catch, a fallback that hides a failure) and for changed behaviour that no test exercises; this adds no lines to its answer.`
- [x] **Step 4:** `bash tests/test-components.sh` ⇒ `PASS pre-done: reviewer focus`, žádný FAIL.
- [x] **Step 5: Commit** `feat(pre-done): revizor hledá tiché chyby a nepokryté chování` (+ řádek do `CHANGELOG.md` → `## Nepublikováno`, sekci vytvořit nad poslední verzí, pokud chybí).

### Task 2: Hookify jako volitelná podoba příčky `hard` v `retro`

**Files:**
- Modify: `skills/retro/SKILL.md` (odrážka **Rung** v `## 2. Findings`)
- Test: `tests/test-components.sh` (za test z Task 1)

**Interfaces:** nic dalšího nepotřebuje ani neposkytuje.

- [x] **Step 1: Test.** `grep -q 'hookify' "$REPO_ROOT/skills/retro/SKILL.md" && grep -qi 'only if .*hookify' "$REPO_ROOT/skills/retro/SKILL.md" && pass "retro: hookify optional" || fail "retro: no optional hookify"`.
- [x] **Step 2:** `bash tests/test-components.sh` ⇒ `FAIL retro: no optional hookify`.
- [x] **Step 3: Text.** V odrážce **Rung** nahradit `` `hard` (hook, deny rule or script, 0 context tokens) `` za `` `hard` (hook, deny rule or script, 0 context tokens; a hookify rule only if the hookify plugin is installed) ``.
- [x] **Step 4:** `bash tests/run-tests.sh` ⇒ `ALL PASS` (včetně rozpočtu 900 slov) a `claude plugin validate --strict .` bez chyby.
- [x] **Step 5: Commit** `feat(retro): hookify jako volitelná podoba tvrdého pravidla` (+ řádek do `CHANGELOG.md` → `## Nepublikováno`, sekci vytvořit, pokud chybí). Push na pracovní větev (draft PR #12 už existuje).

## Fáze 2 – pokus (uživatel; brána: pokračovat až po výsledcích)

### Task 3: Změřit `claude-md-management` a `hookify`

**Files:**
- Modify: tento plán, nová sekce `## Výsledky pokusu` na konci

**Interfaces:**
- Produces: tabulka `plugin | funguje v cloudu | funguje v terminálu | Context tokens: first (bez / s) | verdikt`, kterou čte Task 4.

Prostředí: povinně cloudová session (claude.ai/code) v repu HP; terminál volitelně. Co se nezměří, má v tabulce `nevyzkoušeno`; to platí i pro `retro`, které hodnotu `Context tokens: first` nevypíše.

- [ ] **Step 1: Základ (uživatel).** Dvě nové session bez obou pluginů, v každé první zpráva `Jaká pravidla máš na začátku session?`, pak `retro` ⇒ zapsat obě hodnoty `Context tokens: first` a jejich průměr.
- [ ] **Step 2: Instalace (uživatel).** claude.ai → Customize → Plugins → oficiální marketplace → zapnout `claude-md-management` a `hookify`. Pluginy se načtou až v nové session.
- [ ] **Step 3: S pluginy.** Dvě **nové** session, stejná první zpráva, `retro` ⇒ zapsat obě hodnoty a průměr.
- [ ] **Step 4: claude-md-improver.** Zadat `audit my CLAUDE.md files` ⇒ zapsat, zda najde a ohodnotí `AGENTS.md` (HP nemá CLAUDE.md). Žádnou navrženou změnu nepřijímat.
- [ ] **Step 5: `/revise-claude-md`.** Spustit jednou na konci session ⇒ zapsat, kam navrhuje zapisovat a jestli se překrývá s `handover`. Žádnou změnu nepřijímat.
- [ ] **Step 6: hookify.** Zadat `/hookify warn when a Bash command contains echo hookify-test`, pak spustit `echo hookify-test` ⇒ zapsat, zda se varování objevilo a jakou cestu má soubor pravidla (`git status --short`). Pravidlo odstranit (`/hookify:list`, smazat soubor) a `git status --short --ignored` ⇒ soubor pravidla tam není.
- [ ] **Step 7: Verdikt** pro každý plugin: `doporučeno` (funguje a průměr `Context tokens: first` vzroste nejvýš o 2k), `jen lokálně`, nebo `nedoporučeno` (s důvodem). Commit jen tohoto plánu (`git add docs/plans/2026-11-27-doplnkove-pluginy.md`).

## Fáze 3 – doporučení v docs

### Task 4: Sekce „Doplňkové pluginy“ v `docs/pouziti.md`

**Files:**
- Modify: `docs/pouziti.md` (nová sekce před `## Co plugin nedělá`), `CHANGELOG.md`
- Test: `tests/test-components.sh` (za test `pouziti: S3 reserved note`)

**Interfaces:**
- Consumes: tabulka z Task 3.

- [ ] **Step 1: Test.** `grep -q '^## Doplňkové pluginy' "$REPO_ROOT/docs/pouziti.md" && grep -q 'claude-md-management' "$REPO_ROOT/docs/pouziti.md" && pass "pouziti: companion plugins" || fail "pouziti: no companion plugins"`.
- [ ] **Step 2:** `bash tests/test-components.sh` ⇒ `FAIL pouziti: no companion plugins`.
- [ ] **Step 3: Text (česky).** Tabulka `Plugin | K čemu vedle HP | Kde funguje | Verdikt` s řádky `claude-md-management`, `hookify`, `pr-review-toolkit` (nevyzkoušeno; alternativa revizora `pre-done`, víc agentů = víc tokenů), `episodic-memory` a `claude-hud` (jen lokálně, nevyzkoušeno). Pod ní odstavec „Nedoporučujeme“ (claude-mem, context-mode, samoučící pluginy) s důvody ze sekce „Co do plánu nepatří“. U `claude-md-management` jedna věta o vztahu `/revise-claude-md` a `handover` podle Task 3 Step 5 (bez výsledku věta odpadá).
- [ ] **Step 4:** `bash tests/run-tests.sh` ⇒ `ALL PASS`.
- [ ] **Step 5: Commit** `docs(pouziti): doplňkové pluginy podle pokusu` (+ řádek do `CHANGELOG.md` → `## Nepublikováno`, sekci vytvořit, pokud chybí), push na pracovní větev.
