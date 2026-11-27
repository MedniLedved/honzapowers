# Přednost pravidel, připnutá instalace a opravy přes test – plán

**Stav provedení:** hotovo, vydáno ve verzi 0.6.0 (PR #13 a #14, tag `honzapowers--v0.6.0`).

**Stav:** kontrola 2026-11-27: 8 nálezů, opraveno 7, otázky 0, zamítnuto 1.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline, S1) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tři úpravy z porovnání s jiným nastavením: uživatelův vlastní CLAUDE.md má přednost před výchozí policy, README nabízí připnutou instalaci a vydání dostávají tag, `pre-done` opravuje nálezy přes test.

**Architecture:** Jen text: první řádek policy, README, `docs/pouziti.md`, `docs/vydani.md`, krok 2 skillu `pre-done`. Každou změnu hlídá statický test v `tests/test-components.sh`. Vydání 0.6.0 je samostatná fáze po merge (není v tomto plánu).

**Tech Stack:** Markdown, bash testy (`tests/run-tests.sh`).

**Spec:** zadání v chatu 2026-11-27 („ano 1–4, 5 vynech, 4 jako pokus do osobní“); body 1–3 návrhů pro HP. Bod 4 (pokus s lehkou revizí) je samostatný plán v repu `honzapowers-osobni`.

## Global Constraints
- `policy/policy.md` anglicky, max 3 200 znaků (dnes 2 513); počet pravidel zůstává 22, žádné nové ID.
- AI-facing text (policy, skilly) anglicky; README a `docs/` česky.
- Žádné údaje z konkrétních projektů; příklady vymyšlené.
- Uživatel nespouští `claude` CLI: postup vydání musí mít cestu přes web GitHubu nebo `git`.
- Před pushem `bash tests/run-tests.sh` ⇒ `ALL PASS`.

## Review Focus
1. Pořadí přednosti musí v policy a `docs/pouziti.md` říkat totéž (projekt > uživatel > výchozí policy); README o přednosti nemluví a nemění se.
2. Připnutá instalace nesmí slibovat syntaxi, kterou Claude Code nepodporuje – jen ověřený zápis z dokumentace.
3. Opravy přes test v `pre-done` nesmí vynutit pevný testovací příkaz projektu (pravidlo AGENTS.md) ani commit tam, kde ho projekt nebo lokální session nedovoluje.
4. Druhé kolo revize je nejvýš jedno (úspornost); `pre-done` nesmí sklouznout k smyčce.
5. Délka `pre-done/SKILL.md` naroste nejvýš o ~6 řádků.

---

### Task 1: Přednost uživatelova CLAUDE.md

**Files:**
- Modify: `policy/policy.md:1`
- Modify: `docs/pouziti.md:25-26` (body 2 a 3 seznamu „Na které úrovni pravidla platí“)
- Test: `tests/test-components.sh` (blok „Rules agree with each other“)

- [ ] **Step 1: Failing test** – do bloku „Rules agree with each other“ přidat:
  ```bash
  head -1 "$P" | grep -q "project's CLAUDE.md/AGENTS.md win, then the user's own" && pass "policy: precedence project > user > default" || fail "policy: precedence line"
  grep -q '~/.claude/CLAUDE.md' "$REPO_ROOT/docs/pouziti.md" && pass "pouziti: user CLAUDE.md layer" || fail "pouziti: no user CLAUDE.md layer"
  ```
- [ ] **Step 2:** `bash tests/run-tests.sh 2>&1 | grep -E 'FAIL|ALL PASS'` ⇒ obě nové řádky FAIL.
- [ ] **Step 3:** První řádek policy přesně (fráze `standing rules` musí zůstat, hledá ji `tests/test-session-start.sh:9`):
  `The user's standing rules (honzapowers policy; on a clash the project's CLAUDE.md/AGENTS.md win, then the user's own ~/.claude/CLAUDE.md and personal rules):`
- [ ] **Step 4:** `docs/pouziti.md` bod 2: doplnit, že do uživatelské vrstvy patří i `~/.claude/CLAUDE.md` a že obojí vyhrává nad výchozí policy. Bod 3: „vyhrává projekt, pak uživatel; stojí to v první řádce policy“.
- [ ] **Step 5:** `bash tests/run-tests.sh 2>&1 | grep -E 'FAIL|ALL PASS'` ⇒ `ALL PASS`; `wc -c policy/policy.md` ≤ 3200.
- [ ] **Step 6:** Commit `feat(policy): uživatelův CLAUDE.md má přednost před výchozí policy`.

### Task 2: Připnutá instalace a tag vydání

**Files:**
- Modify: `README.md` (sekce `## Instalace`)
- Modify: `docs/vydani.md:6`
- Test: `tests/test-components.sh`

