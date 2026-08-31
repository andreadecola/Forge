# FORGE - Notifiche.6: hardening finale e collaudo Android

## Stato della fase

La fase applica il freeze funzionale delle notifiche locali. Sono state
verificate e, dove necessario, irrobustite soltanto le integrazioni gia
presenti nelle fasi Notifiche.4 e Notifiche.5.

La feature coperta resta limitata a un solo reminder locale per le attivita
`WORKOUT` e `WALK` pianificate. `PlannedActivity` e il source of truth; la
notifica resta una proiezione ricostruibile. `RECOVERY`, peso, pressione e
inattivita restano fuori dal MVP.

## Audit e hardening

Il percorso verificato e:

`PlannedActivity -> eligibility -> settings -> permission -> schedule -> pending -> reconciliation -> tap -> /plan`.

L'effective state e calcolato dal servizio applicativo dei reminder usando
master switch, opt-in della categoria, orario valido e permission OS. Sono
supportati solo gli stati M8 effettivamente eleggibili; attivita saltate,
posticipate, completate, eliminate, con sessione attiva e date/ore passate
non producono reminder.

La composizione dell'orario usa `scheduledDate` come data-only e l'orario
globale come wall clock locale. Il confronto con il passato usa `Clock`
iniettato. Cambio data, spostamento, cambio orario e cambio timezone
rischedulano lo stesso ID deterministico; skip, delete e completamento lo
cancellano. L'ID appartiene al namespace `planned_activity`, mentre il
payload v1 contiene solo `type` e `entityId`.

Il desired set e riconciliato con i pending reali. Il cleanup legge il
modello applicativo `PendingLocalNotification` e cancella solo pending del
namespace `planned_activity`; namespace futuri o estranei restano intatti.
Il controllo con ID e payload protegge da collisioni teoriche.

Startup, resume e restore sono serializzati. Startup e resume attendono
bootstrap notifiche, catalogo e profilo, non richiedono permission e non
bloccano l'avvio in caso di failure. Senza profilo o timezone risolvibile
viene eseguito soltanto il cleanup sicuro del namespace. Il restore invoca la
reconciliation solo dopo commit e verifica riusciti; un fallimento della
projection non annulla il restore dati.

L'unico bug reale trovato durante l'hardening e stato un possibile errore
asincrono non osservato nel future di bookkeeping del guard lifecycle quando
una reconciliation falliva. Il callback e ora osservato anche sul ramo di
errore e il test di regressione verifica che startup/resume restino non-core.
Il fix precedente di Notifiche.5 che conserva il coordinator prima di
`dispose` evita inoltre l'accesso a Riverpod dopo lo smontaggio della root app.

## Android, reboot e limiti

La configurazione usa `flutter_local_notifications 22.3.0`, scheduling
`inexactAllowWhileIdle`, `timezone 0.11.1` e `flutter_timezone 5.1.0`.
Sono presenti `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`,
`ScheduledNotificationReceiver` e `ScheduledNotificationBootReceiver`.
Non sono presenti `SCHEDULE_EXACT_ALARM` o `USE_EXACT_ALARM`.

Il boot receiver del plugin rischedula le richieste persistite dopo boot,
quick boot e sostituzione dell'app. Startup reconciliation resta la rete di
sicurezza dopo apertura o aggiornamento. Non sono stati introdotti
WorkManager, servizi background, nuove dipendenze o permessi.

Il comportamento durante force-stop e soggetto alle limitazioni Android e
alle policy del produttore/OEM; non viene promessa la consegna in quella
condizione. Il cambio timezone aggiorna il resolver in memoria e la
reconciliation ricrea il reminder mantenendo il wall clock locale, anche
attraverso DST. Se il timezone non e risolvibile, lo scheduling viene rifiutato
in modo controllato e non viene usato UTC ambiguo.

## Tap routing

L'infrastruttura plugin emette un evento applicativo e non conosce le route.
Il coordinator conserva il tap cold-start finche il router e pronto e lo
consuma una sola volta. Un payload `planned_activity` valido con attivita
esistente del profilo corrente apre `/plan`. Payload invalido, attivita
eliminata, profilo diverso o tipo sconosciuto usano il fallback Home senza
switch automatico di profilo e senza crash.

## Test automatici

La suite finale attesa della baseline Notifiche.5 era `1063/1063`. Dopo il
test di regressione del guard lifecycle il conteggio finale diventa
`1064/1064`.

I test coprono eligibility, WORKOUT/WALK, esclusione RECOVERY, settings,
permission, date/ora passate, copy e payload, ID, idempotenza, edit/move,
skip/delete/completion, sessioni abortite, profili, orphan cleanup,
timezone/DST, startup, resume, restore e tap. Il critical set e stato
ripetuto cinque volte sul codice finale senza flaky osservati.

## Collaudo manuale e build

In questo ambiente `adb` non e disponibile e non e stato rilevato un
device/emulatore Android. Di conseguenza la matrice E2E manuale resta
`PENDING`: nessun test manuale viene dichiarato PASS senza esecuzione reale.

| Area | Stato |
|---|---|
| boot/apertura senza popup | PENDING |
| permission deny/grant/revoke/regrant | PENDING |
| reminder WORKOUT e tap | PENDING |
| reminder WALK e tap | PENDING |
| skip, move e cambio orario | PENDING |
| master/category OFF | PENDING |
| chiusura, riapertura e background | PENDING |
| cold start tap | PENDING |
| reboot | PENDING |
| restore manuale | PENDING |

`flutter build apk --debug` e stato tentato per circa cinque minuti, ma il
processo Dart non ha avviato Gradle/Java e non ha prodotto un esito ne un
errore applicativo; e stato interrotto come timeout ambientale. Non viene
quindi dichiarato un APK validato e non viene dichiarato il collaudo Android
E2E completo.

## Vincoli e stato finale della fase

`schemaVersion` resta 11 e `backupFormatVersion` resta 1. Non sono state
aggiunte tabelle, migration o dipendenze. I pending OS non fanno parte del
backup e vengono ricostruiti dopo restore.

I documenti Notifiche.1-3 e i master document richiesti non sono presenti nel
checkout; non ne e stato inventato il contenuto. Sono disponibili e aggiornati
i documenti Notifiche.4, Notifiche.5 e questo documento. `README.md` descrive
gia correttamente i reminder per workout/camminate e startup/restore/resume.

La prossima priorita resta `EXERCISE EXAMPLE IMAGES`; non e stata avviata.

Stato: **NOTIFICHE.6 HARDENING COMPLETATO - MANUAL ANDROID E2E PENDING**.
Il commit finale resta subordinato al collaudo manuale Android disponibile.
