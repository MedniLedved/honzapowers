# Doplňkové pluginy, část 2 – plán

> **Pro prováděcího agenta:** inline `superpowers:executing-plans` (S1, 3 úkoly). Kroky mají checkboxy. Každý task má pokus uživatele a za ním bránu: kroky v docs začnou až po zapsaných výsledcích.

**Cíl:** Změřit, proč `hookify` v cloudové session nevyvolal varování, ověřit nativní podobu příčky `hard` (hook a `permissions.deny` z `.claude/settings.json` repa) a podle naměřeného upřesnit `docs/pouziti.md`; souběžný test `pre-done` proti `pr-review-toolkit` jen se souhlasem uživatele.

**Přístup:** Žádná nová komponenta ani vlastní engine pravidel. Pokusy dělá uživatel v cloudové session (claude.ai/code) nebo v desktopové aplikaci, bez `claude` CLI v terminálu. Výsledky jdou do sekce `## Výsledky pokusu` tohoto plánu (zvláštní commit), teprve potom se mění docs, případně jedna věta v `skills/retro/SKILL.md`.

**Zdroj:** výsledky plánu `docs/plans/2026-11-27-doplnkove-pluginy.md` (sekce `## Výsledky pokusu`, ř. 110–129) a nové zjištění: v cloudové session se hookify nabízí jako skilly `hookify:hookify`, `hookify:list`, `hookify:configure`, `hookify:help`, `hookify:writing-rules` a agent `hookify:conversation-analyzer`. Hypotéza: plugin se načítá, volá se jako skill / `/hookify:hookify` (ne `/hookify`) a vyhodnocení pravidla hookem je samostatná otázka. Příčina minulého neúspěchu nebyla změřena (L9).

**Stav provedení:** hotovo

**Stav:** kontrola 2026-11-27: 4 nálezy (po sloučení), opraveno 4, otázky 0, zamítnuto 0.

## Globální omezení
- `policy/policy.md` se nemění; verze se nevydává (postup `docs/vydani.md`, ručně).
- AI-facing text (skilly) anglicky; plán, `docs/`, `CHANGELOG.md` česky.
- Skill nevynucuje pevný příkaz projektu; hookify i `.claude/settings.json` zůstávají volitelné varianty.
- Tělo skillu nejvýš 900 slov (test `tests/test-components.sh:22-23`); `retro` má teď 552 slov.
- Žádná data z konkrétních projektů ani uživatelů; testovací vzory jsou vymyšlené (`hookify-test`, `hook-rule-test`, `deny-rule-test`).
- Pokusné session nic necommitují a neotevírají PR: na otázku agenta o commitu, pushi nebo PR odpovědět **ne**. Commit výsledků dělá až prováděcí session (`git add` jen tohoto plánu).
- Nic z pokusu neskončí v `main`: pokusné větve `pokus/*` se po zkoušce smažou, bez PR.
- `bash tests/run-tests.sh` ⇒ `ALL PASS` a `claude plugin validate --strict .` před pushem (validaci spouští i CI). Hotový krok se odškrtne ve stejném commitu; commity výsledků (Task 1 Step 8, Task 2 Step 5, Task 3 Step 5) odškrtnou kroky, které už proběhly, a koncový commit tasku zbylé. Přeskočený krok (Task 3 při „ne“) se odškrtne s poznámkou „přeskočeno (bez souhlasu)“.

## Review Focus
- Pokus nesmí spustit nic destruktivního: vzory jsou jen neškodné `echo`, hook nic nemaže a nesahá na síť.
- Verdikty jen z naměřeného: co se nezměřilo, zůstává v docs „nevyzkoušeno“, příčina bez důkazu je „nezměřena“.
- Soubor pravidla hookify ani `.claude/settings.json` z pokusu nezůstane v pracovním stromu ani v `main` (`git status --short --ignored` bez nich; větev `pokus/*` smazána).
- `retro` bez hookify a bez `.claude/settings.json` dál navrhuje na příčce `hard` hook, deny pravidlo nebo skript; test `retro: hookify optional` (`tests/test-components.sh:34`) dál prochází.
- Upravené docs neuvádějí pevný příkaz projektu a nová věta v `retro` nepřekročí 900 slov.

