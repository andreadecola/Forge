# FORGE — Milestone 7.4: Progress Dashboard

Restyling UX/UI (22/11/2026): «Attività e risultati» apre ora Progressi,
con riepilogo narrativo derivato dai valori reali di EVO-010. Metriche corporee,
storici e grafici rimangono disponibili. Temi Ambra/Blu e verifiche in
`Docs/UX_UI_Restyling.md`.

## Aggiornamento corrente — BUG-001 (22/11/2026)

La Home e Progressi condividono ora lo stream delle misurazioni corporee del
profilo corrente. `latestWeightProvider` e `latestWaistProvider` derivano i dati
da `bodyMeasurementsProvider`: non conservano più il risultato di una lettura
singola. Inserimento, modifica, eliminazione e ripristino del backup aggiornano
quindi anche la Home già aperta, senza invalidazioni manuali o query aggiuntive.

La selezione conserva l'ordinamento del repository `measuredAt DESC, id DESC`.
Peso e girovita restano indipendenti: una misura di solo girovita non sostituisce
l'ultimo peso. Variazione, BMI, BMR e TDEE della Home usano il peso aggiornato con
le formule esistenti. In assenza di pesi la Home mostra `Non disponibile` per
questi indicatori; il peso iniziale non diventa una misurazione corrente.

Nessuna modifica a formule, database, catalogo o formato backup:
Il fix BUG-001 era su schema 12; le successive evolutive portano lo schema a
**14**, con catalogo **2** (vedi `Docs/EVOLUTIVE_001_010.md`). Le camminate interne
alle schede sono conteggiate tramite il collegamento alla sessione reale.
I valori nelle sezioni
successive descrivono la baseline storica della milestone M7.4.

Verifica automatica: **94 test mirati superati, 0 falliti**. Le quattro nuove
regressioni in `test/features/dashboard_weight_sync_test.dart` coprono il
percorso Progressi → salvataggio/modifica/eliminazione → Home, date e parità di
timestamp, righe di solo girovita, assenza di pesi, ricreazione dell'interfaccia
sullo stesso database e importazione JSON reale con Home già montata. Nel test
backup sono isolati file picker e riconciliazione delle notifiche native.
`flutter analyze`: nessun problema. `git diff --check`: superato.

**Stato: In collaudo.** Restano da verificare su Android aggiornamenti UI,
riavvio effettivo del processo e ripristino tramite file picker. Non è stata
rieseguita la suite completa e non è stato effettuato alcun commit o push.
Il registro ufficiale è `Docs/EVOLUTIVE_FUTURE.md`, voce BUG-001.

## Stato iniziale

La ricognizione del repository ha confermato l’architettura già introdotta
nelle milestone precedenti:

- `ProgressPage` è la quarta sezione della `StatefulShellRoute` (`/progress`);
- `BodyProgressService` e `BodyProgressSummary` esistono già e sono puri;
- `PressureProgressService` esiste già ed è puro;
- gli stream `bodyMeasurementsProvider` e
  `pressureMeasurementsProvider` arrivano dai repository Drift;
- `PressurePage` è già raggiungibile da `/pressure` e mantiene il CRUD della
  pressione;
- `schemaVersion` è 8.

Baseline iniziale: `flutter analyze` senza issue e `flutter test` con 690 test
passati. Il worktree conteneva già le modifiche delle milestone precedenti;
non sono state sovrascritte.

## Componenti riusati

M7.1: profilo corrente, repository e stream reattivi, validation e clock.

M7.2: `BodyMeasurement`, `BodyMeasurementsTable`, CRUD body, storico,
`BodyProgressService`, `BodyProgressSummary`, parsing e formatter di peso e
girovita.

M7.3: `PressureMeasurement`, `PressurePage`, CRUD pressione,
`PressureProgressService`, formatter di pressione e frequenza cardiaca.

Non è stato creato un `ProgressDashboardService`: la composizione richiesta è
sufficientemente semplice con i due service esistenti.

## Struttura finale della pagina

La pagina esistente è stata evoluta, senza creare una seconda route o una
seconda pagina. Il contenuto è un unico `SingleChildScrollView` con:

1. riepilogo;
2. card Peso;
3. card Girovita;
4. card Pressione;
5. sezione azioni rapide `Registra`;
6. storico corporeo unico.

