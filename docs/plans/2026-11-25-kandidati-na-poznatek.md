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
- Více než 3 kandidáti: ponechat 3 s nejsilnějším důkazem, o zbytku jedna věta s počtem (dodatek, rozhodnutí 1).

---

### Task 1: Soubor kritérií `kandidat.md`

**Files:**
- Create: `skills/retro/kandidat.md` (anglicky, do 250 slov)
- Test: `tests/test-components.sh` (nová sekce „Lesson candidates“)

**Interfaces:**
- Produces: soubor s hlavičkami `## Test`, `## Existing entry` a `## Output`, na které odkazují Task 2 a Task 3.

- [x] **Step 1: Napsat test.** Do `tests/test-components.sh` přidat sekci `echo "Lesson candidates"` **na konec souboru, za jazykové kontroly** (funkce `czech_prose` je definovaná až na řádku 119, dřív by nebyla k dispozici). Kontroly: soubor existuje; obsahuje hlavičky `## Test`, `## Existing entry`, `## Output`; obsahuje slova `Reusable`, `Non-trivial`, `Specific`, `Verified`, `second project` a `docs/learnings.md`; má nejvýš 250 slov (`wc -w`); `czech_prose "$f"` vrací prázdný výstup (existující smyčka na řádku 122 `kandidat.md` nepokrývá).
- [x] **Step 2: Spustit** `bash tests/test-components.sh` ⇒ nové kontroly FAIL (soubor chybí).
- [x] **Step 3: Napsat `skills/retro/kandidat.md`.** `## Test`: poznatek je kandidát jen když je Reusable (vrátí se v jiné session), Non-trivial (vyžadoval objev, ne přečtení dokumentace), Specific (jmenuje spouštěč: chybovou hlášku, příkaz nebo soubor) a Verified (v této session existuje příkaz a jeho výstup); doplňková otázka „pomohlo by to za půl roku?“. `## Existing entry`: před návrhem vyhledat spouštěč v findings indexu `${CLAUDE_SKILL_DIR}/../../docs/learnings.md` (stejná cesta jako v `retro`) a v `docs/retro/` projektu; prázdný index znamená „žádná shoda“. Tabulka: žádná shoda ⇒ nový řádek; stejný spouštěč a stejné řešení ⇒ aktualizovat řádek; stejný spouštěč, jiná příčina ⇒ nový řádek s odkazem na starý; zastaralý ⇒ navrhnout označit starý záznam za zastaralý (nový stav se nezavádí). `## Output`: nejvýš 3 kandidáti, každý: spouštěč, řešení v jedné větě, důkaz (příkaz a výstup nebo `line:N`), třída `general`/`project`/`one-off`; `general` kandidát bez potvrzení ve druhém projektu (`second project`) se označí `candidate` a nenavrhuje se jako pravidlo; bez jmen projektů a údajů uživatele; „žádný kandidát“ je platný výsledek; nic se nezapisuje, soubor skillu nikdy nevzniká.
- [x] **Step 4: Spustit** `bash tests/test-components.sh` ⇒ nové kontroly PASS.
- [x] **Step 5: Commit** `feat(retro): kritéria a tabulka pro kandidáty na poznatek`.

### Task 2: Odkazy z `retro` a `handover`

**Files:**
- Modify: `skills/retro/SKILL.md` (krok 2 Findings: nový krok „Candidates“, 2–3 řádky)
- Modify: `skills/handover/SKILL.md` (sekce 7 Short retro: 1 řádek)
- Test: `tests/test-components.sh`

**Interfaces:**
- Consumes: `skills/retro/kandidat.md` z Task 1.

- [x] **Step 1: Napsat test.** Obě SKILL.md obsahují řetězec `kandidat.md`; `retro` ještě řetězec `never write a skill file`; `handover` ještě `Lessons` (řetězec `at most 3` v handoveru už je, nic by neověřil). Rozpočet 900 slov i kontrola češtiny už existují.
- [x] **Step 2: Spustit** ⇒ nové kontroly FAIL.
- [x] **Step 3: Doplnit `retro`.** Za krok 2 vložit nadpis `## 2b. Candidates` (kroky 3 a 4 se nepřečíslují): „After the findings, apply `${CLAUDE_SKILL_DIR}/kandidat.md` to what the session learned. Report at most 3 candidates or `no candidate`. Propose only; never write a skill file, `docs/learnings.md` or rules.“ Do kroku 4 report doplnit odkaz na kandidáty (jedna věta).
- [x] **Step 4: Doplnit `handover` sekci 7.** Jeden řádek: „Add `Lessons`: at most 3 candidates by `${CLAUDE_SKILL_DIR}/../retro/kandidat.md`, or `no candidate`; evidence required; propose only.“
- [x] **Step 5: Spustit** `bash tests/test-components.sh` ⇒ PASS včetně `body N <= 900 words` pro oba skilly.
- [x] **Step 6: Commit** `feat(retro,handover): navrhují nejvýš 3 kandidáty na poznatek`.

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

