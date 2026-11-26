# Handover 2026-11-26: kandidáti na poznatek

## 1. Identita a cíl
Repo `MedniLedved/honzapowers`, větev `claude/funny-ritchie-lcr9eq`, [draft PR #6](https://github.com/MedniLedved/honzapowers/pull/6). Cíl: `retro` a `handover` navrhují nejvýš 3 poznatky ze session (inspirace Claudeception a continuous-learning-skill; bez hooku při každém promptu, bez automatického zápisu). Komunikace česky, tykat, velké úkoly po fázích. Uživatel nechce, aby se mu doporučovalo spouštět `claude` v terminálu (živý eval proto neběží, viz bod 4). Bez anglicismů s českou koncovkou.

## 2. Hotovo (s důkazem)
- Tasky 1–4 (kritéria `skills/retro/kandidat.md`, odkazy z `retro`/`handover`, eval `retro-lessons-no-write`, docs a CHANGELOG): `bash tests/run-tests.sh` ⇒ `ALL PASS`, `claude plugin validate --strict .` ⇒ passed, 141 kontrol v `tests/test-components.sh`.
- Závěrečná revize větve provedena (4 důležité nálezy opraveny, commit `92b56b7`).
- Dodatek plánu (tasky 5–8) napsán a prošel kontrolou plánu (8 nálezů, 7 opraveno, 1 otázka rozhodnuta výchozí odpovědí). CI na všech commitech zelené, poslední `f2dbd91`.

## 3. Rozhodnutí uživatele
1. Při víc než 3 kandidátech vybrat 3 s nejsilnějším důkazem, o zbytku jedna věta s počtem.
2. Znění tabulky „existující záznam" navázat na opakování (opakovaný poznatek se nenavrhuje znovu, ale posoudí se jako skill).
3. Varianta b): skill smí vzniknout po výslovném „ano", jen třída `project` do `.claude/skills/`; obecný jen jako návrh textu pro osobní plugin. Hranice v plánu (Task 5, sekce `## Skill`).
4. Varianta B: soukromý přehled poznatků `poznatky.md` v osobním pluginu (šablona `honzapowers-sablona`); hook vkládá jen cestu k souboru.
5. Živý eval zatím nespouštět.
Jediné rozhodnutí agenta: glob v graderu `no-skill-file` (`**/{.claude/skills,skills}/*/SKILL.md`); při falešném selhání zúžit na `**/.claude/skills/**`.

## 4. Otevřené a brány
- Tasky 5–8 jsou neprovedené (22 nezaškrtnutých kroků v plánu).
- Task 8 mění cizí repo `MedniLedved/honzapowers-sablona`: je jen ke čtení, před pushem jednou požádat o připojení (`add_repo` s právem zápisu), schvaluje uživatel. Při odmítnutí jen lokálně, nic nepushovat. Nikdy přímo do `main`.
- Merge PR #6 a vydání verze rozhoduje uživatel (G1). Draft PR označit ready až na jeho pokyn.
- Šablona se do hotových kopií osobního pluginu nepropisuje: uživatel si svou soukromou kopii aktualizuje ručně (návod do README šablony, Task 8).
- Ledger a `.superpowers/` jsou lokální a v nové session zmizí; tasky 1–4 jsou ověřené v gitu (`git log`).

## 5. Další krok
V nové session: `git fetch origin claude/funny-ritchie-lcr9eq && git checkout claude/funny-ritchie-lcr9eq`, pak inline `superpowers:executing-plans` od Tasku 5 podle dodatku plánu. Ověření po každém tasku: `bash tests/run-tests.sh` ⇒ `ALL PASS`. Task 8 poslední; po něm závěrečná revize celé větve.

## 6. Soubory a pořadí čtení
1. `docs/plans/2026-11-25-kandidati-na-poznatek.md`, od nadpisu „Dodatek 2026-11-26".
2. `skills/retro/kandidat.md`, `skills/retro/SKILL.md`, `skills/handover/SKILL.md`.
3. `tests/test-components.sh`, sekce „Lesson candidates" (konec souboru).
4. Šablona (klon `git clone --depth 1 https://github.com/MedniLedved/honzapowers-sablona`): `hooks/session-start`, `tests/test-osobni.sh`, `README.md`.

## 7. Krátké retro
- Kontext vyrostl z 84k na 242k (+157k) při 82 odpovědích; 97 % vstupu z cache.
- Největší výsledky: `ReadNotifications` 22,9 kB (8 volání), úpravy souboru plánu po 22 kB.
- Nálezy: (1) 8× `ReadNotifications` s dlouhým pevným textem v každém výsledku: L2, one-off (chování nástroje). (2) 6 úprav jednoho souboru bez běhu příkazu (plán): L14, one-off (hromadné opravy po kontrole, bez dopadu).
- Lessons: `žádný kandidát`.
