import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class GetExercisesByLevel {
  GetExercisesByLevel(this._repository);

  final ExerciseRepository _repository;

  Future<List<Exercise>> call(int userLevel) =>
      _repository.getExercisesByLevel(userLevel);
}
