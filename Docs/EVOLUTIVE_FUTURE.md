# Forge — Registro ufficiale delle evolutive future

Data di istituzione: **16 novembre 2026**.

**Stato:** attività future da sviluppare

**Ultimo aggiornamento:** 22/11/2026

## 1. Obiettivo del documento

Questo documento è il registro permanente e ufficiale delle evolutive, delle
anomalie e dei miglioramenti ancora da sviluppare in Forge. È il riferimento
per pianificazione, implementazione, test e collaudo delle richieste future.

La registrazione di una richiesta non autorizza automaticamente lo sviluppo.
Le attività descritte richiedono un incarico esplicito prima dell'implementazione.

## 2. Evolutive approvate da realizzare

Le dieci evolutive seguenti sono approvate come piano futuro. L'approvazione
del piano non autorizza l'avvio dell'implementazione. Il successivo incarico
del 22/11/2026 autorizza le correzioni dei bug registrati. Un successivo
incarico nella stessa data autorizza EVO-001–006, EVO-009 e EVO-010;
EVO-007/008 restano escluse. Specifica: `Docs/EVOLUTIVE_001_010.md`.

### EVO-001 — Eliminazione camminate dallo storico

- **Stato:** In collaudo
- **Priorità:** Media
- **Data di registrazione:** 16 novembre 2026

**Descrizione funzionale**

Consentire l'eliminazione di una singola camminata registrata, con conferma
esplicita e aggiornamento coerente dello storico e delle statistiche.

**Comportamento alla registrazione**

L'utente può consultare lo storico delle camminate, ma non dispone di un'azione
per eliminare una camminata registrata.

**Comportamento desiderato**

- Esporre l'azione Elimina per una singola camminata nello storico o nel dettaglio.
- Chiedere conferma prima dell'eliminazione dal database locale.
- Aggiornare immediatamente lo storico e ricalcolare le statistiche interessate.
- Annullando o chiudendo il dialogo, conservare integralmente la camminata.

**Criteri di accettazione**

- [ ] La conferma elimina soltanto la camminata scelta.
- [ ] La camminata non compare più nello storico, anche dopo la riapertura.
- [ ] La camminata eliminata non contribuisce più alle statistiche.
- [ ] Annullamento e chiusura del dialogo non modificano dati o statistiche.
- [ ] Le altre camminate e gli altri dati utente restano invariati.
- [ ] Test mirati e collaudo Android verificano il percorso completo.

**Note tecniche e dipendenze**

Analizzare repository/DAO delle camminate, provider dello storico e delle
statistiche, dettagli e collegamenti al piano settimanale. Definire il trattamento
dei riferimenti a una camminata eliminata e la protezione di eventuali sessioni
in corso. Riutilizzare l'architettura esistente; dimostrare la necessità di
eventuali modifiche allo schema prima di introdurle.

### EVO-002 — Eliminazione definitiva delle schede di allenamento

- **Stato:** In collaudo
- **Priorità:** Media
- **Data di registrazione:** 16 novembre 2026

**Descrizione funzionale**

Rendere disponibile un percorso chiaro e sicuro per l'eliminazione definitiva
delle schede manuali e generate da Forge, mantenendolo distinto dall'archiviazione.

**Comportamento alla registrazione**

La richiesta nasce dalla disponibilità dell'azione Archivia e dall'esigenza di
eliminare definitivamente una scheda. Nel repository è però già presente un
percorso di eliminazione nella schermata delle schede archiviate:
`lib/features/training_plan/presentation/pages/archived_workouts_page.dart`
espone il dialogo «Elimina definitivamente» e chiama `deleteWorkout`.

Questa evidenza non chiude la richiesta: occorre verificare accessibilità del
percorso, protezione delle sessioni attive e conservazione dello storico prima
di considerare soddisfatti i requisiti. L'evolutiva resta Da sviluppare.

**Comportamento desiderato**

