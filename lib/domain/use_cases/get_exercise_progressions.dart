import '../entities/exercise_progression.dart';
import '../repositories/exercise_repository.dart';

class GetExerciseProgressions {
  GetExerciseProgressions(this._repository);

  final ExerciseRepository _repository;

  Future<List<ExerciseProgression>> call(int exerciseId) =>
      _repository.getProgressions(exerciseId);
}