## Co do plánu nepatří (rozhodnuto v rešerši, beze změny)
- `claude-mem`, `context-mode`, samoučící pluginy, hooky komprimující výstup, revize plánu druhým modelem (G1, L6).
- Vlastní engine pravidel v HP (náhrada hookify): příčka `hard` už má hook, deny pravidlo nebo skript.
- Pokus s `episodic-memory` a `claude-hud`: fungují jen lokálně; jen upřesnění věty (Task 3).
- Změna `hooks/hooks.json` HP: plán zkouší hook projektu v `.claude/settings.json`, ne hook pluginu.
- Úprava `.gitignore` v `main`: doporučení `.claude/*.local.md` zůstává jen v docs (věta o `.gitignore` v `docs/pouziti.md`).

---

## Fáze 1 – příčina hookify v cloudu

### Task 1: Změřit hookify a opravit jeho řádek v docs

**Files:**
- Modify: tento plán (sekce `## Výsledky pokusu` na konci, tabulka hookify)
- Modify: `docs/pouziti.md:49` (řádek `hookify` v tabulce), `CHANGELOG.md` (`## Nepublikováno`)
- Test: `tests/test-components.sh` (za řádek 110, test `pouziti: companion plugins`)

**Interfaces:**
- Produces: tabulka `krok | výsledek | důkaz (citace výstupu)` a verdikt `funguje v cloudu` / `v cloudu nefunguje: <příčina>` / `v cloudu nefunguje (příčina nezměřena)`; čte ji Step 9 a Task 2 Step 1.

Prostředí: nová cloudová session v repu HP na `main`, hookify zapnutý (claude.ai → Customize → Plugins).

- [x] **Step 1: Zapnutí (uživatel).** Ověřit v claude.ai → Customize → Plugins, že je `hookify` zapnutý. V nové session zadat `Which hookify skills, agents and commands do you have? Do not run any of them.` ⇒ zapsat seznam.
- [x] **Step 2: Registrace hooku (uživatel).** Zadat `Find hookify's hooks/hooks.json under ~/.claude/plugins, show which hook events it registers and the command it runs, and run "python3 --version". Read only, change nothing.` ⇒ zapsat události (např. `PreToolUse`), příkaz a zda `python3` existuje.
- [x] **Step 3: Volání jako skill (uživatel).** Zadat `/hookify:hookify warn when a Bash command contains echo hookify-test`. Když příkaz neexistuje, zadat `Use the hookify:hookify skill to create a warn rule for Bash commands containing echo hookify-test.` ⇒ zapsat, která cesta skill spustila. Otázky na commit, push nebo PR: **ne**.
- [x] **Step 4: Soubor pravidla (uživatel).** `git status --short --ignored` a `/hookify:list` ⇒ zapsat cestu souboru (očekávaně `.claude/hookify.*.local.md`) a zda je pravidlo `enabled`.
- [x] **Step 5: Spuštění (uživatel).** V téže session zadat `Run: echo hookify-test` ⇒ zapsat, zda se objevilo varování hookify (citovat text).
- [x] **Step 6: Úklid (uživatel).** Smazat soubor pravidla, `git status --short --ignored` ⇒ soubor tam není, pracovní strom čistý. Session zavřít bez commitu. *(nepotvrzeno, viz výsledky)*
- [x] **Step 7: Verdikt** do `## Výsledky pokusu`: `funguje v cloudu` (varování v Step 5), jinak `v cloudu nefunguje` s příčinou podle Step 1–4 (plugin nezapnutý / hook neregistrovaný / chybí `python3` / pravidlo nevzniklo nebo je `disabled`), nebo `příčina nezměřena`.
- [x] **Step 8: Commit výsledků** (prováděcí session): `git add docs/plans/2026-11-27-doplnkove-pluginy-cast-2.md`, `docs(plans): výsledky pokusu hookify v cloudu`. **Brána:** Step 9 až po tomto commitu.
- [x] **Step 9: Test.** Za řádek 110 přidat: ``grep -q '^| `hookify` .*\(funguje v cloudu\|v cloudu nefunguje\)' "$REPO_ROOT/docs/pouziti.md" && ! grep -q '^| `hookify` .*| jen lokálně |' "$REPO_ROOT/docs/pouziti.md" && pass "pouziti: hookify verdict measured" || fail "pouziti: hookify verdict not measured"``.
- [x] **Step 10:** `bash tests/test-components.sh` ⇒ `FAIL pouziti: hookify verdict not measured`.
- [x] **Step 11: Text (česky).** Řádek `hookify` v `docs/pouziti.md:49`: sloupec „Kde funguje“ podle Step 7 (v cloudu se volá `/hookify:hookify`, pokud to Step 3 ukázal; terminál: nevyzkoušeno), sloupec „Verdikt“ = verdikt ze Step 7 (bez důkazu „v cloudu nefunguje (příčina nezměřena), lokálně nevyzkoušeno“).
- [x] **Step 12:** `bash tests/run-tests.sh` ⇒ `ALL PASS`.
- [x] **Step 13: Commit** `docs(pouziti): verdikt hookify v cloudu podle měření` (+ řádek do `CHANGELOG.md` → `## Nepublikováno`).

