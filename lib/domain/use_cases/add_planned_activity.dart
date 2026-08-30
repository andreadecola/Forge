import '../../core/validation/onboarding_validators.dart';
import '../entities/planned_activity.dart';
import '../entities/planned_activity_enums.dart';
import '../repositories/planned_activity_repository.dart';

/// Valida e crea una nuova attività pianificata (Milestone 8.1, sezione
/// 31): profilo valido, riferimento a `Workout` coerente col tipo —
/// obbligatorio per [PlannedActivityType.workout], vietato altrimenti.
/// Nessuna validazione temporale ("non nel passato"/"non nel futuro"): a
/// differenza di una misurazione (che registra un fatto già accaduto), una
/// pianificazione riguarda per natura un momento non ancora avvenuto, ma
/// nulla vieta di registrare retroattivamente "cosa era previsto".
class AddPlannedActivity {
  const AddPlannedActivity(this._repository);

  final PlannedActivityRepository _repository;

  Future<int> call(PlannedActivity activity) {
    final error = _validate(activity);
    if (error != null) throw ArgumentError(error);
    return _repository.addPlannedActivity(activity);
  }

  static String? _validate(PlannedActivity activity) {
    return OnboardingValidators.profileId(activity.profileId) ??
        _validateWorkoutReference(activity) ??
        _validateSessionReferences(activity);
  }

  static String? _validateWorkoutReference(PlannedActivity activity) {
    final requiresWorkout = activity.type == PlannedActivityType.workout;
    if (requiresWorkout && activity.workoutId == null) {
      return 'Indica la scheda da collegare all\'allenamento pianificato.';
    }
    if (!requiresWorkout && activity.workoutId != null) {
      return 'Solo un\'attività di tipo allenamento può referenziare una scheda.';
    }
    return null;
  }

  /// Type safety (Milestone 8.5, sezione 41): impedisce di collegare una
  /// sessione del tipo sbagliato (es. `WorkoutSession` a un'attività
  /// WALK/RECOVERY) — un nuovo controllo, stesso principio del vincolo
  /// sopra su [workoutId].
  static String? _validateSessionReferences(PlannedActivity activity) {
    if (activity.type != PlannedActivityType.workout &&
        activity.workoutSessionId != null) {
      return 'Solo un\'attività di tipo allenamento può referenziare una '
          'sessione di allenamento.';
    }
    if (activity.type != PlannedActivityType.walk &&
        activity.walkingSessionId != null) {
      return 'Solo un\'attività di tipo camminata può referenziare una '
          'sessione di camminata.';
    }
    return null;
  }
}
