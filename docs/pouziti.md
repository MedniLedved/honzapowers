# Jak se s honzapowers pracuje

## Běžný průběh
1. **Začátek session.** Hook vloží krátká stálá pravidla a stav repa (větev, rozpracovaný plán a počet otevřených úkolů – ten, který jmenuje poslední handover, pokud existuje; jinak nejnovější podle názvu, nakonec `docs/plan.md` –, poslední handover, navržený další krok). Nic dalšího nedělej, jen začni pracovat.
2. **Před větší prací.** U nového plánu spusť skill `kontrola-planu`; plán zkontrolují čtecí agenti dřív, než se začne psát kód.
3. **Před „hotovo“.** U architektonické práce, mazání dat a změny sdíleného rozhraní spusť `pre-done` (jinak jen na požádání): revizor v čistém kontextu porovná diff se zadáním a pravidly projektu. Totéž před vydáním nebo migrací do produkce, pokud od poslední revize přibyla taková změna (i když plán krok označuje „žádný kód“).
4. **U velkého kontextu.** Od 250k tokenů (pak po každých +50k) přijde návrh na `pre-done` a `handover`. Je to jen návrh: nic se nespustí, dokud neodpovíš.
5. **Konec nebo pauza.** Řekni „handover“ (nebo odpověz „ano“ na návrh). Vznikne datovaný soubor s tím, co je hotové, co je otevřené a co číst jako první; další session na něj naváže.
6. **Po delší době.** Skill `retro` změří jednu session (i vadu, kterou nechytily testy), `mesicni-projektove-retro` projde projekt za období. Obojí jen navrhuje, pravidla sám nemění. `retro` i `handover` k tomu nabídnou nejvýš 3 kandidáty na poznatek (kritéria jsou v `skills/retro/kandidat.md`). Kandidáti jsou jen návrh: do `AGENTS.md`, do skillu ani do osobního přehledu se nezapíše nic, dokud to výslovně neschválíš.

