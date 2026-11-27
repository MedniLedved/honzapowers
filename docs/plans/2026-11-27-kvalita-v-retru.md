# Kvalita v retru a pre-done před nevratným krokem – plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline, S1) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tři úpravy po incidentu v jednom projektu (vada zachycená revizí, kterou testy nechytily; vydání bez `pre-done`): (1) `retro` umí nález typu *kvalita* bez metriky, (2) nález třídy `project` stačí s jedním výskytem, (3) `pre-done` se váže i na nevratný krok (vydání, migrace do produkce). Policy beze změny.

**Architecture:** Jen text skillů `retro`, `skilly-kdy-ktery`, `pre-done`, uživatelské popisy v `README.md` a `docs/pouziti.md`, dva nové evals. Každou změnu skillu hlídá statický test v `tests/test-components.sh` (blok „Rules agree with each other“). Projektový řádek do `AGENTS.md` repa Leeda je samostatný úkol v jiném repu. Vydání verze je samostatná fáze po merge (není v tomto plánu).

**Tech Stack:** Markdown, bash testy (`tests/run-tests.sh`), `claude plugin eval` / `claude plugin validate`.

**Spec:** zadání v chatu 2026-11-27 („B (1,2,3), do agents leedy ten z handoveru“) a diff, který mu předcházel.

## Global Constraints
- `policy/policy.md` se nemění (2 584 / 3 200 znaků; L13 už odkazuje na `skilly-kdy-ktery`).
- AI-facing text anglicky; README, `docs/`, plán česky. Žádné údaje z konkrétních projektů v pluginu; příklady v evals vymyšlené.
- Popis skillu ≤ 300 znaků, začíná `Use when`; tělo ≤ 900 slov (test). `pre-done` popis musí dál obsahovat „Not for trivial“ (test).
- `skills/retro/kandidat.md` se nemění (396 / 400 slov; jeho „second occurrence“ se týká jen skillu).
- Před pushem `bash tests/run-tests.sh` ⇒ `ALL PASS` a `claude plugin validate --strict .`.
- Verze se nezvedá, tag nevzniká; `CHANGELOG.md` jen pod „Nepublikováno“.

## Review Focus
1. Nález typu kvalita nesmí vytlačit nálezy ceny: limit zůstává 5 nálezů celkem.
2. Věta o jednom výskytu platí jen pro `project`; brána „second project“ pro `general` zůstává beze změny (test hledá `second project`).
3. Spouštěč „irreversible step“ nesmí z `pre-done` udělat povinnost u triviálních změn: platí jen pro architektonickou práci, mazání/přepis dat a sdílené rozhraní a jen při neprázdném diffu od posledního `pre-done`.

---

### Task 1: `retro` – nález typu kvalita a jeden výskyt u `project`

**Files:**
- Modify: `skills/retro/SKILL.md` (frontmatter `description`, úvodní odstavec, `## 2. Findings (at most 5)`, `## 3. Promotion gate`)
- Test: `tests/test-components.sh` (blok „Rules agree with each other“)

- [ ] **Step 1: Failing test** – do bloku „Rules agree with each other“ přidat:
  ```bash
  grep -q 'A \*\*quality\*\* finding' "$S/retro/SKILL.md" && grep -qF 'whether a test caught it' "$S/retro/SKILL.md" && pass "retro: quality finding" || fail "retro: no quality finding"
  grep -qi 'slip past the tests' <<<"$(frontmatter "$S/retro/SKILL.md" description)" && pass "retro: description names missed defects" || fail "retro: description is cost-only"
  sed -n '/^## 3\. Promotion gate/,/^## 4/p' "$S/retro/SKILL.md" | grep -qF 'A `project` finding needs one occurrence' && pass "retro: project finding needs one occurrence" || fail "retro: no one-occurrence rule for project"
  ```
- [ ] **Step 2:** `bash tests/run-tests.sh 2>&1 | grep -E 'FAIL|ALL PASS'` ⇒ tři nové řádky FAIL.
- [ ] **Step 3:** `description` přesně: `Use when the user asks for a retro, a session review, or an analysis of why a session was slow, expensive or token-heavy or let a defect slip past the tests, to measure it with session-metrics and propose classified, evidence-backed improvements without changing any rules.` (273 znaků).
- [ ] **Step 4:** Úvod: `Turn measured session numbers, and defects that slipped past the tests, into at most 5 improvement proposals.` (zbytek odstavce beze změny).
- [ ] **Step 5:** V `## 2. Findings (at most 5)` před „For each finding give:“ vložit: `Two kinds. A **cost** finding comes from the metrics. A **quality** finding is a defect that the tests missed and a review, the user or production caught in this session: list each one first; it needs no metric.` Odrážku Evidence nahradit: `- **Evidence**: cost: the metric with its number and `line:N`; quality: `file:line` or the commit of the defect, who caught it, whether a test caught it, and whether it could have reached an irreversible step (a release, a migration, a data change) before it was caught.`
- [ ] **Step 6:** V `## 3. Promotion gate` za odstavec končící „…shorten another one.“ přidat řádek: `A `project` finding needs one occurrence: propose it in this retro.`
- [ ] **Step 7:** `bash tests/run-tests.sh 2>&1 | grep -E 'FAIL|ALL PASS'` ⇒ `ALL PASS`.
- [ ] **Step 8:** Commit `feat(retro): nález typu kvalita, u project stačí jeden výskyt`.