- Esporre l'azione Elimina nei punti concordati, mantenendo separata Archivia.
- Riutilizzare, dove possibile, il percorso di eliminazione già disponibile.
- Mostrare un dialogo esplicito sull'irreversibilità dell'operazione.
- Eliminare le relazioni della scheda secondo le regole del database.
- Gestire allo stesso modo schede manuali e generate da Forge.
- Proteggere le eventuali sessioni attive collegate alla scheda.
- Definire e documentare la politica sullo storico prima di implementare il cambio.
- Aggiornare immediatamente tutte le schermate interessate.

**Criteri di accettazione**

- [ ] La scheda eliminata non compare più tra quelle disponibili o archiviate.
- [ ] L'eliminazione resta effettiva dopo la riapertura dell'app.
- [ ] Archivia resta un'azione distinta con il comportamento attuale.
- [ ] Annullare o chiudere la conferma lascia tutti i dati invariati.
- [ ] Le relazioni sono gestite senza riferimenti incoerenti o cancellazioni involontarie.
- [ ] Una sessione attiva non perde timer, progressi o dati per effetto dell'eliminazione.
- [ ] Gli allenamenti completati non vengono cancellati involontariamente;
  la politica sullo storico è esplicita, documentata e verificata.
- [ ] Il percorso funziona sia con schede manuali sia con schede Forge.
- [ ] Test mirati e collaudo Android verificano eliminazione e dati conservati.

**Note tecniche e dipendenze**

Prima dello sviluppo eseguire un audit di `WorkoutRepository.deleteWorkout`,
DAO, vincoli FK, righe scheda, snapshot delle sessioni, storico e piano
settimanale. Verificare le regole CASCADE/SET NULL effettive e la gestione delle
sessioni in corso. Non duplicare l'azione già disponibile fra le archiviate.
La politica implementata conserva le sessioni concluse e blocca l'eliminazione
con sessioni attive/in pausa; il comando è disponibile nel dettaglio e fra le
archiviate. Specifica e verifiche: `Docs/EVOLUTIVE_001_010.md`.

### EVO-003 — Notifiche intelligenti per attività pianificate

- **Stato:** In collaudo
- **Priorità:** Alta
- **Data di registrazione:** 22 novembre 2026

**Descrizione funzionale**

Rendere automatici i promemoria locali degli allenamenti e delle camminate
pianificati, mantenendo soltanto l'abilitazione generale e il permesso Android.

**Comportamento alla registrazione**

Sono già presenti notifiche locali e promemoria per attività pianificate, con
un interruttore separato «Promemoria attività pianificate» nella pagina Profilo.
L'evolutiva deve estendere e semplificare il sistema esistente.

**Comportamento desiderato**

- Mantenere soltanto l'abilitazione generale delle notifiche e il permesso Android.
- Rimuovere l'interruttore separato «Promemoria attività pianificate» dal Profilo.
- Verificare automaticamente le attività pianificate nel giorno.
- Non inviare notifiche nei giorni senza attività.
- Aprire l'attività direttamente dalla notifica.
- Consentire di rinviare il promemoria scegliendo un orario personalizzato.
- Aggiornare o annullare i promemoria quando un'attività cambia, viene completata
  o viene eliminata; evitare notifiche duplicate.
- Usare notifiche locali, senza server.

**Criteri di accettazione**

- [ ] Con abilitazione generale e permesso Android, i promemoria seguono le attività previste.
- [ ] Giorni senza attività e attività non più pertinenti non producono promemoria.
- [ ] Apertura diretta e rinvio a un orario personalizzato funzionano su Android.
- [ ] Modifiche, completamento ed eliminazione aggiornano o annullano le notifiche senza duplicati.
- [ ] La rimozione del secondo interruttore preserva correttamente le preferenze esistenti e i backup.

**Note tecniche e dipendenze**

