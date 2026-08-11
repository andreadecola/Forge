import '../entities/forge_exercise_evaluation.dart';
import '../entities/workout_enums.dart';

/// Ordine di esecuzione degli esercizi selezionati per un piano (Milestone
/// 5.2, sezione 39-42).
///
/// Un rango di categorie per `WorkoutType` — un ordinamento concettuale
/// (es. mobilità prima, cardio/stretching dopo), non una vera alternanza
/// treno superiore/inferiore: la spec la presenta come "esempio
/// concettuale" e avvisa esplicitamente di non costruire "una regola
/// enorme" per questo. Usa solo i codici di categoria reali già usati in
/// `ForgeWorkoutTypePolicy`.
///
/// Tie-break finale su `exercise.code` — stabile e deterministico, stesso
/// principio della Milestone 5.1.
abstract final class ForgeExerciseOrderingPolicy {
  static const Map<WorkoutType, List<String>> _categoryRank = {
    WorkoutType.fullBody: [
      'MOBILITA',
      'GAMBE_GLUTEI',
      'PETTO_SPINTA',
      'SCHIENA',
      'SPALLE',
      'BRACCIA',
      'CORE',
      'EQUILIBRIO',
      'CARDIO',
      'STRETCHING',
    ],
    WorkoutType.upperBody: [
      'MOBILITA',
      'PETTO_SPINTA',
      'SCHIENA',
      'SPALLE',
      'BRACCIA',
      'CORE',
      'EQUILIBRIO',
      'STRETCHING',
    ],
    WorkoutType.lowerBody: [
      'MOBILITA',
      'GAMBE_GLUTEI',
      'CORE',
      'EQUILIBRIO',
      'CARDIO',
      'STRETCHING',
    ],
    WorkoutType.mobility: ['MOBILITA', 'EQUILIBRIO', 'CORE', 'STRETCHING'],
    WorkoutType.cardio: ['MOBILITA', 'CARDIO', 'GAMBE_GLUTEI', 'EQUILIBRIO'],
    WorkoutType.recovery: ['MOBILITA', 'STRETCHING', 'EQUILIBRIO'],
  };

  /// Ordina [evaluations] per esecuzione: rango di categoria per
  /// [workoutType], poi `exercise.code` ASC come tie-break stabile. Una
  /// categoria non elencata nel rango (rete di sicurezza, nessuna
  /// categoria reale attuale ne è priva) va in coda.
  static List<ForgeExerciseEvaluation> order({
    required List<ForgeExerciseEvaluation> evaluations,
    required WorkoutType workoutType,
  }) {
    final rank = _categoryRank[workoutType];
    if (rank == null) {
      throw ArgumentError.value(
        workoutType,
        'workoutType',
        'Nessuna policy di ordinamento Forge per questo WorkoutType (CUSTOM '
            'non è generabile dal motore, sezione 32).',
      );
    }
    final sorted = List<ForgeExerciseEvaluation>.of(evaluations);
    sorted.sort((a, b) {
      final rankA = rank.indexOf(a.candidate.categoryCode);
      final rankB = rank.indexOf(b.candidate.categoryCode);
      final effectiveRankA = rankA == -1 ? rank.length : rankA;
      final effectiveRankB = rankB == -1 ? rank.length : rankB;
      final rankComparison = effectiveRankA.compareTo(effectiveRankB);
      if (rankComparison != 0) return rankComparison;
      return a.candidate.exercise.code.compareTo(b.candidate.exercise.code);
    });
    return sorted;
  }
}
