# Allenamenti manuali — multilivello e immagini

## Stato reale

La creazione e modifica manuale usa `WorkoutMetadataForm`, condiviso tra
`CreateWorkoutPage` e `WorkoutEditPage`. Il selettore `MultiLevelChoiceChips`
consente uno o più livelli tra 1 e 5 e impedisce di rimuovere l'ultimo.

Il dominio mantiene `Workout.level` come rappresentante numerico massimo per
compatibilità con le API precedenti e `Workout.selectedLevels` per il set
completo. Il database salva il set come JSON ordinato in
`allenamenti.livelli`; il campo è nullable per le schede preesistenti, che
vengono lette come `{livello}`.

## Migrazione e compatibilità

La modifica richiede schema 12 perché lo schema precedente consentiva un solo
intero. La migrazione 11→12 aggiunge una sola colonna nullable e non ricrea né
cancella `allenamenti`, `allenamenti_esercizi`, sessioni, misurazioni o storico.
Le schede generate da Forge salvano lo stesso set selezionato nella richiesta;
le richieste legacy restano monolivello.

Il backup JSON conserva ora anche `selectedLevels`, oltre al campo legacy
`level` massimo. Il round-trip export/import mantiene il set completo.
Nei backup precedenti il campo assente o nullo usa `{level}`; valori corrotti
vengono rifiutati prima delle scritture. Dettagli e verifiche in
[HARDENING_Backup_And_Sessions.md](HARDENING_Backup_And_Sessions.md).

## Compatibilità esercizi

Nel picker manuale la disponibilità è ricalcolata rispetto a tutti i livelli
della scheda. Un esercizio è compatibile se rispetta `minimumLevel`/
`maximumLevel` per almeno un livello; attrezzatura e sicurezza restano vincoli
separati. Come nel comportamento manuale precedente, un esercizio bloccato
richiede conferma esplicita prima dell'aggiunta.

Il picker non consente di aggiungere due volte lo stesso `exerciseId` nella
stessa scheda. Il controllo è applicato sia alla UI sia al controller condiviso,
quindi vale anche per le schede generate da Forge quando vengono poi modificate
manualmente.

Il picker resta aperto dopo ogni aggiunta: ciascun esercizio viene configurato
singolarmente e salvato subito. Gli esercizi già presenti sono esclusi dalla
lista selezionabile, riletta dallo stato aggiornato dell'editor; il controllo
del controller verifica anche il database e impedisce aggiunte concorrenti.
Il pulsante fisso `Scheda completata` riporta all'editor senza cambiare lo stato
Bozza/Pronta della scheda. Tornando indietro le aggiunte già salvate restano
presenti. Dopo la rimozione dall'editor un esercizio torna selezionabile.
Le schede precedenti con duplicati non vengono modificate automaticamente.

## Immagini nel percorso manuale

Il picker, l'editor, il dettaglio scheda, lo storico e la sessione usano il
componente condiviso `ExerciseImageThumbnail` per la fotografia START. Il
dettaglio esercizio e la sessione attiva mantengono la gallery START/END. Le
schede persistono solo gli ID degli esercizi: dopo salvataggio, riapertura o
modifica gli asset vengono risolti nuovamente dal catalogo SQLite locale.

Il fallback viene mostrato esclusivamente quando il riferimento manca o
l'asset non è caricabile; non sono effettuate chiamate web.

## Avvio dalla scheda e dalla Home

Una scheda diventa avviabile solo quando è `PRONTA`, contiene almeno un
esercizio e ogni riga ha ripetizioni oppure `durationSeconds`. Il dettaglio
scheda e la Home usano lo stesso launcher applicativo e lo stesso
`WorkoutSessionController`; il tap esplicito crea la sessione, mentre il solo
salvataggio non la crea automaticamente.

La Home osserva `watchWorkoutsProvider`, filtra le sole schede `PRONTA` e
aggiorna automaticamente il menu quando una scheda viene creata, modificata,
archiviata o eliminata. Con una sola scheda questa è preselezionata; con più
schede l'utente può scegliere nome, tipo e livelli. Bozze e schede archiviate
non sono avviabili dalla sezione.

Se esiste già una sessione attiva, il launcher non la sostituisce: mantiene la
guardia del repository/controller e propone di raggiungere la sessione
corrente.

## Serie a tempo

`WorkoutExercise.durationSeconds` è persistito in `allenamenti_esercizi` e
viene mantenuto durante creazione, modifica, salvataggio e riapertura. Quando
è presente, prevale sulle ripetizioni anche se entrambi i campi fossero
valorizzati: la UI mostra `serie × N sec`, separando il `Recupero N sec`.
Durante la sessione il countdown usa lo stesso `durationSeconds`; il recupero
usa invece `restSeconds` e un timer distinto. Non sono stati aggiunti valori di
durata impliciti né migration per questa evolutiva.

## Verifiche mirate

Per il picker continuo sono passati 37 test mirati (editor, flusso Forge con
catalogo reale, catalogo esercizi), inclusi aggiunte consecutive con prescrizioni
distinte, esclusione degli esercizi già presenti, riapertura del picker,
rimozione e nuova selezionabilità, controllo del DB aggiornato e richieste
concorrenti. Il layout del picker è verificato a 360 px di larghezza; il badge
di disponibilità va a capo quando necessario. La nuova interazione resta da
collaudare sull'emulatore prima del commit.

Sono coperti il set singolo, due livelli, livelli non consecutivi, tutti i
livelli, il rifiuto della selezione vuota, salvataggio/riapertura/modifica,
retrocompatibilità delle righe legacy e migrazione 11→12. La verifica Android
del percorso completo resta da eseguire dall'utente prima del commit.
