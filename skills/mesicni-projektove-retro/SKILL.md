---
name: mesicni-projektove-retro
description: Use when the user asks for a retrospective of AI agent work in a project over a period or topic (monthly retro, after an incident), wants recurring mistakes found, or lessons turned into proposed rule changes. Not for the cost of the current session alone: use the retro skill.
---

# Retro projektu za období

Nezávislý analytik čte objektivní signály a (v cloudu) přepisy session a vrací retrospektivu s důkazy. Změny pravidel jen navrhne jako diff. **Nic neaplikuj bez schválení uživatele.** Odpovídej česky.

Liší se od `retro`: to měří jednu session, tento skill hledá opakované chyby napříč session za období.

## Postup (hlavní session)

1. **Zadání.** Zjisti období (`<od>` včetně, `<do>` mimo) a téma. Chybí-li, zeptej se jednou otázkou. Mimořádné retro po incidentu (chyba v produkci, revert, ztracená práce): od vzniku chyby (sha z `git log`) do opravy.
2. **Git signály.** `git fetch -q origin`, pak `bash "${CLAUDE_SKILL_DIR}/git-signals.sh" <od> <do> > <scratchpad>/signaly.md`. Bez třetího argumentu skript zvolí výchozí větev: `origin/HEAD`, jinak `main`, `master`, aktuální větev. Vyvíjí-li se projekt na jiné integrační větvi (např. `dev`), předej ji jako třetí argument (`origin/dev`), jinak se signály vezmou z výchozí větve.
3. **CI.** Čísla vezmi ze souhrnu, který projekt má (např. měsíční issue). Jinak z GitHubu (`actions_list`, `list_workflow_runs`, `perPage` nejvýš 20), výstup vždy do souboru a zpracuj ho `python3 -I`. Spočítej běhy `success` / `failure` / `cancelled` na výchozí větvi; u červených uveď selhaný krok a dobu do dalšího zeleného. Připiš do `signaly.md`. Nemáš-li přístup k CI, napiš to do „Co nevím“.
4. **Přepisy session** jen v **cloudu**: subagent nástroj `list_events` nemá, stáhni je sám. `list_events` s `kinds: ["user"]` a `limit` nejvýš 30 (stránka obsahuje i výsledky nástrojů a bývá stovky kB), výstup vždy do souboru, na něj `python3 -I "${CLAUDE_SKILL_DIR}/human-messages.py" <soubor>`, stránkuj `before_id`, dokud `has_more=False`. Cesty ke zpracovaným souborům předej analytikovi. **Lokálně** přepisy nečti: retro je jen z gitu a CI a uveď to v „Co nevím“.
5. **Analytik.** Spusť jednoho subagenta (`general-purpose`) s textem z `analyst-prompt.md`, kde doplníš cesty a období. Nedávej mu své závěry ani domněnky.
6. **Kontrola výstupu.** Ověř 3 náhodná tvrzení podle jejich důkazu (`git show`, ID běhu). Škrtni všechno bez důkazu. U každého návrhu ověř pole „Už pokryto?“ vlastním `grep`.
7. **Uložení.** Retrospektivu ulož podle `sablona.md` do `docs/retro/RRRR-MM-DD-obdobi-<téma>.md` (název se liší od souborů skillu `retro`). Commitni jen ji. Návrhy změn ukaž uživateli jako diff, nic nepushuj bez souhlasu.

## Kam návrhy patří

- Cíl: `AGENTS.md` / `CLAUDE.md` projektu, hook nebo CI, šablona zadání. Návrh na úrovni uživatele jen po potvrzení ve druhém projektu a se souhlasem: je-li v kontextu blok „Personal rules (honzapowers-osobni)“, jde diff do `pravidla.md` toho pluginu, jinak jako text k vložení do osobních preferencí na claude.ai.
- **Nikdy** výchozí policy pluginu (`policy/policy.md`) ani `docs/learnings.md`: to je ruční vydání se souhlasem uživatele.
- Pravidlo, které už hlídá kód, test nebo hook, se nenavrhuje.

## Pravidla pro analytika (podrobně v `analyst-prompt.md`)

- Každé tvrzení má důkaz: sha, ID běhu CI, nebo ID session + čas zprávy. Bez důkazu patří do „Co nevím“.
- Přepisy: projdi **všechny** session z `signaly.md`, ne vzorek, a jen zprávy člověka (`human-messages.py`).
- Výstup nástroje se cituje jen k důkazu: nejvýš 3 řádky, bez osobních údajů a tajných hodnot.
- Nejvýš 3 návrhy, seřazené podle důkazů. Každý má pole „Už pokryto?“ s výsledkem prohledání pravidel projektu, testů, CI a hooků.
- Poučka je pravidlo s kontextem a měřitelným „Zabral, když“.

## Časté chyby

| Chyba | Jak se jí vyhnout |
|---|---|
| Návrh opakuje existující pravidlo nebo test | Povinné pole „Už pokryto?“ a `grep` před zápisem |
| „Moje opravy“ spočítané z vzorku přepisů | `human-messages.py` a stránkování, dokud `has_more=False` |
| Vlastní způsob počítání metrik | Jen čísla z `git-signals.sh` a z CI |
| Do retro se zkopíruje výstup nástroje s osobními daty | Citovat jen k důkazu, zkráceně, očištěně |