## Fáze 2 – příčka `hard` bez pluginu

### Task 2: Ověřit hook a `permissions.deny` z `.claude/settings.json` v cloudu

**Files:**
- Modify: tento plán (`## Výsledky pokusu`, tabulka `prostředek | spuštěno | důkaz`)
- Modify: `docs/pouziti.md` (nový odstavec v `## Doplňkové pluginy` za odstavcem začínajícím `Pokud pravidla hookify zkoušíš lokálně`), `CHANGELOG.md`
- Modify (jen pokud aspoň jeden prostředek v cloudu funguje): `skills/retro/SKILL.md:26` (odrážka **Rung**)
- Test: `tests/test-components.sh` (za test z Task 1)

**Interfaces:**
- Consumes: verdikt Task 1 (věta v docs ho porovná).
- Produces: výsledek `hook: ano/ne`, `deny: ano/ne` pro Step 9–11.

Pokusná větev: `.claude/` v repu má dnes jen `kontrola-planu.md`; `.claude/settings.json` neexistuje. Soubor se proto zkouší na větvi `pokus/hard-rule-test`, ne v `main`.

- [x] **Step 1: Pokusná větev (prováděcí session, jen po výslovném souhlasu uživatele s pushem mimo pracovní větev).** Z `main` vytvořit `pokus/hard-rule-test` s jediným novým souborem `.claude/settings.json` a pushnout ji, **bez PR**:

```json
{
  "permissions": { "deny": ["Bash(echo deny-rule-test:*)"] },
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash",
        "hooks": [ { "type": "command",
          "command": "grep -q 'hook-rule-test' && { echo 'hard-rule-test: blocked by project hook' >&2; exit 2; } || exit 0" } ] }
    ]
  }
}
```

- [x] **Step 2: Hook (uživatel).** Nová cloudová session na větvi `pokus/hard-rule-test`. Zadat `Run: echo hook-rule-test` ⇒ zapsat, zda byl příkaz zablokován s textem `blocked by project hook`. Na otázky o commitu nebo PR: **ne**.
- [x] **Step 3: Deny (uživatel).** V téže session `Run: echo deny-rule-test` ⇒ zapsat, zda byl příkaz odmítnut pravidlem oprávnění (citovat hlášku). Kontrola: `Run: echo neutral-test` proběhne.
- [x] **Step 4: Úklid.** Session zavřít; větev `pokus/hard-rule-test` smazat na GitHubu (Branches → Delete) ⇒ v seznamu větví není a `main` nemá `.claude/settings.json` (`git ls-tree main .claude/` ukáže jen `kontrola-planu.md`). *(větev smazána, `git ls-remote --heads origin 'pokus/*'` je prázdné)*
- [x] **Step 5: Verdikt a commit výsledků:** `docs(plans): výsledky pokusu s nativním hard pravidlem` (`git add` jen tohoto plánu). **Brána:** Step 6 až po tomto commitu.
- [x] **Step 6: Test.** Za test z Task 1: `grep -q '\.claude/settings.json' "$REPO_ROOT/docs/pouziti.md" && grep -q 'permissions.deny' "$REPO_ROOT/docs/pouziti.md" && pass "pouziti: native hard rule" || fail "pouziti: no native hard rule"`. Pokud se mění `retro`, přidat i `grep -q 'cloud session.*settings.json' "$REPO_ROOT/skills/retro/SKILL.md" && pass "retro: native hard rule in cloud" || fail "retro: no native hard rule note"`.
- [x] **Step 7:** `bash tests/test-components.sh` ⇒ nové testy `FAIL`.
- [x] **Step 8: Text docs (česky).** V `docs/pouziti.md` za odstavcem začínajícím `Pokud pravidla hookify zkoušíš lokálně` odstavec „Tvrdé pravidlo bez pluginu“: hook a `permissions.deny` v `.claude/settings.json` repa, u každého naměřený výsledek z cloudu (Step 2–3; neměřené „nevyzkoušeno“), jedna věta srovnání s hookify podle Task 1. Bez pevného příkazu projektu.
- [x] **Step 9: Text retro (anglicky, jen při `ano` v Step 2 nebo 3).** V odrážce **Rung** za `a hookify rule only if the hookify plugin is installed` doplnit `; in a cloud session, a hook or deny rule in the repo's .claude/settings.json` jen pro prostředek, který fungoval. Fráze `only if the hookify plugin is installed` zůstává (test ř. 34).
- [x] **Step 10:** `bash tests/run-tests.sh` ⇒ `ALL PASS` (včetně 900 slov) a `claude plugin validate --strict .` bez chyby (nebo zelené CI na pracovní větvi).
- [x] **Step 11: Commit** `docs(pouziti): tvrdé pravidlo přes .claude/settings.json podle pokusu` (při změně `retro`: `feat(retro): nativní tvrdé pravidlo v cloudu`) + řádek do `CHANGELOG.md` → `## Nepublikováno`.

