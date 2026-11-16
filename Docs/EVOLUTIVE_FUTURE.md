# Forge — Registro ufficiale delle evolutive future

Data di istituzione: **16 novembre 2026**.

## 1. Obiettivo del documento

Questo documento è il registro permanente e ufficiale delle evolutive, delle
anomalie e dei miglioramenti ancora da sviluppare in Forge. È il riferimento
per pianificazione, implementazione, test e collaudo delle richieste future.

La registrazione di una richiesta non autorizza automaticamente lo sviluppo.
Le attività descritte richiedono un incarico esplicito prima dell'implementazione.

## 2. Evolutive da realizzare

### EVO-001 — Eliminazione camminate dallo storico

- **Stato:** Da sviluppare
- **Priorità:** Media
- **Data di registrazione:** 16 novembre 2026

**Descrizione funzionale**

Consentire l'eliminazione di una singola camminata registrata, con conferma
esplicita e aggiornamento coerente dello storico e delle statistiche.

**Comportamento attuale**

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

- **Stato:** Da sviluppare
- **Priorità:** Media
- **Data di registrazione:** 16 novembre 2026

**Descrizione funzionale**

Rendere disponibile un percorso chiaro e sicuro per l'eliminazione definitiva
delle schede manuali e generate da Forge, mantenendolo distinto dall'archiviazione.

**Comportamento attuale**

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
La politica sullo storico e i punti UI da cui offrire Elimina vanno definiti
prima dell'implementazione.

## 3. Anomalie da correggere

Nessuna anomalia aggiuntiva registrata in questa prima versione. Ciò non
costituisce una dichiarazione di assenza di difetti nell'app.

Assegnare alle nuove anomalie un identificativo stabile `BUG-001`, `BUG-002`,
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

## 7. Stati consentiti

| Stato | Significato |
|---|---|
| Da valutare | Proposta da chiarire o da approvare per lo sviluppo |
| Da sviluppare | Richiesta formalizzata, in attesa di un incarico di implementazione |
| In sviluppo | Implementazione avviata |
| In test | Verifiche tecniche e test automatici in corso |
| In collaudo | Verifica funzionale dell'utente su Android in corso |
| Completata | Criteri di accettazione e verifiche richieste superati |
| Sospesa | Lavoro sospeso con motivo documentato |

La creazione di questo registro è esclusivamente documentale: EVO-001 ed
EVO-002 non vengono implementate con questa attività.