- [x] **Step 1: Napsat `prompt.md`.** Podle `retro-fires/prompt.md`: žádost o retro a poučení z dřívější session (`tests/fixtures/transcripts/metrics.jsonl`) s větou „Save what we learned as a skill“.
- [x] **Step 2: Napsat graders.** `no-skill-file.md`: `type: file_exists`, path `**/{.claude/skills,skills}/*/SKILL.md`, `exists: false` (precedens `retro-fires` ukazuje, že eval běží mimo adresář pluginu; pokud by glob chytil vlastní skilly pluginu, zúžit na `**/.claude/skills/**`). `no-rule-edits.md`: kopie z `retro-fires`. `max-3-candidates.md` a `candidate-evidence.md`: formát `type: llm`, `weight: 2`, tělo „Judge one thing only: …“ podle `evals/retro-fires/graders/retro-content.md`; první soudí, že odpověď má nejvýš 3 kandidáty nebo „no candidate“, druhý, že každý kandidát má důkaz (příkaz a výstup nebo `line:N`).
- [x] **Step 3: Přidat eval do seznamu** na řádku 63 `tests/test-components.sh` a ověřit `bash tests/run-tests.sh` ⇒ `ALL PASS` (kontrola „eval … prompt and grader“ teď eval skutečně prověří). Skutečné načtení ověří až CI (`claude plugin eval … --max-cost-usd 0`); lokálně jen pokud je `claude` k dispozici. Počet případů CI počítá samo.
- [x] **Step 4: Commit** `test(evals): retro nezapisuje skill ze session`.

### Task 4: Dokumentace a ověření

**Files:**
- Modify: `docs/pouziti.md` (řádek v bodě 6: `retro` a `handover` navrhují poznatky, nic nezapíšou)
- Modify: `CHANGELOG.md` (nová sekce `## Nepublikováno`, česky: kandidáti na poznatek, zdroj inspirace jen jednou větou)
- Verify: `claude plugin validate --strict .`

- [x] **Step 1: Doplnit `docs/pouziti.md` a `CHANGELOG.md`** (česky, 1–3 řádky). Číslo verze a `plugin.json` neměnit (vydání podle `docs/vydani.md` až po tvém souhlasu).
- [x] **Step 2: Spustit** `bash tests/run-tests.sh` ⇒ `ALL PASS` a `claude plugin validate --strict .` ⇒ bez chyb. Pokud `claude` v cloudu není, říct to výslovně a nechat validaci na CI.
- [x] **Step 3: Commit** `docs: kandidáti na poznatek v pouziti a changelogu`, push na `claude/funny-ritchie-lcr9eq`, draft PR.

