#!/usr/bin/env python3
"""Z uloženého výstupu list_events (kinds=["user"]) vybere jen zprávy napsané člověkem.

Použití:  python3 -I human-messages.py <soubor s výstupem list_events>
Výstup:   řádky `čas | session | text` (text zkrácený na 400 znaků, tajné hodnoty skryté)
          a na konci `has_more=... before_id=<first_id>` pro stránkování dál do minulosti.

Zprávu od člověka pozná podle `client_platform` v události a textového obsahu.
Výstupy nástrojů (`tool_result`) se zahazují, v retrospektivě se nikdy nepoužijí celé.
"""
import json
import re
import sys

MAX = 400
SKRYT = [
    (re.compile(r"[\w.+-]+@[\w-]+\.[\w.-]+"), "[e-mail]"),
    (re.compile(r"\b[a-z][a-z0-9+.-]*://[^\s/@:]+:[^\s/@]+@\S+"), "[url s heslem]"),
    (re.compile(r"\beyJ[\w-]{10,}\.[\w-]{10,}\.[\w-]+"), "[token]"),
    (re.compile(r"\b(?:sk|pk|ghp|gho|xox[bp])[-_][\w-]{16,}"), "[klíč]"),
    (re.compile(r"\b[A-Za-z0-9+/_=-]{32,}\b"), "[dlouhý řetězec]"),
]


def skryj(text: str) -> str:
    for vzor, nahrada in SKRYT:
        text = vzor.sub(nahrada, text)
    return text


def nacti(raw: str) -> dict:
    zacatek = raw.find('{"ccr"')
    if zacatek < 0:
        raise ValueError('Ve vstupu není JSON s klíčem "ccr".')
    obj, _ = json.JSONDecoder(strict=False).raw_decode(raw[zacatek:])
    return obj["ccr"]


def text_zpravy(content):
    """Text zprávy, nebo None, když to není zpráva člověka (např. výstup nástroje)."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        if any(isinstance(b, dict) and b.get("type") == "tool_result" for b in content):
            return None
        casti = [b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text"]
        return "\n".join(casti) if casti else None
    return None


def zpravy_cloveka(ccr: dict):
    for ev in ccr.get("data", []):
        zaklad = (ev.get("user") or {}).get("internal_anthropic_catchall") or {}
        if not zaklad.get("client_platform"):
            continue
        text = text_zpravy((zaklad.get("message") or {}).get("content"))
        if text is None or not text.strip():
            continue
        yield ev.get("created_at", "?")[:16], zaklad.get("session_id", "?"), text


def main(cesta: str) -> int:
    with open(cesta, encoding="utf-8") as f:
        ccr = nacti(f.read())
    for cas, sid, text in zpravy_cloveka(ccr):
        t = " ".join(skryj(text).split())
        print(f"{cas} | {sid[-6:]} | {t[:MAX]}{'…' if len(t) > MAX else ''}")
    print(f"has_more={ccr.get('has_more')} before_id={ccr.get('first_id')}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