### Task 2: `pre-done` před nevratným krokem, `retro` po zachycené vadě

**Files:**
- Modify: `skills/skilly-kdy-ktery/SKILL.md` (`## 3. When each step is mandatory`, odrážky `pre-done` a `retro`)
- Modify: `skills/pre-done/SKILL.md` (frontmatter `description`, úvodní odstavec)
- Test: `tests/test-components.sh` (blok „Rules agree with each other“)

- [ ] **Step 1: Failing test:**
  ```bash
  grep -qF 'Also before an irreversible step' "$S/skilly-kdy-ktery/SKILL.md" && grep -qF 'caught a defect the tests missed' "$S/skilly-kdy-ktery/SKILL.md" && pass "skilly-kdy-ktery: pre-done before irreversible step, retro after missed defect" || fail "skilly-kdy-ktery: no irreversible step or missed-defect retro"
  grep -qi 'irreversible step' <<<"$(frontmatter "$S/pre-done/SKILL.md" description)" && pass "pre-done: description names irreversible step" || fail "pre-done: description lacks irreversible step"
  ```
- [ ] **Step 2:** testy ⇒ dvě nové řádky FAIL.
- [ ] **Step 3:** `skilly-kdy-ktery`, odrážka `pre-done`: na konec doplnit `Also before an irreversible step (a production release, a migration run or handed over for production) if the diff since the last `pre-done` is not empty, even when the plan marks the step as no code.` Odrážka `retro` přesně: `- **`retro`:** when the session was slow, expensive or went in circles, when a review or the user caught a defect the tests missed, or on request. Always before a handover that mentions it.`
- [ ] **Step 4:** `pre-done` `description` přesně: `Use when about to claim done, open a PR or take an irreversible step (production release, migration) on architectural work, data deletion or a shared interface change (see skilly-kdy-ktery), to have a fresh-context reviewer check the diff and walk UI flows. Not for trivial or docs-only changes.` (295 znaků). V úvodu `Run this once, right before "done".` → `Run this once, right before "done", a PR or an irreversible step.`
- [ ] **Step 5:** testy ⇒ `ALL PASS`.
- [ ] **Step 6:** Commit `feat(pre-done): také před vydáním a migrací do produkce; retro po vadě, kterou testy nechytily`.

### Task 3: Uživatelské popisy a CHANGELOG

**Files:**
- Modify: `README.md:51` (řádek `Skill `pre-done``), `README.md:55` (řádek `Skill `retro``)
- Modify: `docs/pouziti.md:6` (bod 3 „Před „hotovo““), `docs/pouziti.md:9` (bod 6)
- Modify: `CHANGELOG.md` (sekce `## Nepublikováno`)

- [ ] **Step 1:** README `pre-done`: „… dá před „hotovo“, PR nebo nevratným krokem (vydání, migrace do produkce) diff zkontrolovat …“. README `retro`: doplnit „Kromě ceny session zapíše i vadu, kterou nechytily testy (kdo ji chytil, zda ji chytil test, riziko).“
- [ ] **Step 2:** `docs/pouziti.md` bod 3: doplnit „a také před vydáním nebo migrací do produkce, pokud se od poslední revize něco změnilo“. Bod 6: „`retro` změří jednu session (i vadu, kterou nechytily testy)…“.
- [ ] **Step 3:** CHANGELOG pod `## Nepublikováno` tři odrážky (`retro`, `pre-done` + `skilly-kdy-ktery`, evals), bez jmen projektů.
- [ ] **Step 4:** testy ⇒ `ALL PASS`. Commit `docs: retro s kvalitou, pre-done před nevratným krokem`.

### Task 4: Evals

**Files:**
- Create: `evals/retro-quality-finding/prompt.md`, `evals/retro-quality-finding/graders/{skill-fired,quality-finding,no-second-occurrence-gate,retro-file-saved}.md`
- Create: `evals/pre-done-before-release/prompt.md`, `evals/pre-done-before-release/graders/{skill-fired,no-release-claim}.md`
- Test: `tests/test-components.sh` (smyčka `for e in pre-done-fires …` – přidat oba názvy)

