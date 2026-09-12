# IMMAGINI.1 â€” Audit web per fotografie didattiche degli esercizi Forge

## Esito

Lâ€™audit campione conferma che la ricerca di fotografie reali didattiche Ã¨
fattibile, ma non Ã¨ sicuro importare automaticamente immagini trovate sul web.
Le fonti piÃ¹ utili per la chiarezza del movimento mostrano spesso una coppia o
una sequenza `START/END`; tuttavia, nei casi verificati, la licenza per
redistribuire lâ€™immagine dentro un APK non Ã¨ sempre dichiarata. Le fonti con
licenza chiara trovate nel campione sono invece talvolta una variante diversa
da quella del catalogo Forge, oppure un video/animazione invece di una
fotografia.

Conclusione operativa: IMMAGINI.2 deve usare una pipeline con approvazione
manuale per esercizio e per immagine. Nessun asset entra nel catalogo solo
perchÃ© il nome o la posa sembrano simili. Gli esercizi senza candidato che
supera contemporaneamente semantica, valore didattico e licenza restano
`MISSING`.

## Perimetro verificato

Il catalogo locale `assets/data/exercises_v1.json` Ã¨ la fonte di veritÃ  della
variante Forge. Al momento della verifica contiene:

| Campo | Valore |
|---|---:|
| Versione catalogo | 2 |
| Esercizi | 118 |
| Riferimenti immagine | 236 (2 per esercizio) |
| File locali presenti | 0 |
| File locali mancanti | 236 |

La convenzione prevista dal repository Ã¨:

```text
assets/images/img_allenamenti/<codice_normalizzato>/start.webp
assets/images/img_allenamenti/<codice_normalizzato>/end.webp
```

Il catalogo Ã¨ stato letto prima della ricerca. Per ogni campione sono stati
considerati nome, descrizione, istruzioni, attrezzatura, livello, impatto e
note di sicurezza. Le query hanno usato italiano, inglese, attrezzatura e
sinonimi tecnici; non sono stati scaricati asset.

## Query campione

| Codice | Query italiane | Query inglesi e sinonimi |
|---|---|---|
| `MOB-012` | `wall slide parziale esercizio muro` | `wall slide exercise`, `wall slide shoulder mobility`, `wall angel exercise` |
| `LEG-001` | `sit to stand assistito sedia mani` | `assisted sit to stand chair exercise`, `chair stand with arm support` |
| `LEG-007` | `goblet squat manubrio leggero` | `dumbbell goblet squat exercise`, `single dumbbell goblet squat` |
| `PUSH-001` | `wall push-up alto muro` | `wall push-up exercise`, `wall press-up`, `standing wall pushup` |
| `BACK-002` | `rematore elastico seduto` | `seated resistance band row`, `seated band row`, `band row with feet anchor` |
| `CORE-003` | `Pallof press elastico seduto` | `seated Pallof press band`, `seated anti-rotation press`, `band anti-rotation press chair` |

## Verifica semantica del campione

