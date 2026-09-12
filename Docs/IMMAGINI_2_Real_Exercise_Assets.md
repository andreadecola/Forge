# IMMAGINI.2 / IMMAGINI.3 - Asset didattici locali

## Stato verificato

Questo documento e il riferimento ufficiale per gli asset didattici Forge.
IMMAGINI.3 ha aggiunto un batch unico di 47 esercizi per raggiungere la soglia
del 60%; la review Android completa resta una fase separata successiva.

| Voce | Valore |
|---|---:|
| HEAD di riferimento | `669223d8111f9b6efe7eeb02f182fc335590d35a` |
| `schemaVersion` | 11 |
| `catalogVersion` | 2 |
| esercizi | 118 |
| riferimenti immagine | 236 |
| esercizi con asset reali | 71 |
| file immagine reali | 142 |
| directory asset locali | `assets/images/img_allenamenti/` |

Copertura corrente: 71/118 esercizi con immagini reali, 47/118 ancora in
fallback, pari al 60,17% del catalogo.

Non sono state introdotte migration, nuove architetture immagini o modifiche a
notifiche, Forge Engine, sessioni, walking o progressi.

## Esercizi del batch

La variante e stata verificata in `assets/data/exercises_v1.json` leggendo
nome, descrizione, istruzioni, attrezzatura, livello e sicurezza prima della
produzione.

| Codice | Nome Forge | START | END |
|---|---|---|---|
| `LEG-001` | Sit-to-stand assistito con mani | `leg_001/start.jpg` | `leg_001/end.jpg` |
| `LEG-012` | Calf raise con appoggio | `leg_012/start.jpg` | `leg_012/end.jpg` |
| `PUSH-009` | Press isometrica palmo contro palmo | `push_009/start.jpg` | `push_009/end.jpg` |
| `BACK-001` | Band pull-apart leggero | `back_001/start.jpg` | `back_001/end.jpg` |
| `BACK-002` | Rematore elastico seduto | `back_002/start.jpg` | `back_002/end.jpg` |
| `SHO-006` | Alzata laterale con manubri leggeri | `sho_006/start.jpg` | `sho_006/end.jpg` |
| `MOB-012` | Wall slide parziale | `mob_012/start.jpg` | `mob_012/end.jpg` |
| `PUSH-001` | Wall push-up alto | `push_001/start.jpg` | `push_001/end.jpg` |

Il codice tecnico e usato solo nel path locale e nel registro; non viene
mostrato dalla UI.

## IMMAGINI.3 - Batch 1

Prima di generare ogni coppia sono stati verificati nel catalogo codice, nome,
descrizione, esecuzione, attrezzatura, livello e sicurezza. Sono stati usati
riferimenti tecnici web per la variante: Leeds Teaching Hospitals per
l'estensione del ginocchio seduto, ACE per press e lavoro con elastico, NHS e
Cambridge University Hospitals per step, equilibrio e supporti. Le pagine web
sono riferimenti tecnici: nessuna loro fotografia e stata incorporata.

| Codice | Nome Forge | START | END | Stato |
|---|---|---|---|---|
| `MOB-001` | Respirazione diaframmatica seduta | `mob_001/start.jpg` | `mob_001/end.jpg` | APPROVED |
| `MOB-013` | Hip hinge assistito al muro | `mob_013/start.jpg` | `mob_013/end.jpg` | APPROVED |
| `LEG-002` | Estensione ginocchio seduto controllata | `leg_002/start.jpg` | `leg_002/end.jpg` | APPROVED |
| `LEG-007` | Goblet squat con manubrio leggero | `leg_007/start.jpg` | `leg_007/end.jpg` | APPROVED |
| `LEG-018` | Step-up basso assistito | `leg_018/start.jpg` | `leg_018/end.jpg` | APPROVED |
| `PUSH-003` | Push-up inclinato su supporto molto stabile | `push_003/start.jpg` | `push_003/end.jpg` | APPROVED |
| `PUSH-005` | Chest press con elastico da seduto | `push_005/start.jpg` | `push_005/end.jpg` | APPROVED |
| `BACK-003` | Rematore elastico in piedi | `back_003/start.jpg` | `back_003/end.jpg` | APPROVED |
| `BACK-004` | Rematore con manubrio supportato | `back_004/start.jpg` | `back_004/end.jpg` | APPROVED |
| `SHO-002` | Shoulder press seduto con manubri leggeri | `sho_002/start.jpg` | `sho_002/end.jpg` | APPROVED |
| `ARM-001` | Curl da seduto con elastico | `arm_001/start.jpg` | `arm_001/end.jpg` | APPROVED |
| `CORE-003` | Pallof press con elastico da seduto | `core_003/start.jpg` | `core_003/end.jpg` | APPROVED |
| `CORE-005` | Wall plank | `core_005/start.jpg` | `core_005/end.jpg` | APPROVED |
| `BAL-007` | Toe taps su target basso | `bal_007/start.jpg` | `bal_007/end.jpg` | APPROVED |
| `STR-006` | Posteriori coscia da seduto | `str_006/start.jpg` | `str_006/end.jpg` | APPROVED |
| `CARD-004` | Step touch laterale | `card_004/start.jpg` | `card_004/end.jpg` | APPROVED |

