# Forge — Evolutive EVO-001–010

Incarico del 22/11/2026: implementare EVO-001, 002, 003, 004, 005, 006, 009
e 010. EVO-007 e 008 restano escluse; EVO-012 e 013 non fanno parte del lavoro.
Le verifiche Android sono rinviate dall'utente al collaudo complessivo.

## Decisioni e comportamento

- **EVO-001:** eliminazione esplicita di una camminata conclusa, da storico o
  dettaglio, con conferma e protezione delle camminate attive. Statistiche e
  storico seguono gli stream SQLite. L'attività pianificata sopravvive senza
  collegamento alla camminata cancellata; non è più considerata completata.
- **EVO-002:** eliminazione disponibile anche nel dettaglio scheda, con lo
  stesso componente usato nell'archivio. La transazione rifiuta schede con
  sessioni IN_PROGRESS/PAUSED. Le sessioni concluse conservano nome, esercizi,
  prescrizioni e diario snapshot. I riferimenti alla scheda vengono azzerati;
  le attività pianificate sopravvivono come «allenamento non più disponibile».
- **EVO-003:** l'interruttore generale e il permesso Android governano i
  promemoria; il vecchio flag di categoria resta nei backup per compatibilità,
  ma non determina più l'attivazione. Orario precedente conservato, oppure
  09:00 se non impostato. Un promemoria per attività, ID deterministico,
  riconciliazione esistente. Il tap apre l'attività con azioni Avvia/Riprendi;
  «Rinvia» apre il selettore di un orario futuro nello stesso giorno. Il rinvio
  persiste e non sposta l'attività. Spostando il giorno il rinvio viene azzerato.
  Attività saltate, rinviate nel piano, attive o completate non notificano.
- **EVO-004/005/006:** un solo form e una sola policy per piano automatico e
  manuale: una scheda comprende esercizi e camminata, con una sola frequenza
  e gli stessi giorni. La durata della camminata parte dal profilo; l'utente
  sceglie Prima degli esercizi o Dopo gli esercizi. Sono disponibili anche
  Solo allenamento e Solo camminata. Giorni alterni = lun/mer/ven/dom;
  altre modalità = lun–ven, tutti i giorni, selezione personalizzata.
  Una sola attività al giorno, niente passato o giorni già occupati, nessun
  adattamento silenzioso delle quantità richieste nella nuova UI. La ricerca
  è deterministica e privilegia allenamenti distanziati; allenamenti quotidiani
  sono possibili solo se l'utente sceglie giorni e frequenza compatibili.
  I giorni liberi restano liberi: non vengono inventate attività di recupero.
  Forge compone gli esercizi con l'algoritmo esistente; nel percorso manuale
  l'utente sceglie una scheda pronta. Tipo, livelli e durata degli esercizi
  manuali si modificano nella scheda. La conferma manuale salva durata e posizione
  della camminata nella scheda scelta, mantenendo livelli e prescrizioni.
  Anteprima senza scritture, conferma atomica e nuovo controllo delle collisioni.
- **EVO-009:** diario per serie, legato allo snapshot della sessione. Quantità
  effettive, carico e difficoltà soggettiva 1–10 sono facoltativi ma almeno un
  valore deve essere inserito; zero è ammesso per quantità/carico effettivi,
  valori negativi o non finiti no. Nessun valore effettivo viene dedotto dalla
  prescrizione. Il diario non completa automaticamente una serie e non altera
  i timer. Inserimento durante la sessione o dallo storico, modifica della
  stessa serie senza duplicati, confronto con sessioni concluse precedenti.
- **EVO-010:** sezione «Attività e risultati» in Progressi. Settimana e mese
  di calendario confrontati con il periodo precedente. Totali delle sessioni
  completate, pianificati/svolti tramite link espliciti, minuti di allenamento
  (durata totale incluse pause), minuti attivi di camminata, passi e distanza
  registrati. Per le attività reali il periodo è quello della data di inizio;
  per i piani è quello del giorno previsto. La variazione di peso richiede due
  misure nel periodo; i grafici esistenti restano disponibili. Nessun valore
  inventato quando una metrica manca. Il rilevamento da sensori resta EVO-013.

## Database e backup

Schema corrente **14**, catalogo **2**. Lo schema 13 introduceva due dati prima non
rappresentabili: `sessioni_esercizi.prestazioni` (JSON, default `[]`) e
`attivita_pianificate.promemoria_rinviato_al` (timestamp nullable).
Nessuna tabella parallela e nessuna cancellazione di dati. I percorsi storici
di migrazione che creano/ricreano la tabella usano già la definizione corrente.

Backup JSON v1 esteso con campi opzionali `performedSets` e `reminderAt`.
I vecchi backup si leggono con diario vuoto e nessun rinvio. Le nuove
prestazioni vengono validate prima della sostituzione dei dati. Livelli,
prescrizioni, immagini e altri dati delle schede restano invariati.

### Correzione dal collaudo: camminata nella scheda (22/11/2026)

