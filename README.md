# honzapowers

Plugin pro Claude Code, který drží session úsporné a navazující: na začátku vloží krátká pravidla a stav repa, u velkého kontextu navrhne předání (handover) a po práci pomůže změřit a zhodnotit session.

**Pro koho:** pro lidi, kteří s Claude Code pracují na delších úkolech přes víc session a chtějí méně opakování, kontrolu plánů a předání práce bez ztráty kontextu. Pravidla jsou doporučení pro Claude, ne technické omezení; vedení [Superpowers](https://github.com/obra/superpowers) je doporučené, ne povinné (bez nich platí záložní postup `F1`).

## Požadavky
- Claude Code (terminál, desktop nebo claude.ai/code) a účet s pluginy.
- `git` v repu, ve kterém pracuješ (stav repa a `git-signals.sh`).
- **Windows:** Git Bash. Hooky se spouští přes `hooks/run-hook.cmd`; bez Git Bash tiše skončí a plugin se zdánlivě nic nedělá.
- `python3` jen pro `mesicni-projektove-retro`.
- Superpowers: doporučené, ne nutné.

## Instalace
Na claude.ai: Customize → Plugins → Add → **Add marketplace** → `MedniLedved/honzapowers`, zapni **Sync automatically** a pak povol `honzapowers`. Synchronizuje se do terminálu na počítači i do cloudových session. Názvy tlačítek se mohou lišit podle verze aplikace.

V Claude Code (bez synchronizace účtu) zadej do příkazového řádku Claude Code, ne do shellu:

```text
/plugin marketplace add MedniLedved/honzapowers
/plugin install honzapowers@honzapowers
```

### Připnutá verze
Hooky pluginu běží při každé session bez dotazu, takže se automatická synchronizace hodí, když repu věříš. Chceš-li nové verze nejdřív vidět, připni se na tag vydání (tvar `honzapowers--vX.Y.Z`, seznam na [stránce tagů](https://github.com/MedniLedved/honzapowers/tags)):

```text
/plugin marketplace add MedniLedved/honzapowers#honzapowers--vX.Y.Z
/plugin install honzapowers@honzapowers
```

`X.Y.Z` nahraď existujícím tagem. Na novou verzi přejdeš příkazem `/plugin marketplace remove honzapowers` a novým `add` s novějším tagem. Automatické aktualizace marketplace se vypínají v `/plugin` na záložce Marketplaces. Na claude.ai připnutí ověřené není; tam si udělej fork repa a synchronizuj z něj.

## Ověření
Spusť novou session v repu a zeptej se: „Jaká pravidla (L1–L14, S1–S6) máš na začátku session?“ Claude je má vyjmenovat. V terminálu navíc `claude plugin list` ukáže `honzapowers` jako povolený. Když pravidla chybí, na Windows zkontroluj Git Bash.

## Návrat zpět
Plugin vypni na claude.ai (Customize → Plugins), nebo v nastavení Claude Code dej `"honzapowers@synced": false`. Nic dalšího se nemusí odstraňovat.

## Jak pracovat
Postup v praxi je v [`docs/pouziti.md`](docs/pouziti.md). Práh návrhu handoveru je výchozích 250k tokenů a počítá s velkým oknem; při okně 200k ho sniž, např. `HONZAPOWERS_HANDOVER_TOKENS=150000`. Rejstřík pravidel a nálezů: [`docs/learnings.md`](docs/learnings.md).

## Komponenty

| Komponenta | Co dělá |
|---|---|
| Hook `SessionStart` | Vloží krátká stálá pravidla (úsporný provoz `L1`–`L14`, vedení Superpowers `S1`–`S6`, viditelnost skillů `V1`, záložní postup `F1`, brány `G1`) a stručný stav repa: větev, rozpracovaný plán s počtem otevřených úkolů (ten, který jmenuje poslední handover, pokud existuje; jinak nejnovější podle názvu, nakonec `docs/plan.md`), poslední handover, navržený další krok. Jen cesty a počty, nikdy obsah souborů. |
| Hook `UserPromptSubmit` | Přečte velikost kontextu z posledního záznamu `usage` v přepisu. Při 250k tokenech (pro okno 200k nastav nižší práh, viz níže), pak po každých dalších +50k, přidá jednu poznámku: navrhni `pre-done` a potom `handover`, nic nespouštěj, dokud uživatel neodpoví. Přepsání: `HONZAPOWERS_HANDOVER_TOKENS`, `HONZAPOWERS_HANDOVER_STEP` (starší `LEAN_WORKFLOW_*` fungují jako záloha). |
| Hook `PreCompact` | Řekne kompaktaci, aby zachovala poslední výsledek ověření, otevřené brány souhlasu a stav úkolů. |
| Skill `handover` | Napíše datovaný handover (konvence projektu, výchozí `docs/handover/RRRR-MM-DD-<téma>.md`) s krátkým retro. Spustí se jen na přání nebo „ano“ uživatele; nejdřív zkontroluje `pre-done`; lokálně commit až po souhlasu, v cloudu hned commit na pracovní větev s nabídkou vrácení. |
| Skill `pre-done` | U architektonické práce, mazání dat a změny sdíleného rozhraní (jinak na požádání, viz `skilly-kdy-ktery`) dá před „hotovo“, PR nebo nevratným krokem (vydání, migrace do produkce) diff zkontrolovat revizorovi v čistém kontextu a u UI toků projde hlavní cestu ručně. |
| Skill `kontrola-planu` | Před provedením zkontroluje napsaný plán čtecími agenty `kontrola-souladu` a `kontrola-auditu` (druhý jen u plánů nad 3 úkoly), roztřídí nálezy (opravit, zeptat se, zamítnout) a navrhne poučení do `.claude/kontrola-planu.md` projektu. |
| Skill `skilly-kdy-ktery` | Třídy práce a standardní cesta skilly, kdy je na řadě `pre-done`, `retro` a `handover`. |
| Skill `mesicni-projektove-retro` | Retrospektiva projektu za období: objektivní signály z gitu (`git-signals.sh`), čísla z CI a v cloudu i vlastní zprávy uživatele z přepisů session (`human-messages.py`). Nezávislý analytik navrhne nejvýš 3 změny pravidel s důkazy. Výchozí policy nikdy neupravuje. |
| Skill `retro` | Změří session pomocí `scripts/session-metrics` a navrhne nejvýš 5 roztříděných nálezů (ID pravidla, obecné/projektové/jednorázové, příčka žebříčku pravidel). Kromě ceny session zapíše i vadu, kterou nechytily testy (kdo ji chytil, zda ji chytil test, riziko). Pravidla nikdy sám nemění. |
| Agent `log-reader` | Haiku; přečte dlouhý log a vrátí verdikt a řádky s chybou (≤ 30 řádků). |
| `scripts/session-metrics` | ≤ 30 řádků čísel z přepisu: růst kontextu, tokeny, volání nástrojů, opakované příkazy, opakované běhy testů, velké výstupy. Žádný obsah přepisu. |

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

Případy pro eval jsou v `evals/` (spouštění skillů, s ramenem bez pluginu). Spuštění zakládá skutečné agentní session na tvém účtu (počet případů v `evals/` × 3 běhy × 2 ramena; cena roste s počtem případů, proto strop `--max-cost-usd`):

```bash
claude plugin eval . --allow-tools Write Edit Bash --max-cost-usd 5
```

CI jen kontroluje, že se případy načtou (`--max-cost-usd 0`, žádný agent neběží).

Hooky jsou bash skripty bez přípony spouštěné přes `hooks/run-hook.cmd`, takže fungují i na Windows s Git Bash. Sdílené pomocné funkce jsou v `hooks/lib/`. Hooky vždy končí s kódem 0, jsou jen pro čtení (kromě stavového souboru session v `${CLAUDE_PLUGIN_DATA}`), nepoužívají síť ani `jq`.

## Licence

MIT, viz [`LICENSE`](LICENSE).
