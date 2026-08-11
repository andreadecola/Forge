import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_workout_naming_policy.dart';

void main() {
  test('ogni WorkoutType supportato ha un nome default, mai vuoto', () {
    for (final type in WorkoutType.values) {
      if (type == WorkoutType.custom) continue;
      final name = ForgeWorkoutNamingPolicy.defaultNameFor(type);
      expect(name.trim(), isNotEmpty, reason: '$type');
    }
  });

  test('deterministico: stesso WorkoutType -> stesso nome ogni volta', () {
    final first = ForgeWorkoutNamingPolicy.defaultNameFor(WorkoutType.fullBody);
    final second = ForgeWorkoutNamingPolicy.defaultNameFor(
      WorkoutType.fullBody,
    );
    expect(first, second);
    expect(first, 'Forge Full Body');
  });

  test('CUSTOM non è generabile: defaultNameFor lancia', () {
    expect(
      () => ForgeWorkoutNamingPolicy.defaultNameFor(WorkoutType.custom),
      throwsArgumentError,
    );
  });
}
