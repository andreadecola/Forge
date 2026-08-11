import 'forge_score_component.dart';

/// Configurazione del Forge Engine (Milestone 5.1, sezione 23; estesa in
/// Milestone 5.2 con le costanti della composizione): centralizza le
/// costanti altrimenti sparse nel codice.
class ForgeEngineConfig {
  const ForgeEngineConfig({
    this.estimatedSecondsPerRepetition = 4,
    this.durationTolerance = 0.5,
    this.componentWeights = const {
      ForgeScoreComponentType.workoutTypeMatch: 0.4,
      ForgeScoreComponentType.levelFit: 0.2,
      ForgeScoreComponentType.equipmentSimplicity: 0.15,
      ForgeScoreComponentType.durationFit: 0.25,
    },
    this.transitionSecondsBetweenExercises = 10,
    this.planDurationTolerance = 0.15,
    this.minimumExercises = 3,
    this.maximumExercises = 8,
    this.maxExercisesPerCategory = 3,
    this.adaptationHistorySessions = 8,
    this.adaptationHistoryLookbackDays = 365,
    this.minimumSessionsForAdaptation = 3,
    this.progressCompletionRateThreshold = 0.8,
    this.progressSetCompletionRateThreshold = 0.85,
    this.simplifySetCompletionRateThreshold = 0.5,
    this.progressExerciseCompletionRateThreshold = 0.8,
    this.minimumExerciseOccurrencesForProgression = 2,
    this.repeatedSkipThreshold = 2,
    this.regressSetCompletionRateThreshold = 0.5,
    this.repsProgressionIncrement = 1,
    this.durationProgressionIncrementSeconds = 5,
    this.maxGeneratedSets = 4,
  });

  /// Secondi stimati per singola ripetizione (sezione 19): un esercizio a
  /// ripetizioni non ha una durata reale registrata, questa costante
  /// esplicita è l'unico punto in cui si "inventa" — dichiaratamente — un
  /// tempo per poterlo stimare, invece di farlo in una formula sparsa.
  final int estimatedSecondsPerRepetition;

  /// Frazione massima "comoda" della durata target dell'intera richiesta
  /// che un singolo esercizio **isolato** può occupare, usata dal
  /// componente `durationFit` della Milestone 5.1: oltre questa soglia il
  /// punteggio decresce verso 0. Non è la finestra di durata dell'intero
  /// piano (quella è [planDurationTolerance] — sezione 13 della Milestone
  /// 5.2: valore correlato ma distinto, non lo stesso campo, per non
  /// sovraccaricare di due significati diversi una costante già testata in
  /// Milestone 5.1).
  final double durationTolerance;

  /// Peso di ogni componente nel punteggio totale (sezione 34): la somma
  /// dei valori usati deve restare `1.0` perché `total` resti in
  /// `0.0..1.0` come ogni singolo componente.
  final Map<ForgeScoreComponentType, double> componentWeights;

  /// Tempo tecnico stimato tra un esercizio e il successivo (Milestone
  /// 5.2, sezione 24/40): per N esercizi nel piano, N-1 transizioni.
  /// Assente in Milestone 5.1 perché lì non esisteva ancora una sequenza
  /// di più esercizi da collegare.
  final int transitionSecondsBetweenExercises;

  /// Finestra accettabile di durata del **piano intero** attorno a
  /// `targetDurationMinutes`, come frazione (sezione 13): `0.15` significa
  /// ±15%. Usata da `ForgeWorkoutComposer` per decidere quando fermare la
  /// selezione ed eventualmente segnalare `durationBelowTarget`/
  /// `durationAboveTarget`.
  final double planDurationTolerance;

  /// Minimo di esercizi nel piano generato (sezione 15). Il composer usa
  /// in realtà `max(minimumExercises, numero di requisiti di copertura
  /// del WorkoutType)`: un FULL_BODY con 4 categorie da coprire richiede
  /// comunque almeno 4 esercizi, senza bisogno di una mappa separata
  /// "minimo per tipo" — la lista di copertura already lo esprime.
  final int minimumExercises;

