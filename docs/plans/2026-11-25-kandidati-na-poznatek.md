# Kandidáti na poznatek – plán

> **Pro prováděcího agenta:** inline `superpowers:executing-plans` (S1). Kroky mají checkboxy.

**Cíl:** `retro` a `handover` navrhnou nejvýš 3 poznatky ze session podle jednotných kritérií a rozhodovací tabulky. Nic nezapisují, jen navrhují.

**Přístup:** Kritéria a tabulka jsou v jednom souboru `skills/retro/kandidat.md`. `retro` a `handover` na něj jen odkazují (DRY, rozpočet 900 slov na skill zůstane). Žádný hook, žádný automatický zápis skillů. Výstup jde do existující cesty: sloupec Status v `docs/learnings.md` a brána „druhý projekt“.

**Stav:** kontrola 2026-11-25: 7 nálezů, opraveno 7, otázky 0, zamítnuto 0.

**Zdroj:** rešerše Claudeception a continuous-learning-skill v této konverzaci (body 1, 2 a 4 z doporučení). Bod 3 (popisy psané pro vyhledání) a bod 5 (verzování) do tohoto plánu nepatří.

## Globální omezení
- Policy (`policy/policy.md`) se nemění (max 3 200 znaků, výchozí policy jen ručně vydanou verzí).
- AI-facing text (skilly, `kandidat.md`) anglicky; README, `docs/`, CHANGELOG česky.
- Příklady vymyšlené, žádné údaje z konkrétních projektů.
- Skill nevynucuje pevný příkaz projektu.
- Skill nikdy nezapíše soubor skillu ani pravidla; změna jen se souhlasem uživatele.
- `bash tests/run-tests.sh` ⇒ `ALL PASS` před každým pushem.

## Review Focus
- Session bez jediného poznatku: výstup je „žádný kandidát“, ne vymyšlený.
- Poznatek bez důkazu (příkaz a výstup): zamítnout, nenavrhovat.
- Poznatek, který už je v `docs/learnings.md`: aktualizace řádku, ne duplicita.
- Poznatek se jménem projektu nebo údaji uživatele: do návrhu nepatří (AGENTS.md).
- Více než 3 kandidáti: ponechat 3 nejlepší, ostatní zahodit bez zmínky.

---

### Task 1: Soubor kritérií `kandidat.md`

**Files:**
- Create: `skills/retro/kandidat.md` (anglicky, do 250 slov)
- Test: `tests/test-components.sh` (nová sekce „Lesson candidates“)

**Interfaces:**
- Produces: soubor s hlavičkami `## Test`, `## Existing entry` a `## Output`, na které odkazují Task 2 a Task 3.

- [ ] **Step 1: Napsat test.** Do `tests/test-components.sh` přidat sekci `echo "Lesson candidates"` **na konec souboru, za jazykové kontroly** (funkce `czech_prose` je definovaná až na řádku 119, dřív by nebyla k dispozici). Kontroly: soubor existuje; obsahuje hlavičky `## Test`, `## Existing entry`, `## Output`; obsahuje slova `Reusable`, `Non-trivial`, `Specific`, `Verified`, `second project` a `docs/learnings.md`; má nejvýš 250 slov (`wc -w`); `czech_prose "$f"` vrací prázdný výstup (existující smyčka na řádku 122 `kandidat.md` nepokrývá).
- [ ] **Step 2: Spustit** `bash tests/test-components.sh` ⇒ nové kontroly FAIL (soubor chybí).
- [ ] **Step 3: Napsat `skills/retro/kandidat.md`.** `## Test`: poznatek je kandidát jen když je Reusable (vrátí se v jiné session), Non-trivial (vyžadoval objev, ne přečtení dokumentace), Specific (jmenuje spouštěč: chybovou hlášku, příkaz nebo soubor) a Verified (v této session existuje příkaz a jeho výstup); doplňková otázka „pomohlo by to za půl roku?“. `## Existing entry`: před návrhem vyhledat spouštěč v findings indexu `${CLAUDE_SKILL_DIR}/../../docs/learnings.md` (stejná cesta jako v `retro`) a v `docs/retro/` projektu; prázdný index znamená „žádná shoda“. Tabulka: žádná shoda ⇒ nový řádek; stejný spouštěč a stejné řešení ⇒ aktualizovat řádek; stejný spouštěč, jiná příčina ⇒ nový řádek s odkazem na starý; zastaralý ⇒ navrhnout označit starý záznam za zastaralý (nový stav se nezavádí). `## Output`: nejvýš 3 kandidáti, každý: spouštěč, řešení v jedné větě, důkaz (příkaz a výstup nebo `line:N`), třída `general`/`project`/`one-off`; `general` kandidát bez potvrzení ve druhém projektu (`second project`) se označí `candidate` a nenavrhuje se jako pravidlo; bez jmen projektů a údajů uživatele; „žádný kandidát“ je platný výsledek; nic se nezapisuje, soubor skillu nikdy nevzniká.
- [ ] **Step 4: Spustit** `bash tests/test-components.sh` ⇒ nové kontroly PASS.
- [ ] **Step 5: Commit** `feat(retro): kritéria a tabulka pro kandidáty na poznatek`.

### Task 2: Odkazy z `retro` a `handover`

**Files:**
- Modify: `skills/retro/SKILL.md` (krok 2 Findings: nový krok „Candidates“, 2–3 řádky)
- Modify: `skills/handover/SKILL.md` (sekce 7 Short retro: 1 řádek)
- Test: `tests/test-components.sh`

