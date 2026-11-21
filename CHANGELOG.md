# Changelog

## 0.2.0 — 2026-11-21
- Plugin přejmenován z `lean-workflow` na `honzapowers` (nové repo s čistou historií).
- Proměnné prostředí `HONZAPOWERS_HANDOVER_TOKENS`, `HONZAPOWERS_HANDOVER_STEP`, `HONZAPOWERS_RESUME_TOKENS` a `HONZAPOWERS_REAL_TRANSCRIPT` mají přednost; původní `LEAN_WORKFLOW_*` dál fungují jako záloha.

## 0.1.5 — 2026-11-17
- Handover se už nikdy nespouští sám: je jen návrh, předchází mu `pre-done` (když session měnila kód) a commit/push proběhne až po souhlasu.
