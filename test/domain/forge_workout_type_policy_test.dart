import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_category_tier.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_workout_type_policy.dart';

/// Verifica la policy usando i codici categoria **reali** del catalogo
/// seedato (`assets/data/exercises_v1.json`): MOBILITA, GAMBE_GLUTEI,
/// PETTO_SPINTA, SCHIENA, SPALLE, BRACCIA, CORE, EQUILIBRIO, CARDIO,
/// STRETCHING (sezione 27/63).
void main() {
  test('FULL_BODY: preferisce le categorie di forza principali', () {
    for (final code in [
      'GAMBE_GLUTEI',
      'PETTO_SPINTA',
      'SCHIENA',
      'SPALLE',
      'BRACCIA',
      'CORE',
    ]) {
      expect(
        ForgeWorkoutTypePolicy.tierFor(
          workoutType: WorkoutType.fullBody,
          categoryCode: code,
        ),
        ForgeCategoryTier.preferred,
        reason: code,
      );
    }
  });

  test('UPPER_BODY: preferisce la parte superiore, non le gambe', () {
    expect(
      ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.upperBody,
        categoryCode: 'PETTO_SPINTA',
      ),
      ForgeCategoryTier.preferred,
    );
    expect(
      ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.upperBody,
        categoryCode: 'GAMBE_GLUTEI',
      ),
      ForgeCategoryTier.discouraged,
    );
  });

  test('LOWER_BODY: preferisce gambe e glutei, non la parte superiore', () {
    expect(
      ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.lowerBody,
        categoryCode: 'GAMBE_GLUTEI',
      ),
      ForgeCategoryTier.preferred,
    );
    expect(
      ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.lowerBody,
        categoryCode: 'BRACCIA',
      ),
      ForgeCategoryTier.discouraged,
    );
  });

  test('MOBILITY: preferisce mobilità/stretching/equilibrio', () {
    for (final code in ['MOBILITA', 'STRETCHING', 'EQUILIBRIO']) {
      expect(
        ForgeWorkoutTypePolicy.tierFor(
          workoutType: WorkoutType.mobility,
          categoryCode: code,
        ),
        ForgeCategoryTier.preferred,
        reason: code,
      );
    }
    expect(
      ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.mobility,
        categoryCode: 'PETTO_SPINTA',
      ),
      ForgeCategoryTier.discouraged,
    );
  });

  test('CARDIO: preferisce la categoria cardio', () {
    expect(
      ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.cardio,
        categoryCode: 'CARDIO',
      ),
      ForgeCategoryTier.preferred,
    );
    expect(
      ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.cardio,
        categoryCode: 'CORE',
      ),
      ForgeCategoryTier.discouraged,
    );
  });

  test('RECOVERY: preferisce stretching/mobilità, nessun dato sanitario '
      'coinvolto (sezione 31)', () {
    expect(
      ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.recovery,
        categoryCode: 'STRETCHING',
      ),
      ForgeCategoryTier.preferred,
    );
    expect(
      ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.recovery,
        categoryCode: 'CARDIO',
      ),
      ForgeCategoryTier.discouraged,
    );
  });

  test('CUSTOM non ha una policy (sezione 32): tierFor lancia', () {
    expect(
      () => ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.custom,
        categoryCode: 'CORE',
      ),
      throwsArgumentError,
    );
    expect(ForgeWorkoutTypePolicy.isSupported(WorkoutType.custom), isFalse);
  });

  test('tutti i tipi non-CUSTOM sono supportati', () {
    for (final type in WorkoutType.values) {
      if (type == WorkoutType.custom) continue;
      expect(ForgeWorkoutTypePolicy.isSupported(type), isTrue, reason: '$type');
    }
  });

  test('categoria non mappata -> neutral (rete di sicurezza)', () {
    expect(
      ForgeWorkoutTypePolicy.tierFor(
        workoutType: WorkoutType.fullBody,
        categoryCode: 'CATEGORIA_INESISTENTE',
      ),
      ForgeCategoryTier.neutral,
    );
  });
}
