import '../entities/generated_workout_plan.dart';
import '../entities/workout_validation_result.dart';
import 'workout_validation_service.dart';

/// Valida la forma strutturale di un [GeneratedWorkoutPlan] (Milestone
/// 5.3), **prima** della conversione in `Workout`/`WorkoutExercise`: solo
/// vincoli che riguardano il piano Forge in sé (ordine, duplicati), non
/// riconvalidati altrove. I vincoli per-esercizio (serie/ripetizioni/
/// durata/recupero) sono invece delegati a
/// [WorkoutValidationService.validateWorkoutExercise] — nessuna seconda
/// implementazione delle stesse regole.
class GeneratedWorkoutPlanValidator {
  const GeneratedWorkoutPlanValidator({
    this.workoutValidationService = const WorkoutValidationService(),
  });

  final WorkoutValidationService workoutValidationService;

  WorkoutValidationResult validate(GeneratedWorkoutPlan plan) {
    final errors = <String>[];

    if (plan.exercises.isEmpty) {
      errors.add('Il piano generato non contiene alcun esercizio.');
    }

    final orders = plan.exercises.map((e) => e.workoutExercise.order).toList();
    final expectedOrders = List.generate(orders.length, (i) => i + 1);
    if (!_sameSequence(orders, expectedOrders)) {
      errors.add(
        'L\'ordine degli esercizi del piano generato non è una sequenza '
        '1..N valida.',
      );
    }

    final exerciseIds = plan.exercises.map((e) => e.exercise.id).toList();
    if (exerciseIds.toSet().length != exerciseIds.length) {
      errors.add('Il piano generato contiene un esercizio duplicato.');
    }

    for (final entry in plan.exercises) {
      errors.addAll(
        workoutValidationService
            .validateWorkoutExercise(entry.workoutExercise)
            .errors,
      );
    }

    return WorkoutValidationResult(errors: errors);
  }

  bool _sameSequence(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