La Home espone «Pianifica allenamento» sotto «Inizia allenamento».
Nel piano combinato viene creata una sola attività WORKOUT per giorno:
la camminata non occupa un giorno separato. Le attività preesistenti restano
conservate e non vengono abbinate automaticamente.

La migrazione 13 → 14 aggiunge tre campi nullable: `allenamenti.camminata`
(durata/posizione JSON), `sessioni_allenamento.camminata_snapshot` e
`sessioni_allenamento.id_camminata` (FK SET NULL). Sono necessari per salvare
la scelta e conservare lo storico anche dopo modifiche della scheda.
Non vengono cancellati dati e il catalogo resta 2.

La sessione riusa controller, timer e registrazione del modulo Camminate.
Prima/Dopo determina la fase disponibile; il completamento della scheda richiede
entrambe le parti. Pausa/ripresa e interruzione della scheda si applicano anche
alla sua camminata attiva. Un'altra camminata attiva impedisce un secondo avvio.
La conclusione della camminata aggiorna la scheda anche da un altro ingresso;
lo stato persistito consente la ripresa dopo riapertura. Il blocco resta visibile
nel dettaglio e nello storico; le statistiche usano il collegamento reale.

Il backup v1 include `walkingBlock` opzionale nelle schede e negli snapshot,
e `walkingSessionLocalId` nelle sessioni: il restore rimappa il collegamento.
Backup precedenti senza questi campi rimangono leggibili.

Verifica della correzione: **50 test mirati superati**, inclusi migrazioni,
pianificazione manuale/Forge, prima/dopo, pausa/ripresa, riapertura e backup.
La tabella sottostante descrive il controllo precedente su schema 13;
i risultati finali della correzione sono riportati in fondo al documento.

## Verifiche

Verifiche mirate eseguite durante lo sviluppo:

- `test/data/evolutions_001_010_test.dart`: eliminazioni su SQLite, protezione
  delle sessioni, snapshot conservati per tutte le origini delle schede, diario
  persistente, validazione di quantità/carico/difficoltà, migrazione 12 → 13,
  round-trip backup completo e rifiuto di prestazioni corrotte prima del replace.
- `test/domain/weekly_schedule_policy_test.dart`: modalità di scelta dei giorni,
  piano misto deterministico, giorni non consecutivi, nessun giorno, configurazioni
  impossibili, giorni occupati/passati e piano di sole camminate.
- `test/domain/activity_dashboard_service_test.dart`: conteggi reali, confronto
  fra periodi, link espliciti piano/sessione, confini mese/anno, pause delle
  camminate, distinzione fra zero registrato e dato mancante.
- `test/features/evolutions_001_010_ui_test.dart`: conferme/annullamenti,
  aggiornamento della dashboard dopo eliminazione, ritorno dai dettagli agli
  elenchi, protezione sessioni, inserimento/modifica/rilettura del diario a
  320×480, tap notifica → attività specifica → avvio esplicito e collegamento.
- `test/features/weekly_forge_generation_sheet_test.dart`: percorsi misti
  automatico e manuale con anteprima senza scritture, conferma, riapertura,
  configurazione irrealizzabile e layout ridotto/testo grande.
- Test notifiche esistenti estesi: master sufficiente con flag legacy spento,
  orario predefinito, rinvio persistente, ricostruzione del reminder con lo
  stesso ID e rifiuto dei rinvii passati, fuori giorno o non pertinenti.

Le regressioni della prima esecuzione completa sono state corrette:

- per gli schemi 9/10 la ricreazione di `attivita_pianificate` deve dichiarare
  la nuova colonna del promemoria in `TableMigration.newColumns`, senza tentare
  di copiarla dalla vecchia tabella;
- i test che eliminavano una scheda con sessione attiva ora verificano il
  blocco e la conservazione dello storico dopo il termine della sessione;
- il feedback «Allenamento eliminato» dell'archivio è stato conservato anche
  nel componente condiviso;
- il dettaglio ora espone Elimina, lo storico con diario richiede scorrimento,
  e il tap notifica apre l'attività specifica mantenendo la shell principale.
  I test UI sono stati aggiornati ai comportamenti richiesti.

Verifiche finali del 22/11/2026:

| Controllo | Esito |
|---|---|
| `flutter test --reporter expanded` (suite completa) | **1154 superati, 0 falliti** |
| `flutter analyze` | **Nessun problema** |
| `git diff --check` | **Superato** |
| Manifest Android | XML valido; receiver dell'azione notifica dichiarato |
| Immagini/catalogo e algoritmo Forge | Nessuna modifica |
| HEAD iniziale e finale | `f89103f` — `documento contenente evolutive` |
| Database/catalogo | Schema **13**, catalogo **2**, migrazione compatibile |
| APK, commit, push | **Non eseguiti** |
| Collaudo Android | **PENDING**, rinviato dall'utente |

Stato del registro: **In collaudo** per EVO-001–006, EVO-009 ed EVO-010.
BUG-001 resta in collaudo; EVO-012/013 non avviate; gli ID esclusi restano esclusi.

