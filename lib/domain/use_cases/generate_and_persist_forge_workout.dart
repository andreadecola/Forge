import '../entities/generate_and_persist_forge_workout_request.dart';
import '../entities/persist_generated_workout_request.dart';
import '../entities/persist_generated_workout_result.dart';
import 'generate_forge_workout.dart';
import 'persist_generated_workout.dart';

/// Use case combinato (Milestone 5.3, sezione 30): genera e persiste in
/// sequenza, ma è pura composizione — [GenerateForgeWorkout] e
/// [PersistGeneratedWorkout] restano use case indipendenti, richiamabili
/// da soli. Nessuna UI.
class GenerateAndPersistForgeWorkout {
  GenerateAndPersistForgeWorkout(this._generate, this._persist);

  final GenerateForgeWorkout _generate;
  final PersistGeneratedWorkout _persist;

  Future<PersistGeneratedWorkoutResult> call(
    GenerateAndPersistForgeWorkoutRequest request,
  ) async {
    final generationResult = await _generate(request.forgeRequest);
    return _persist(
      PersistGeneratedWorkoutRequest(
        profileId: request.profileId,
        generationResult: generationResult,
        name: request.name,
        description: request.description,
      ),
    );
  }
}