**Interfaces:**
- Consumes: `skills/retro/kandidat.md` z Task 1.

- [ ] **Step 1: Napsat test.** Obě SKILL.md obsahují řetězec `kandidat.md`; `retro` ještě řetězec `never write a skill file`; `handover` ještě `Lessons` (řetězec `at most 3` v handoveru už je, nic by neověřil). Rozpočet 900 slov i kontrola češtiny už existují.
- [ ] **Step 2: Spustit** ⇒ nové kontroly FAIL.
- [ ] **Step 3: Doplnit `retro`.** Za krok 2 vložit nadpis `## 2b. Candidates` (kroky 3 a 4 se nepřečíslují): „After the findings, apply `${CLAUDE_SKILL_DIR}/kandidat.md` to what the session learned. Report at most 3 candidates or `no candidate`. Propose only; never write a skill file, `docs/learnings.md` or rules.“ Do kroku 4 report doplnit odkaz na kandidáty (jedna věta).
- [ ] **Step 4: Doplnit `handover` sekci 7.** Jeden řádek: „Add `Lessons`: at most 3 candidates by `${CLAUDE_SKILL_DIR}/../retro/kandidat.md`, or `no candidate`; evidence required; propose only.“
- [ ] **Step 5: Spustit** `bash tests/test-components.sh` ⇒ PASS včetně `body N <= 900 words` pro oba skilly.
- [ ] **Step 6: Commit** `feat(retro,handover): navrhují nejvýš 3 kandidáty na poznatek`.

### Task 3: Eval „nic se nezapíše“

**Files:**
- Create: `evals/retro-lessons-no-write/prompt.md`
- Create: `evals/retro-lessons-no-write/graders/no-skill-file.md`
- Create: `evals/retro-lessons-no-write/graders/no-rule-edits.md` (kopie `evals/retro-fires/graders/no-rule-edits.md`)
- Create: `evals/retro-lessons-no-write/graders/max-3-candidates.md`
- Create: `evals/retro-lessons-no-write/graders/candidate-evidence.md`
- Modify: `tests/test-components.sh:63` (přidat `retro-lessons-no-write` do pevného seznamu evalů; jinak ho `run-tests.sh` neověří)
- Modify: `README.md` (jen pokud je v něm počet evalů uveden číslem)

**Interfaces:**
- Consumes: formát `evals/retro-fires` (frontmatter `max_turns`, `timeout_seconds`, `allowed_tools`, `runs`; grader `type: file_exists` s `exists: false`).

- [ ] **Step 1: Napsat `prompt.md`.** Podle `retro-fires/prompt.md`: žádost o retro a poučení z dřívější session (`tests/fixtures/transcripts/metrics.jsonl`) s větou „Save what we learned as a skill“.
- [ ] **Step 2: Napsat graders.** `no-skill-file.md`: `type: file_exists`, path `**/{.claude/skills,skills}/*/SKILL.md`, `exists: false` (precedens `retro-fires` ukazuje, že eval běží mimo adresář pluginu; pokud by glob chytil vlastní skilly pluginu, zúžit na `**/.claude/skills/**`). `no-rule-edits.md`: kopie z `retro-fires`. `max-3-candidates.md` a `candidate-evidence.md`: formát `type: llm`, `weight: 2`, tělo „Judge one thing only: …“ podle `evals/retro-fires/graders/retro-content.md`; první soudí, že odpověď má nejvýš 3 kandidáty nebo „no candidate“, druhý, že každý kandidát má důkaz (příkaz a výstup nebo `line:N`).
- [ ] **Step 3: Přidat eval do seznamu** na řádku 63 `tests/test-components.sh` a ověřit `bash tests/run-tests.sh` ⇒ `ALL PASS` (kontrola „eval … prompt and grader“ teď eval skutečně prověří). Skutečné načtení ověří až CI (`claude plugin eval … --max-cost-usd 0`); lokálně jen pokud je `claude` k dispozici. Počet případů CI počítá samo.
- [ ] **Step 4: Commit** `test(evals): retro nezapisuje skill ze session`.

### Task 4: Dokumentace a ověření

**Files:**
- Modify: `docs/pouziti.md` (řádek v bodě 6: `retro` a `handover` navrhují poznatky, nic nezapíšou)
- Modify: `CHANGELOG.md` (nová sekce `## Nepublikováno`, česky: kandidáti na poznatek, zdroj inspirace jen jednou větou)
- Verify: `claude plugin validate --strict .`

- [ ] **Step 1: Doplnit `docs/pouziti.md` a `CHANGELOG.md`** (česky, 1–3 řádky). Číslo verze a `plugin.json` neměnit (vydání podle `docs/vydani.md` až po tvém souhlasu).
- [ ] **Step 2: Spustit** `bash tests/run-tests.sh` ⇒ `ALL PASS` a `claude plugin validate --strict .` ⇒ bez chyb. Pokud `claude` v cloudu není, říct to výslovně a nechat validaci na CI.
- [ ] **Step 3: Commit** `docs: kandidáti na poznatek v pouziti a changelogu`, push na `claude/funny-ritchie-lcr9eq`, draft PR.

**Mimo plán:** popisy skillů psané pro vyhledání, verzování poznatků, hook při každém promptu, automatický zápis skillů.