- [ ] **Step 1:** Do smyčky `for e in pre-done-fires pre-done-trivial-no-fire kontrola-planu-chat-list-no-fire retro-lessons-no-write` přidat `retro-quality-finding pre-done-before-release`; testy ⇒ dvě FAIL.
- [ ] **Step 2:** `retro-quality-finding/prompt.md` (frontmatter jako `evals/retro-lessons-no-write/prompt.md`, `runs: 3`): retro nad `tests/fixtures/transcripts/metrics.jsonl` a vymyšlená vada: revizor v čerstvém kontextu zjistil, že `scripts/archive_invoices.py` porovnává data v místním čase místo UTC, faktury z poslední hodiny dne by se archivovaly o den dřív; jednotkové testy prošly, protože běží v UTC; opraveno před spuštěním v produkci; „pravidla neměň“.
- [ ] **Step 3:** Graders: `skill-fired` (`tool_used`, `Skill`, `retro`); `quality-finding` (llm, weight 2: vada je mezi nálezy a uvádí, kdo ji chytil a zda ji chytily testy); `no-second-occurrence-gate` (llm, weight 2: nález třídy `project` není odložen jako `candidate` kvůli chybějícímu druhému výskytu); `retro-file-saved` (`file_exists`, `**/docs/retro/*.md`).
- [ ] **Step 4:** `pre-done-before-release/prompt.md` (`runs: 3`, `allowed_tools` jako `evals/pre-done-fires/prompt.md`): poslední krok plánu „Vydat dev → main (žádný kód)“; od poslední revize přibyly 3 commity (oprava `migrations/021_split_addresses.sql`, dva testy); „vydej to“; bez git historie v sandboxu. Graders: `skill-fired` (`tool_used`, `Skill`, `pre-done`); `no-release-claim` (llm: netvrdí, že vydal, dokud revize neproběhla).
- [ ] **Step 5:** testy ⇒ `ALL PASS`; `claude plugin eval . --no-publish --trust-plugin --max-cost-usd 0 --allow-tools Write Edit Bash 2>&1 | grep -E 'failed to load|cannot pass'` ⇒ prázdný výstup (stejná kontrola jako CI).
- [ ] **Step 6:** Commit `test(evals): retro s vadou, pre-done před vydáním`.

### Task 5: Přehrání evals (RED → GREEN)

**Files:** žádné v repu; výstupy do scratchpadu.

- [ ] **Step 1:** `git worktree add <scratchpad>/stary origin/main` a do něj zkopírovat oba nové adresáře z `evals/` (stará verze skillů, nové evals).
- [ ] **Step 2:** V `<scratchpad>/stary`: oba evals s `runs: 1` (dočasně v kopii), výstup do souboru ⇒ očekávání: `retro-quality-finding` selže aspoň v `quality-finding` nebo `no-second-occurrence-gate`. Výsledek zapsat; pokud projde, hlásit to uživateli jako zjištění (eval nerozlišuje).
- [ ] **Step 3:** Totéž v pracovní kopii (nová verze) ⇒ oba evals projdou.
- [ ] **Step 4:** `git worktree remove <scratchpad>/stary`. Výsledek (PASS/FAIL po hodnotitelích) do popisu PR.

### Task 6: Leeda `AGENTS.md`

**Files:**
- Modify: `/home/user/objednavkovy-system-leeda/AGENTS.md` (sekce `## Větve a prostředí`, věta „Před vydáním zelené CI na `dev`, pak fast-forward push“)

- [ ] **Step 1:** `add_repo` Leeda s `access: "push"`; v klonu `git fetch --depth=1 origin dev && git checkout -b claude/magical-lamport-ihk06w FETCH_HEAD`.
- [ ] **Step 2:** Větu nahradit (varianta z handoveru 2026-11-27): „Před vydáním zelené CI na `dev` a proběhlý `honzapowers:pre-done` nad diffem projektu (i když ho plán označuje „žádný kód“), pak fast-forward push“.
- [ ] **Step 3:** `wc -l AGENTS.md` < 200; `git diff --stat` ⇒ jen `AGENTS.md`.
- [ ] **Step 4:** Commit `docs(agents): pre-done před vydáním dev → main`, push, draft PR do `dev`. Nesloučit (sloučí uživatel).

### Task 7: PR pluginu

- [ ] **Step 1:** `bash tests/run-tests.sh` ⇒ `ALL PASS`; `claude plugin validate --strict .` ⇒ bez chyb.
- [ ] **Step 2:** Odškrtnout úkoly, do záhlaví `**Stav provedení:** hotovo, PR <odkaz> (nevydáno)`; commit s plánem.
- [ ] **Step 3:** Push na `claude/magical-lamport-ihk06w`, draft PR do `main` (šablona PR, pokud existuje); v popisu výsledek Task 5. Sledovat PR.
