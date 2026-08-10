import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class SearchExercises {
  SearchExercises(this._repository);

  final ExerciseRepository _repository;

  Future<List<Exercise>> call(String query) =>
      _repository.searchExercises(query);
}