La pressione resta gestibile nella pagina esistente `/pressure`; lo storico
body resta nella ProgressPage e non viene duplicato.

## Riepiloghi e semantica

### Peso

La card mostra peso iniziale, ultimo peso, data/ora dell’ultima riga con
`weightKg != null` e variazione rispetto alla baseline. La baseline è sempre
`UserProfile.initialWeightKg`; una misurazione non la modifica.

`BodyProgressService` seleziona l’ultima misura con ordinamento logico
`measuredAt DESC`, poi `id DESC`. Una riga successiva di solo girovita non
sostituisce l’ultimo peso. La variazione è `latestWeightKg - initialWeightKg`:
valore positivo o negativo con segno, oppure `Nessuna variazione` quando è
zero. Se non esiste peso viene mostrato `Nessuna misurazione di peso
registrata` e non viene fabbricato un peso attuale.

### Girovita

La card mostra l’ultima misura con `waistCm != null` e la sua data/ora. La
selezione usa la stessa semantica `measuredAt DESC`, `id DESC`, indipendente
dal peso. In assenza di dati mostra `Nessuna misurazione del girovita
registrata`, mai zero.

### Pressione

La card usa `PressureProgressService.latest` e mostra esclusivamente i dati
registrati: `systolic / diastolic mmHg`, data/ora e `heartRate` solo quando
presente. Non contiene giudizi, classificazioni cliniche, colori di rischio,
range ideali o alert medici. In assenza di dati mostra `Nessuna misurazione
della pressione registrata`.

### Null e date

`null` significa dato non registrato e resta `null` fino alla composizione UI:
non viene trasformato in 0, trattino o valore fittizio. Le date di peso e
girovita possono essere diverse. La visualizzazione usa
`formatItalianDate`/`formatItalianTime` esistenti, senza duplicare formatter.

## Provider e aggiornamenti reattivi

La pagina osserva un solo stream body e un solo stream pressione per il profilo.
Il riepilogo viene calcolato in memoria con i service puri; i widget non
eseguono query Drift direttamente. Non sono stati aggiunti provider o
repository nuovi.

Le emissioni degli stream aggiornano automaticamente card e storico dopo
create, update e delete. La cancellazione dell’ultima riga fa ricomparire la
riga precedente secondo le stesse regole di ordinamento.

Body e pressione hanno stati di loading/error indipendenti. Un errore di una
sorgente viene mostrato nella relativa card senza far crashare l’intera
pagina. Il comportamento di onboarding/profile resta quello già presente.

## CTA, navigazione e responsive

Le card Peso e Girovita riusano lo stesso form body M7.2. La sezione `Registra`
offre `Peso / Girovita` e `Registra pressione`. Le CTA pressione riusano
`AppRoutes.pressure` e la `PressurePage` esistente. La bottom navigation resta
immutata: Home, Programma, Progressi, Profilo.

Il contenuto è completamente scrollabile con larghezze ridotte e testo grande.
Le azioni usano `Wrap` dove serve e non introducono layout clinici o goal.

## Scope escluso e limiti

Non sono stati aggiunti grafici, sparkline, trend, obiettivi, forecast, BMI,
modifiche profilo, cloud, export, integrazioni wearable o adattamento Forge.
Non è stata aggiunta alcuna migration e `schemaVersion` resta 8.

Il form body non è stato rifattorizzato per l’hardening generale M7.7: è stato
lasciato invariato perché la milestone richiedeva di correggerlo solo in caso
di bug concreto osservato nei test della dashboard.

## Test

Sono stati aggiunti test widget per:

- dashboard completa con peso, baseline, delta, date, girovita, pressione e
  frequenza cardiaca;
- dati parziali e assenza della frequenza cardiaca;
- tie-break pressione a timestamp uguale;
- aggiornamenti live create/update/delete con ricalcolo del riepilogo;
- numeri e note lunghi a 320×480;
- `TextScaler` 2.0.

I test service già presenti coprono lista vuota, order-invariance, baseline,
delta, peso/girovita indipendenti e tie-break `id DESC`.

Quality gate iniziale: analyze 0 issue, 690/690 test passati.

Quality gate finale: `dart format .` completato, `flutter analyze` senza issue
e `flutter test` con 695 test passati.
