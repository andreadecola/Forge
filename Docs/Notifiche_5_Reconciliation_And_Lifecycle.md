# FORGE — Notifiche.5: reconciliation e lifecycle

## Desired set

`PlannedActivity` resta la source of truth. Il metodo
`computeDesiredPlannedActivityReminders()` costruisce il set applicativo
ricostruibile delle sole attività `WORKOUT` e `WALK` eleggibili del profilo
corrente. Il bulk confronta quel set con i pending locali: rischedula le
richieste desiderate, cancella gli orfani e non tocca altri namespace.

Il gateway Flutter espone `PendingLocalNotificationReader`, che mappa soltanto
`id` e `payload` dal plugin. Gli ID desiderati vengono verificati anche contro
il payload: una collisione teorica non viene sovrascritta né cancellata alla
cieca. Il bulk mantiene inoltre l'eventuale cancellazione deterministica per
gateway che non espongono la lista pending.

## Startup e foreground

`NotificationLifecycleCoordinator` attende, nell'ordine applicativo, bootstrap
notifiche, bootstrap catalogo e risoluzione del profilo corrente. Solo dopo
esegue la reconciliation; non richiede permission OS. Startup e resume sono
non-core e catturano i failure: Forge può aprirsi anche se plugin, timezone o
reconciliation non sono disponibili.

La root app osserva `AppLifecycleState.resumed`. Ogni resume rilegge profilo,
settings, permission, attività e timezone. Le chiamate ravvicinate sono
serializzate; una richiesta arrivata durante un'operazione può causare una
seconda passata seriale per vedere l'ultimo stato DB, mai due passate
concorrenti.

Senza profilo corrente, oppure con timezone non risolvibile, il coordinator non
schedula e prova a rimuovere soltanto i pending `planned_activity`.

## Restore e first run

`BackupRestoreService` resta responsabile di validazione, transaction,
verification e commit. Il callback notifiche viene invocato soltanto dopo il
commit riuscito e gli eventuali errori non trasformano un restore dati riuscito
in un fallimento.

Il restore non richiede permission. Con permission negata la reconciliation
mantiene effective state falso e rimuove/evita i reminder; dopo una concessione
esterna, il resume ricostruisce il set desiderato. Il profilo usato è quello
corrente secondo la semantica attuale Forge, non tutti i profili del backup.
I pending OS non fanno parte del backup e vengono ricostruiti.

## Timezone, DST e reboot

`NotificationTimezoneService.refreshIfChanged()` rilegge l'identificativo del
device senza aggiungere un setting DB. Se cambia timezone, la reconciliation
ricrea le richieste mantenendo `scheduledDate + orario configurato` come wall
clock locale nella nuova timezone. Un resolver fallito attiva il rifiuto
controllato già definito in Notifiche.2; non viene usato UTC ambiguo.

L'adapter usa `zonedSchedule` in modalità
`inexactAllowWhileIdle`. Il manifest contiene già `RECEIVE_BOOT_COMPLETED`,
`ScheduledNotificationReceiver` e `ScheduledNotificationBootReceiver`. La
versione in uso del plugin (`flutter_local_notifications` 22.3.0) persiste i
dettagli delle notifiche e il boot receiver li rischedula su
`BOOT_COMPLETED`, `MY_PACKAGE_REPLACED` e quick-boot. La startup reconciliation
resta la rete di sicurezza dopo apertura/aggiornamento app; non è stato aggiunto
WorkManager o un background service.

Android/OEM può limitare le app in background. In particolare non viene
promessa la consegna durante force-stop; il comportamento dipende dal sistema
e dal produttore.

## Tap routing

Il plugin produce un `NotificationTapEvent`; l'infrastruttura non conosce le
route. `NotificationTapCoordinator` conserva l'evento cold-start finché la
root app installa l'handler, lo consuma una sola volta e protegge gli errori.

Per `type=planned_activity`, se l'attività esiste e appartiene al profilo
corrente, il tap apre la route reale del Piano settimanale (`/plan`). Attività
eliminata, profilo diverso, payload invalido o tipo sconosciuto usano il
fallback Home (`/`). Nessun cambio profilo automatico e nessuna pagina nuova.

## Limiti e stato manuale

Restano fuori scope recovery/peso/pressione/inattività, nuove categorie,
restore/startup observer separati, nuove tabelle/migration/dependency, exact
alarm e hardening Android oltre il supporto del plugin esistente.

Il collaudo con device/emulatore Android è `MANUAL PENDING` quando Android SDK/
`adb` non sono disponibili. Il routing e la reconciliation sono comunque
coperti da test applicativi deterministici.

Schema database: 11. Backup format: 1. Nessuna migration e nessuna nuova
dipendenza.