| Codice Forge e variante | Fonte/candidato | QualitÃ  didattica | CompatibilitÃ  con Forge | Licenza e redistribuzione | Stato |
|---|---|---|---|---|---|
| `MOB-012` â€” wall slide parziale: schiena e gomiti al muro, braccia che salgono finchÃ© il contatto resta comodo | [Leicester Partnership NHS, Wall Slides, PDF p. 10](https://www.leicspart.nhs.uk/wp-content/uploads/2026/04/LPT-CHSMSK16-Rotator-Cuff-Related-Shoulder-Pain.pdf) | Alta: sequenza fotografica in piÃ¹ fasi, muro e direzione del movimento visibili | Alta per la variante con mani/avambracci al muro; va controllato il contatto continuo richiesto da Forge | Licenza dellâ€™immagine non indicata nel PDF | `LICENSE_UNCLEAR` |
| `LEG-001` â€” sit-to-stand con mani su sedia/ginocchia | [South Tees NHS, Sit to stand from chair](https://www.southtees.nhs.uk/resources/sit-to-stand-from-chair-combined/), [START](https://www.southtees.nhs.uk/wp-content/uploads/2022/03/FigA-sittostand-chair.jpg), [fase intermedia](https://www.southtees.nhs.uk/wp-content/uploads/2022/03/FigB-sittostand-chair.jpg), [END](https://www.southtees.nhs.uk/wp-content/uploads/2022/03/FigC-sittostand-chair.jpg) | Alta: tre fotografie mostrano seduta, sollevamento e stazione eretta | Alta per la dinamica; la pagina descrive anche la discesa controllata | La pagina non espone una licenza di riuso dellâ€™immagine | `LICENSE_UNCLEAR` |
| `LEG-007` â€” goblet squat con un manubrio davanti al petto | [Wikimedia Commons, Kettlebell Goblet Squat](https://commons.wikimedia.org/wiki/File:Kettlebell_Goblet_Squat.webm) | Alta come dimostrazione del movimento, ma Ã¨ un video 640Ã—480, non una fotografia | Bassa: usa un kettlebell, mentre Forge richiede un manubrio | CC BY-SA 4.0; richiede attribuzione e share-alike. La licenza Ã¨ chiara, ma non risolve il mismatch di attrezzatura e formato | `SEMANTIC_MISMATCH` |
| `PUSH-001` â€” wall push-up alto: corpo allineato, mani al muro allâ€™altezza del petto | [MedlinePlus, Wall push-up](https://medlineplus.gov/ency/imagepages/19916.htm), [immagine](https://medlineplus.gov/ency/images/ency/fullsize/23370.jpg) | Potenzialmente alta come riferimento medico e tecnico; da verificare visivamente la leggibilitÃ  di start/end | La pagina identifica esattamente il wall push-up; la variante deve restare a muro, non a terra o su panca | Lâ€™immagine Ã¨ attribuita a A.D.A.M./MedlinePlus e la pagina non concede una licenza di redistribuzione nellâ€™APK | `LICENSE_UNCLEAR` |
| `PUSH-001` â€” stessa variante | [DVIDS, Full body workout with low impact](https://www.dvidshub.net/image/785090/full-body-workout-with-low-impact) | Fotografia reale ad alta risoluzione; una singola fase, contesto affollato e acqua visibile | Bassa: Ã¨ un wall push-up in piscina con flippers e resistenza dellâ€™acqua, non la variante Forge a terra | La pagina dichiara Public Domain, ma richiama limitazioni su diritti di immagine, marchi e non-endorsement ([DVIDS Copyright](https://www.dvidshub.net/about/copyright)) | `SEMANTIC_MISMATCH` |
| `PUSH-001` â€” stessa variante | [CDC wall pushup su Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Wallpushup-CDC_strength_training_for_older_adults.gif) | Movimento comprensibile, ma Ã¨ una GIF animata piccola, non una fotografia reale | Semantica alta, formato non conforme alla preferenza Forge | Public domain dichiarato per il lavoro CDC; non Ã¨ perÃ² una fotografia | `REJECTED` |
| `BACK-002` â€” rematore elastico seduto: gambe distese, elastico ai piedi/ancoraggio, tirata dei gomiti indietro | [COVID Move / PDF di esercizi con resistance band, p. 72](https://covidmove.umb.sk/wp-content/uploads/2025/01/PR3_Recommendations_SK_eng_compressed.pdf) | Alta: il risultato di ricerca identifica due foto affiancate, posizione iniziale e tirata finale; il PDF descrive anche errori comuni | Alta: seduto, elastico sotto i piedi, schiena dritta e trazione verso il petto corrispondono al catalogo | Licenza delle fotografie non indicata nel PDF | `LICENSE_UNCLEAR` |
| `LEG-015` â€” abduzione anca con elastico: elastico a caviglie/sopra caviglie, gamba laterale, busto stabile | [COVID Move / Standing Leg Abduction, PDF p. 63](https://covidmove.umb.sk/wp-content/uploads/2025/01/PR3_Recommendations_SK_eng_compressed.pdf) | Da verificare sulla pagina: il testo descrive chiaramente la direzione, ma il campione non Ã¨ stato scaricato/ispezionato come asset | CompatibilitÃ  da verificare: la sezione Ã¨ dedicata agli elastici, ma va confermata la posizione dellâ€™elastico mostrata | Licenza delle fotografie non indicata nel PDF | `PENDING_REVIEW` |
| `CORE-003` â€” Pallof press seduto con elastico ancorato lateralmente al petto | [ACE, Pallof press con cavo](https://www.acefitness.org/resources/pros/expert-articles/6474/5-core-exercises-to-improve-balance/) | Fonte autorevole per la tecnica, ma il candidato trovato Ã¨ una fotografia/guida del gesto in piedi con cavo | Bassa: Forge richiede seduto, elastico e ancoraggio laterale; cavo in piedi non Ã¨ intercambiabile | Licenza immagine non indicata | `SEMANTIC_MISMATCH` |

### Osservazioni sulle licenze

Una licenza aperta non elimina la verifica semantica. Il materiale Wikimedia
spiega che ogni file puÃ² avere condizioni diverse, che lâ€™autore deve essere
attribuito quando richiesto e che devono essere considerate anche restrizioni
non copyright, come diritti della persona ritratta. Vanno quindi archiviati
sia la pagina del file sia la licenza specifica, non solo il dominio ospitante
([Wikimedia Commons â€” Reusing content outside Wikimedia](https://commons.wikimedia.org/wiki/Commons:REUSE)).

Per le immagini DVIDS, la marcatura Public Domain non va interpretata come
assenza di ogni rischio: le condizioni ufficiali mantengono limitazioni su
diritti di immagine/pubblicitÃ , marchi e non-endorsement
([DVIDS â€” Copyright Information](https://www.dvidshub.net/about/copyright)).

Nel campione non Ã¨ stato approvato alcun file per lâ€™incorporamento. Questo Ã¨
un esito corretto: i candidati con la migliore qualitÃ  visiva hanno licenza
non verificata, mentre quelli con licenza chiara non rappresentano sempre la
variante Forge o non sono fotografie.

## Registro asset

Il registro campione Ã¨ [asset_registry.csv](../assets/images/img_allenamenti/asset_registry.csv).
Ogni riga rappresenta un candidato o una decisione di assenza, non un file
giÃ  approvato. I campi obbligatori sono:

| Campo | Regola |
|---|---|
| `exerciseCode` | Codice esatto del catalogo, mai solo il nome libero |
| `exerciseName` | Nome letto dal catalogo al momento della verifica |
| `imageRole` | `START`, `END`; eventuali fotogrammi intermedi restano candidati separati e non sostituiscono START/END |
| `sourcePage` | Pagina originale che descrive o ospita la fotografia |
| `sourceImage` | URL diretto dellâ€™immagine, quando disponibile; per PDF indicare pagina e lasciare `PENDING_REVIEW` finchÃ© non si estrae lâ€™URL verificabile |
| `author` | Autore o organizzazione dichiarata dalla fonte |
| `license` | Nome preciso: `PUBLIC_DOMAIN`, `CC_BY_4.0`, ecc.; mai `free` generico |
| `licenseUrl` | URL della licenza o della pagina ufficiale che la concede |
| `attributionRequired` | `true`/`false`/`UNKNOWN` |
| `localAssetPath` | Valorizzato solo dopo approvazione e acquisizione controllata |
| `verificationStatus` | `APPROVED`, `REJECTED`, `LICENSE_UNCLEAR`, `SEMANTIC_MISMATCH`, `PENDING_REVIEW`, `MISSING` |
| `notes` | Motivazione concreta, mismatch, qualitÃ , diritti o azione successiva |

## FattibilitÃ  di coprire i 118 esercizi

La copertura tecnica Ã¨ fattibile: le ricerche restituiscono materiale reale
per esercizi comuni e per molte sequenze di riabilitazione. La copertura
legale e semantica al 100% non Ã¨ dimostrata dal campione e non va presunta.
Le difficoltÃ  maggiori sono:

- varianti Forge molto specifiche, per esempio `PUSH-001` wall push-up alto
  rispetto a push-up su panca o a terra;
- attrezzatura che cambia la variante, per esempio elastico contro cavo,
  manubrio contro kettlebell, sedia contro supporto generico;
- licenze mancanti sulle fotografie incluse in PDF o pagine sanitarie;
- immagini reali che mostrano una sola fase, unâ€™inquadratura decorativa o un
  contesto che nasconde arti e attrezzatura;
- diritti della persona ritratta e condizioni di non-endorsement anche quando
  il copyright dellâ€™immagine Ã¨ risolto.

La strategia consigliata Ã¨ ibrida:

1. fonti aperte o public domain solo quando la pagina specifica documenta la
   licenza e la variante Ã¨ esatta;
2. fotografie con autorizzazione scritta per lâ€™uso nellâ€™app quando una fonte
   autorevole Ã¨ didatticamente perfetta ma non ha licenza redistributiva;
3. sessioni fotografiche commissionate per le varianti Forge rare o per i
   buchi che impedirebbero la copertura;
4. `MISSING` per tutto il resto, senza sostituzioni semantiche.

## Pipeline proposta per IMMAGINI.2

### 1. Congelare la scheda Forge

Per ogni codice esportare in una scheda di lavoro: nome, descrizione,
istruzioni, attrezzatura, livello, impatto, sicurezza, sinonimi e criteri
visivi obbligatori. Se cambia la variante nel catalogo, i candidati devono
essere rivalutati.

### 2. Generare le query

Generare almeno quattro famiglie di query per esercizio:

- nome italiano + `esercizio`;
- nome inglese equivalente + `exercise`;
- nome inglese + attrezzatura;
- sinonimo tecnico + posizione/variante, per esempio `seated`, `wall`,
  `assisted`, `with band`, `with dumbbell`.

Le query servono a trovare la pagina originale. Google/Bing o la ricerca
immagini non sono la fonte da registrare.

### 3. Valutare prima la semantica

Scartare il candidato se non si puÃ² verificare ciascun requisito pertinente:

- posizione iniziale e finale;
- orientamento del corpo;
- arti e direzione del movimento;
- attrezzatura e punto di ancoraggio;
- variante di supporto, sedia, muro o tappetino;
- sicurezza visibile quando Ã¨ parte dellâ€™istruzione Forge.

Il punteggio estetico non puÃ² compensare un mismatch di variante.

### 4. Verificare i diritti

Archiviare pagina sorgente, URL immagine, autore, licenza, URL licenza,
attribuzione, modifiche consentite, uso commerciale e restrizioni di persone,
marchi o endorsement. `UNKNOWN`, `UNCLEAR` o `ALL RIGHTS RESERVED` senza
autorizzazione portano a `LICENSE_UNCLEAR` e impediscono il download nel
catalogo.

### 5. Review didattica e legale

Ogni candidato deve avere due verifiche separate:

- review tecnica: corrispondenza con la scheda Forge e chiarezza start/end;
- review diritti: licenza e redistribuzione nellâ€™app, con evidenza salvata.

Solo due esiti positivi permettono `APPROVED`.

### 6. Acquisizione controllata

Per i soli `APPROVED`:

- scaricare dalla `sourceImage` registrata;
- verificare checksum, MIME, dimensioni e assenza di watermark;
- convertire in WebP solo se la licenza consente la modifica;
- salvare `start.webp` e `end.webp` nel percorso normalizzato;
- conservare nel registro checksum, data di verifica e attribuzione pronta per
  la schermata About/credits dellâ€™app.

Non usare hotlink remoti nellâ€™APK e non scaricare in massa prima della review.

### 7. Controlli CI prima di dichiarare copertura

Un controllo automatico deve fallire se:

- esiste un file locale senza una riga `APPROVED`;
- una riga `APPROVED` non ha file o checksum corrispondente;
- manca `sourcePage`, `sourceImage`, `license` o `licenseUrl`;
- la licenza Ã¨ non commerciale, salvo decisione esplicita compatibile con il
  modello di distribuzione;
- un esercizio Ã¨ marcato completo ma ha immagini `MISSING` o non verificate.

La copertura dichiarata deve distinguere `APPROVED`, `PENDING_REVIEW` e
`MISSING`; non deve contare i candidati semplicemente trovati sul web.

## Fonti consultate

- [Leicester Partnership NHS â€” Rotator Cuff Related Shoulder Pain, Wall Slides](https://www.leicspart.nhs.uk/wp-content/uploads/2026/04/LPT-CHSMSK16-Rotator-Cuff-Related-Shoulder-Pain.pdf)
- [South Tees Hospitals NHS â€” Sit to stand from chair](https://www.southtees.nhs.uk/resources/sit-to-stand-from-chair-combined/)
- [MedlinePlus â€” Wall push-up](https://medlineplus.gov/ency/imagepages/19916.htm)
- [DVIDS â€” Full body workout with low impact](https://www.dvidshub.net/image/785090/full-body-workout-with-low-impact)
- [DVIDS â€” Copyright Information](https://www.dvidshub.net/about/copyright)
- [Wikimedia Commons â€” Kettlebell Goblet Squat](https://commons.wikimedia.org/wiki/File:Kettlebell_Goblet_Squat.webm)
- [Wikimedia Commons â€” Reusing content outside Wikimedia](https://commons.wikimedia.org/wiki/Commons:REUSE)
- [COVID Move / UMB â€” exercise recommendations PDF](https://covidmove.umb.sk/wp-content/uploads/2025/01/PR3_Recommendations_SK_eng_compressed.pdf)
- [ACE â€” Core exercises / Pallof press](https://www.acefitness.org/resources/pros/expert-articles/6474/5-core-exercises-to-improve-balance/)
