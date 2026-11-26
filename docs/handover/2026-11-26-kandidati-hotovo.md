# Handover 2026-11-26: kandidáti na poznatek, hotovo a mergnuto

## 1. Identita a cíl
Repo `MedniLedved/honzapowers` (plugin) a `MedniLedved/honzapowers-sablona` (osobní plugin, šablona). Větev této session `claude/eloquent-pascal-p9jk4i`, fáze: plán `docs/plans/2026-11-25-kandidati-na-poznatek.md` (tasky 1–8) je dokončený, zkontrolovaný (`pre-done`) a mergnutý. Cíl viz `docs/handover/2026-11-26-kandidati-na-poznatek.md`, sekce 1.

## 2. Hotovo v této session
- Tasky 5–7 a úprava handoveru, mergnuto: PR #7 (`b87a828`), oprava po `pre-done` PR #9 (`da80ca5`). Důkaz: `bash tests/run-tests.sh` ⇒ `ALL PASS`, CI zelené (`validate`, `hooks (ubuntu-latest)`, `hooks (windows-latest)`) na posledním commitu.
- Task 8 v šabloně, mergnuto: PR #8 `honzapowers-sablona` (`bfe2a78`, verze 0.3.0, `poznatky.md`, hook vkládá jen cestu). Drobnosti z revize opraveny před merge.
- Závěrečná revize (Sonnet, high) i `pre-done` (Sonnet, high) našly po 2 Important; opraveno s testem, který nejdřív selhal (kritérium pro větu s povolením pushe, shoda jen z dřívější session, cesta osobního souboru se do repa neukládá, čárka v `kandidat.md`).
- PR #6 (stará větev `funny-ritchie`) zavřený.

## 3. Rozhodnutí
- Zůstat na větvi `claude/eloquent-pascal-p9jk4i` místo `funny-ritchie` (je jeho potomek, nic se nerozešlo).
- Handover navrhuje hotovou větu k vložení s větví; klauzule „push tam máš povolený“ jen pro větev přidělenou prostředím.
- Nezastavit na pochybnostech u cesty kontejneru a preferencí v `docs/`: ponecháno, rozhodnutí na tobě (viz 4).

## 4. Otevřené a brány
- **Plán a handovery v `docs/`** obsahují cestu kontejneru a pracovní preference uživatele (`docs/plans/…:171`, `docs/handover/2026-11-26-kandidati-implementace.md:8`, `…-na-poznatek.md:4,46`). Repo je veřejné: nechat, nebo přepsat/vyřadit?
- **Vydání verze `honzapowers`** podle `docs/vydani.md` (CHANGELOG má záznamy pod „Nepublikováno“). Rozhoduje uživatel (G1).
- **Soukromá kopie osobního pluginu:** aktualizovat podle sekce „Aktualizace existující kopie“ v README šablony.
- **Staré větve** ke smazání uživatelem: `claude/funny-ritchie-lcr9eq`, `claude/eloquent-pascal-p9jk4i` (po mergi tohoto handoveru), `claude/prehled-poznatku` v šabloně.
- Odložené drobnosti: `handover` neříká, kam zapsat kandidáty (`docs/retro/` pod `Kandidáti na poznatek`); hook šablony bere řádek se samotnou pomlčkou jako data; odkaz na PR #8 v `CHANGELOG.md` může zastarat; push s `--force-with-lease` zamítl klasifikátor, větev se restartovala slučováním `main`.

## 5. Další krok
Rozhodnout body v sekci 4 (zejména soukromé údaje v `docs/` a vydání verze). Ověření: `bash tests/run-tests.sh` ⇒ `ALL PASS`, `claude plugin validate --strict .` ⇒ `Validation passed`.

Věta k vložení do nové session: `Pracuj na větvi claude/eloquent-pascal-p9jk4i, push tam máš povolený.`

## 6. Soubory a pořadí čtení
1. Tento soubor.
2. `docs/plans/2026-11-25-kandidati-na-poznatek.md` (stav po tascích 5–8).
3. `skills/retro/kandidat.md`, `skills/handover/SKILL.md` (řádek „Next step“), `docs/pouziti.md` (sekce „Kam se poznatky ukládají“).

## 7. Krátké retro
- Kontext 82,5k → 262k (+179k), 99 % vstupu z cache, 122 volání nástrojů, 0 opakovaných testů bez změny.
- Největší výsledek: `mcp__github__actions_list` 88,1 kB (`line:603`); `ReadNotifications` 19× při čekání na CI.
- Nálezy: (1) Filtr `head_sha` u `actions_list` se ignoroval a vrátil 50 běhů, 88 kB (`line:603`): L3, class `one-off`. (2) Handover počítal s jinou větví než cloudová session, což stálo kolo dotazů: opraveno větou k vložení (L14, class `project`). (3) Čekání na CI přes 19 samostatných notifikací: L5, class `one-off`.
- Lessons: kandidát (class `general`, zatím jen z jednoho projektu, takže jen `candidate`, ne pravidlo): spouštěč `mcp__github__actions_list` s `workflow_runs_filter.head_sha` vrací všechny běhy; řešení: kontroly PR číst přes `pull_request_read` s `get_check_runs`; důkaz: výstup 88,1 kB, `line:603`.
