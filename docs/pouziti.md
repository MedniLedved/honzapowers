# Jak se s honzapowers pracuje

## Běžný průběh
1. **Začátek session.** Hook vloží krátká stálá pravidla a stav repa (větev, rozpracovaný plán a počet otevřených úkolů – ten, který jmenuje poslední handover, pokud existuje; jinak nejnovější podle názvu, nakonec `docs/plan.md` –, poslední handover, navržený další krok). Nic dalšího nedělej, jen začni pracovat.
2. **Před větší prací.** U nového plánu spusť skill `kontrola-planu`; plán zkontrolují čtecí agenti dřív, než se začne psát kód.
3. **Před „hotovo“.** U architektonické práce, mazání dat a změny sdíleného rozhraní spusť `pre-done` (jinak jen na požádání): revizor v čistém kontextu porovná diff se zadáním a pravidly projektu.
4. **U velkého kontextu.** Od 250k tokenů (pak po každých +50k) přijde návrh na `pre-done` a `handover`. Je to jen návrh: nic se nespustí, dokud neodpovíš.
5. **Konec nebo pauza.** Řekni „handover“ (nebo odpověz „ano“ na návrh). Vznikne datovaný soubor s tím, co je hotové, co je otevřené a co číst jako první; další session na něj naváže.
6. **Po delší době.** Skill `retro` změří jednu session, `mesicni-projektove-retro` projde projekt za období. Obojí jen navrhuje, pravidla sám nemění. `retro` i `handover` k tomu nabídnou nejvýš 3 kandidáty na poznatek (kritéria jsou v `skills/retro/kandidat.md`). Kandidáti jsou jen návrh: do `AGENTS.md`, do skillu ani do osobního přehledu se nezapíše nic, dokud to výslovně neschválíš.

## Soubory, které plugin vytváří v projektech
| Soubor | Kdo ho vytváří | K čemu |
|---|---|---|
| `docs/handover/RRRR-MM-DD-<téma>.md` | skill `handover` | předání práce další session, včetně krátkého retro; lokálně se commituje až po tvém souhlasu, v cloudu se hned commitne na pracovní větev (kontejner by zmizel) a nabídne se vrácení |
| `docs/retro/RRRR-MM-DD-<téma>.md` | skill `retro` | změřená session s nálezy |
| `docs/retro/RRRR-MM-DD-obdobi-<téma>.md` | skill `mesicni-projektove-retro` | retrospektiva projektu za období |
| `.claude/kontrola-planu.md` | skill `kontrola-planu` (po tvém schválení) | kritéria kontroly plánu specifická pro projekt, nejvýš 15 bodů |
| `.claude/skills/<název>/SKILL.md` | skill `retro` (po tvém výslovném souhlasu) | skill třídy `project`, jen u poznatku, který se v projektu objevil podruhé |
| `poznatky.md` | osobní plugin (návrh řádku po tvém schválení) | přehled obecných poznatků napříč projekty; vyžaduje aktualizovanou šablonu |

Skill `handover` se řídí konvencí projektu (cesta `docs/handover/` je jen výchozí). Cesty skillů `retro`, `mesicni-projektove-retro`, `kontrola-planu` a `.claude/skills/` jsou pevné.

## Na které úrovni pravidla platí
1. **Výchozí** (plugin): `policy/policy.md`, vkládá se při startu session, po `/clear` a po kompaktaci (ne při `resume` a `fork`, tam přijde jen stav repa). Mění se jen ručně vydanou verzí pluginu, nikdy retrem, kontrolou plánu ani handoverem.
2. **Uživatel** (osobní vrstva): vlastní pravidla v osobním pluginu vytvořeném ze šablony `honzapowers-sablona` (soubor `pravidla.md`, max 800 znaků). Platí ve všech tvých projektech a doplňuje výchozí pravidla. Číslo S3 je vyhrazené pro tvoje osobní pravidlo (výchozí policy ho nepoužívá), další vlastní pravidla čísluj třeba M1, M2…
3. **Projekt**: `CLAUDE.md` / `AGENTS.md` repa a `.claude/kontrola-planu.md`. Při střetu s pravidly pluginu vyhrává projekt; stojí to v první řádce policy.

Nový poznatek patří tam, kde platí: jednorázové věci nikam, projektové do projektu, obecné jako návrh do osobního pluginu; výchozí pravidla se mění jen ručně vydanou verzí.

## Kam se poznatky ukládají
- **Samo:** do `docs/retro/` a `docs/handover/` projektu (sekce `Kandidáti na poznatek`); podle nich se příště hledají duplicity.
- **Jen po tvém souhlasu:** řádek do `AGENTS.md`, skill třídy `project` do `.claude/skills/` a u obecného poznatku návrh do osobního pluginu.
- **Nikdy:** `docs/learnings.md` je soubor správce pluginu, uživatel ho nepíše a skilly ho nemění.
- **Osobní přehled `poznatky.md`:** soubor v osobním pluginu s obecnými poznatky napříč projekty. Hook do kontextu vloží jen jeho cestu, ne obsah. Vyžaduje aktualizovanou šablonu `honzapowers-sablona`; až bude šablona aktualizovaná, popíše postup její README.

## Nastavení
- `HONZAPOWERS_HANDOVER_TOKENS` – práh prvního návrhu handoveru (výchozí 250000).
- `HONZAPOWERS_HANDOVER_STEP` – další upozornění po tolika tokenech (výchozí 50000).
- `HONZAPOWERS_RESUME_TOKENS` – po `resume` nebo `fork` s vypršenou cache promptu a kontextem aspoň tolik tokenů hook navrhne handover a novou session (výchozí 50000).
- Starší proměnné `LEAN_WORKFLOW_*` fungují jako záloha.

## Co plugin nedělá
Nečte obsah souborů při startu (jen cesty a počty), nepoužívá síť, nic nepushuje a nic nemaže bez tvého souhlasu.
