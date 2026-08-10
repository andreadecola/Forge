import '../entities/exercise_alternative.dart';
import '../repositories/exercise_repository.dart';

class GetExerciseAlternatives {
  GetExerciseAlternatives(this._repository);

  final ExerciseRepository _repository;

  Future<List<ExerciseAlternative>> call(int exerciseId) =>
      _repository.getAlternatives(exerciseId);
}
