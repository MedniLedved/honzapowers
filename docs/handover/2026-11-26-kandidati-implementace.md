# Handover 2026-11-26: kandidáti na poznatek, implementace tasků 5–8

## 1. Identita a cíl
Repo `MedniLedved/honzapowers`, větev `claude/funny-ritchie-lcr9eq`, [draft PR #6](https://github.com/MedniLedved/honzapowers/pull/6). Fáze: plán dodatku (tasky 5–8) je zkontrolovaný a připravený k provedení. Cíl a pracovní pravidla (česky, tykat, po fázích, nedoporučovat spouštění `claude` v terminálu, bez anglicismů s českou koncovkou) viz předchozí handover `docs/handover/2026-11-26-kandidati-na-poznatek.md`, sekce 1 a 3.

## 2. Hotovo v této session
- Druhá kontrola plánu (`kontrola-planu`, agenti `kontrola-souladu` + `kontrola-auditu` na Opusu, medium): 9 nálezů, opraveno 7, otázky 1, zamítnuto 1. Commity `4a6d129`, `23c2352`, pushnuto na `claude/funny-ritchie-lcr9eq`.
- Hlavní opravy: cesta ke klonu šablony (`/home/user/honzapowers-sablona`), seznam souborů v Tasku 6, starý bod Review Focus proti rozhodnutí 1, test sekce `## Existing entry` přes `sed`, fráze `už je v …` ve zpětných apostrofech (`czech_prose`), volitelné argumenty `run_hook`, nové sekce README šablony před „Vývoj“, větev šablony z `origin/main`.
- Založen `.claude/kontrola-planu.md` (1 bod: cesty v plánu ověřit před uložením).
- Důkaz: `bash tests/run-tests.sh` ⇒ `ALL PASS` po obou commitech.

## 3. Rozhodnutí uživatele (nová)
1. Šablonu 0.3.0 psát v Tasku 7 podmíněně, bez čísla verze. Verzi a odkaz na PR šablony doplní nový Task 8 Step 7, jen pokud draft PR šablony vznikne.
2. Soubor kritérií `.claude/kontrola-planu.md` založit (hotovo).
3. Zamítnuto: obava, že `claude plugin eval … --max-cost-usd 0` v Tasku 6 porušuje „živý eval nespouštět“. Jde jen o kontrolu načtení jako v CI; 9 případů ověřeno.
Starší rozhodnutí 1–5 platí beze změny (předchozí handover, sekce 3).

## 4. Otevřené a brány
- Tasky 5–8 neprovedené: 23 nezaškrtnutých kroků.
- Task 8 mění `MedniLedved/honzapowers-sablona`: před pushem `add_repo` s `access: "push"`, schvaluje uživatel. Při odmítnutí jen lokálně v klonu, nic nepushovat. Nikdy do `main`.
- Větve: implementační session může mít v systémových instrukcích jinou povolenou větev. Pokud se liší od `claude/funny-ritchie-lcr9eq`, před prvním pushem se zeptat.
- Merge PR #6, označení ready a vydání verze rozhoduje uživatel (G1).

## 5. Další krok
```bash
git fetch origin claude/funny-ritchie-lcr9eq && git checkout claude/funny-ritchie-lcr9eq
```
Pak inline `superpowers:executing-plans` od Tasku 5. Ověření po každém tasku: `bash tests/run-tests.sh` ⇒ `ALL PASS`. Task 8 poslední, po něm závěrečná revize větve (S3).

## 6. Soubory a pořadí čtení
1. Tento soubor.
2. `docs/plans/2026-11-25-kandidati-na-poznatek.md` od nadpisu „Dodatek 2026-11-26“ (tasky 5–8).
3. `docs/handover/2026-11-26-kandidati-na-poznatek.md`, sekce 3 a 4.
4. `skills/retro/kandidat.md`, `skills/retro/SKILL.md`, `skills/handover/SKILL.md`, `tests/test-components.sh` sekce „Lesson candidates“.
5. Šablona (Task 8): `hooks/session-start`, `tests/test-osobni.sh`, `README.md`.

## 7. Krátké retro
- 18 odpovědí, kontext z 83,8k na 115k (+31k), 97 % vstupu z cache, 17 volání nástrojů.
- Žádná opakovaná volání, opakované testy ani čtení celých velkých souborů.
- Největší výsledek: Bash 31 kB (výpis dodatku plánu pro ověření nálezů).
- Nálezy: (1) Chybná cesta ke klonu prošla první kontrolou plánu: `new`, `project` (už zapsáno do `.claude/kontrola-planu.md`).
- Lessons: `žádný kandidát`.
