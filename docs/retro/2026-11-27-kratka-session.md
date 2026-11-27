# Retro 2026-11-27 – krátká session (výpis pravidel)

## Metriky
- 43 řádků transkriptu, 468k bajtů, 3 odpovědi, 3 volání nástrojů (Skill 1, Bash 1, Read 1).
- Kontext: start 83,5k, konec 88,4k, růst +4,9k. Cache reads 89 %.
- Opakované Bash běhy: 0; opakované editace: 0; opakované testy: 0; celosouborová čtení >300 řádků: 0.
- Největší výsledek nástroje: Skill 833 B (line:38). Nejdelší odpověď: 3,1k znaků (line:26).

## Nálezy
1. **Vysoký počáteční kontext** – 83,5k tokenů před první prací (line:1 až první odpověď). Příčina se z čísel nepozná (seznam skillů, hooky, MCP instrukce). Pravidlo: L9 (navrhnout /clear mezi nesouvisejícími úkoly). Třída: one-off, jen záznam. Rung: žádný.

Jiné nálezy nejsou: session měla 3 odpovědi, bez opakování a bez zbytečných čtení.

Rules flagged: žádná (L9 jen jako poznámka)

## Kandidáti na poznatek
žádný kandidát
