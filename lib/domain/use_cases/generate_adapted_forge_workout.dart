import '../entities/exercise_alternative.dart';
import '../entities/exercise_progression.dart';
import '../entities/forge_adapted_generation_result.dart';
import '../entities/forge_generation_error.dart';
import '../entities/forge_request.dart';
import '../repositories/exercise_repository.dart';
import '../services/forge_workout_adaptation_service.dart';
import '../services/generated_workout_plan_validator.dart';
import 'build_forge_adaptation_context.dart';
import 'generate_forge_workout.dart';

/// Use case combinato (Milestone 5.4, sezione 44): compone
/// [BuildForgeAdaptationContext], [GenerateForgeWorkout] (Milestone 5.2,
/// invariato) e [ForgeWorkoutAdaptationService], poi rivalida il piano
/// finale (sezione 37). **Non persiste automaticamente** (sezione 44 —
/// nessuna chiamata a `PersistGeneratedWorkout` qui).
class GenerateAdaptedForgeWorkout {
  GenerateAdaptedForgeWorkout(
    this._exerciseRepository,
    this._buildContext,
    this._generate,
    this._adaptationService, {
    this.planValidator = const GeneratedWorkoutPlanValidator(),
  });

  final ExerciseRepository _exerciseRepository;
  final BuildForgeAdaptationContext _buildContext;
  final GenerateForgeWorkout _generate;
  final ForgeWorkoutAdaptationService _adaptationService;
  final GeneratedWorkoutPlanValidator planValidator;

  Future<ForgeAdaptedGenerationResult> call({
    required ForgeRequest request,
    required int profileId,
    required DateTime now,
  }) async {
    final generation = await _generate(request);
    final basePlan = generation.plan;
    if (!generation.success || basePlan == null) {
      // Stesso esito della Milestone 5.2 (richiesta non valida, nessun
      // eleggibile, copertura mancante): l'adattamento non introduce una
      // nuova categoria di fallimento a monte, la eredita.
      return ForgeAdaptedGenerationResult(
        errors: generation.errors,
        warnings: generation.warnings,
        evaluation: generation.evaluation,
      );
    }

    final context = await _buildContext(profileId: profileId, now: now);

    final progressionsByExerciseId = <int, List<ExerciseProgression>>{};
    final regressionsByExerciseId = <int, List<ExerciseProgression>>{};
    final alternativesByExerciseId = <int, List<ExerciseAlternative>>{};
    // Limite noto (come `EvaluateForgeRequest`, Milestone 5.1): una
    // chiamata per relazione per esercizio del piano — accettabile,
    // limitato alla dimensione del piano (pochi esercizi), non del
    // catalogo intero.
    for (final entry in basePlan.exercises) {
      final id = entry.exercise.id;
      progressionsByExerciseId[id] = await _exerciseRepository.getProgressions(
        id,
      );
      regressionsByExerciseId[id] = await _exerciseRepository.getRegressions(
        id,
      );
      alternativesByExerciseId[id] = await _exerciseRepository.getAlternatives(
        id,
      );
    }

    final adapted = _adaptationService.adapt(
      plan: basePlan,
      context: context,
      evaluation: generation.evaluation,
      progressionsByExerciseId: progressionsByExerciseId,
      regressionsByExerciseId: regressionsByExerciseId,
      alternativesByExerciseId: alternativesByExerciseId,
    );

    final validation = planValidator.validate(adapted.plan);
    if (!validation.isValid) {
      // Difesa (sezione 37): non dovrebbe accadere per costruzione, ogni
      // sostituzione applicata dal service ha già superato le guardie di
      // eleggibilità/duplicato/copertura/durata.
      return ForgeAdaptedGenerationResult(
        errors: const [ForgeGenerationError.cannotBuildExecutablePlan],
        warnings: generation.warnings,
        evaluation: generation.evaluation,
      );
    }

    return ForgeAdaptedGenerationResult(
      plan: adapted,
      errors: const [],
      warnings: adapted.plan.warnings,
      evaluation: generation.evaluation,
    );
  }
}