Riutilizzare notifiche, riconciliazione e navigazione esistenti. Definire prima
dello sviluppo come trattare le preferenze precedenti e il rinvio personalizzato.
Coordinare i promemoria con EVO-004, EVO-005 ed EVO-006. Nessun nuovo servizio remoto.

### EVO-004 — Integrare le camminate nei piani settimanali Forge

- **Stato:** In collaudo
- **Priorità:** Alta
- **Data di registrazione:** 22 novembre 2026

**Descrizione funzionale**

La generazione automatica del piano settimanale deve includere allenamenti
domestici e camminate, con una distribuzione coerente nella settimana.

**Comportamento alla registrazione**

La richiesta riguarda l'inclusione delle camminate nel piano generato, oltre
agli allenamenti in casa. Pianificazione, camminate e preferenze di durata sono
già aree dell'app: prima dello sviluppo verificare quanto è già supportato
dal generatore settimanale, senza duplicarlo.

**Comportamento desiderato**

- Generare un piano contenente allenamenti e camminate.
- Configurare una sola frequenza e gli stessi giorni per la scheda combinata.
- Includere la camminata nella scheda, scegliendo prima o dopo gli esercizi
  (precisazione dell'utente durante il collaudo del 22/11/2026).
- Utilizzare le preferenze di durata già disponibili.
- Distribuire le attività nella settimana evitando sovrapposizioni indesiderate.
- Rispettare i giorni di recupero e integrare le attività con le notifiche.

**Criteri di accettazione**

- [ ] Il piano generato include i tipi e i numeri di attività richiesti, quando realizzabili.
- [ ] Durate, distribuzione, recuperi e sovrapposizioni rispettano la configurazione.
- [ ] Le attività generate sono salvate e integrate con i promemoria previsti.
- [ ] Le configurazioni non realizzabili sono segnalate chiaramente.

**Note tecniche e dipendenze**

Riutilizzare il piano settimanale e il modello delle attività pianificate.
Coordinare con la scelta dei giorni EVO-005, la parità manuale EVO-006 e le
notifiche EVO-003. Specifiche dettagliate da preparare prima dell'implementazione.

### EVO-005 — Scelta dei giorni di allenamento

- **Stato:** In collaudo
- **Priorità:** Alta
- **Data di registrazione:** 22 novembre 2026

**Descrizione funzionale**

Consentire di scegliere quando svolgere le attività nella pianificazione settimanale.

**Comportamento alla registrazione**

È presente la pianificazione settimanale; la richiesta formalizza le modalità
di scelta dei giorni da offrire e uniformare nei percorsi automatico e manuale.

**Comportamento desiderato**

- Modalità Giorni alterni.
- Modalità Dal lunedì al venerdì.
- Modalità Tutti i giorni.
- Selezione manuale dei giorni della settimana.
- Rispetto dei giorni selezionati, coordinando allenamenti e camminate.
- Verifica della compatibilità con il numero di attività richiesto e segnalazione
  delle configurazioni non realizzabili.

**Criteri di accettazione**

- [ ] Tutte e quattro le modalità sono selezionabili e rispettate dal piano.
- [ ] Il numero di attività è compatibile con i giorni e i recuperi previsti.
- [ ] Allenamenti e camminate vengono coordinati senza sovrapposizioni indesiderate.
- [ ] Una richiesta non realizzabile viene segnalata, senza cambiare silenziosamente i giorni.

**Note tecniche e dipendenze**

Prima dell'implementazione definire la semantica dei giorni alterni e i criteri
di compatibilità. Coordinare con EVO-004 ed EVO-006; riutilizzare le validazioni
del piano esistente.

### EVO-006 — Parità funzionale tra Forge Engine e creazione manuale

- **Stato:** In collaudo
- **Tipo:** Requisito trasversale
- **Priorità:** Alta
- **Data di registrazione:** 22 novembre 2026

**Descrizione funzionale**

Ogni nuova opzione condivisibile introdotta in «Genera con Forge» deve essere
prevista anche nel percorso manuale, quando pertinente. La differenza deve
rimanere nella composizione: Forge genera automaticamente, mentre l'utente
costruisce manualmente la scheda o il piano.

**Comportamento alla registrazione**

I percorsi automatico e manuale condividono già alcune capacità, fra cui
multilivello e immagini. La parità delle nuove opzioni di pianificazione va
verificata a ogni evoluzione, senza considerare questo requisito già completato.

**Comportamento desiderato**

Offrire in entrambi i percorsi, dove pertinenti: scelta dei giorni, giorni
alterni, lunedì–venerdì, tutta la settimana, giorni personalizzati,
pianificazione delle camminate e impostazioni comuni di durata e frequenza.
Riutilizzare componenti UI, validazioni e logica applicativa.

**Criteri di accettazione**

- [ ] Le opzioni condivisibili hanno un equivalente coerente nel percorso manuale.
- [ ] Le stesse configurazioni rispettano le stesse regole nei due percorsi.
- [ ] Composizione automatica e manuale restano distinte.
- [ ] Il collaudo delle evolutive collegate comprende entrambi i percorsi.

**Note tecniche e dipendenze**

Requisito da applicare trasversalmente, in particolare a EVO-004 ed EVO-005.
Le eccezioni di pertinenza devono essere esplicite e documentate. Evitare
architetture o validazioni parallele.

### EVO-009 — Diario delle prestazioni

- **Stato:** In collaudo
- **Priorità:** Alta
- **Data di registrazione:** 22 novembre 2026

**Descrizione funzionale**

Registrare e consultare le prestazioni effettive durante gli allenamenti,
rendendole confrontabili nel tempo.

**Comportamento alla registrazione**

Le sessioni registrano già avanzamento e serie completate. Il diario richiesto
deve estendere i dati effettivi disponibili senza confonderli con le prescrizioni
della scheda.

**Comportamento desiderato**

- Serie realmente completate e ripetizioni effettive.
- Carichi utilizzati e durata effettiva degli esercizi a tempo.
- Difficoltà percepita.
- Consultazione delle prestazioni precedenti e confronto dei risultati nel tempo.

**Criteri di accettazione**

- [ ] Le prestazioni effettive possono essere registrate e rilette dopo la riapertura.
- [ ] Dati effettivi e valori prescritti restano distinguibili.
- [ ] Il diario permette di consultare e confrontare le prestazioni precedenti.
- [ ] Persistenza e backup preservano correttamente i nuovi dati.

**Note tecniche e dipendenze**

Analizzare snapshot e progresso delle sessioni prima di definire nuovi campi.
Valutare le eventuali modifiche a schema e formato backup solo nella specifica
tecnica. Collegamento con EVO-012 per l'inserimento durante l'allenamento.

### EVO-010 — Dashboard completa dei progressi

- **Stato:** In collaudo
- **Priorità:** Media
- **Data di registrazione:** 22 novembre 2026

**Descrizione funzionale**

Realizzare una dashboard riepilogativa dell'andamento delle attività e dei risultati.

**Comportamento alla registrazione**

Forge dispone già di misurazioni, storico e statistiche in più aree. La richiesta
è una vista riepilogativa più completa e coordinata, usando principalmente
i dati disponibili nel database locale.

**Comportamento desiderato**

- Andamento del peso.
- Allenamenti completati e confronto fra programmati e svolti.
- Minuti totali di allenamento.
- Numero e minuti delle camminate, passi effettuati e distanza percorsa.
- Statistiche settimanali e mensili e confronto dei progressi nel tempo.

**Criteri di accettazione**

- [ ] Gli indicatori richiesti sono consultabili con periodi settimanali e mensili.
- [ ] Totali e confronti corrispondono ai dati locali e si aggiornano quando cambiano.
- [ ] Dati mancanti sono rappresentati correttamente, senza inventare risultati.
- [ ] La dashboard integra i dati di EVO-013 quando disponibili.

**Note tecniche e dipendenze**

Riutilizzare repository, provider e calcoli esistenti. Coordinare con BUG-001
per la coerenza del peso e con EVO-013 per passi e obiettivi.

### EVO-012 — Modalità allenamento guidato

- **Stato:** Da sviluppare
- **Priorità:** Media
- **Data di registrazione:** 22 novembre 2026

**Descrizione funzionale**

Migliorare l'interfaccia usata durante una sessione e integrarla con il diario
delle prestazioni.

**Comportamento attuale**

Immagini START/END, serie corrente, prescrizioni, countdown, recuperi e azioni
di sessione sono già presenti almeno in parte. Queste basi vanno riutilizzate;
non costituiscono da sole il completamento dell'evolutiva richiesta.

**Comportamento desiderato**

- Visualizzazione delle immagini START/END e indicazione della serie corrente.
- Ripetizioni o secondi previsti, countdown dedicato e timer di recupero.
- Pulsanti per avanzare fra le serie.
- Possibilità di saltare o ripetere una serie.
- Integrazione con il diario delle prestazioni.

**Criteri di accettazione**

- [ ] L'esecuzione guidata mantiene immagini, prescrizioni, serie e timer coerenti.
- [ ] Avanzamento, salto e ripetizione della singola serie sono gestiti correttamente.
- [ ] Il diario registra le prestazioni senza alterare le prescrizioni originali.
- [ ] Pausa, ripresa e ripristino mantengono correttamente stato e progressi.

**Note tecniche e dipendenze**

Riutilizzare timer e controller delle sessioni già implementati. Distinguere
il salto di una singola serie dal salto dell'intero esercizio. Dipendenza
funzionale da EVO-009 per il diario.

### EVO-013 — Monitoraggio camminate, passi e obiettivi

- **Stato:** Da sviluppare
- **Priorità:** Media
- **Data di registrazione:** 22 novembre 2026

**Descrizione funzionale**

Estendere il monitoraggio delle camminate con conteggio dei passi tramite
sensori, statistiche più complete e obiettivi personalizzati.

**Comportamento attuale**

Sono già disponibili sessioni di camminata, storico e metriche. La richiesta
aggiunge il rilevamento tramite sensori e il monitoraggio degli obiettivi;
prima dello sviluppo verificare la provenienza dei dati già registrabili.

**Comportamento desiderato**

- Conteggio dei passi tramite sensori del telefono, quando disponibili.
- Durata della camminata e distanza percorsa.
- Storico dei passi giornalieri e statistiche settimanali.
- Obiettivi personalizzati di passi, minuti e frequenza.
- Monitoraggio dei progressi rispetto agli obiettivi.
- Integrazione con la dashboard EVO-010.

**Criteri di accettazione**

- [ ] Il conteggio usa i sensori disponibili e gestisce correttamente la loro assenza.
- [ ] Permessi Android e comportamento in background sono verificati sul dispositivo.
- [ ] Storico giornaliero e statistiche settimanali mantengono dati coerenti.
- [ ] Gli obiettivi personalizzati sono persistenti e confrontabili con i risultati.
- [ ] La dashboard EVO-010 può utilizzare i dati senza duplicazioni.

**Note tecniche e dipendenze**

Verificare sensori, permessi, ciclo di vita Android e comportamento in background.
Definire nella specifica la provenienza di passi e distanza e il rapporto con
gli eventuali dati manuali. Coordinamento con EVO-010.

### EVO-015 — Temi Ambra sportiva e Blu elettrico

- **Stato:** In collaudo
- **Priorità:** Alta
- **Autorizzazione:** restyling UX/UI approvato dall'utente il 22/11/2026.
- Tema chiaro Ambra sportiva e tema scuro Blu elettrico, con token semantici,
  varianti di contrasto e scelta Chiaro/Scuro/Sistema persistita.
- Criteri: contrasto dei testi, stato indicato anche da testo/icona,
  compatibilità con preferenze e backup, controlli a 48 dp, testo ingrandito,
  verifica visiva Android di entrambi i temi.
- Specifica e risultati: `Docs/UX_UI_Restyling.md`.
- Verifiche automatiche: 1176 test completi superati, analisi statica pulita;
  verifica visiva Android dei temi effettuata. Restano riscontro dell'utente,
  telefono reale e percorso TalkBack completo. Nessun commit/push.

## 3. Anomalie da correggere

### BUG-001 — Mancato aggiornamento del peso nella Home

- **Priorità:** Alta
- **Stato:** In collaudo
- **Data di segnalazione:** 22/11/2026
- **Conferma:** caso riscontrato dall'utente durante il collaudo.
- **Stato della correzione:** implementata il 22/11/2026; 94 test mirati
  superati, collaudo Android ancora da effettuare. Esiti statici riportati sotto.
- **Versione app e dispositivo:** non specificati nella segnalazione.

**Passaggi per riprodurre il problema segnalato**

1. Usare un profilo con peso iniziale di 150,5 kg.
2. Registrare nella pagina Progressi una nuova misurazione di 150,4 kg.
3. Tornare alla Home e controllare peso e variazione.

**Comportamento attuale riscontrato**

La Home continua a mostrare il peso precedente: 151,0 kg, con variazione
+0,5 kg invece di −0,1 kg rispetto al peso iniziale di 150,5 kg.

**Comportamento atteso e criteri di accettazione**

- [ ] La Home mostra immediatamente l'ultimo peso registrato: nel caso segnalato 150,4 kg.
- [ ] La variazione viene ricalcolata correttamente: nel caso segnalato −0,1 kg.
- [ ] BMI, BMR e TDEE si aggiornano coerentemente con la misurazione pertinente.
- [ ] Inserimento, modifica ed eliminazione di una misurazione sincronizzano le schermate.
- [ ] Riavvio dell'app e ripristino del backup mantengono peso e indicatori coerenti.

**Note tecniche e dipendenze**

La regressione UI ha riprodotto il difetto prima della correzione: la nuova
misurazione veniva salvata ma la Home rimaneva al valore precedente.
`latestWeightProvider` era un FutureProvider che leggeva una sola volta e non
dipendeva dagli aggiornamenti delle misurazioni. Ora peso e girovita più recenti
sono derivati dall'AsyncValue dello stream `bodyMeasurementsProvider`, già
utilizzato da Progressi, senza query aggiuntive o invalidazioni manuali.
Restano invariati ordinamento `measuredAt DESC, id DESC`, separazione per profilo,
filtro dei valori nulli, formule di BMI/BMR/TDEE e schema del database.

File applicativo: `lib/features/weight/application/weight_providers.dart`.
Regressioni: `test/features/dashboard_weight_sync_test.dart`.
Collegamento a EVO-010 per la coerenza degli indicatori. Il bug non verrà
spostato nello storico fino al superamento delle verifiche e del collaudo Android.

**Verifiche automatiche del 22/11/2026**

- 94 test mirati superati, 0 falliti: Home, Progressi, Profilo, repository
  misurazioni, formule corporee, riepiloghi e ripristino backup.
- `flutter analyze`: nessun problema; `git diff --check`: superato.
- Suite completa non rieseguita; nessun commit o push.
- Le quattro nuove regressioni verificano CRUD da Progressi con Home già aperta;
  ordinamento per data e ID, misure di solo girovita e assenza di pesi;
  ricreazione dell'interfaccia sullo stesso database; importazione JSON reale
  con aggiornamento della Home già montata.
- Il test di importazione isola il file picker e la riconciliazione nativa delle
  notifiche; esportazione, validazione, transazione SQLite e provider sono reali.
- Collaudo Android ancora richiesto per il flusso utente e il riavvio del processo.
  Le caselle di accettazione restano aperte fino alla verifica dell'utente.

Assegnare alle nuove anomalie un identificativo stabile dal successivo `BUG-002`,
ecc. Per ciascuna registrare:

- Identificativo e titolo.
- Data di segnalazione, versione dell'app e ambiente interessato.
- Passaggi riproducibili e relativi prerequisiti.
- Comportamento attuale e comportamento atteso.
- Priorità e stato della correzione, usando gli stati consentiti.
- Evidenze, note tecniche e collegamenti alle richieste correlate.
- Verifiche richieste e risultati prima della chiusura.

Non usare un identificativo BUG per duplicare una richiesta EVO: collegare le
voci quando esistono aspetti distinti da seguire separatamente.

## 4. Idee da valutare

Nessuna proposta aggiuntiva registrata. Questa sezione raccoglie idee non
ancora approvate per lo sviluppo, sempre nello stato **Da valutare**.

Per ogni proposta indicare titolo, beneficio atteso, descrizione, questioni
aperte e riferimento a un'eventuale richiesta esistente. Quando un'idea diventa
una richiesta formalizzata, assegnare un EVO e conservare il collegamento
all'idea originaria, evitando due attività equivalenti.

## 5. Storico delle evolutive completate

Nessuna delle evolutive di questo registro è stata completata. Le funzionalità
precedenti all'istituzione del registro restano documentate nei rispettivi report;
non vengono dichiarate nuovamente completate né ricevono identificativi retroattivi.

Quando una richiesta supera le verifiche, spostare qui l'intera voce, mantenendo
identificativo e contenuto, e aggiungere:

| Campo | Contenuto richiesto |
|---|---|
| Identificativo | EVO o BUG originario, senza rinumerazione |
| Titolo | Titolo della richiesta |
| Stato | Completata |
| Data di completamento | Data effettiva di conclusione delle verifiche richieste |
| Soluzione | Descrizione del comportamento implementato |
| Test effettuati | Test automatici, risultati e collaudo Android pertinente |
| Commit Git | Hash, se disponibile; altrimenti «Non effettuato» |
| Note residue | Eventuali limiti e collegamenti ad altre richieste |

## 6. Regole di gestione

- Non considerare automaticamente approvate le nuove idee.
- Non implementare una richiesta soltanto perché è presente nel registro.
- Aggiornare lo stato all'inizio di sviluppo, test e collaudo.
- Non dichiarare Completata una funzionalità senza le verifiche necessarie.
- Non cancellare le richieste completate: spostarle nello storico.
- Mantenere stabili gli identificativi e non riutilizzarli per altre richieste.
- Assegnare il successivo numero libero nel relativo prefisso, considerando
  anche le voci nello storico e quelle sospese.
- Cercare richieste equivalenti prima di registrarne una nuova; integrare o
  collegare la voce esistente per evitare duplicazioni.
- Registrare decisioni, dipendenze, risultati dei test ed eventuali commit reali.
- Una sospensione deve riportare motivo e condizioni necessarie alla ripresa.
- Affrontare le evolutive singolarmente o in gruppi strettamente collegati.
- Preparare le specifiche tecniche dettagliate soltanto prima dell'implementazione.
- Riutilizzare l'architettura e i componenti esistenti; non riscrivere parti
  funzionanti senza necessità.
- Preservare la compatibilità con il database locale e con i backup.
- Eseguire test mirati durante lo sviluppo e la suite completa prima dei
  rilasci significativi.
- Aggiornare la documentazione al completamento di ogni attività.
- Non eseguire commit o push senza autorizzazione.
- Conservare anche le richieste escluse e non riutilizzarne gli identificativi.

## 7. Stati consentiti

| Stato | Significato |
|---|---|
| Da valutare | Proposta da chiarire o da approvare per lo sviluppo |
| Da sviluppare | Richiesta formalizzata, in attesa di un incarico di implementazione |
| Da correggere | Anomalia confermata, correzione non ancora avviata |
| In sviluppo | Implementazione avviata |
| In test | Verifiche tecniche e test automatici in corso |
| In collaudo | Verifica funzionale dell'utente su Android in corso |
| Completata | Criteri di accettazione e verifiche richieste superati |
| Sospesa | Lavoro sospeso con motivo documentato |
| Esclusa | Richiesta esclusa dal piano attivo per decisione dell'utente; ID riservato |

Gli stati Da correggere ed Esclusa sono introdotti con l'aggiornamento del
22/11/2026 per rappresentare le decisioni esplicite dell'utente. Il carattere
trasversale di EVO-006 è un attributo della richiesta, non uno stato aggiuntivo.

## 8. Evolutive escluse dal piano attivo

Le seguenti evolutive sono state valutate e successivamente escluse per
decisione dell'utente. Non devono entrare nel piano di sviluppo attivo.

| ID | Evolutiva | Stato |
|---|---|---|
| EVO-007 | Riprogrammazione intelligente | Esclusa |
| EVO-008 | Sostituzione esercizi | Esclusa |
| EVO-011 | Adattamento dell'allenamento alla giornata | Esclusa |
| EVO-014 | Backup automatici locali | Esclusa |

Gli identificativi restano riservati e non possono essere riutilizzati.
Il successivo identificativo EVO disponibile è **EVO-016**.

## 9. Ordine di sviluppo proposto

| Fase | Ambito | Ordine indicativo |
|---|---|---|
| 1 | Correzioni e gestione dati | BUG-001 → EVO-001 → EVO-002 |
| 2 | Pianificazione settimanale | EVO-004 → EVO-005 → EVO-006 |
| 3 | Monitoraggio e progressi | EVO-013 → EVO-010 → EVO-009 |
| 4 | Esperienza di allenamento e notifiche | EVO-012 → EVO-003 |

L'ordine è indicativo e può cambiare in base alle priorità del collaudo.
EVO-006 deve essere applicata anche durante le attività collegate, essendo
un requisito trasversale. Questa pianificazione non costituisce un incarico
di implementazione.

## 10. Riepilogo al 22/11/2026

- **11 evolutive approvate:** EVO-001, EVO-002, EVO-003, EVO-004, EVO-005,
  EVO-006, EVO-009, EVO-010, EVO-012, EVO-013, EVO-015.
- **1 bug confermato dall'utente:** BUG-001, correzione in collaudo.
- **4 evolutive escluse:** EVO-007, EVO-008, EVO-011, EVO-014.
- **EVO-001–006, EVO-009 e EVO-010 in collaudo**, su incarico esplicito;
  EVO-012/013 non avviate. Collaudo Android complessivo rinviato dall'utente.

Verifiche dell'implementazione del 22/11/2026: **1154 test della suite completa
superati, 0 falliti**, `flutter analyze` senza problemi, `git diff --check`
superato. Questi risultati si riferiscono alla baseline schema 13.
La successiva correzione richiesta nel collaudo integra la camminata nella scheda,
con scelta prima/dopo, giorni condivisi e pulsante Home «Pianifica allenamento».
Schema corrente 14, catalogo 2; 50 test mirati superati per questa correzione.
La nuova verifica Android resta da eseguire.
Verifica tecnica finale su schema 14: **1166 test completi superati, 0 falliti**,
analisi statica senza problemi e diff check superato.
Il report con specifica, file principali e checklist Android è
`Docs/EVOLUTIVE_001_010.md`. Nessuna richiesta viene ancora spostata nello
storico delle completate. Commit e push non effettuati.

Il registro rappresenta le attività future concordate, non funzionalità già
sviluppate. Le capacità già presenti sono annotate come basi da riutilizzare
e non comportano la chiusura automatica delle richieste.
