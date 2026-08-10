import '../entities/exercise_details.dart';
import '../repositories/exercise_repository.dart';

class GetExerciseDetails {
  GetExerciseDetails(this._repository);

  final ExerciseRepository _repository;

  Future<ExerciseDetails?> call(int exerciseId) =>
      _repository.getExerciseDetails(exerciseId);
}
