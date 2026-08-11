import '../entities/forge_generation_result.dart';
import '../entities/forge_request.dart';
import '../entities/persist_generated_workout_request.dart';
import '../entities/persist_generated_workout_result.dart';
import 'generate_adapted_forge_workout.dart';
import 'persist_generated_workout.dart';

/// Use case combinato (Milestone 5.4, sezione 45): compone
/// [GenerateAdaptedForgeWorkout] e [PersistGeneratedWorkout] (Milestone
/// 5.3, invariato) — **non duplica** la logica di persistenza, la
/// riusa esattamente com'è.
class GenerateAndPersistAdaptedForgeWorkout {
  GenerateAndPersistAdaptedForgeWorkout(this._generateAdapted, this._persist);

  final GenerateAdaptedForgeWorkout _generateAdapted;
  final PersistGeneratedWorkout _persist;

  Future<PersistGeneratedWorkoutResult> call({
    required ForgeRequest forgeRequest,
    required int profileId,
    required DateTime now,
    String? name,
    String? description,
  }) async {
    final adaptedResult = await _generateAdapted(
      request: forgeRequest,
      profileId: profileId,
      now: now,
    );

    // Il piano adattato, alla fine, è comunque un `GeneratedWorkoutPlan`
    // valido (Milestone 5.2): lo stesso tipo che `PersistGeneratedWorkout`
    // già sa gestire, nessun secondo percorso di persistenza.
    final generationResult = ForgeGenerationResult(
      plan: adaptedResult.plan?.plan,
      errors: adaptedResult.errors,
      warnings: adaptedResult.warnings,
      evaluation: adaptedResult.evaluation,
    );

    return _persist(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: generationResult,
        name: name,
        description: description,
      ),
    );
  }
}