## Fáze 3 – revize a lokální pluginy

### Task 3: Volitelný test `pre-done` proti `pr-review-toolkit`; věta o `episodic-memory` a `claude-hud`

**Files:**
- Modify: tento plán (`## Výsledky pokusu`, jen při souhlasu)
- Modify: `docs/pouziti.md` (řádky `pr-review-toolkit`, `episodic-memory`, `claude-hud` v tabulce `## Doplňkové pluginy`), `CHANGELOG.md`
- Test: `tests/test-components.sh` (za test z Task 2)

**Interfaces:**
- Produces: tabulka `revize | nálezy (Critical/Important/Minor) | zachycená vložená chyba | Context tokens: first / max` (jen při souhlasu).

- [x] **Step 1: Brána (uživatel).** Zeptat se: „Chcete souběžný test `pre-done` proti `pr-review-toolkit`?“ Při **ne** přeskočit na Step 6; řádek `pr-review-toolkit` zůstane „nevyzkoušeno“.
- [x] **Step 2: Diff.** Větev `pokus/review-test` z `main` (push mimo pracovní větev jen po výslovném souhlasu uživatele) s jedním vymyšleným souborem `pokus/review.sh` (~10 řádků) s vloženou tichou chybou (`cmd || true` spolkne selhání) a bez testu; push, **bez PR**.
- [x] **Step 3: Dvě session (uživatel).** Dvě nové cloudové session na `pokus/review-test`, `pr-review-toolkit` zapnutý jen pro druhou. V první `Run pre-done on the diff against main.`, ve druhé `/pr-review-toolkit:review-pr`; v obou pak `retro` ⇒ zapsat počty nálezů, zda chytila `|| true`, a řádek `Context tokens` (`scripts/session-metrics:167`). Žádný nález neopravovat; otázky o commitu/PR: **ne**. Tokeny podagentů, které `retro` nevypíše: „nezměřeno“.
- [x] **Step 4: Úklid.** Smazat větev `pokus/review-test` na GitHubu; `main` nemá `pokus/`.
- [x] **Step 5: Commit výsledků** `docs(plans): výsledky souběžné revize` (jen tento plán). **Brána:** Step 6 až po tomto commitu.
- [x] **Step 6: Test.** `grep -q 'zaplnění kontextu' "$REPO_ROOT/docs/pouziti.md" && grep -q 'překrývá se s `handover`' "$REPO_ROOT/docs/pouziti.md" && pass "pouziti: claude-hud context fill" || fail "pouziti: no claude-hud context fill"`.
- [x] **Step 7:** `bash tests/test-components.sh` ⇒ `FAIL pouziti: no claude-hud context fill`.
- [x] **Step 8: Text (česky).** Řádek `claude-hud`: „ukazuje zaplnění kontextu; hodí se jen při lokální práci“. Řádek `episodic-memory`: doplnit „překrývá se s `handover`“. Řádek `pr-review-toolkit`: při testu naměřené výsledky ze Step 3 místo odhadu „víc agentů znamená víc tokenů“, jinak beze změny.
- [x] **Step 9:** `bash tests/run-tests.sh` ⇒ `ALL PASS`.
- [x] **Step 10: Commit** `docs(pouziti): upřesnění lokálních pluginů a revize` (+ řádek do `CHANGELOG.md` → `## Nepublikováno`), push na pracovní větev. Plán označit `**Stav provedení:** hotovo` v tomto commitu.

## Výsledky pokusu

(Doplní Task 1 Step 7, Task 2 Step 5 a Task 3 Step 5.)

### Task 1: hookify v cloudové session (2026-11-27)

