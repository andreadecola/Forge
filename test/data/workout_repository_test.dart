import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/repositories/workout_repository.dart';

import 'workout_test_helpers.dart';

void main() {
  late AppDatabase database;
  late DriftWorkoutRepository repository;
  late int profileId;
  late int categoryId;
  late int exerciseAId;
  late int exerciseBId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftWorkoutRepository(database);
    profileId = await insertProfilo(database);
    categoryId = await insertCategoria(database);
    exerciseAId = await insertEsercizio(
      database,
      codice: 'LEG-001',
      idCategoria: categoryId,
      defaultSets: 2,
      defaultReps: 10,
      defaultRestSeconds: 60,
    );
    exerciseBId = await insertEsercizio(
      database,
      codice: 'LEG-002',
      idCategoria: categoryId,
    );
  });

  tearDown(() => database.close());

  Workout newWorkout({
    WorkoutDefinitionStatus status = WorkoutDefinitionStatus.draft,
  }) {
    return Workout(
      profileId: profileId,
      name: 'Scheda A',
      type: WorkoutType.fullBody,
      status: status,
      origin: WorkoutOrigin.user,
    );
  }

  Future<int> createWorkout() => repository.createWorkout(newWorkout());

  test('createWorkout + getWorkoutById', () async {
    final id = await createWorkout();
    final workout = await repository.getWorkoutById(id);
    expect(workout, isNotNull);
    expect(workout!.name, 'Scheda A');
    expect(workout.profileId, profileId);
    expect(workout.status, WorkoutDefinitionStatus.draft);
  });

  test('getWorkouts elenca le schede attive del profilo', () async {
    await createWorkout();
    await repository.createWorkout(newWorkout().copyWith(name: 'Scheda B'));

    final workouts = await repository.getWorkouts(profileId: profileId);
    expect(workouts, hasLength(2));
  });

  test('updateWorkout aggiorna i campi della scheda', () async {
    final id = await createWorkout();
    final workout = await repository.getWorkoutById(id);

    await repository.updateWorkout(
      workout!.copyWith(name: 'Scheda rinominata', level: 3),
    );

    final updated = await repository.getWorkoutById(id);
    expect(updated!.name, 'Scheda rinominata');
    expect(updated.level, 3);
  });

  test(
    'archiveWorkout imposta status ARCHIVED e isActive false senza eliminare il record',
    () async {
      final id = await createWorkout();
      await repository.archiveWorkout(id);

      final workout = await repository.getWorkoutById(id);
      expect(workout, isNotNull);
      expect(workout!.status, WorkoutDefinitionStatus.archived);
      expect(workout.isActive, isFalse);

      // Una scheda archiviata non compare più nell'elenco normale.
      final workouts = await repository.getWorkouts(profileId: profileId);
      expect(workouts, isEmpty);
    },
  );

  test('deleteWorkout elimina la scheda e le righe collegate, ma non il '
      'catalogo esercizi', () async {
    final id = await createWorkout();
    await repository.addExercise(
      workoutId: id,
      exercise: WorkoutExercise(
        workoutId: id,
        exerciseId: exerciseAId,
        order: 1,
      ),
    );

    await repository.deleteWorkout(id);

    expect(await repository.getWorkoutById(id), isNull);
    expect(await database.allenamentiEserciziDao.getByWorkoutId(id), isEmpty);
    final exercise = await database.eserciziDao.getById(exerciseAId);
    expect(exercise, isNotNull);
  });

  group('addExercise / updateExercise / removeExercise', () {
    test('addExercise senza ordine esplicito lo assegna in coda', () async {
      final workoutId = await createWorkout();

      final id1 = await repository.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseAId,
          order: 0,
        ),
      );
      final id2 = await repository.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseBId,
          order: 0,
        ),
      );

      final row1 = await database.allenamentiEserciziDao.getById(id1);
      final row2 = await database.allenamentiEserciziDao.getById(id2);
      expect(row1!.ordine, 1);
      expect(row2!.ordine, 2);
    });

    test('updateExercise aggiorna i valori della riga', () async {
      final workoutId = await createWorkout();
      final id = await repository.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseAId,
          order: 1,
        ),
      );

      await repository.updateExercise(
        WorkoutExercise(
          id: id,
          workoutId: workoutId,
          exerciseId: exerciseAId,
          order: 1,
          sets: 4,
          repetitions: 12,
        ),
      );

      final row = await database.allenamentiEserciziDao.getById(id);
      expect(row!.serie, 4);
      expect(row.ripetizioni, 12);
    });

    test(
      'removeExercise elimina la riga e normalizza gli ordini successivi',
      () async {
        final workoutId = await createWorkout();
        final idA = await repository.addExercise(
          workoutId: workoutId,
          exercise: WorkoutExercise(
            workoutId: workoutId,
            exerciseId: exerciseAId,
            order: 1,
          ),
        );
        final idB = await repository.addExercise(
          workoutId: workoutId,
          exercise: WorkoutExercise(
            workoutId: workoutId,
            exerciseId: exerciseBId,
            order: 2,
          ),
        );
        final idC = await repository.addExercise(
          workoutId: workoutId,
          exercise: WorkoutExercise(
            workoutId: workoutId,
            exerciseId: exerciseAId,
            order: 3,
          ),
        );

        await repository.removeExercise(idB);

        final remaining = await database.allenamentiEserciziDao.getByWorkoutId(
          workoutId,
        );
        expect(remaining.map((r) => r.id), [idA, idC]);
        expect(remaining.map((r) => r.ordine), [1, 2]);
      },
    );
  });

  group('reorderExercises', () {
    Future<List<int>> seedThree(int workoutId) async {
      final idA = await repository.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseAId,
          order: 1,
        ),
      );
      final idB = await repository.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseBId,
          order: 2,
        ),
      );
      final idC = await repository.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseAId,
          order: 3,
        ),
      );
      return [idA, idB, idC];
    }

    test('A,B,C -> C,A,B', () async {
      final workoutId = await createWorkout();
      final ids = await seedThree(workoutId);
      final [idA, idB, idC] = ids;

      await repository.reorderExercises(
        workoutId: workoutId,
        orderedWorkoutExerciseIds: [idC, idA, idB],
      );

      final rows = await database.allenamentiEserciziDao.getByWorkoutId(
        workoutId,
      );
      expect(rows.map((r) => r.id), [idC, idA, idB]);
      expect(rows.map((r) => r.ordine), [1, 2, 3]);
    });

    test('A,B,C -> B,C,A', () async {
      final workoutId = await createWorkout();
      final ids = await seedThree(workoutId);
      final [idA, idB, idC] = ids;

      await repository.reorderExercises(
        workoutId: workoutId,
        orderedWorkoutExerciseIds: [idB, idC, idA],
      );

      final rows = await database.allenamentiEserciziDao.getByWorkoutId(
        workoutId,
      );
      expect(rows.map((r) => r.id), [idB, idC, idA]);
    });

    test('ordine identico -> nessun problema', () async {
      final workoutId = await createWorkout();
      final ids = await seedThree(workoutId);

      await repository.reorderExercises(
        workoutId: workoutId,
        orderedWorkoutExerciseIds: ids,
      );

      final rows = await database.allenamentiEserciziDao.getByWorkoutId(
        workoutId,
      );
      expect(rows.map((r) => r.id), ids);
    });

    test('lista con ID duplicato -> errore, nessuna modifica', () async {
      final workoutId = await createWorkout();
      final ids = await seedThree(workoutId);
      final [idA, idB, idC] = ids;

      expect(
        () => repository.reorderExercises(
          workoutId: workoutId,
          orderedWorkoutExerciseIds: [idA, idA, idC],
        ),
        throwsA(isA<WorkoutReorderException>()),
      );

      final rows = await database.allenamentiEserciziDao.getByWorkoutId(
        workoutId,
      );
      expect(rows.map((r) => r.id), [idA, idB, idC]);
      expect(rows.map((r) => r.ordine), [1, 2, 3]);
    });

    test(
      'lista con ID di un\'altra scheda -> errore, nessuna modifica',
      () async {
        final workoutId = await createWorkout();
        final ids = await seedThree(workoutId);
        final [idA, idB, idC] = ids;

        final otherWorkoutId = await createWorkout();
        final foreignId = await repository.addExercise(
          workoutId: otherWorkoutId,
          exercise: WorkoutExercise(
            workoutId: otherWorkoutId,
            exerciseId: exerciseAId,
            order: 1,
          ),
        );

        expect(
          () => repository.reorderExercises(
            workoutId: workoutId,
            orderedWorkoutExerciseIds: [foreignId, idA, idB],
          ),
          throwsA(isA<WorkoutReorderException>()),
        );

        final rows = await database.allenamentiEserciziDao.getByWorkoutId(
          workoutId,
        );
        expect(rows.map((r) => r.id), [idA, idB, idC]);
      },
    );

    test(
      'lista incompleta (manca un ID) -> errore, nessuna modifica',
      () async {
        final workoutId = await createWorkout();
        final ids = await seedThree(workoutId);
        final [idA, idB, idC] = ids;

        expect(
          () => repository.reorderExercises(
            workoutId: workoutId,
            orderedWorkoutExerciseIds: [idA, idB],
          ),
          throwsA(isA<WorkoutReorderException>()),
        );

        final rows = await database.allenamentiEserciziDao.getByWorkoutId(
          workoutId,
        );
        expect(rows.map((r) => r.id), [idA, idB, idC]);
      },
    );
  });

  test(
    'getWorkoutDetails risolve gli esercizi dal catalogo, in ordine',
    () async {
      final workoutId = await createWorkout();
      await repository.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseBId,
          order: 2,
        ),
      );
      await repository.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseAId,
          order: 1,
        ),
      );

      final details = await repository.getWorkoutDetails(workoutId);
      expect(details, isNotNull);
      expect(details!.workout.id, workoutId);
      expect(details.exercises, hasLength(2));
      expect(details.exercises[0].exercise.code, 'LEG-001');
      expect(details.exercises[1].exercise.code, 'LEG-002');
    },
  );

  test('getWorkoutDetails restituisce null se la scheda non esiste', () async {
    expect(await repository.getWorkoutDetails(999), isNull);
  });
}
