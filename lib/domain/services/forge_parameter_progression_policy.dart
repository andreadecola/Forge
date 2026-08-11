import '../entities/forge_engine_config.dart';
import '../entities/forge_exercise_history.dart';
import '../entities/workout_exercise.dart';
import 'exercise_duration_estimator.dart';

/// Una candidata proposta di [ForgeParameterProgressionPolicy.propose]: la
/// guardia di durata sull'intero piano vive in
/// `ForgeWorkoutAdaptationService` (sezione 38), non qui — questa policy
/// non conosce il resto del piano.
typedef ForgeParameterProposal = ({
  WorkoutExercise workoutExercise,
  int estimatedDurationSeconds,
});

/// Propone aumenti **conservativi** di un solo parametro per volta
/// (Milestone 5.4, sezione 25): mai il recupero (sezione 30 — "NON
/// ridurre automaticamente il recupero... mantenere default/rest del
/// piano").
///
/// Restituisce una lista **ordinata per preferenza** (sezione 26 — "prima
/// piccolo aumento di reps/duration, poi eventualmente: sets"), non un
/// singolo risultato: la prima candidata è l'aumento di ripetizioni/
/// durata (coerente con `ExerciseDurationEstimator`, "durata prevale su
/// ripetizioni"); le serie sono un **secondo tentativo di riserva**, mai
/// combinato con il primo nella stessa proposta (un solo parametro alla
/// volta, sempre). Il chiamante (`ForgeWorkoutAdaptationService`) prova le
/// candidate in ordine e applica la prima che rispetta la finestra di
/// durata del piano — se la prima sfora la tolleranza, la seconda offre
/// un adattamento più piccolo invece di rinunciare del tutto.
class ForgeParameterProgressionPolicy {
  const ForgeParameterProgressionPolicy();

  /// Lista vuota se lo storico non è sufficiente (sezione 21): nessuna
  /// progressione applicabile questa generazione, qualunque parametro.
  List<ForgeParameterProposal> propose({
    required WorkoutExercise current,
    required ForgeExerciseHistory? history,
    required ForgeEngineConfig config,
  }) {
    if (!_hasSufficientEvidence(history, config)) return const [];

    final proposals = <ForgeParameterProposal>[];

    if (current.durationSeconds != null) {
      final proposed = current.copyWith(
        durationSeconds: () =>
            current.durationSeconds! +
            config.durationProgressionIncrementSeconds,
      );
      final estimate = _estimate(proposed, config);
      if (estimate != null) proposals.add(estimate);
    } else if (current.repetitions != null) {
      final proposed = current.copyWith(
        repetitions: () =>
            current.repetitions! + config.repsProgressionIncrement,
      );
      final estimate = _estimate(proposed, config);
      if (estimate != null) proposals.add(estimate);
    }

    // Sezione 29: l'aumento di serie è il più conservativo dei tre, e
    // resta un'opzione di riserva indipendentemente dal tipo
    // dell'esercizio — anche uno a ripetizioni/durata può ricevere questa
    // seconda candidata, mai applicata insieme alla prima nella stessa
    // generazione (il chiamante ne applica al massimo una).
    final currentSets = current.sets ?? 1;
    if (currentSets < config.maxGeneratedSets) {
      final proposed = current.copyWith(sets: () => currentSets + 1);
      final estimate = _estimate(proposed, config);
      if (estimate != null) proposals.add(estimate);
    }

    return proposals;
  }

  bool _hasSufficientEvidence(
    ForgeExerciseHistory? history,
    ForgeEngineConfig config,
  ) {
    if (history == null) return false;
    if (history.timesCompleted <
        config.minimumExerciseOccurrencesForProgression) {
      return false;
    }
    final rate = history.completionRate;
    return rate != null &&
        rate >= config.progressExerciseCompletionRateThreshold;
  }

  ForgeParameterProposal? _estimate(
    WorkoutExercise proposed,
    ForgeEngineConfig config,
  ) {
    final duration = ExerciseDurationEstimator.estimateSecondsForParameters(
      sets: proposed.sets,
      repetitions: proposed.repetitions,
      durationSeconds: proposed.durationSeconds,
      restSeconds: proposed.restSeconds,
      config: config,
    );
    // Un esercizio senza né ripetizioni né durata non è mai stimabile
    // (stessa regola di `ExerciseDurationEstimator`/M5.1
    // `unsupportedParameters`) — non dovrebbe mai arrivare qui, essendo
    // già escluso a monte dall'eligibility, ma la difesa resta esplicita,
    // mai un'eccezione silenziosa.
    if (duration == null) return null;
    return (workoutExercise: proposed, estimatedDurationSeconds: duration);
  }
}
