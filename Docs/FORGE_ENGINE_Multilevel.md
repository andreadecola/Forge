# Forge Engine — generazione multilivello

## Stato corrente

Forge supporta la selezione di uno o più livelli tra 1 e 5 nella generazione
singola e nel generatore del Piano Settimanale. Il valore iniziale resta il
livello 1, come nella UI precedente. `UserProfile.activityLevel` non viene
usato per dedurre il livello Forge: quel campo serve alla stima TDEE.

## Semantica effettiva del livello

Prima di questa evoluzione, `ForgeRequest.userLevel` rappresentava il livello
di capacità scelto per la richiesta. La policy hard applicata dal motore era:

- `exercise.minimumLevel <= userLevel`;
- se presente, `userLevel <= exercise.maximumLevel`;
- esercizio attivo;
- attrezzatura obbligatoria posseduta;
- parametri sufficienti per stimare la durata.

Il livello non era una preferenza grafica: influenzava eleggibilità, punteggio
di vicinanza al livello, progressioni/regressioni e il livello numerico della
scheda persistita.

## Regola multilivello

`ForgeRequest.selectedLevels` è un set opzionale per compatibilità con i
chiamanti precedenti. Se è `null`, il motore usa `{userLevel}` e il risultato
resta quello precedente.

Con un set esplicito, un esercizio entra nel pool se è compatibile con almeno
uno dei livelli selezionati. La verifica di ogni livello usa la stessa policy
hard minima/massima precedente: un livello superiore selezionato non può
rendere compatibile un esercizio oltre il suo `maximumLevel`. Non viene
forzata alcuna presenza per livello e il composer non aumenta il numero di
esercizi, la durata, il volume o l'intensità per il solo fatto che il set è
più ampio.

Lo scoring usa il livello compatibile più basso per il quale l'esercizio è
valido. In questo modo un esercizio già adatto a un livello basso non riceve
un bonus artificiale solo perché è stato selezionato anche un livello alto.
Attrezzatura, stato attivo, sicurezza catalogo e adattamento basato sullo
storico restano invariati. Le progressioni e regressioni continuano a poter
usare soltanto target già risultati eleggibili per la stessa richiesta.

La normalizzazione ordina il set e usa il massimo selezionato come
rappresentante `userLevel` del piano. Questo valore serve a mantenere la
compatibilità con il modello DB delle schede, che conserva un solo livello;
non sostituisce il controllo del set e non bypassa `minimumLevel`/
`maximumLevel`.

Un set vuoto è rifiutato dal validator. La UI impedisce di rimuovere l'ultimo
livello.

## Flusso e persistenza

Il percorso è:

`ChoiceChip multipli` → `ForgeGeneratorState.selectedLevels` →
`ForgeRequest.selectedLevels` → normalizer → eligibility/scoring →
composer/adaptation → anteprima → persistenza.

L'anteprima mostra tutti i livelli selezionati. Il salvataggio continua a
creare una normale scheda `Workout` con il rappresentante numerico massimo.
La migrazione schema 11→12 aggiunge solo la colonna nullable
`allenamenti.livelli`; le schede precedenti ricadono automaticamente su
`{livello}` e non perdono dati. `catalogVersion = 2` resta invariato. Le
richieste legacy che valorizzano solo `userLevel` continuano a funzionare.

Il salvataggio di una richiesta multilivello conserva il set completo nella
scheda `Workout`, mentre `level` resta il rappresentante numerico massimo per
la compatibilità con le API precedenti.

## Verifiche

Sono coperti da test mirati: livello singolo e compatibilità retroattiva, due
livelli, livelli non consecutivi, tutti i cinque livelli, set vuoto,
determinismo indipendente dall'ordine del set e rispetto di `maximumLevel`.
La verifica Android della UI multilivello resta da eseguire dall'utente.
