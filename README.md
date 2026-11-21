# honzapowers

Plugin pro Claude Code, který drží session úsporné a navazující: na začátku vloží krátká pravidla a stav repa, u velkého kontextu navrhne předání (handover) a po práci pomůže změřit a zhodnotit session.

Původně vznikl jako `lean-workflow`; proměnné `LEAN_WORKFLOW_*` dál fungují jako záloha k `HONZAPOWERS_*`.

## Komponenty

| Komponenta | Co dělá |
|---|---|
| Hook `SessionStart` | Vloží krátká stálá pravidla (úsporný provoz `L1`–`L14`, vedení Superpowers `S1`–`S6`, viditelnost skillů `V1`, záložní postup `F1`, brány `G1`) a stručný stav repa: větev, nejnovější plán s počtem otevřených úkolů, poslední handover, navržený další krok. Jen cesty a počty, nikdy obsah souborů. |
| Hook `UserPromptSubmit` | Přečte velikost kontextu z posledního záznamu `usage` v přepisu. Při 250k tokenech, pak po každých dalších +50k, přidá jednu poznámku: navrhni `pre-done` a potom `handover`, nic nespouštěj, dokud uživatel neodpoví. Přepsání: `HONZAPOWERS_HANDOVER_TOKENS`, `HONZAPOWERS_HANDOVER_STEP` (starší `LEAN_WORKFLOW_*` fungují jako záloha). |
| Hook `PreCompact` | Řekne kompaktaci, aby zachovala poslední výsledek ověření, otevřené brány souhlasu a stav úkolů. |
| Skill `handover` | Napíše datovaný handover (konvence projektu, výchozí `docs/handover/RRRR-MM-DD-<téma>.md`) s krátkým retro. Spustí se jen na přání nebo „ano“ uživatele; nejdřív zkontroluje `pre-done`, commit až po souhlasu. |
| Skill `pre-done` | Před slovem „hotovo“ nebo PR dá diff zkontrolovat revizorovi v čistém kontextu a u UI toků projde hlavní cestu ručně. |
| Skill `kontrola-planu` | Před provedením zkontroluje napsaný plán čtecími agenty `kontrola-souladu` a `kontrola-auditu` (druhý jen u plánů nad 3 úkoly), roztřídí nálezy (opravit, zeptat se, zamítnout) a navrhne poučení do `.claude/kontrola-planu.md` projektu. |
| Skill `skilly-kdy-ktery` | Třídy práce a standardní cesta skilly, kdy je na řadě `pre-done`, `retro` a `handover`. |
| Skill `mesicni-projektove-retro` | Retrospektiva projektu za období: objektivní signály z gitu (`git-signals.sh`), čísla z CI a v cloudu i vlastní zprávy uživatele z přepisů session (`human-messages.py`). Nezávislý analytik navrhne nejvýš 3 změny pravidel s důkazy. Výchozí policy nikdy neupravuje. |
| Skill `retro` | Změří session pomocí `scripts/session-metrics` a navrhne nejvýš 5 roztříděných nálezů (ID pravidla, obecné/projektové/jednorázové, příčka žebříčku pravidel). Pravidla nikdy sám nemění. |
| Agent `log-reader` | Haiku; přečte dlouhý log a vrátí verdikt a řádky s chybou (≤ 30 řádků). |
| `scripts/session-metrics` | ≤ 30 řádků čísel z přepisu: růst kontextu, tokeny, volání nástrojů, opakované příkazy, opakované běhy testů, velké výstupy. Žádný obsah přepisu. |

Jak se s pluginem pracuje v praxi: [`docs/pouziti.md`](docs/pouziti.md).
Rejstřík pravidel a nálezů: [`docs/learnings.md`](docs/learnings.md).

## Instalace

Na claude.ai: Customize → Plugins → Add → **Add marketplace** → `MedniLedved/honzapowers`, zapni **Sync automatically** a pak povol `honzapowers`. Synchronizuje se do terminálu na počítači i do cloudových session.

V terminálu bez synchronizace účtu:

```bash
/plugin install honzapowers --marketplace MedniLedved/honzapowers
```

## Návrat zpět

Plugin vypni na claude.ai, nebo v nastavení dej `"honzapowers@synced": false`. Nic dalšího se nemusí odstraňovat.

## Vývoj

```bash
bash tests/run-tests.sh
```

```bash
claude plugin validate --strict .
```

```bash
claude --plugin-dir . plugin details honzapowers
```

```bash
bash scripts/session-metrics cesta/k/prepisu.jsonl
```

Případy pro eval jsou v `evals/` (spouštění skillů, s ramenem bez pluginu). Spuštění zakládá skutečné agentní session na tvém účtu (3 případy × 3 běhy × 2 ramena):

```bash
claude plugin eval . --allow-tools Write Edit Bash --max-cost-usd 5
```

CI jen kontroluje, že se případy načtou (`--max-cost-usd 0`, žádný agent neběží).

Hooky jsou bash skripty bez přípony spouštěné přes `hooks/run-hook.cmd`, takže fungují i na Windows s Git Bash. Sdílené pomocné funkce jsou v `hooks/lib/`. Hooky vždy končí s kódem 0, jsou jen pro čtení (kromě stavového souboru session v `${CLAUDE_PLUGIN_DATA}`), nepoužívají síť ani `jq`.

## Licence

MIT, viz [`LICENSE`](LICENSE).
