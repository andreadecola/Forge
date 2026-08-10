import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class GetExercisesByCategory {
  GetExercisesByCategory(this._repository);

  final ExerciseRepository _repository;

  Future<List<Exercise>> call(String categoryCode) =>
      _repository.getExercisesByCategory(categoryCode);
}
