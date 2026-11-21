# AGENTS.md — honzapowers

Vývojová pravidla tohoto repa (plugin pro Claude Code).

## Testy a ověření
- Před každým pushem: `bash tests/run-tests.sh` ⇒ `ALL PASS`.
- Při změně pluginu nebo marketplace: `claude plugin validate --strict .` (dělá to i CI).
- Verze v `plugin.json` a v záznamu marketplace se shodují (test).

## Pravidla obsahu
- Policy (`policy/policy.md`) je **anglicky** a má max **3 200 znaků** (test rozpočtu v `tests/test-components.sh`).
- Skilly a agenti jsou **česky**, výstupy uživateli česky. Názvy pluginu, skillů a agentů: ASCII, malá písmena, pomlčky.
- Skill nevynucuje pevný příkaz projektu (např. testovací).
- Žádná pravidla, nálezy ani údaje z konkrétních projektů či uživatelů. Příklady jsou vymyšlené.
- Žádné tajné hodnoty v souborech ani commit zprávách.
- Výchozí policy se mění jen ručně vydanou verzí.

## Vydání
Postup je v `docs/vydani.md`.
