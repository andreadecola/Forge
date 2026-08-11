import '../entities/persist_generated_workout_error.dart';
import '../entities/persist_generated_workout_request.dart';
import '../entities/persist_generated_workout_result.dart';
import '../entities/workout.dart';
import '../entities/workout_details.dart';
import '../entities/workout_enums.dart';
import '../entities/workout_exercise.dart';
import '../entities/workout_exercise_details.dart';
import '../repositories/workout_repository.dart';
import '../services/clock.dart';
import '../services/forge_workout_naming_policy.dart';
import '../services/generated_workout_plan_validator.dart';
import '../services/workout_validation_service.dart';

/// Persiste un `GeneratedWorkoutPlan` (Milestone 5.2) come vera scheda
/// allenamento (Milestone 5.3). Separa nettamente la **decisione** del
/// motore (già presa, arriva dentro [PersistGeneratedWorkoutRequest.generationResult])
/// dalla sua **persistenza**: questo use case non ricalcola né rivaluta
/// nulla del motore, decide solo se e come scrivere il risultato.
///
/// Mai una scrittura parziale (sezione 9): ogni controllo avviene prima
/// di toccare il database; l'unica scrittura effettiva
/// (`WorkoutRepository.createWorkoutWithExercises`) è atomica.
class PersistGeneratedWorkout {
  const PersistGeneratedWorkout(
    this._repository, {
    this.planValidator = const GeneratedWorkoutPlanValidator(),
    this.workoutValidationService = const WorkoutValidationService(),
    this.clock = const SystemClock(),
  });

  final WorkoutRepository _repository;
  final GeneratedWorkoutPlanValidator planValidator;
  final WorkoutValidationService workoutValidationService;
  final Clock clock;

  Future<PersistGeneratedWorkoutResult> call(
    PersistGeneratedWorkoutRequest request,
  ) async {
    final generationResult = request.generationResult;

    if (!generationResult.success) {
      return PersistGeneratedWorkoutResult(
        errors: const [PersistGeneratedWorkoutError.generationFailed],
        warnings: generationResult.warnings,
      );
    }

    final plan = generationResult.plan;
    if (plan == null) {
      return PersistGeneratedWorkoutResult(
        errors: const [PersistGeneratedWorkoutError.missingPlan],
        warnings: generationResult.warnings,
      );
    }

    if (!plan.isComplete) {
      // Scelta più sicura per questa milestone (sezione 27): mai salvare
      // automaticamente un piano incompleto, nemmeno come bozza. Una
      // futura UI potrà offrire esplicitamente "salva comunque come
      // bozza".
      return PersistGeneratedWorkoutResult(
        errors: const [PersistGeneratedWorkoutError.incompletePlan],
        warnings: generationResult.warnings,
      );
    }

    final planValidation = planValidator.validate(plan);
    if (!planValidation.isValid) {
      return PersistGeneratedWorkoutResult(
        errors: const [PersistGeneratedWorkoutError.invalidGeneratedPlan],
        warnings: generationResult.warnings,
      );
    }

    final now = clock.now();
    final workout = Workout(
      profileId: request.profileId,
      name:
          request.name ??
          ForgeWorkoutNamingPolicy.defaultNameFor(plan.workoutType),
      description: request.description,
      type: plan.workoutType,
      // Livello dal request originale del motore (sezione 11): mai un
      // livello diverso inventato qui.
      level: plan.request.userLevel,
      // Arrotondamento per eccesso (sezione 12): un piano di 8m30s conta
      // come 9 minuti stimati, mai troncato a 8 (sottostimerebbe il tempo
      // reale servito all'utente).
      estimatedDurationMinutes: (plan.estimatedDurationSeconds / 60).ceil(),
      status: WorkoutDefinitionStatus.ready,
      origin: WorkoutOrigin.forgeEngine,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final exercises = <WorkoutExercise>[
      for (final entry in plan.exercises)
        entry.workoutExercise.copyWith(createdAt: now, updatedAt: now),
    ];

    final details = WorkoutDetails(
      workout: workout,
      exercises: [
        for (final entry in plan.exercises)
          WorkoutExerciseDetails(
            workoutExercise: entry.workoutExercise,
            exercise: entry.exercise,
          ),
      ],
    );
    final workoutValidation = workoutValidationService.validateReady(details);
    if (!workoutValidation.isValid) {
      return PersistGeneratedWorkoutResult(
        errors: const [PersistGeneratedWorkoutError.invalidWorkout],
        warnings: generationResult.warnings,
      );
    }

    try {
      final workoutId = await _repository.createWorkoutWithExercises(
        workout: workout,
        exercises: exercises,
      );
      return PersistGeneratedWorkoutResult(
        workoutId: workoutId,
        errors: const [],
        warnings: generationResult.warnings,
      );
    } on Object {
      return PersistGeneratedWorkoutResult(
        errors: const [PersistGeneratedWorkoutError.persistenceFailed],
        warnings: generationResult.warnings,
      );
    }
  }
}
