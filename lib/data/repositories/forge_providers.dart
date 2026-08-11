import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/forge_engine_config.dart';
import '../../domain/services/clock.dart';
import '../../domain/services/forge_engine.dart';
import '../../domain/services/forge_exercise_adaptation_policy.dart';
import '../../domain/services/forge_exercise_parameter_policy.dart';
import '../../domain/services/forge_parameter_progression_policy.dart';
import '../../domain/services/forge_workout_adaptation_service.dart';
import '../../domain/services/forge_workout_composer.dart';
import '../../domain/services/forge_workout_generator.dart';
import '../../domain/services/generated_workout_plan_validator.dart';
import '../../domain/use_cases/build_forge_adaptation_context.dart';
import '../../domain/use_cases/evaluate_forge_request.dart';
import '../../domain/use_cases/generate_adapted_forge_workout.dart';
import '../../domain/use_cases/generate_and_persist_adapted_forge_workout.dart';
import '../../domain/use_cases/generate_and_persist_forge_workout.dart';
import '../../domain/use_cases/generate_forge_workout.dart';
import '../../domain/use_cases/persist_generated_workout.dart';
import 'catalog_providers.dart';
import 'workout_providers.dart';
import 'workout_session_providers.dart';

/// Provider per il Forge Engine (Milestone 5.1, sezione 52): nessun
/// provider UI qui — solo motore/config/use case, riutilizzabili da una
/// futura interfaccia (non in questa milestone, sezione 74).
final forgeEngineConfigProvider = Provider<ForgeEngineConfig>(
  (ref) => const ForgeEngineConfig(),
);

final forgeEngineProvider = Provider<ForgeEngine>((ref) {
  return ForgeEngine(config: ref.watch(forgeEngineConfigProvider));
});

final evaluateForgeRequestProvider = Provider<EvaluateForgeRequest>((ref) {
  return EvaluateForgeRequest(
    ref.watch(exerciseRepositoryProvider),
    ref.watch(forgeEngineProvider),
  );
});

/// Provider per la generazione (Milestone 5.2, sezione 52): stesso schema
/// dei provider della Milestone 5.1 — nessun provider UI qui.
final forgeExerciseParameterPolicyProvider =
    Provider<ForgeExerciseParameterPolicy>(
      (ref) => const ForgeExerciseParameterPolicy(),
    );

final forgeWorkoutComposerProvider = Provider<ForgeWorkoutComposer>((ref) {
  return ForgeWorkoutComposer(
    parameterPolicy: ref.watch(forgeExerciseParameterPolicyProvider),
    config: ref.watch(forgeEngineConfigProvider),
  );
});

final forgeWorkoutGeneratorProvider = Provider<ForgeWorkoutGenerator>((ref) {
  return ForgeWorkoutGenerator(
    composer: ref.watch(forgeWorkoutComposerProvider),
  );
});

final generateForgeWorkoutProvider = Provider<GenerateForgeWorkout>((ref) {
  return GenerateForgeWorkout(
    ref.watch(exerciseRepositoryProvider),
    ref.watch(forgeEngineProvider),
    ref.watch(forgeWorkoutGeneratorProvider),
  );
});

/// Provider per la persistenza (Milestone 5.3, sezione 41): stesso
/// schema — nessun provider UI qui. Nessun provider per
/// `ForgeWorkoutNamingPolicy` (classe statica, nulla da iniettare) né per
/// le altre policy Forge statiche, stessa scelta già presa per
/// `ForgeWorkoutTypePolicy`/`ForgeWorkoutTypeCoveragePolicy`/
/// `ForgeExerciseOrderingPolicy` nelle Milestone 5.1/5.2.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

final generatedWorkoutPlanValidatorProvider =
    Provider<GeneratedWorkoutPlanValidator>(
      (ref) => GeneratedWorkoutPlanValidator(
        workoutValidationService: ref.watch(workoutValidationServiceProvider),
      ),
    );

final persistGeneratedWorkoutProvider = Provider<PersistGeneratedWorkout>((
  ref,
) {
  return PersistGeneratedWorkout(
    ref.watch(workoutRepositoryProvider),
    planValidator: ref.watch(generatedWorkoutPlanValidatorProvider),
    workoutValidationService: ref.watch(workoutValidationServiceProvider),
    clock: ref.watch(clockProvider),
  );
});

final generateAndPersistForgeWorkoutProvider =
    Provider<GenerateAndPersistForgeWorkout>((ref) {
      return GenerateAndPersistForgeWorkout(
        ref.watch(generateForgeWorkoutProvider),
        ref.watch(persistGeneratedWorkoutProvider),
      );
    });

/// Provider per l'adattamento da storico (Milestone 5.4, sezione 41):
/// stesso schema. Nessun provider per `ForgeProgressionAnalyzer`
/// (`abstract final class` statica, nulla da iniettare) — stessa scelta
/// già presa per le altre policy Forge puramente statiche.
final buildForgeAdaptationContextProvider =
    Provider<BuildForgeAdaptationContext>((ref) {
      return BuildForgeAdaptationContext(
        ref.watch(workoutSessionRepositoryProvider),
        config: ref.watch(forgeEngineConfigProvider),
      );
    });

final forgeExerciseAdaptationPolicyProvider =
    Provider<ForgeExerciseAdaptationPolicy>(
      (ref) => const ForgeExerciseAdaptationPolicy(),
    );

final forgeParameterProgressionPolicyProvider =
    Provider<ForgeParameterProgressionPolicy>(
      (ref) => const ForgeParameterProgressionPolicy(),
    );

final forgeWorkoutAdaptationServiceProvider =
    Provider<ForgeWorkoutAdaptationService>((ref) {
      return ForgeWorkoutAdaptationService(
        exerciseAdaptationPolicy: ref.watch(
          forgeExerciseAdaptationPolicyProvider,
        ),
        parameterProgressionPolicy: ref.watch(
          forgeParameterProgressionPolicyProvider,
        ),
        parameterPolicy: ref.watch(forgeExerciseParameterPolicyProvider),
        config: ref.watch(forgeEngineConfigProvider),
      );
    });

final generateAdaptedForgeWorkoutProvider =
    Provider<GenerateAdaptedForgeWorkout>((ref) {
      return GenerateAdaptedForgeWorkout(
        ref.watch(exerciseRepositoryProvider),
        ref.watch(buildForgeAdaptationContextProvider),
        ref.watch(generateForgeWorkoutProvider),
        ref.watch(forgeWorkoutAdaptationServiceProvider),
        planValidator: ref.watch(generatedWorkoutPlanValidatorProvider),
      );
    });

final generateAndPersistAdaptedForgeWorkoutProvider =
    Provider<GenerateAndPersistAdaptedForgeWorkout>((ref) {
      return GenerateAndPersistAdaptedForgeWorkout(
        ref.watch(generateAdaptedForgeWorkoutProvider),
        ref.watch(persistGeneratedWorkoutProvider),
      );
    });