Tutte le 16 coppie sono `ORIGINAL_FORGE`, senza download web e senza
attribuzione esterna. Sono state generate con START come riferimento visivo
per END, controllate per soggetto, scena, attrezzatura, camera, semantica e
artefatti. `CARD-004 END` e stato rigenerato una volta per rendere evidente il
passo laterale.

## IMMAGINI.3 - Batch unico target 60%

Il batch ha aggiunto 47 esercizi non precedentemente coperti e 94 immagini
locali. Ogni coppia e stata verificata rispetto alla variante del catalogo,
generata come `ORIGINAL_FORGE` con END derivato dallo START e controllata per
coerenza minima di soggetto, scena, attrezzatura, camera e posa.

Codici aggiunti:

`MOB-002`, `MOB-003`, `MOB-004`, `MOB-006`, `MOB-007`, `MOB-008`, `MOB-009`,
`MOB-014`, `LEG-003`, `LEG-004`, `LEG-006`, `LEG-009`, `LEG-010`, `LEG-013`,
`LEG-014`, `LEG-015`, `LEG-016`, `PUSH-002`, `PUSH-004`, `PUSH-006`,
`PUSH-007`, `PUSH-008`, `PUSH-010`, `BACK-005`, `BACK-006`, `BACK-007`,
`BACK-008`, `BACK-009`, `SHO-001`, `SHO-003`, `SHO-004`, `SHO-005`, `SHO-007`,
`SHO-008`, `ARM-002`, `ARM-003`, `ARM-004`, `ARM-005`, `ARM-007`, `CORE-001`,
`CORE-002`, `CORE-004`, `CORE-006`, `CORE-007`, `CORE-009`, `BAL-001`,
`BAL-004`.

Tutti gli asset del batch sono `APPROVED`, JPEG 1024x1024 quality 88, con
path deterministico `assets/images/img_allenamenti/<code_normalizzato>/`.

## Origine e licenze

Tutti gli asset locali sono `ORIGINAL_FORGE`. Sono rappresentazioni fotorealistiche
originali prodotte da specifiche tecniche Forge, non fotografie web scaricate
o copiate. Le fonti web dell'audit IMMAGINI.1 sono state usate solo come
riferimento tecnico; nessun candidato web del batch ha licenza approvata per
la redistribuzione nell'APK.

Il registro ufficiale e
[`assets/images/exercises/asset_registry.csv`](../assets/images/exercises/asset_registry.csv).
Per ogni asset locale contiene `sourcePage=ORIGINAL_FORGE`, origine dello
strumento di generazione, autore, licenza, attribuzione, path deterministico e
stato di verifica.

## IMMAGINI.2.1 - Standard START/END consolidato

La prima revisione ha classificato tutte le coppie precedenti come
`NEEDS_REGENERATION`: la semantica dell'esercizio era corretta, ma START e END
erano stati generati indipendentemente e quindi non garantivano la continuita
di soggetto, scena e camera richiesta.

Sono state rigenerate tutte le 8 coppie. Per ogni esercizio e stato generato
prima START; END e stato poi prodotto usando START come riferimento diretto,
cambiando principalmente la posa. La verifica visiva finale non ha rilevato
artefatti evidenti di mani, piedi, arti, elastici, pesi o attrezzatura.

| exerciseCode | exerciseName | START | END | sameSubject | sameScene | sameEquipment | sameCamera | semanticCheck | visualCheck | status |
|---|---|---|---|---|---|---|---|---|---|---|
| `LEG-001` | Sit-to-stand assistito con mani | `start.jpg` | `end.jpg` | PASS | PASS | PASS | PASS | PASS | PASS | APPROVED |
| `LEG-012` | Calf raise con appoggio | `start.jpg` | `end.jpg` | PASS | PASS | PASS | PASS | PASS | PASS | APPROVED |
| `PUSH-009` | Press isometrica palmo contro palmo | `start.jpg` | `end.jpg` | PASS | PASS | PASS | PASS | PASS | PASS | APPROVED |
| `BACK-001` | Band pull-apart leggero | `start.jpg` | `end.jpg` | PASS | PASS | PASS | PASS | PASS | PASS | APPROVED |
| `BACK-002` | Rematore elastico seduto | `start.jpg` | `end.jpg` | PASS | PASS | PASS | PASS | PASS | PASS | APPROVED |
| `SHO-006` | Alzata laterale con manubri leggeri | `start.jpg` | `end.jpg` | PASS | PASS | PASS | PASS | PASS | PASS | APPROVED |
| `MOB-012` | Wall slide parziale | `start.jpg` | `end.jpg` | PASS | PASS | PASS | PASS | PASS | PASS | APPROVED |
| `PUSH-001` | Wall push-up alto | `start.jpg` | `end.jpg` | PASS | PASS | PASS | PASS | PASS | PASS | APPROVED |

