# Postup vydání

1. Zvýšit verzi v `.claude-plugin/plugin.json` a ve stejném záznamu v `.claude-plugin/marketplace.json` (test to hlídá).
2. Doplnit `CHANGELOG.md`.
3. `bash tests/run-tests.sh` ⇒ `ALL PASS` a `claude plugin validate --strict .`.
4. Změny jdou přes pull request (`main` je chráněná, push přímo je zakázán). Po merge tag `honzapowers--vX.Y.Z` (stejný tvar jako `claude plugin tag`). Push tagu je **nevratný**, uživatelé s připnutou instalací na něj odkazují. Předtím ověř, že verze v `plugin.json` i `marketplace.json` je `X.Y.Z` a že cílový commit je v `main` se zeleným CI. Pak jedna z cest:
   - web GitHubu: Releases → Draft a new release → Choose a tag → nový tag `honzapowers--vX.Y.Z`, cíl `main` → Publish release;
   - `git tag -a honzapowers--vX.Y.Z -m "honzapowers X.Y.Z" <sha> && git push origin honzapowers--vX.Y.Z`;
   - v terminálu Claude Code `claude plugin tag --push`.
5. Claude.ai synchronizuje automaticky (nebo „Check for updates“); další session v terminálu i v cloudu načte novou verzi.

Výchozí policy (`policy/policy.md`) mění jen takto ručně vydaná verze, nikdy retro, kontrola plánu ani handover.
