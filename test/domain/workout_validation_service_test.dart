import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_catalog_enums.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_details.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/entities/workout_exercise_details.dart';
import 'package:forge/domain/services/workout_validation_service.dart';

Workout _workout({
  WorkoutDefinitionStatus status = WorkoutDefinitionStatus.draft,
  String name = 'Scheda',
  int level = 1,
}) {
  return Workout(
    profileId: 1,
    name: name,
    type: WorkoutType.fullBody,
    level: level,
    status: status,
    origin: WorkoutOrigin.user,
  );
}

Exercise _exercise({int id = 1, String name = 'Esercizio'}) {
  return Exercise(
    id: id,
    code: 'X-$id',
    name: name,
    description: 'desc',
    instructions: 'istr',
    categoryId: 1,
    minimumLevel: 1,
    impactLevel: ExerciseImpactLevel.low,
    balanceRequired: false,
    floorRequired: false,
    standingRequired: false,
    supportAllowed: false,
    isSystem: true,
    isActive: true,
    catalogVersion: 1,
  );
}

WorkoutExerciseDetails _entry({
  int id = 1,
  int order = 1,
  int? repetitions,
  int? durationSeconds,
  bool isActive = true,
}) {
  return WorkoutExerciseDetails(
    workoutExercise: WorkoutExercise(
      id: id,
      workoutId: 1,
      exerciseId: id,
      order: order,
      repetitions: repetitions,
      durationSeconds: durationSeconds,
      isActive: isActive,
    ),
    exercise: _exercise(id: id),
  );
}

void main() {
  const service = WorkoutValidationService();

  group('DRAFT', () {
    test('senza esercizi è valida', () {
      final details = WorkoutDetails(
        workout: _workout(status: WorkoutDefinitionStatus.draft),
        exercises: const [],
      );
      final result = service.validateDraft(details);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('con una voce senza ripetizioni né durata è comunque valida', () {
      final details = WorkoutDetails(
        workout: _workout(status: WorkoutDefinitionStatus.draft),
        exercises: [_entry()],
      );
      final result = service.validateDraft(details);
      expect(result.isValid, isTrue);
    });

    test('viola comunque i vincoli base (es. ordine <= 0)', () {
      final details = WorkoutDetails(
        workout: _workout(status: WorkoutDefinitionStatus.draft),
        exercises: [_entry(order: 0)],
      );
      final result = service.validateDraft(details);
      expect(result.isValid, isFalse);
      expect(result.errors, isNotEmpty);
    });

    test('nome vuoto non è valido nemmeno in DRAFT', () {
      final details = WorkoutDetails(
        workout: _workout(status: WorkoutDefinitionStatus.draft, name: '  '),
        exercises: const [],
      );
      final result = service.validateDraft(details);
      expect(result.isValid, isFalse);
    });
  });

  group('READY', () {
    test('senza esercizi non è valida', () {
      final details = WorkoutDetails(
        workout: _workout(status: WorkoutDefinitionStatus.ready),
        exercises: const [],
      );
      final result = service.validateReady(details);
      expect(result.isValid, isFalse);
      expect(
        result.errors,
        contains('Una scheda pronta deve avere almeno un esercizio.'),
      );
    });

    test('con un esercizio senza ripetizioni e senza durata non è valida', () {
      final details = WorkoutDetails(
        workout: _workout(status: WorkoutDefinitionStatus.ready),
        exercises: [_entry(repetitions: null, durationSeconds: null)],
      );
      final result = service.validateReady(details);
      expect(result.isValid, isFalse);
    });

    test('con ripetizioni è valida', () {
      final details = WorkoutDetails(
        workout: _workout(status: WorkoutDefinitionStatus.ready),
        exercises: [_entry(repetitions: 10)],
      );
      final result = service.validateReady(details);
      expect(result.isValid, isTrue);
    });

    test('con durata è valida', () {
      final details = WorkoutDetails(
        workout: _workout(status: WorkoutDefinitionStatus.ready),
        exercises: [_entry(durationSeconds: 30)],
      );
      final result = service.validateReady(details);
      expect(result.isValid, isTrue);
    });

    test('con una voce non valida (ordine <= 0) non è valida', () {
      final details = WorkoutDetails(
        workout: _workout(status: WorkoutDefinitionStatus.ready),
        exercises: [_entry(order: 0, repetitions: 10)],
      );
      final result = service.validateReady(details);
      expect(result.isValid, isFalse);
    });

    test(
      'un esercizio disattivato non conta per il requisito "almeno uno"',
      () {
        final details = WorkoutDetails(
          workout: _workout(status: WorkoutDefinitionStatus.ready),
          exercises: [_entry(repetitions: 10, isActive: false)],
        );
        final result = service.validateReady(details);
        expect(result.isValid, isFalse);
      },
    );
  });

  test('validate() smista in base allo stato della scheda', () {
    final readyEmpty = WorkoutDetails(
      workout: _workout(status: WorkoutDefinitionStatus.ready),
      exercises: const [],
    );
    expect(service.validate(readyEmpty).isValid, isFalse);

    final draftEmpty = WorkoutDetails(
      workout: _workout(status: WorkoutDefinitionStatus.draft),
      exercises: const [],
    );
    expect(service.validate(draftEmpty).isValid, isTrue);
  });
}