  /// Massimo di esercizi nel piano generato (sezione 16), per evitare
  /// schede con troppi micro-esercizi.
  final int maximumExercises;

  /// Oltre questa soglia di esercizi già selezionati per la stessa
  /// categoria, il composer preferisce un'altra categoria pertinente se
  /// disponibile (sezione 26/27) — non un divieto assoluto: due esercizi
  /// GAMBE_GLUTEI restano validi, solo la concentrazione eccessiva è
  /// scoraggiata.
  final int maxExercisesPerCategory;

  // --- Milestone 5.4: adattamento deterministico da storico ---

  /// Numero di sessioni concluse più recenti considerate dall'analisi
  /// dello storico (sezione 7): un numero limitato, non l'intero storico —
  /// "NON analizzare indefinitamente tutto lo storico se non necessario".
  final int adaptationHistorySessions;

  /// Limite defensivo sulla query dello storico, in giorni prima di `now`
  /// (sezione 7): il meccanismo di finestra *primario* resta
  /// [adaptationHistorySessions] (numero di sessioni), questo è solo un
  /// argine contro una lettura effettivamente indefinita per un profilo
  /// con anni di storico — "NON analizzare indefinitamente tutto lo
  /// storico se non necessario".
  final int adaptationHistoryLookbackDays;

  /// Sotto questa soglia di sessioni concluse disponibili, la decisione è
  /// sempre `maintain` (sezione 8): storico insufficiente per qualunque
  /// progressione, per quanto l'evidenza disponibile sembri positiva.
  final int minimumSessionsForAdaptation;

  /// Completion rate delle sessioni (COMPLETED / totale) nella finestra
  /// recente, sopra la quale il contesto globale può proporre `progress`
  /// (sezione 12).
  final double progressCompletionRateThreshold;

  /// Rapporto serie completate/pianificate nella finestra recente, sopra
  /// il quale il contesto globale può proporre `progress` (sezione 12) —
  /// entrambe le soglie (sessioni e serie) devono essere superate.
  final double progressSetCompletionRateThreshold;

  /// Sotto questa soglia di rapporto serie completate/pianificate nella
  /// finestra recente, il contesto globale propende per `simplify`
  /// (sezione 11) — zona intermedia altrimenti `maintain` (sezione 11,
  /// "zona intermedia -> MAINTAIN").
  final double simplifySetCompletionRateThreshold;

  /// Completion rate del **singolo esercizio** (completato/pianificato),
  /// gate per la progressione sia di parametro sia di esercizio (sezione
  /// 21/27/28) — distinta dalla soglia globale perché un esercizio può
  /// avere un'evidenza diversa dal resto della scheda.
  final double progressExerciseCompletionRateThreshold;

  /// Numero minimo di volte in cui un esercizio deve essere stato
  /// completato prima che sia considerata qualunque progressione (di
  /// parametro o di esercizio) su di esso (sezione 21: "eseguito
  /// sufficientemente") — un singolo completamento non è evidenza.
  final int minimumExerciseOccurrencesForProgression;

  /// Numero minimo di skip dello stesso esercizio prima che sia un segnale
  /// sufficiente per regressione/sostituzione (sezione 22: "Non usare un
  /// singolo skip").
  final int repeatedSkipThreshold;

  /// Sotto questa soglia di rapporto serie completate/pianificate **del
  /// singolo esercizio**, è un segnale sufficiente per regressione/
  /// sostituzione (sezione 22), alternativo al conteggio skip.
  final double regressSetCompletionRateThreshold;

  /// Incremento ripetizioni per una progressione di parametro (sezione
  /// 27): un numero esplicito in config, mai un magic number sparso.
  final int repsProgressionIncrement;

  /// Incremento secondi per una progressione di parametro su esercizi a
  /// tempo (sezione 28): un numero esplicito in config.
  final int durationProgressionIncrementSeconds;

  /// Tetto assoluto di serie generabili da una progressione di parametro
  /// (sezione 29): l'aumento delle serie è il più conservativo dei tre
  /// (dopo ripetizioni/durata, sezione 26), e non deve mai superare questo
  /// valore.
  final int maxGeneratedSets;
}
