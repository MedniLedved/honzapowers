# Postup vydání

1. Zvýšit verzi v `.claude-plugin/plugin.json` a ve stejném záznamu v `.claude-plugin/marketplace.json` (test to hlídá).
2. Doplnit `CHANGELOG.md`.
3. `bash tests/run-tests.sh` ⇒ `ALL PASS` a `claude plugin validate --strict .`.
4. Změny jdou přes pull request (`main` je chráněná, push přímo je zakázán). Po merge `claude plugin tag` (nevratné, dělá se až po merge a zeleném CI) a push tagu.
5. Claude.ai synchronizuje automaticky (nebo „Check for updates“); další session v terminálu i v cloudu načte novou verzi.

Výchozí policy (`policy/policy.md`) mění jen takto ručně vydaná verze, nikdy retro, kontrola plánu ani handover.
