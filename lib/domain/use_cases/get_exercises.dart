import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class GetExercises {
  GetExercises(this._repository);

  final ExerciseRepository _repository;

  Future<List<Exercise>> call() => _repository.getExercises();
}
