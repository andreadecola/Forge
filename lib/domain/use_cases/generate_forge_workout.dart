import '../entities/exercise_details.dart';
import '../entities/forge_generation_result.dart';
import '../entities/forge_request.dart';
import '../repositories/exercise_repository.dart';
import '../services/forge_engine.dart';
import '../services/forge_workout_generator.dart';

/// Use case applicativo (Milestone 5.2, sezione 51): stesso schema di
/// [EvaluateForgeRequest] (Milestone 5.1) — recupera il catalogo tramite
/// [ExerciseRepository], valuta con [ForgeEngine], poi compone con
/// [ForgeWorkoutGenerator]. **Non chiama mai `WorkoutRepository.createWorkout`**:
/// nessuna scheda viene persistita da questa milestone.
class GenerateForgeWorkout {
  GenerateForgeWorkout(this._repository, this._engine, this._generator);

  final ExerciseRepository _repository;
  final ForgeEngine _engine;
  final ForgeWorkoutGenerator _generator;

  Future<ForgeGenerationResult> call(ForgeRequest request) async {
    final exercises = await _repository.getExercises();
    final detailsList = await Future.wait(
      exercises.map((exercise) => _repository.getExerciseDetails(exercise.id)),
    );
    final validDetails = detailsList.whereType<ExerciseDetails>().toList();
    final evaluation = _engine.evaluateExercises(request, validDetails);
    return _generator.generate(evaluation);
  }
}
