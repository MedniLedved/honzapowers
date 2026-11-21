# Postup vydání

1. Zvýšit verzi v `.claude-plugin/plugin.json` a ve stejném záznamu v `.claude-plugin/marketplace.json` (test to hlídá).
2. Doplnit `CHANGELOG.md`.
3. `bash tests/run-tests.sh` ⇒ `ALL PASS` a `claude plugin validate --strict .`.
4. `claude plugin tag`, pak push na `main`.
5. Claude.ai synchronizuje automaticky (nebo „Check for updates“); další session v terminálu i v cloudu načte novou verzi.

Výchozí policy (`policy/policy.md`) mění jen takto ručně vydaná verze, nikdy retro, kontrola plánu ani handover.
