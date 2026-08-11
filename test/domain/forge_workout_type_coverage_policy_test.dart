import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_workout_type_coverage_policy.dart';

void main() {
  test('ogni WorkoutType supportato ha almeno un requisito di copertura '
      'obbligatoria, con solo categorie reali del catalogo', () {
    const realCategories = {
      'MOBILITA',
      'GAMBE_GLUTEI',
      'PETTO_SPINTA',
      'SCHIENA',
      'SPALLE',
      'BRACCIA',
      'CORE',
      'EQUILIBRIO',
      'CARDIO',
      'STRETCHING',
    };
    for (final type in WorkoutType.values) {
      if (type == WorkoutType.custom) continue;
      final requirements = ForgeWorkoutTypeCoveragePolicy.requiredCoverageFor(
        type,
      );
      expect(requirements, isNotEmpty, reason: '$type');
      for (final requirement in requirements) {
        expect(requirement.categoryCodes, isNotEmpty, reason: '$type');
        expect(
          requirement.categoryCodes.difference(realCategories),
          isEmpty,
          reason: '$type ha categorie non reali',
        );
      }
    }
  });

  test('CUSTOM non è generabile: requiredCoverageFor lancia', () {
    expect(
      () => ForgeWorkoutTypeCoveragePolicy.requiredCoverageFor(
        WorkoutType.custom,
      ),
      throwsArgumentError,
    );
  });

  test('preferredCategoriesFor deriva dal vivo da ForgeWorkoutTypePolicy '
      '(RECOVERY preferisce STRETCHING/MOBILITA)', () {
    final preferred = ForgeWorkoutTypeCoveragePolicy.preferredCategoriesFor(
      WorkoutType.recovery,
    );
    expect(preferred, containsAll(<String>{'STRETCHING', 'MOBILITA'}));
  });
}