### Template definitivo di generazione

Ogni coppia futura deve usare questo template, completato con i dati reali
della scheda catalogo:

```text
IDENTITA VISIVA
- un solo soggetto fittizio coerente tra START ed END
- stesso volto, capelli, corporatura, eta apparente, abbigliamento e scarpe

SCENA
- ambiente domestico neutro, stessa parete/pavimento e stessa illuminazione
- nessun logo, testo, watermark o elemento decorativo inutile

CAMERA
- camera fissa, stesso punto di vista, altezza, distanza, orientamento e crop
- formato quadrato, corpo intero quando serve a capire postura o appoggio

ABBIGLIAMENTO
- sportivo neutro, senza marchi; invariato nella coppia

ATTREZZATURA
- variante esatta descritta dal catalogo; stesso oggetto e stesso aspetto
  in START ed END

START POSE
- posizione iniziale descritta da esercizio, istruzioni, sicurezza e supporti

END POSE
- posizione finale della stessa sequenza; cambiare principalmente il movimento

VINCOLI NEGATIVI
- niente testo, grafica, watermark, persone extra, arti duplicati, mani o piedi
  deformi, attrezzatura sospesa o deformata, posa impossibile, variante diversa

RISOLUZIONE E FORMATO
- sorgente fotorealistica quadrata; output locale 1024x1024 JPEG quality 88
- nominare deterministicamente <codice>/{start,end}.jpg
```

Procedura obbligatoria: congelare la variante Forge, ricercare riferimenti
tecnici con query italiane/inglesi e attrezzatura, generare START, generare END
con START come riferimento, ispezionare visivamente la coppia, convertire in
1024x1024, aggiornare il registro e solo dopo collegare il seed.

## Formato e peso attuali

I file finali sono JPEG 1024x1024, quality 88. Il primo batch IMMAGINI.2 pesa
1,733,010 byte. IMMAGINI.3 batch 1 aggiunge 3,834,089 byte e il batch target
60% aggiunge 13,382,228 byte; il totale corrente e 18,949,327 byte per 142
file. Tutti i file sono locali; non esiste download runtime.

| Batch | File | Peso |
|---|---:|---:|
| IMMAGINI.2 | 16 | 1,733,010 byte |
| IMMAGINI.3 batch 1 | 32 | 3,834,089 byte |
| IMMAGINI.3 batch target 60% | 94 | 13,382,228 byte |
| Totale corrente | 142 | 18,949,327 byte |

| Codice | START bytes | END bytes | Totale |
|---|---:|---:|---:|
| `LEG-001` | 138,914 | 131,697 | 270,611 |
| `LEG-012` | 89,651 | 90,332 | 179,983 |
| `PUSH-009` | 115,945 | 108,537 | 224,482 |
| `BACK-001` | 106,528 | 108,100 | 214,628 |
| `BACK-002` | 136,694 | 129,943 | 266,637 |
| `SHO-006` | 110,209 | 107,482 | 217,691 |
| `MOB-012` | 92,079 | 86,554 | 178,633 |
| `PUSH-001` | 94,937 | 85,408 | 180,345 |
| **Totale batch** | **885,957** | **848,053** | **1,733,010** |

## Mapping, fallback e test

Il mapping resta quello esistente:

```text
assets/data/exercises_v1.json
  -> ExerciseCatalogSeeder (sourceType ASSET, path, order)
  -> immagini_esercizi (DB, schema invariato)
  -> DriftExerciseRepository / ExerciseDetails
  -> ExerciseImageGallery
  -> Image.asset + ExerciseImageViewerPage (zoom)
```

Il seed mantiene START come ordine 1 e END come ordine 2. Gli altri 47
esercizi mantengono i riferimenti originari senza file reali e usano il
placeholder tramite il fallback della gallery.

`test/data/exercise_image_asset_batch_test.dart` verifica baseline del
catalogo, esistenza dei path, ordine START/END, mapping seed/DB/repository e
fallback per un esercizio senza asset reale.

## Review Android richiesta

1. Avviare Forge offline.
2. Aprire il catalogo e scegliere ciascun esercizio del batch.
3. Aprire il dettaglio e verificare START, END e ordine.
4. Provare zoom/pan e controllare nitidezza e orientamento.
5. Confrontare ogni posa con descrizione, esecuzione, attrezzatura e sicurezza.
6. Aprire un esercizio senza asset e verificare il fallback.

La produzione degli altri 47 esercizi resta bloccata fino alla review Android.
In questa fase non sono stati eseguiti test, analyze o build, come richiesto
per la produzione rapida del batch. Nessun commit e nessun push vengono
eseguiti.
