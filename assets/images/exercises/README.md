# Immagini esercizi

Convenzione (vedi `06_Exercise_Catalog.md`):

```
assets/images/img_allenamenti/<codice_normalizzato>/start.jpg
assets/images/img_allenamenti/<codice_normalizzato>/end.jpg
```

Dove `<codice_normalizzato>` e il codice esercizio in minuscolo con `-`
sostituito da `_` (es. `MOB-001` -> `mob_001`).

Per gli esercizi non ancora coperti il catalogo puo mantenere riferimenti
legacy `.webp`, con fallback placeholder finche gli asset reali non vengono
prodotti.

I batch IMMAGINI.2 e IMMAGINI.3 includono anche asset originali JPEG in
`assets/images/img_allenamenti/<codice>/start.jpg` e `end.jpg` per i codici documentati in
[`Docs/IMMAGINI_2_Real_Exercise_Assets.md`](../../Docs/IMMAGINI_2_Real_Exercise_Assets.md).
Lo standard dei batch approvati e JPEG 1024x1024 quality 88. Il formato WebP
resta ammesso per riferimenti non ancora coperti; non si devono rinominare
altri formati in `.webp`. L'app deve tollerare l'assenza del file mostrando un
placeholder o nessuna immagine: nessun URL remoto.

Le directory approvate devono essere dichiarate esplicitamente in
`pubspec.yaml`, per garantire l'inclusione nel bundle Flutter.