## Soubory, které plugin vytváří v projektech
| Soubor | Kdo ho vytváří | K čemu |
|---|---|---|
| `docs/handover/RRRR-MM-DD-<téma>.md` | skill `handover` | předání práce další session, včetně krátkého retro; lokálně se commituje až po tvém souhlasu, v cloudu se hned commitne na pracovní větev (kontejner by zmizel) a nabídne se vrácení |
| `docs/retro/RRRR-MM-DD-<téma>.md` | skill `retro` | změřená session s nálezy |
| `docs/retro/RRRR-MM-DD-obdobi-<téma>.md` | skill `mesicni-projektove-retro` | retrospektiva projektu za období |
| `.claude/kontrola-planu.md` | skill `kontrola-planu` (po tvém schválení) | kritéria kontroly plánu specifická pro projekt, nejvýš 15 bodů |
| `.claude/skills/<název>/SKILL.md` | skill `retro` (po tvém výslovném souhlasu) | skill třídy `project`, jen u poznatku, který se v projektu objevil podruhé |
| `poznatky.md` | osobní plugin (návrh řádku po tvém schválení) | přehled obecných poznatků napříč projekty; vyžaduje šablonu 0.3.0 ([PR](https://github.com/MedniLedved/honzapowers-sablona/pull/8)) |

Skill `handover` se řídí konvencí projektu (cesta `docs/handover/` je jen výchozí). Cesty skillů `retro`, `mesicni-projektove-retro`, `kontrola-planu` a `.claude/skills/` jsou pevné.

## Na které úrovni pravidla platí
1. **Výchozí** (plugin): `policy/policy.md`, vkládá se při startu session, po `/clear` a po kompaktaci (ne při `resume` a `fork`, tam přijde jen stav repa). Mění se jen ručně vydanou verzí pluginu, nikdy retrem, kontrolou plánu ani handoverem.
2. **Uživatel**: tvůj `~/.claude/CLAUDE.md` a osobní vrstva, tj. vlastní pravidla v osobním pluginu vytvořeném ze šablony `honzapowers-sablona` (soubor `pravidla.md`, max 800 znaků). Platí ve všech tvých projektech, doplňují výchozí pravidla a při střetu s nimi vyhrávají. Číslo S3 je vyhrazené pro tvoje osobní pravidlo (výchozí policy ho nepoužívá), další vlastní pravidla čísluj třeba M1, M2…
3. **Projekt**: `CLAUDE.md` / `AGENTS.md` repa a `.claude/kontrola-planu.md`. Při střetu vyhrává projekt, pak uživatel, nakonec výchozí pravidla pluginu; stojí to v první řádce policy.

Nový poznatek patří tam, kde platí: jednorázové věci nikam, projektové do projektu, obecné jako návrh do osobního pluginu; výchozí pravidla se mění jen ručně vydanou verzí.

## Kam se poznatky ukládají
- **Samo:** do `docs/retro/` a `docs/handover/` projektu (sekce `Kandidáti na poznatek`); podle nich se příště hledají duplicity.
- **Jen po tvém souhlasu:** řádek do `AGENTS.md`, skill třídy `project` do `.claude/skills/` a u obecného poznatku návrh do osobního pluginu.
- **Nikdy:** `docs/learnings.md` je soubor správce pluginu, uživatel ho nepíše a skilly ho nemění.
- **Osobní přehled `poznatky.md`:** soubor v osobním pluginu s obecnými poznatky napříč projekty. Hook do kontextu vloží jen jeho cestu, ne obsah. Vyžaduje šablonu `honzapowers-sablona` 0.3.0 ([PR](https://github.com/MedniLedved/honzapowers-sablona/pull/8)); postup aktualizace existující kopie popisuje README šablony.

## Nastavení
- `HONZAPOWERS_HANDOVER_TOKENS` – práh prvního návrhu handoveru (výchozí 250000).
- `HONZAPOWERS_HANDOVER_STEP` – další upozornění po tolika tokenech (výchozí 50000).
- `HONZAPOWERS_RESUME_TOKENS` – po `resume` nebo `fork` s vypršenou cache promptu a kontextem aspoň tolik tokenů hook navrhne handover a novou session (výchozí 50000).
- Starší proměnné `LEAN_WORKFLOW_*` fungují jako záloha.

## Doplňkové pluginy

Vedle HP můžeš zapnout další pluginy. Tabulka uvádí jen to, co ověřil pokus v cloudové session (Sonnet medium, 2 session bez pluginů a 2 s nimi); co se nezkoušelo, je označeno „nevyzkoušeno“. Měřilo se `Context tokens: first` přes `retro`: průměr bez pluginů 84,1k, s `claude-md-management` a `hookify` 84,05k, tedy bez znatelného nárůstu.

| Plugin | K čemu vedle HP | Kde funguje | Verdikt |
|---|---|---|---|
| `claude-md-management` | audit `CLAUDE.md` / `AGENTS.md` (`claude-md-improver`) a návrhy zápisu poznatků do souboru s pravidly (`/revise-claude-md`) | cloud: ano; terminál: nevyzkoušeno | doporučeno |
| `hookify` | pravidla jako soubor `.claude/hookify.*.local.md`, např. varování před příkazem | cloud: volá se jako skill `/hookify:hookify`, pravidlo vznikne a je `enabled`, varování se ale při `echo` neukázalo; terminál: nevyzkoušeno | v cloudu nefunguje (příčina nezměřena), lokálně nevyzkoušeno |
| `pr-review-toolkit` | revize změn více agenty; alternativa k revizoru z `pre-done` | cloud: v jednom běhu na 10řádkovém diffu zachytil vloženou tichou chybu (`\|\| true`) jako `pre-done`, ale nenašel chybějící test; podagenty nespustil; plugin zvedl kontext na startu o ~4k (84,4k → 88,4k) | jeden běh, nerozhoduje; `pre-done` stačí |
| `episodic-memory` | paměť napříč session; překrývá se s `handover` | jen lokálně | nevyzkoušeno |
| `claude-hud` | stavový panel, ukazuje zaplnění kontextu; hodí se jen při lokální práci | jen lokálně | nevyzkoušeno |

`/revise-claude-md` navrhuje zápisy do `AGENTS.md`, `CLAUDE.md` nezakládá. S `handover` se potkává jen u poznatků ze session; `handover` píše do `docs/handover/`. Navržené změny posuzuj sám, plugin je nepřijímá za tebe.

Pokud pravidla `hookify` zkoušíš lokálně, přidej do `.gitignore` řádek `.claude/*.local.md`, ať se testovací pravidlo omylem nedostane do commitu.

**Tvrdé pravidlo bez pluginu.** Stejnou službu jako hookify udělá soubor `.claude/settings.json` v repu. Zkoušeno v cloudové session na větvi jiné než `main`: hook `PreToolUse` na Bash příkaz zablokoval s hláškou hooku, a pravidlo `permissions.deny` (`Bash(echo …:*)`) příkaz odmítlo hláškou oprávnění; neutrální příkaz proběhl. Na rozdíl od `hookify`, který se v cloudu nepotvrdil, tedy tahle cesta v cloudu funguje. Soubor se dostane do repa commitem, proto ho dávej jen tam, kam ho tým chce; lokální terminál nevyzkoušen.

**Nedoporučujeme:**
- `claude-mem` a `context-mode`: vkládají kontext na startu session a při PreCompact podruhé, takže zdvojují to, co už dělá HP.
- Samoučící pluginy (claude-smart a podobné): mění pravidla bez tvého souhlasu, což odporuje bráně G1.

## Co plugin nedělá
Nečte obsah souborů při startu (jen cesty a počty), nepoužívá síť, nic nepushuje a nic nemaže bez tvého souhlasu.
