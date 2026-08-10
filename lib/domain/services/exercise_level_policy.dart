import '../entities/exercise.dart';

/// Punto unico della regola di compatibilità di livello, condivisa da
/// availability service e repository. La query SQL in `EserciziDao.getByLevel`
/// è la trasposizione della stessa regola lato database.
abstract final class ExerciseLevelPolicy {
  static bool isCompatible({
    required int minimumLevel,
    required int? maximumLevel,
    required int userLevel,
  }) {
    if (minimumLevel > userLevel) return false;
    if (maximumLevel != null && userLevel > maximumLevel) return false;
    return true;
  }

  static bool isExerciseCompatible(Exercise exercise, int userLevel) {
    return isCompatible(
      minimumLevel: exercise.minimumLevel,
      maximumLevel: exercise.maximumLevel,
      userLevel: userLevel,
    );
  }
}
