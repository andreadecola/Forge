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

  /// Compatibilità multilivello: un esercizio è compatibile se rispetta la
  /// stessa regola completa (minimo e massimo) per almeno uno dei livelli
  /// scelti. Non viene mai assegnato un esercizio per quota obbligatoria di
  /// ciascun livello.
  static bool isExerciseCompatibleWithAnyLevel(
    Exercise exercise,
    Set<int> levels,
  ) {
    return levels.any((level) => isExerciseCompatible(exercise, level));
  }

  static List<int> compatibleLevels(Exercise exercise, Set<int> levels) {
    final sorted = levels.toList()..sort();
    return [
      for (final level in sorted)
        if (isExerciseCompatible(exercise, level)) level,
    ];
  }
}
