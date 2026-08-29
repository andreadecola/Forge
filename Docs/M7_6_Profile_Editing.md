# FORGE — Milestone 7.6: Modifica profilo e dati iniziali

## Baseline e ricognizione

La baseline reale eseguita prima delle modifiche era:

- schema database: 8;
- `flutter analyze`: 0 issue;
- `flutter test`: 709/709 passati.

Il repository contiene già il flusso profilo completo a livello dati. Non è
stato creato un secondo repository, use case, provider, entity o route.

La pagina `ProfilePage` esisteva già in
`lib/features/settings/presentation/pages/profile_page.dart`, ma era ancora
un placeholder. La route `/profile` era già registrata in `AppRoutes` e nella
shell principale; Profilo è la quarta destinazione della bottom navigation.

## Modello e persistenza reali

`UserProfile` è l’entity di dominio corrispondente alla tabella
`UserProfilesTable` (`profili_utente`). I campi presenti e usati dall’app
sono:

- `id`;
- `name`;
- `birthDate`;
- `biologicalSexForFormula`;
- `heightCm`;
- `initialWeightKg`;
- `targetWeightKg` opzionale;
- `preferredWalkMinutes`;
- `equipmentBudgetLimit`;
- `startDate`;
- `activityLevel`;
- `createdAt` e `updatedAt`.

Il DAO reale è `UserProfileDao`; il repository è
`ProfileRepositoryImpl`; il use case riusato è `SaveProfile`. Con un profilo
con ID valorizzato, `SaveProfile` porta all’update della riga esistente tramite
DAO. L’ID, il numero di profili e lo storico delle misurazioni restano
invariati.

Il provider riusato è `currentProfileProvider`, basato sullo stream del DAO.
Non è stato aggiunto un provider parallelo. L’update del profilo viene quindi
riflesso dagli osservatori esistenti senza riavvio dell’app.

## Pagina e campi modificabili

La pagina esistente è stata evoluta in un form scrollabile diviso in:

- Dati personali: nome, data di nascita, parametro sesso;
- Dati corporei iniziali: altezza, peso iniziale e peso obiettivo opzionale;
- Preferenze: durata camminata, livello di attività e budget attrezzatura.

Il peso iniziale mostra il testo neutrale:

> Il peso iniziale viene usato come riferimento nella sezione Progressi.

`targetWeightKg` è stato incluso perché è già un campo reale del profilo,
presente nell’onboarding e usato dall’app; non è stato introdotto un nuovo
sistema di goal. Non sono stati inventati campi per attrezzatura posseduta,
account o altri dati.

Il salvataggio segue il flusso:

`ProfilePage → SaveProfile → ProfileRepositoryImpl → UserProfileDao`.

Il pulsante è disabilitato durante l’operazione. Il doppio submit produce una
sola chiamata. In caso di errore viene mostrato uno SnackBar, il form conserva
i valori inseriti e torna utilizzabile. In caso di successo viene mostrato
`Dati personali aggiornati`.

## Validazione e parsing

Sono stati riusati senza duplicazione i validator di
`OnboardingValidators` per nome, data, altezza, peso iniziale, peso obiettivo,
durata camminata e budget. Altezza e pesi usano il parser condiviso
`lib/core/utils/decimal_parser.dart`, che conserva la semantica già presente
per virgola e punto decimale. `progress_metrics.dart` riesporta lo stesso
parser per mantenere compatibili gli import esistenti.

Il peso iniziale e l’altezza restano obbligatori e non-null come nel modello
attuale. Il salvataggio conserva la precisione `double` prevista.

## Semantiche Progressi e metriche derivate

`initialWeightKg` resta la baseline autorevole di Progressi. Cambiandola,
ProgressPage aggiorna baseline e delta tramite il provider del profilo. Non
viene modificata, inserita o cancellata alcuna `BodyMeasurement`.

I grafici M7.5 ricevono le misurazioni corporee e non `initialWeightKg`:
cambiare la baseline non cambia punti, valori o numero di punti storici.

`heightCm` viene consumata dai calcolatori esistenti di
`BodyMetricsService` tramite il profilo aggiornato. Non sono state modificate
le formule BMI, BMR o TDEE né la semantica del peso usato dal Dashboard: il
Dashboard continua a usare l’ultimo peso corporeo disponibile per le metriche
derivate e l’altezza aggiornata dal profilo.

`createdAt` è preservato. Il repository esistente valorizza `updatedAt` con il
proprio pattern attuale (`DateTime.now()`); non è stato introdotto un nuovo
clock path o modificato il repository fuori scope.

## Loading, errori e responsività

La pagina gestisce loading, errore del provider e profilo nullo senza creare
un profilo vuoto automaticamente. Il form usa `SingleChildScrollView` e
`Column`: questo mantiene tutti i campi partecipanti alla validazione anche se
sono fuori viewport e permette di raggiungere Salva con tastiera o viewport
ridotto. Sono stati verificati 320×480 e text scale 2.0 senza overflow.

Non sono state introdotte guardie per modifiche non salvate, nuove preferenze,
nuove route o nuove tab.

## Test M7.6

Sono stati aggiunti:

- `test/data/profile_repository_update_test.dart`: update di altezza/peso,
  preservazione dei campi, ID invariato e prevenzione del doppio profilo;
- `test/features/profile_page_test.dart`: visualizzazione e modifica dei
  campi, validator e decimali, doppio submit, errore con valori conservati,
  update reale della baseline Progressi con invariance dei punti chart,
  layout 320×480 e text scale 2.0.

I test M2 sui calcolatori delle metriche derivate restano invariati e vengono
eseguiti nella suite completa. Non sono state aggiunte migration.

## Fuori scope e limiti

Restano fuori scope: modifica delle formule, classificazioni cliniche, goal o
target nuovi, storico/audit delle modifiche profilo, cloud, autenticazione,
modifica dello storico corporeo, hardening generale dei form body e nuove
funzionalità di pressione o grafici.

## Quality gate

Il quality gate finale previsto è:

```text
dart format .
flutter analyze
flutter test
```

Nessun commit o push è stato eseguito. Lo stato Git finale deve essere letto
insieme alle modifiche preesistenti delle milestone precedenti.
