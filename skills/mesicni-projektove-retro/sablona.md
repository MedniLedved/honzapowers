# Retrospektiva: <téma> (<od> – <do>)

> Jeden soubor na retrospektivu: `docs/retro/RRRR-MM-DD-obdobi-<téma>.md`. Hledáme příčiny v procesu a pravidlech,
> ne viníky. Tvrzení vždy s odkazem na commit, běh CI nebo issue. Co nevím, píšu do „Co nevím“, ne do závěrů.

## Rozsah
- Větev / PR / commity: `<sha>..<sha>`, PR `<odkazy>`
- Období: `<od – do>`; kdo pracoval: `<session / souběžné session>`

## Objektivní signály
| Signál | Hodnota | Zdroj |
|---|---|---|
| Commity (feat / fix / docs / ostatní) | | `git log` |
| Červené CI na výchozí větvi (počet, doba do zeleného) | | CI |
| Zrušené běhy CI | | CI |
| Reverty, fixup/squash | | `git log` |
| Chyba nalezená až v produkci | | issue, monitoring |
| Opravy a vrácení zadání (uživatel opravil agenta) | | přepis session |

## Náklady session
Jen z hotových souborů (`docs/handover/`, `docs/retro/`), čísla se necitují bez jména souboru a nesčítají napříč formáty.
| session nebo soubor | kontext začátek → konec | největší výstupy | nález |
|---|---|---|---|
| | | | |

Session bez záznamu: <počet>

## Časová osa (jen zlomové body)
- `<datum čas>` co se stalo (`<sha>`)

## Co fungovalo (zachovat)
-

## Co selhalo a proč (příčina v procesu, ne „agent se spletl“)
| # | Co | Příčina | Důkaz | Mělo to zachytit |
|---|---|---|---|---|
| 1 | | | | test / CI / pravidlo / hook / nic |

## Poučky
Jedna věta, ověřitelná, s kontextem „kdy to platí“.
1.

## Návrhy změn (nic se neaplikuje bez schválení)
Nejvýš 3. Cíl: `AGENTS.md` / `CLAUDE.md` projektu · hook nebo CI · šablona zadání · úroveň uživatele (jen třída `obecné`, po druhém projektu).
Každý návrh jako diff, s důkazem, s polem **Už pokryto?** (co jsem prohledal a našel; pokrývá-li to existující
pravidlo nebo test, návrh vynech) a s tím, jak poznáme, že zabral.
Každý návrh nese pole `Třída:` (obecné / projektové / jednorázové) a `Stupeň:` (hard / skill / project / policy, proč ne levnější).

```diff
# cíl: <soubor>
- starý řádek
+ nový řádek
```
Zabral, když: `<měřitelné kritérium>`

## Co nevím
-
