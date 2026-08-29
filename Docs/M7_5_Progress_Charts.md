# FORGE — Milestone 7.5: grafici e andamento Progressi

## Stato e ricognizione

La baseline reale prima delle modifiche era:

- `schemaVersion = 8`;
- `flutter analyze`: 0 issue nella riesecuzione isolata;
- `flutter test`: 695/695 passati.

La prima esecuzione di analyze era stata avviata contemporaneamente ai test e
aveva incontrato un lock transitorio nella directory Flutter ephemeral. È stata
rieseguita dopo la fine dei test e ha dato esito pulito.

La pagina esistente è `ProgressPage`, raggiunta da `/progress` e già collegata
alla tab Progressi della `StatefulShellRoute`. I provider esistenti
`bodyMeasurementsProvider` e `pressureMeasurementsProvider` alimentano sia le
card M7.4 sia la sezione grafici: non sono state introdotte query aggiuntive.

Sono stati riutilizzati:

- `BodyMeasurement` e `PressureMeasurement`;
- `BodyProgressService` e `BodyProgressSummary` per il riepilogo/latest;
- `PressureProgressService` per la pressione latest;
- `progress_metrics.dart` per i valori e `italian_date_formatter.dart` per le
  date/ore;
- `clockProvider` per fornire l’istante di riferimento alla pagina.

## Libreria e architettura

Il progetto non conteneva una libreria chart. I due widget già presenti erano
grafici custom a barre per attività, non adatti a serie temporali di
misurazioni. È stata aggiunta `fl_chart: ^1.2.0`, una dipendenza mirata per
`LineChart` e tooltip touch; riferimento: [fl_chart su pub.dev](https://pub.dev/packages/fl_chart).

La preparazione dati è separata in `ProgressChartService`, puro e senza accesso
a DB, Riverpod o clock. I modelli non persistiti sono:

- `BodyMetricPoint(measurementId, measuredAt, value)`;
- `PressureChartPoint(measurementId, measuredAt, systolic, diastolic)`.

Il service espone punti distinti per peso, girovita e pressione. Ogni punto
corrisponde a una riga reale; non sono presenti interpolazione, forward fill,
padding con valori, medie, min/max o aggregazioni giornaliere.

## Filtri e ordinamento

La sezione `ProgressChartsSection` mantiene localmente la metrica e l’intervallo
selezionati. La metrica predefinita è Peso, l’intervallo predefinito è 30
giorni. I controlli sono chip e non sono persistiti nel database.

Gli intervalli sono:

- 7 giorni;
- 30 giorni;
- 90 giorni;
- Tutto.

Per i primi tre, il service include la soglia inferiore (`measuredAt >= now -
durata`) e l’istante `now`, quindi esclude dati futuri. Il range Tutto non applica
un filtro temporale. L’istante arriva da `clockProvider`; il codice della
preparazione chart non usa `DateTime.now()`.

I punti sono ordinati cronologicamente ASC e, a parità di timestamp, per `id`
ASC. Le righe con lo stesso timestamp restano distinte. `weightKg == null` e
`waistCm == null` eliminano solo il punto della relativa serie.

## UI dei grafici

La pagina Progressi contiene una sola card Andamento, con un grafico alla volta:

- Peso: valori `weightKg`, unità kg;
- Girovita: valori `waistCm`, unità cm;
- Pressione: due serie contemporanee, Sistolica e Diastolica, unità mmHg.

La frequenza cardiaca non è un grafico M7.5 e resta nei dettagli/riepiloghi già
esistenti. La pressione non contiene soglie, zone, colori clinici, giudizi,
warning o classificazioni.

Un singolo punto è valido e viene visualizzato. Un intervallo senza punti mostra
`Nessun dato disponibile per questo intervallo`; con dati presenti viene mostrato
anche il numero di misurazioni nel periodo. I tooltip, quando attivati dal touch,
mostrano solo serie, valore, data e ora. Le etichette della pressione sono
testualmente `Sistolica` e `Diastolica`.

I limiti grafici aggiunti per rendere leggibili un solo punto o valori costanti
sono esclusivamente viewport/padding dell’asse: non creano punti nel dominio.
Le label X sono giorno/mese; le label Y mostrano i valori senza ripetere l’unità
su ogni tick.

## Reattività, layout e navigazione

La sezione riceve gli stessi due `AsyncValue` già osservati da `ProgressPage`.
Create, update e delete sui repository aggiornano gli stream e ricostruiscono i
punti; il filtro corrente viene quindi riapplicato automaticamente. Un record
body con peso e girovita presente contribuisce a entrambe le serie; se viene
modificato a una sola metrica, il punto dell’altra serie scompare.

La pagina e i controlli restano nella route `/progress`, senza nuove route o tab.
Le CTA e i flussi CRUD di M7.2/M7.3 non sono stati riscritti. La card usa
`Wrap`, una singola colonna scrollabile e un’altezza chart contenuta per gestire
320×480 e TextScaler 2.0. È presente inoltre un summary testuale del numero di
misurazioni vicino al grafico.

## Database e scope

Non sono state aggiunte tabelle, colonne, entità persistite o migration.
`schemaVersion` resta 8. Non sono stati modificati profilo, baseline iniziale,
CRUD body/pressione, bottom navigation o routing.

Restano esclusi da M7.5: grafico frequenza cardiaca, goal, target, forecast,
regressione, giudizi sul trend, interpretazione clinica, aggregazioni, export,
cloud e integrazioni wearable.

## File

Creati:

- `lib/domain/entities/progress_chart_point.dart`;
- `lib/domain/services/progress_chart_service.dart`;
- `lib/features/progress/presentation/widgets/progress_charts_section.dart`;
- `test/domain/progress_chart_service_test.dart`;
- `test/features/progress_charts_section_test.dart`;
- `Docs/M7_5_Progress_Charts.md`.

Modificati:

- `pubspec.yaml` e `pubspec.lock` per la dipendenza chart;
- `lib/features/progress/presentation/pages/progress_page.dart` per inserire la
  sezione nella pagina già esistente.

## Test e quality gate

I test del service coprono input vuoto, metriche parziali/null, ordine
cronologico, tie-break ID, stesso timestamp, range 7/30/90/Tutto, boundary
inclusiva, dati futuri esclusi nei range finiti, un punto, pressione a due serie
e dataset da 1000 body measurement senza benchmark a tempo.

I widget test coprono stato vuoto, selezione Peso/Girovita/Pressione, filtri,
legend pressione, un punto, dati parziali, rebuild con delete, 320×480 e
TextScaler 2.0. La suite preesistente di `ProgressPage` resta verde, inclusi i
flussi CRUD e la pressione.

La form body non è stata sottoposta a hardening generale: il limite noto di
scroll/doppio submit resta fuori scope salvo regressioni concrete, che non si
sono verificate.

Il quality gate finale viene registrato nel report di consegna insieme a
`dart format .`, `flutter analyze`, `flutter test` e `git status`.