## File principali

| Area | File |
|---|---|
| Eliminazioni | `drift_walking_session_repository.dart`, `drift_workout_repository.dart`, `delete_walking_button.dart`, `delete_workout_button.dart`, storico/dettagli camminate e schede |
| Piano | `weekly_schedule_policy.dart`, `weekly_days_selector.dart`, `weekly_plan_generation_service.dart`, `weekly_plan_generation_repository.dart`, `weekly_forge_generation_sheet.dart`, `weekly_plan_page.dart` |
| Notifiche | `notification_settings.dart`, `notification_settings_section.dart`, `planned_activity_reminder_sync_service.dart`, `flutter_local_notification_gateway.dart`, `notification_tap_event.dart`, `app.dart`, router, `AndroidManifest.xml` |
| Apertura attività | `planned_activity_detail_page.dart`, `today_planned_activities_card.dart` (azioni condivise) |
| Diario | `set_performance.dart`, `performance_repository.dart`, `exercise_performance_diary.dart`, sessione e dettaglio storico |
| Progressi | `activity_dashboard_service.dart`, `activity_dashboard_section.dart`, `progress_page.dart` |
| Persistenza | `app_database.dart` e codice generato, tabelle attività/sessioni esercizi, entità e mapper corrispondenti, DTO/mapper/restore backup |
| Documentazione | README, registro, documenti master allenamenti, progressi, backup e notifiche |

Le modifiche BUG-001 già presenti all'inizio dell'incarico sono state conservate.

## Collaudo Android da eseguire

1. Eliminare una camminata conclusa, annullando prima la conferma; controllare
   poi storico, riepiloghi e riapertura dell'app.
2. Eliminare schede manuali/Forge, anche archiviate: lo storico completato deve
   restare consultabile. Con una sessione attiva la cancellazione deve essere
   bloccata senza alterare timer e progressi.
3. Dalla Home aprire «Pianifica allenamento». Confrontare automatico e manuale:
   scegliere Allenamento e camminata, durata, posizione prima/dopo, frequenza
   e giorni comuni (alterni, lun–ven, tutti, personalizzati). Verificare una sola
   attività per giorno, riapertura della scheda, entrambe le fasi della sessione,
   pausa/ripresa e riapertura durante la camminata. Controllare anche le modalità
   Solo allenamento/Solo camminata e le configurazioni impossibili.
4. Con il solo interruttore generale e il permesso Android, verificare le
   notifiche di attività pianificate. Tap e azione Rinvia devono aprire l'attività
   corretta; scegliere un orario futuro nello stesso giorno e riaprire l'app.
   Verificare annullamento dopo modifica, avvio, completamento o eliminazione.
5. In una sessione registrare ripetizioni o secondi effettivi, carico e difficoltà;
   riaprire il diario dallo storico, modificare una serie e confrontare le
   precedenti. Prescrizioni e timer devono restare invariati.
6. In Progressi verificare settimana/mese, confronto precedente, peso, attività
   pianificate/svolte, minuti, passi e distanza registrati.
7. Esportare/ripristinare un backup con selezioni multilivello, prestazioni,
   promemoria rinviati e camminata interna alla scheda; controllare anche un backup
   precedente allo schema 14. La camminata effettiva deve restare collegata.

Queste verifiche manuali restano pending per decisione dell'utente. Le richieste
non vengono spostate nello storico delle completate prima del collaudo.

## Esito finale della correzione camminata integrata

22/11/2026, schema 14 / catalogo 2:

- Test mirati: **50 superati, 0 falliti**.
- `flutter test --no-pub --reporter expanded`: **1166 superati, 0 falliti**.
- `flutter analyze --no-pub`: **nessun problema**.
- `git diff --check`: **superato**.
- Corretto un rilievo di stile nel nuovo test; fixture di migrazione 4/5 congelate
  allo schema storico per non importare il nuovo collegamento camminate.
- Collaudo Android della correzione: **PENDING**.
- Dati dell'emulatore non cancellati; APK, commit e push non eseguiti.

Per il collaudo terminare il precedente `flutter run` e avviare
`flutter run -d emulator-5554`. La migrazione richiede il riavvio completo
dell'app; non serve disinstallarla. Provare un nuovo piano in giorni liberi:
le vecchie attività separate vengono conservate, non convertite automaticamente.

### Pianificazione avviata di domenica

Correzione dal collaudo del 22/11/2026: aprendo il piano di domenica viene
proposta automaticamente la settimana successiva (23–29 novembre nel caso
segnalato). Il calendario e il form mostrano lo stesso intervallo. Negli altri
giorni resta proposta la settimana corrente. Frecce e «Vai alla settimana
corrente» consentono ancora una scelta esplicita. Nessuna attività già salvata
viene spostata. Test aggiunti per domenica, cambio anno e altri giorni;
il test Home verifica la navigazione domenicale e l'intervallo mostrato.
