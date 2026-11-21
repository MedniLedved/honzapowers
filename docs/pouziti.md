# Jak se s honzapowers pracuje

## Běžný průběh
1. **Začátek session.** Hook vloží krátká stálá pravidla a stav repa (větev, nejnovější plán a počet otevřených úkolů, poslední handover, navržený další krok). Nic dalšího nedělej, jen začni pracovat.
2. **Před větší prací.** U nového plánu spusť skill `kontrola-planu`; plán zkontrolují čtecí agenti dřív, než se začne psát kód.
3. **Před „hotovo“.** Spusť `pre-done`: revizor v čistém kontextu porovná diff se zadáním a pravidly projektu.
4. **U velkého kontextu.** Od 250k tokenů (pak po každých +50k) přijde návrh na `pre-done` a `handover`. Je to jen návrh: nic se nespustí, dokud neodpovíš.
5. **Konec nebo pauza.** Řekni „handover“ (nebo odpověz „ano“ na návrh). Vznikne datovaný soubor s tím, co je hotové, co je otevřené a co číst jako první; další session na něj naváže.
6. **Po delší době.** Skill `retro` změří jednu session, `mesicni-projektove-retro` projde projekt za období. Obojí jen navrhuje, pravidla sám nemění.

## Soubory, které plugin vytváří v projektech
| Soubor | Kdo ho vytváří | K čemu |
|---|---|---|
| `docs/handover/RRRR-MM-DD-<téma>.md` | skill `handover` | předání práce další session, včetně krátkého retro; až po tvém souhlasu se commituje |
| `docs/retro/RRRR-MM-DD-<téma>.md` | skill `retro`, `mesicni-projektove-retro` | změřená session nebo retrospektiva období s nálezy |
| `.claude/kontrola-planu.md` | skill `kontrola-planu` (po tvém schválení) | kritéria kontroly plánu specifická pro projekt, nejvýš 15 bodů |

Cesty a názvy může projekt přepsat vlastní konvencí; skilly se řídí tím, co projekt stanoví.

## Na které úrovni pravidla platí
Od nejslabší po nejsilnější:
1. **Výchozí** (plugin): `policy/policy.md`, vkládá se na začátku každé session. Mění se jen ručně vydanou verzí pluginu, nikdy retrem, kontrolou plánu ani handoverem.
2. **Uživatel** (osobní vrstva): vlastní pravidla v osobním pluginu vytvořeném ze šablony `honzapowers-sablona` (soubor `pravidla.md`, max 800 znaků). Platí ve všech tvých projektech.
3. **Projekt**: `CLAUDE.md` / `AGENTS.md` repa a `.claude/kontrola-planu.md`. Při střetu vyhrává projekt (brána `G1` a pravidla v policy to říkají výslovně).

Nový poznatek tedy patří na nejnižší úroveň, kde platí: jednorázové věci nikam, projektové do projektu, obecné jako návrh na další vydání pluginu.

## Nastavení
- `HONZAPOWERS_HANDOVER_TOKENS` – práh prvního návrhu handoveru (výchozí 250000).
- `HONZAPOWERS_HANDOVER_STEP` – další upozornění po tolika tokenech (výchozí 50000).
- Starší proměnné `LEAN_WORKFLOW_*` fungují jako záloha.

## Co plugin nedělá
Nečte obsah souborů při startu (jen cesty a počty), nepoužívá síť, nic nepushuje a nic nemaže bez tvého souhlasu.
