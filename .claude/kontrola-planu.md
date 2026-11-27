# Kritéria kontroly plánu (honzapowers)

Projektová kritéria pro skill `kontrola-planu`, navíc k obecným. Nejvýš 15 bodů.

1. Každá cesta v plánu (soubor, klon jiného repa, adresář) je před uložením plánu ověřená (`ls`, `git ls-files`); klony cizích rep se uvádějí cestou, kde opravdu jsou.
2. Když test hledá přesnou frázi, krok plánu ji uvádí doslova; dokumentace neodkazuje na tag ani soubor, který vznikne až později.
