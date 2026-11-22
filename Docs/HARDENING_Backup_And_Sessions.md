# Hardening backup multilivello e sessioni

## Formato JSON e compatibilità

Aggiornamento del 22/11/2026: lo schema corrente è **14**.
La camminata interna alla scheda viene esportata nel campo opzionale
`walkingBlock` (minuti e posizione prima/dopo), anche nello snapshot di sessione.
`walkingSessionLocalId` conserva il collegamento alla camminata effettiva e
viene rimappato al ripristino. Backup precedenti senza questi campi restano
compatibili. La sessione combinata termina solo dopo esercizi e camminata;
riusa pausa/ripresa e timer esistenti. Collaudo Android ancora richiesto.
Il backup v1 conserva anche i campi opzionali `performedSets` (diario per
serie) e `reminderAt` (rinvio promemoria nello stesso giorno). Backup precedenti
mantengono diario vuoto e nessun rinvio. I nuovi valori vengono validati prima
di sostituire i dati. Vedi `Docs/EVOLUTIVE_001_010.md` per specifica e collaudo.
Il paragrafo seguente descrive la baseline dello hardening su schema 12.

Lo schema SQLite resta 12; catalogVersion resta 2. Il formato backup resta v1:
`selectedLevels` è un campo opzionale aggiuntivo, come le preferenze opzionali
già supportate dal formato. Non serve una migration SQLite. Un vecchio backup
resta leggibile; le vecchie app che rifiutano databaseVersion 12 continuano a
rifiutare i nuovi export secondo la policy esistente.

Ogni workout esporta ad esempio `"level": 5, "selectedLevels": [1, 3, 5]`.
La lista è ordinata. Sono esportate entrambe le origini USER e FORGE_ENGINE,
incluse le schede archiviate; tutti gli altri campi restano invariati.

Regole di import:

- campo assente o null: compatibilità legacy, insieme `{level}`;
- campo presente: lista non vuota di interi univoci tra 1 e 5;
- `level` deve coincidere con il massimo dei livelli selezionati;
- stringhe, decimali, booleani, elementi nulli, duplicati e valori fuori
  intervallo sono errori: nessuna conversione o correzione silenziosa.

Parsing e validazione precedono qualunque cancellazione. Il restore REPLACE
usa la transazione Drift esistente e verifica anche il set ripristinato prima
del commit. I backup vecchi già prodotti con un solo livello non contengono
informazioni sufficienti a ricostruire eventuali selezioni multiple perdute.

## Timer e recuperi: regole effettive

Il timer delle serie usa `durationSeconds`; il recupero usa `restSeconds`.
Ogni serie a tempo richiede un avvio esplicito. Il countdown completa la serie
e avvia il recupero solo se restano altre serie. Dopo l'ultima serie passa
all'esercizio successivo o al riepilogo, senza recupero aggiuntivo.
Gli esercizi a ripetizioni mantengono il completamento manuale delle serie.

La pausa congela il residuo della serie o del recupero; la ripresa riparte da
quel residuo. Il controller mantiene un solo ticker e rifiuta l'avvio di un
secondo timer mentre una serie o un recupero sono in corso.

I timer sono derivati dai timestamp, non dal numero di tick ricevuti. In
background il tempo trascorre se la sessione non è in pausa. Alla riapertura,
`WorkoutSessionRestoreService` ricostruisce parametri, progresso e residuo.
Se il timer è scaduto applica una sola transizione, secondo le regole già
implementate: serie scaduta → completamento e recupero a partire dal ripristino;
recupero scaduto → prossima serie pronta, senza avviarla automaticamente.

Le scritture dei progressi restano best-effort su eventi significativi, mai
a ogni tick. Una terminazione del processo prima che una scrittura termini
può ripristinare l'ultimo stato persistito: non viene promessa una garanzia
aggiuntiva di flush sincrono. La pausa non è automatica al background.

## Una sola sessione attiva

Home, dettaglio, avvio immediato dopo salvataggio e avvio dal piano Oggi
passano dal controller globale. Una guardia copre l'intero avvio asincrono;
il repository verifica a sua volta la sessione attiva nella transazione di
creazione. Due richieste concorrenti creano una sola sessione.

Il dialogo condiviso permette di tornare alla sessione esistente. Dopo un
riavvio legge dal database, ricostruisce e adotta lo stato prima di navigare.
Una sessione terminale libera lo slot persistito; il riepilogo resta runtime
fino a Fine. Nessun avvio automatico o sostituzione della sessione corrente.

## Verifiche

Test automatici con SQLite e tempo simulato coprono round-trip dei set `[1]`,
`[1,2]`, `[1,3,5]`, `[1,2,3,4,5]` per USER e FORGE_ENGINE, compatibilità dei
campi assenti/null e rigetto pre-write dei dati corrotti. Il confronto completo
del payload verifica anche serie, ripetizioni, secondi, recuperi e stato.
Sono verificati tre countdown da 15 secondi e due recuperi da 30, pausa e
ripresa, timer scaduti durante la chiusura, avvii concorrenti e ripresa della
sessione persistita da Home, dettaglio e salvataggio.

Il collaudo Android resta necessario per il selettore file del backup e il
comportamento del processo in background/riapertura sul dispositivo reale.
Nessun APK generato, nessun commit o push.

## File interessati dall'hardening

- Backup: `lib/data/backup/models/backup_workout.dart`, `backup_mapper.dart`,
  `backup_restore_service.dart`, `backup_validator.dart`, `backup_format_version.dart`.
- Sessioni: `lib/features/training_plan/application/workout_session_controller.dart`,
  `lib/features/training_plan/presentation/widgets/active_workout_dialog.dart`.
- Home/Oggi: `lib/features/dashboard/presentation/widgets/ready_workout_launcher.dart`,
  `today_planned_activities_card.dart`.
- Test: backup export/restore/storage, controller sessione, repository sessione,
  launcher Home e card Oggi; otto fixture delle migrazioni storiche 3–10.
- Documentazione: questo documento, `MANUAL_WORKOUTS_Multilevel_And_Images.md`,
  `README.md` del repository.

La prima suite completa ha rilevato otto fixture storiche che riusavano la
Table corrente e includevano già `livelli`: le fixture ora ricostruiscono
lo schema storico senza quella colonna prima di eseguire la migrazione.
La migrazione di produzione non è stata cambiata. È stato inoltre reso
deterministico il test del nome file backup, che confrontava due export con
l'orologio reale e poteva fallire al cambio di secondo. L'aspettativa della
versione DB dell'export legge ora la versione reale del database.

## Esito tecnico finale — 16 novembre 2026

- Prima suite completa: 1113 superati, 9 falliti (otto fixture storiche e il
  confronto temporale instabile del nome file backup); cause corrette.
- Riesecuzione dei test interessati: 43 superati, zero falliti.
- Suite completa definitiva `flutter test`: **1122 superati, zero falliti**.
- `flutter analyze`: **nessun problema**.
- `git diff --check`: **verde**.
- Schema SQLite **12**, catalogo **2**, formato backup **1** con campo opzionale.
- Nessuna nuova migration SQLite, modifica Forge Engine o modifica immagini.
- Collaudo Android del file picker e del processo in background: **PENDING**.
- APK: non generato. Commit: NO. Push: NO.

Sono stati corretti anche il recupero della sessione persistita prima della
navigazione, lo spinner della Home che restava attivo durante il dialogo e il
menu Home che debordava con nomi lunghi. I test della card Oggi ora la portano
in vista dopo l'aggiunta della sezione di avvio rapido alla Home.
