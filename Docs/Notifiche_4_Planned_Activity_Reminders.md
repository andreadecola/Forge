# FORGE — Notifiche.4: reminder PlannedActivity

## Stato

Implementazione dei reminder locali reali per le sole attività pianificate
`WORKOUT` e `WALK`. `PlannedActivity` resta la source of truth; la notifica è
una proiezione ricostruibile e non introduce calendario, tabella o stato
duplicato.

I documenti richiesti dal prompt (`Docs/README.md`, `Docs/09_Roadmap.md`,
`Docs/08_Notifications_Backup.md`, `Docs/Notifiche_1–3`, `Docs/02–03`) non sono
presenti nel checkout di questa baseline. `Docs/` contiene solo M7.4–M7.6 e
`Forge_Docs/` è vuota. L’implementazione è stata confrontata con il codice e
con i test M8 presenti.

## Source of truth e profilo

La fonte autorevole è `PlannedActivity` e il suo repository M8. Non vengono
copiati data, tipo, stato, completamento o session link nel layer notifiche.
Il completamento deriva dallo stato della sessione collegata; una sessione
`IN_PROGRESS`/`PAUSED` rende il reminder non più utile e lo cancella, una
`COMPLETED` lo cancella, mentre `ABORTED` torna semanticamente disponibile
secondo la semantica M8 esistente.

Il bulk riceve esplicitamente il `profileId` del profilo attivo. Non vengono
notificati profili diversi da quello corrente.

## Eligibility centralizzata

`PlannedActivityReminderSyncService` applica un’unica regola:

- tipo `WORKOUT` o `WALK`;
- stato persistito `PLANNED`;
- nessuna sessione collegata attiva o completata;
- impostazioni effettive: master ON, categoria planned activity ON e orario
  valido non nullo;
- permission OS `granted`;
- data/ora futura.

`RECOVERY` e ogni tipo futuro sono sempre cancellati/non schedulati. `SKIPPED`
e `POSTPONED` sono cancellati; in M8 `POSTPONED` mantiene la data originale,
mentre uno spostamento cambia `scheduledDate` e riporta lo stato a `PLANNED`.

Il master/category/time e la validazione dell’orario riusano
`NotificationSettings.hasDesiredPlannedActivityReminders`; la permission è
valutata nello stesso servizio, senza duplicare la semantica nei widget.

## Scheduling, orario e ID

Il servizio espone `syncActivity(activityId)`:

1. legge l’attività corrente;
2. valuta eligibility e session link;
3. cancella l’ID deterministico;
4. se eleggibile, ricompone `scheduledDate` date-only con
   `plannedActivityReminderTimeMinutes` come wall clock locale;
5. se futuro, cancella e schedula inexact tramite `NotificationScheduler` e
   `LocalNotificationGateway`.

`scheduledDate` non è interpretata come UTC. Il confronto usa `Clock` injected;
un datetime passato, compreso oggi dopo l’orario scelto, non genera una
notifica immediata e restituisce l’outcome esplicito `skippedPast`.

Il namespace è `planned_activity` e l’ID usa
`NotificationIdGenerator.forEntity`. La stessa attività mantiene quindi lo
stesso ID tra sync, edit e move.

## Copy e payload

WORKOUT:

- titolo: `Allenamento previsto oggi`
- corpo: `Quando vuoi, il tuo allenamento è pronto.`

WALK:

- titolo: `Camminata prevista oggi`
- corpo: `Quando vuoi, la tua camminata è pronta.`

Il payload è v1 e contiene solo `type = planned_activity` ed `entityId`.
Non contiene profilo, peso, pressione, note o altre informazioni sensibili.

## Lifecycle M8

Il controller M8 richiama il service dopo la persistenza riuscita:

- create: `syncActivity`;
- edit/data change: `syncActivity`;
- move: `syncActivity` sulla nuova data;
- skip: cancel tramite `syncActivity`;
- postpone: cancel tramite `syncActivity`;
- restore: `syncActivity`;
- delete: `cancelByActivityId`, usando l’ID già noto dopo la delete;
- link sessione Workout/Walk: `syncActivity`, quindi il reminder viene
  cancellato appena la sessione parte;
- completion: rilevata dal link/session state e cancellata al successivo sync.

La generazione Forge M8.4 conferma prima la transazione DB e poi esegue un
bulk sync. Il codice M8 attuale non sostituisce una settimana già contenente
attività `FORGE_ENGINE`: la seconda generazione è rifiutata. Non è stata
inventata una nuova semantica di rigenerazione; le delete M8 passano dal
controller e cancellano i reminder relativi.

## Settings e permission

Il controller settings persiste prima e può ricevere il `profileId` per
richiedere una bulk sync. La UI del Profilo esegue una sola bulk sync dopo il
completamento dell’azione settings; un errore della proiezione non annulla né
nasconde il salvataggio delle impostazioni.

Il cambio master/category/time non richiede automaticamente permission. La
permission viene chiesta solo dal flusso esplicito già presente. Al termine di
una richiesta permission, e al resume della UI, viene eseguita la
reconciliation del profilo attivo: denied/unsupported evita e cancella,
granted ricrea i reminder desiderati.

## Bulk e orphan cleanup

`syncAllPlannedActivityReminders(profileId)` legge tutte le attività del
profilo, applica la stessa eligibility del sync singolo e riconcilia ogni ID.

Per il cleanup viene usata la capability opzionale
`PendingLocalNotificationReader`, che espone un modello applicativo minimale
(`id`, `payload`) e non espone tipi del plugin. L’adapter Flutter la implementa
con `pendingNotificationRequests()`. Vengono cancellati solo i pending con
payload `planned_activity` che non corrispondono a un’attività attualmente
schedulata; altre categorie restano intatte. Se un gateway non supporta la
lista pending, ID deterministici e cancel singoli restano funzionanti.

## Architettura e limiti

M8 non importa `flutter_local_notifications`. Il coupling è:

`M8 write → PlannedActivityReminderSyncService → NotificationScheduler → LocalNotificationGateway`.

Il service usa Riverpod tramite
`plannedActivityReminderSyncServiceProvider`, dipende da una porta minima per
lo stato della sessione e usa `Clock`. Nessuna tabella, migration o dependency
nuova è stata aggiunta; lo schema resta 11. Exact alarm e nuovi permessi Android
non sono stati introdotti.

Il tap continua a produrre un `NotificationTapEvent` con payload decodificato.
Non è stata aggiunta una nuova pagina o una navigazione inventata: il routing
cold-start resta materiale per Notifiche.5 se non può essere collegato in modo
pulito alle route M8 esistenti.

Restano fuori scope: recovery reminder, peso, pressione, inattività, restore
sync, startup reconciliation automatica, hardening completo reboot/timezone e
observer timezone completo.

## Test

Sono coperti eligibility WORKOUT/WALK, RECOVERY, stati skip/completed/active,
settings e permission, passato/oggi dopo orario, copy, payload, ID, idempotenza,
date/time change, skip/delete/completion, move, abort semantics, multi-profile,
orphan cleanup namespace-scoped, failure controllato e clock/wall-clock.

Quality gate baseline: `flutter analyze` 0 issue e `flutter test` 1040/1040.
Quality gate finale e stato manual Android vengono riportati nel report di
consegna; nessun device/emulatore Android è stato dichiarato disponibile in
questa sessione.