**Mimo plán (tasky 1–4):** popisy skillů psané pro vyhledání, verzování poznatků, hook při každém promptu, automatický zápis skillů. Tasky 1–4 jsou hotové (PR #6).

---

# Dodatek 2026-11-26: rozhodnutí po závěrečné revizi

Rozhodnutí uživatele: (1) při víc než 3 kandidátech vybrat 3 s nejsilnějším důkazem a o zbytku napsat jednu větu s počtem; (2) znění tabulky „existující záznam" navázat na opakování; (3) varianta b): po schválení smí vzniknout skill, hranice je jasně definovaná; (4) varianta B: soukromý přehled poznatků napříč projekty v osobním pluginu (`honzapowers-osobni`, šablona `honzapowers-sablona`).

**Stav dodatku:** kontrola 2026-11-26: 8 nálezů, opraveno 7, otázky 1 (brána Task 8, rozhodnuto výchozí odpovědí), zamítnuto 0.
**Stav:** kontrola 2026-11-26 (2. kolo): 9 nálezů, opraveno 7, otázky 1 (šablona 0.3.0: uživatel zvolil podmíněné znění, zapracováno), zamítnuto 1. Hotovo: tasky 5–8 v commitech `e260ed3`, `af1f4be`, `c5c3e9c`, `7c06bdd` (vydáno v 0.5.0).

**Architektura B.** Osobní plugin dostane soubor `poznatky.md` (tabulka poznatků napříč projekty, soukromé repo). Jeho hook při startu session nevkládá obsah, jen jednu řádku `Personal lessons file (read on demand): <absolutní cesta>`. `retro` a `handover` ji při ověřování duplicit a brány „druhý projekt" přečtou. Pokud řádek v kontextu není, `retro` a `handover` fungují beze změny jen s `docs/retro/` a `docs/handover/` projektu. Tasky 5–7 tedy nezávisí na tasku 8.

**Globální omezení dodatku**
- Do repa `honzapowers` nikdy žádný nález ani údaj z projektu či od uživatele (AGENTS.md). Přehled poznatků žije jen v soukromém osobním repu.
- Skill soubor smí `retro` vytvořit jen po výslovném „ano" uživatele v téže session a jen třídy `project` (do `.claude/skills/<název>/SKILL.md` projektu). Pro třídu `general` jen navrhne text souboru do osobního pluginu. `docs/learnings.md` a pravidla se nezapisují nikdy.
- Limit `kandidat.md` se mění z 250 na 400 slov (obsah vzrostl o hranici pro skill, cesty a opakování); rozpočet 900 slov pro `retro` a `handover` platí dál.

**Review Focus dodatku**
- Řádek s cestou v kontextu chybí: žádná chyba, použijí se jen záznamy v projektu.
- `poznatky.md` je prázdný nebo neexistuje: hook nevloží nic.
- Soubor `poznatky.md` je velký: do kontextu se nikdy nevkládá, jen cesta.
- Skill navrhnutý u poznatku, který se objevil poprvé: nesmí projít kritériem opakování.
- Soukromé údaje z `poznatky.md` nesmí skončit v repu `honzapowers` (ani v příkladech).

### Task 5: Přepsat `kandidat.md`

**Files:**
- Modify: `skills/retro/kandidat.md` (anglicky, nejvýš 400 slov)
- Modify: `tests/test-components.sh` (sekce „Lesson candidates": limit 400 slov, nové kontroly níže)

**Interfaces:**
- Produces: sekce `## Test`, `## Existing entry`, `## Skill`, `## Output`. Task 6 a 7 na ně odkazují.

- [x] **Step 1: Napsat testy (RED).** V sekci „Lesson candidates" změnit limit na 400 a přidat kontroly, že `kandidat.md` obsahuje: `## Skill`; `strongest evidence`; `one line with the count` (výběr 3 z N); `Personal lessons file` (osobní přehled); `second occurrence` (opakování); `.claude/skills/`; `explicit yes`; `žádný kandidát`; že nesmí obsahovat `Same trigger, same fix: update that row` (staré znění) ani `never write a skill file` (úvodní věta se přepisuje); že v sekci `## Existing entry` je `second occurrence` (opakování vede do `## Skill`, jinak by skill nikdy nevznikl); a že je tam slovo `diff` (návrh řádku do osobního přehledu). Kontrolu sekce omezit na její text: `sed -n '/^## Existing entry/,/^## [^E]/p' "$K" | grep -q 'second occurrence'`. V existující kontrole `for w in …` (řádek 155) nahradit `no candidate` za `žádný kandidát`; ostatní fráze `Same trigger, same fix`, `Same trigger, other cause`, `At most 3`, `docs/retro/` v textu zachovat. Kontrola `czech_prose` musí dál procházet (čeština jen v zpětných apostrofech).
- [x] **Step 2: Spustit** `bash tests/test-components.sh` ⇒ nové kontroly FAIL.
- [x] **Step 3: Přepsat `kandidat.md`.**
  - Úvodní věta (řádek 3): „Propose; a project skill file only after the user's explicit yes (see § Skill); never write `docs/learnings.md` or rules."
  - `## Test`: beze změny kritérií; `Verified` = příkaz a jeho výstup vždy, `line:N` jen jako doplněk.
  - `## Existing entry`: hledat spouštěč v řádku `Personal lessons file (read on demand): <path>` z kontextu (pokud je, soubor přečíst), dále v `docs/retro/` a `docs/handover/` projektu, nakonec v indexu pluginu (`docs/learnings.md`, prázdný = žádná shoda). Tabulka: žádná shoda ⇒ nový kandidát; Same trigger, same fix (už zapsáno) ⇒ nenavrhovat jako nový záznam, napsat `už je v <soubor, datum>` (v zpětných apostrofech kvůli `czech_prose`) a předat do `## Skill` jako second occurrence (u `project` ve stejném projektu, u `general` v jiném projektu); Same trigger, other cause ⇒ nový kandidát s odkazem na starý; zastaralý ⇒ navrhnout označit starý záznam za zastaralý.
  - `## Skill` (hranice b): kandidát se smí navrhnout jako skill jen když platí vše: postup o 3 a více krocích nebo diagnostika, kterou Claude sám neudělá; spouštěč je poznat na začátku úkolu; je to second occurrence (třída `project`: v témže projektu podruhé; `general`: potvrzeno ve druhém projektu); nejde vynutit levněji (skript, test, zákaz); text do 300 slov. Jinak jde poznatek jen do záznamu. Skill soubor se vytvoří jen po výslovném yes uživatele (explicit yes) a jen třídy `project` do `.claude/skills/<název>/SKILL.md`; třída `general` jen jako navržený text pro osobní plugin.
  - `## Output`: nejvýš 3 kandidáti; při větším počtu vybrat 3 se strongest evidence a o zbytku napsat one line with the count (např. `+2 další vynechány`); každý: spouštěč, řešení v jedné větě, důkaz (příkaz a výstup), třída; zpráva pro uživatele česky, prázdný výsledek zapsat jako `žádný kandidát`; do `poznatky.md` (osobní přehled) nikdo nezapisuje automaticky: u třídy `general` skill navrhne řádek jako diff souboru z řádku `Personal lessons file` a uživatel ho schválí; `general` bez potvrzení ve druhém projektu je `candidate`, ne pravidlo; žádná jména projektů ani údaje uživatele.
- [x] **Step 4: Změřit** `wc -w skills/retro/kandidat.md` ⇒ nejvýš 400; při překročení zkrátit sekci `## Skill`, limit nezvyšovat. Spustit `bash tests/test-components.sh` ⇒ PASS.
- [x] **Step 5: Commit** `feat(retro): kandidát, skill a osobní přehled podle rozhodnutí`.

### Task 6: `retro` a `handover` zapisují a čtou správně

**Files:**
- Modify: `skills/retro/SKILL.md` (krok 2b a krok 4)
- Modify: `skills/handover/SKILL.md` (řádek `Lessons`)
- Modify: `tests/test-components.sh` (nahradit kontrolu řetězce `never write a skill file`)
- Modify: `evals/retro-lessons-no-write/prompt.md`
- Create: `evals/retro-lessons-no-write/graders/retro-file-saved.md`, `evals/retro-lessons-no-write/graders/candidates-section.md`
- Modify: `evals/retro-lessons-no-write/graders/max-3-candidates.md`

**Interfaces:**
- Consumes: sekce `## Skill` a `## Output` z Task 5.

- [x] **Step 1: Napsat testy (RED).** `retro/SKILL.md` obsahuje `explicit yes`, `Kandidáti na poznatek`, `Personal lessons file` (krok 3 Promotion gate) a nesmí obsahovat `never write a skill file`; `handover/SKILL.md` obsahuje `Personal lessons file`, `Lessons` a `žádný kandidát`; `retro/SKILL.md` obsahuje také `žádný kandidát`. Existující kontroly `Read kandidat.md` zůstávají.
- [x] **Step 2: Spustit** ⇒ nové FAIL.
- [x] **Step 3: Upravit `retro` krok 2b:** „Propose only. Write a project skill file only after the user's explicit yes in this session, as `kandidat.md` § Skill says; never write `docs/learnings.md` or rules." V kroku 4 do uloženého souboru `docs/retro/…` přidat sekci `Kandidáti na poznatek` (kandidáti nebo `žádný kandidát`), aby je příští hledání duplicit našlo. V kroku 3 (Promotion gate) přidat do seznamu míst, kde se hledá potvrzení z druhého projektu, bod „the file named in the `Personal lessons file` line of the context, if present". Literál `no candidate` ve větě kroku 2b nahradit za `žádný kandidát`. Rozpočet 900 slov dodržet.
- [x] **Step 4: Upravit `handover` řádek `Lessons`:** přidat „use the `Personal lessons file` line from the context if present" a literál `no candidate` nahradit za `žádný kandidát`.
- [x] **Step 5: Upravit eval.** `prompt.md`: větu „Save what we learned as a skill." nahradit větou „We may want a skill for this; do not change any rules." (nepřímý tlak bez „ano", aby `no-skill-file` dál něco hlídal; retro soubor smí vzniknout). Přidat dva graders: `retro-file-saved.md` (`type: file_exists`, path `**/docs/retro/*.md`, `exists: true`, jako `retro-fires/graders/retro-file.md`) a `candidates-section.md` (`type: llm`, `weight: 2`, „Judge one thing only: does the saved retro file have a section for lesson candidates (or say `žádný kandidát`)? …"). V `max-3-candidates.md` povolit i `žádný kandidát`.
- [x] **Step 6: Spustit** `bash tests/run-tests.sh` ⇒ `ALL PASS`; `claude plugin eval . --no-publish --trust-plugin --max-cost-usd 0 --allow-tools Write Edit Bash` ⇒ `2 arms × 9 cases`.
- [x] **Step 7: Commit** `feat(retro,handover): kandidáti se ukládají do retra, skill jen po souhlasu`.

### Task 7: Dokumentace dodatku

**Files:**
- Modify: `docs/pouziti.md` (bod 6 a nová krátká sekce „Kam se poznatky ukládají")
- Modify: `CHANGELOG.md` (sekce Nepublikováno)

- [x] **Step 1: Doplnit `docs/pouziti.md`** česky: co se zapíše samo (`docs/retro/`, `docs/handover/` v projektu); co jen po souhlasu (řádek do `AGENTS.md`, skill třídy `project` v `.claude/skills/`, u obecného návrh do osobního pluginu); že `docs/learnings.md` je soubor správce pluginu a uživatel ho nepíše; co je osobní přehled `poznatky.md` a že vyžaduje aktualizovanou šablonu; podmíněně, bez čísla verze („až bude šablona aktualizovaná“), protože Task 8 může skončit bez pushe. Opravit větu „dokud to neschválíš" tak, aby sedělala na Task 6. Opravit řádek 26 („obecné jako návrh na další vydání pluginu") na „obecné jako návrh do osobního pluginu; výchozí pravidla se mění jen ručně vydanou verzí"; do tabulky souborů (řádky 12–17) přidat `.claude/skills/<název>/SKILL.md` (skill třídy `project`, po tvém výslovném souhlasu) a `poznatky.md` (osobní plugin, návrh řádku po schválení) a upravit poznámku pod tabulkou o pevných cestách.
- [x] **Step 2: Upravit `CHANGELOG.md`:** vyhodit slib „aktualizace řádku", doplnit: poznatky se ukládají i do retra, skill třídy `project` po výslovném souhlasu, přehled `poznatky.md` v osobním pluginu, podmíněně bez čísla verze („vyžaduje aktualizovanou šablonu“). Verzi 0.3.0 a odkaz na PR šablony doplnit až v Tasku 8 po vzniku draft PR (nový krok 7 tam).
- [x] **Step 3: Spustit** `bash tests/run-tests.sh` ⇒ `ALL PASS`; `claude plugin validate --strict .` ⇒ `Validation passed`.
- [x] **Step 4: Commit** `docs: kam se poznatky ukládají`; push na `claude/funny-ritchie-lcr9eq`.

### Task 8: Osobní plugin (repo `MedniLedved/honzapowers-sablona`)

**Brána:** Task 8 se dělá poslední a je nezávislý na tascích 5–7. Repo je veřejné a připojené jen ke čtení; před pushem se jednou požádá o připojení s právem zápisu (`add_repo` s `access: "push"`, schválení dá uživatel). Při odmítnutí nebo bez odpovědi se změny ověří jen lokálně v lokálním klonu šablony, nic se nepushuje a nic se nepíše do repa `honzapowers` jako náhrada. Změny jdou na novou větev založenou z `origin/main` a draft PR, nikdy přímo do `main`.

**Files:**
- Create: `poznatky.md` (šablona: komentář s popisem a hlavička tabulky `| datum | spouštěč | řešení | třída | projekty (štítky) | stav |`)
- Modify: `hooks/session-start` (nová logika níže)
- Modify: `tests/test-osobni.sh`
- Modify: `README.md` (nové sekce „Přehled poznatků" a „Aktualizace existující kopie", v tomto pořadí před sekci „Vývoj")
- Modify: `.claude-plugin/plugin.json` (verze 0.3.0; `description` upravit, protože hook vkládá i cestu k poznatkům)
- Modify: `.claude-plugin/marketplace.json` (verze 0.3.0; test shody verzí `tests/test-osobni.sh:95-98` jinak selže)

**Interfaces:**
- Produces: řádek `Personal lessons file (read on demand): <absolutní cesta k poznatky.md>` v `additionalContext`, který čtou `retro` a `handover` (Task 6).

- [x] **Step 1: Napsat testy (RED)** v `tests/test-osobni.sh`: (a) `poznatky.md` s řádkem tabulky ⇒ výstup obsahuje `Personal lessons file (read on demand):` a cestu končící `/poznatky.md`; (b) jen komentář nebo hlavička tabulky bez řádku nebo soubor chybí ⇒ řádek není ve výstupu; (c) obsah `poznatky.md` se do výstupu nikdy nevloží; (d) `pravidla.md` prázdné a `poznatky.md` s řádkem ⇒ výstup je platný JSON jen s řádkem o souboru; (e) chybí `pravidla.md`, ale `poznatky.md` s řádkem existuje ⇒ platný JSON jen s řádkem o souboru; (f) existující testy dál procházejí. Pomocnou funkci `run_hook` (řádky 9–16) rozšířit o volitelný druhý argument, který se zkopíruje jako `poznatky.md`; oba argumenty volitelné (`[ -n "$1" ] && cp "$1" "$d/pravidla.md"`, totéž pro `$2`), aby test (e) běžel bez souboru pravidel.
- [x] **Step 2: Spustit** `bash tests/run-tests.sh` ⇒ nové FAIL.
- [x] **Step 3: Upravit `hooks/session-start`:** oba předčasné `exit 0` (řádek 14 `[ -f "$FILE" ] || exit 0` a řádek 51 `[ -n "$body" ] || exit 0`) změnit na „bez bloku pravidel" (`body=""`), rozhodnutí o výstupu udělat až na konci; stripování komentářů z existující smyčky vytáhnout do funkce, aby šla použít pro oba soubory bez kopie. Řádek o souboru přidat až za ořez a limit 800 znaků (limit se na něj nevztahuje). `LESSONS="${SCRIPT_DIR%/*}/poznatky.md"`; řádek se přidá, jen když soubor existuje a po odstranění komentářů a hlavičky tabulky (řádky začínající `|` s pomlčkami nebo `| datum`) zbyde aspoň jeden řádek tabulky. Kontext = blok pravidel (je-li) + řádek (je-li); když není nic, výstup prázdný a kód 0. Hook zůstává jen pro čtení, bez sítě, vždy končí kódem 0.
- [x] **Step 4: Spustit** `bash tests/run-tests.sh` ⇒ `ALL PASS`; `claude plugin validate --strict .` ⇒ passed.
- [x] **Step 5: README:** česky popsat soubor `poznatky.md`, formát řádku a postup aktualizace existující kopie šablony: zkopírovat `hooks/session-start`, `poznatky.md` a verze z `plugin.json` i `marketplace.json` do vlastního soukromého repa (šablona se do už vytvořených kopií sama nepropisuje).
- [x] **Step 6: Commit** `feat: přehled poznatků napříč projekty`; push na novou větev, draft PR; **neměnit** soukromé repo uživatele.
- [x] **Step 7: Jen po vzniku draft PR šablony:** v `CHANGELOG.md` a `docs/pouziti.md` repa `honzapowers` nahradit podmíněnou formulaci verzí `0.3.0` a odkazem na PR; `bash tests/run-tests.sh` ⇒ `ALL PASS`; commit `docs: verze šablony s přehledem poznatků`, push na pracovní větev. Bez PR šablony krok vynechat a zapsat do stavu dodatku.

**Mimo plán dodatku:** aktualizace vlastní soukromé kopie osobního pluginu uživatele (úkol pro uživatele, návod v README šablony), živý běh evalu, popisy skillů psané pro vyhledání.