- [ ] **Step 1: Failing test:**
  ```bash
  grep -q '^### Připnutá verze' "$REPO_ROOT/README.md" && pass "README: pinned install" || fail "README: no pinned install"
  grep -q 'honzapowers--v' "$REPO_ROOT/README.md" && grep -q 'Releases' "$REPO_ROOT/docs/vydani.md" && grep -q 'honzapowers--v' "$REPO_ROOT/docs/vydani.md" \
    && pass "README/vydani: tag honzapowers--vX.Y.Z, web path" || fail "README/vydani: tag name or web path"
  ```
- [ ] **Step 2:** testy ⇒ obě FAIL.
- [ ] **Step 3:** README, za odstavec o Sync automatically: podsekce `### Připnutá verze` – kdy ji chtít (chceš aktualizace nejdřív vidět; hooky běží bez dotazu). Zápis v Claude Code: `/plugin marketplace add MedniLedved/honzapowers#honzapowers--vX.Y.Z`, kde `X.Y.Z` je existující tag ze stránky https://github.com/MedniLedved/honzapowers/tags (dokumentace: „Add `#ref` to pin a branch or tag“). Na novou verzi: `/plugin marketplace remove honzapowers` a znovu `add` s novým tagem. Automatické aktualizace marketplace jdou vypnout v `/plugin` → záložka Marketplaces. Na claude.ai není připnutí ověřené: tam místo toho fork a synchronizace z něj.
- [ ] **Step 4:** `docs/vydani.md` bod 4: zachovat „nevratné“ (push tagu nejde vzít zpět). Před tagem ověřit, že verze v `plugin.json` a `marketplace.json` je `X.Y.Z` a že `<sha>` je commit v `main` se zeleným CI. Pak tag `honzapowers--vX.Y.Z` (stejný tvar jako `claude plugin tag`) na commitu v `main`, přes GitHub web (Releases → Draft a new release → nový tag, cíl `main`) nebo `git tag -a honzapowers--vX.Y.Z -m "honzapowers X.Y.Z" <sha> && git push origin honzapowers--vX.Y.Z`; `claude plugin tag --push` jen jako alternativa pro terminál. Test kroku 1 hledá `honzapowers--v` v README i ve `vydani.md` a `Releases` ve `vydani.md`.
- [ ] **Step 5:** testy ⇒ `ALL PASS`.
- [ ] **Step 6:** Commit `docs: připnutá instalace a tag vydání přes web`.

**Poznámka:** Zápis ověřen 2026-11-27 v dokumentaci Claude Code (discover-plugins, plugins CLI reference): `owner/repo#ref` připne větev nebo tag; `claude plugin tag` vytváří tag `<name>--v<version>`. Dosud žádný tag neexistuje; první vznikne při vydání 0.6.0.

### Task 3: Opravy nálezů z `pre-done` přes test

**Files:**
- Modify: `skills/pre-done/SKILL.md:21-22`
- Test: `tests/test-components.sh`

- [ ] **Step 1: Failing test:**
  ```bash
  grep -q 'fails because of the finding' "$REPO_ROOT/skills/pre-done/SKILL.md" && grep -qi 'at most one re-review' "$REPO_ROOT/skills/pre-done/SKILL.md" \
    && pass "pre-done: test-first fixes, one re-review" || fail "pre-done: no test-first fix rule"
  ```
- [ ] **Step 2:** testy ⇒ FAIL.
- [ ] **Step 3:** Řádek 21 nahradit doslova (řádek 22 „Do not re-run unrelated passed tests.“ zůstává):
  ```text
  For each Critical or Important finding: first add a test that fails because of the finding,
  in the project's own way of testing (if no test can show it, e.g. wording or config, say so).
  Then fix it, see that test pass, and commit the fix on its own if the session commits
  (the project's git rules win). Then run at most one re-review, on the fix changes only
  (their commits, or `git diff` of the files the fixes touched); report what is left and
  never start a third round.
  ```
- [ ] **Step 4:** testy ⇒ `ALL PASS`; jazykový test (`czech_prose`) bez nálezu.
- [ ] **Step 5:** Commit `feat(pre-done): opravy nálezů přes test, nejvýš jedno opakování`.

### Task 4: Changelog a PR

**Files:**
- Modify: `CHANGELOG.md` (sekce `## Nepublikováno`)

- [ ] **Step 1:** Do `## Nepublikováno` tři odrážky česky (přednost, připnutá instalace a tag, `pre-done` přes test). Verze se nemění (vydání je další fáze).
- [ ] **Step 2:** `bash tests/run-tests.sh 2>&1 | tail -1` ⇒ `ALL PASS`.
- [ ] **Step 3:** Commit, push na `claude/funny-turing-jovzro`, draft PR do `main`.