| krok | výsledek | důkaz |
|---|---|---|
| 1 Zapnutí | skilly `hookify:hookify`, `:configure`, `:list`, `:help`, `:writing-rules`; agent `hookify:conversation-analyzer`; samostatné commands žádné | „Samostatné commands: žádné zvlášť nevidím“ |
| 2 Registrace hooku | registrované `PreToolUse`, `PostToolUse`, `Stop`, `UserPromptSubmit`, vše `python3 "${CLAUDE_PLUGIN_ROOT}/hooks/<událost>.py"`, timeout 10; `python3` existuje | `Python 3.13.18` |
| 3 Volání | `/hookify:hookify warn when …` fungovalo jako skill (přes `hookify:writing-rules`), pravidlo vzniklo | „Vytvořeno: .claude/hookify.warn-echo-hookify-test.local.md“ |
| 4 Soubor pravidla | `.claude/hookify.warn-echo-hookify-test.local.md`, `enabled: true`, `event: bash`, `action: warn`; soubor není v `.gitignore` | `?? .claude/hookify.warn-echo-hookify-test.local.md`; `/hookify:list`: „1 enabled“ |
| 5 Spuštění | `echo hookify-test` proběhl, varování se **neobjevilo** | „Příkaz proběhl a vypsal hookify-test. Varování … jsem ale nedostal.“ |
| 6 Úklid | nepotvrzeno (soubor pravidla ve výpisu stále je) | – |

Vedlejší zjištění: stop hook prostředí opakovaně žádal commit a push a auto-mode klasifikátor ho zamítl (G1).

**Verdikt hookify:** v cloudu nefunguje (příčina nezměřena). Plugin je zapnutý, hooky jsou registrované, `python3` je k dispozici, pravidlo vzniklo a je `enabled`, varování se přesto neukázalo. Nezměřeno: zda se hooky pluginu načítají až při startu session, zda `pretooluse.py` pravidlo vyhodnotí (ruční spuštění nebylo provedeno), zda se varování zobrazuje jinde než agent vidí. Lokálně nevyzkoušeno.

### Task 2: hook a `permissions.deny` z `.claude/settings.json` v cloudu (2026-11-27)

| prostředek | spuštěno | důkaz |
|---|---|---|
| hook (`PreToolUse`, `echo hook-rule-test`) | ano, příkaz zablokován | „zablokoval ho PreToolUse hook s hláškou hard-rule-test: blocked by project hook“ |
| `permissions.deny` (`Bash(echo deny-rule-test:*)`) | ano, příkaz odmítnut | „oprávnění pro něj bylo zamítnuto“ (zamítací pravidlo oprávnění, ne hook) |
| kontrola (`echo neutral-test`) | proběhl | „vypsal neutral-test“ |

Větev `pokus/hard-rule-test` se z cloudové session na větvi jiné než `main` načetla (soubor `.claude/settings.json` zabral). Úklid: větev smazána; `origin/main` nemá `.claude/settings.json`.

**Výsledek:** `hook: ano`, `deny: ano`.

### Task 3: souběžná revize `pre-done` × `pr-review-toolkit` (2026-11-27)

Diff: vymyšlený `pokus/review.sh` (10 řádků) s `tar … || true` a „Záloha hotová“ + `exit 0`, bez testu.

| revize | nálezy (Critical/Important/Minor) | zachycená vložená chyba | Context tokens: first / max |
|---|---|---|---|
| A: `pre-done` (Sonnet, high, 1 reviewer) | 2 / 4 / 1 | ano: „pokus/review.sh:7: tar ... \|\| true spolkne jakoukoli chybu tar“; druhý Critical: „Záloha hotová“ s `exit 0`; mezi Important chybějící test | 84,4k / 91,6k (+7,2k); tokeny podagenta nezměřeno |
| B: `/pr-review-toolkit:review-pr` | 1 / 3 / 3 | ano: „silent-failure: pokus/review.sh:7 – \|\| true zahodí chybu tar“ + řádky 9–10; chybějící test neuvedla | 88,4k / 93,2k (+4,8k); agenty pluginu nespustila (u 10 řádků zbytečné), revizi udělala sama |

Vedlejší: zapnutý plugin zvedl kontext na startu o ~4k (84,4k → 88,4k). Stop hook po `retro` chtěl commit, push a v B i draft PR; klasifikátor to zablokoval, odpověď ne. Úklid: `git ls-remote --heads origin 'pokus/*'` nevrací nic (větev smazána).

**Omezení:** jeden běh na každou variantu, jeden vymyšlený diff; B nevyužila podagenty, takže nejde o srovnání víceagentní revize.
