import '../entities/exercise.dart';
import '../entities/forge_engine_config.dart';

/// Stima il costo temporale di un esercizio isolato (Milestone 5.1,
/// sezione 17), usando solo `sets`/`reps`/`durationSeconds`/`restSeconds`
/// del catalogo e le costanti esplicite di [ForgeEngineConfig] — mai un
/// dato inventato in una formula sparsa.
abstract final class ExerciseDurationEstimator {
  /// `null` se l'esercizio non ha né ripetizioni né durata (sezione 22):
  /// il tempo non è stimabile correttamente, e non viene inventato.
  /// [ForgeEligibilityService] esclude questi esercizi con
  /// `unsupportedParameters`.
  static int? estimateSeconds({
    required Exercise exercise,
    required ForgeEngineConfig config,
  }) {
    return estimateSecondsForParameters(
      sets: exercise.defaultSets,
      repetitions: exercise.defaultReps,
      durationSeconds: exercise.defaultDurationSeconds,
      restSeconds: exercise.defaultRestSeconds,
      config: config,
    );
  }

  /// Stessa identica formula di [estimateSeconds], applicabile a
  /// parametri espliciti invece che ai default del catalogo (Milestone
  /// 5.4: stima la durata di un esercizio con parametri adattati —
  /// serie/ripetizioni/durata/recupero non necessariamente uguali ai
  /// default). Estratta qui perché la formula deve restare **unica**: una
  /// seconda implementazione nella policy di adattamento sarebbe la stessa
  /// "seconda interpretazione" già evitata altrove (STOP 3, Milestone
  /// 5.1) — solo applicata a un dato diverso, non a una regola diversa.
  static int? estimateSecondsForParameters({
    required int? sets,
    required int? repetitions,
    required int? durationSeconds,
    required int? restSeconds,
    required ForgeEngineConfig config,
  }) {
    // sets == null -> 1 sola serie, solo per questa stima (sezione 21):
    // stessa regola già stabilita per la sessione runtime (Milestone
    // 4.4.2) — non scrive né modifica mai il catalogo.
    final effectiveSets = sets ?? 1;

    final secondsPerSet = _secondsPerSet(
      durationSeconds: durationSeconds,
      repetitions: repetitions,
      config: config,
    );
    if (secondsPerSet == null) return null;

    // N serie -> N - 1 recuperi (sezione 20): nessun recupero dopo
    // l'ultima serie nella stima del singolo esercizio.
    final restBetweenSets = restSeconds ?? 0;
    final rest = effectiveSets > 1 ? restBetweenSets * (effectiveSets - 1) : 0;

    return secondsPerSet * effectiveSets + rest;
  }

  /// `durationSeconds` prevale su `repetitions` se entrambi presenti
  /// (sezione 18/62), stessa regola della sessione runtime (Milestone
  /// 4.4.2, sezione 19 di quella milestone).
  static int? _secondsPerSet({
    required int? durationSeconds,
    required int? repetitions,
    required ForgeEngineConfig config,
  }) {
    if (durationSeconds != null) return durationSeconds;
    if (repetitions != null) {
      return repetitions * config.estimatedSecondsPerRepetition;
    }
    return null;
  }
}
