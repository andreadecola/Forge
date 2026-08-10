import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';

import 'exercise_test_fixtures.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  testWidgets(
    'il dettaglio mostra nome, tipo, livello, stato ed esercizi in ordine',
    (tester) async {
      final repo = DriftWorkoutRepository(database);
      final profile = await ProfileRepositoryImpl(
        database.userProfileDao,
      ).getCurrentProfile();
      final workoutId = await repo.createWorkout(
        Workout(
          profileId: profile!.id!,
          name: 'Scheda gambe',
          type: WorkoutType.lowerBody,
          level: 3,
          status: WorkoutDefinitionStatus.draft,
          origin: WorkoutOrigin.user,
        ),
      );
      final availableId = (await database.eserciziDao.getByCode(
        'EX-AVAILABLE',
      ))!.id;
      final lockedId = (await database.eserciziDao.getByCode(
        'EX-LOCKED-LEVEL',
      ))!.id;
      await repo.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: lockedId,
          order: 1,
          repetitions: 8,
        ),
      );
      await repo.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: availableId,
          order: 2,
          sets: 2,
          repetitions: 10,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: const ForgeApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Programma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scheda gambe'));
      await tester.pumpAndSettle();

      expect(find.text('Dettaglio scheda'), findsOneWidget);
      expect(find.text('Scheda gambe'), findsOneWidget);
      expect(find.textContaining('Parte inferiore'), findsOneWidget);
      expect(find.textContaining('Livello 3'), findsOneWidget);
      expect(find.text('Bozza'), findsOneWidget);

      // Esercizi in ordine: prima "livello avanzato" (ordine 1), poi
      // "disponibile" (ordine 2).
      final names = tester
          .widgetList<Text>(find.textContaining('Esercizio'))
          .map((t) => t.data)
          .where((data) => data != null && data.startsWith('Esercizio'))
          .toList();
      expect(
        names.indexOf('Esercizio livello avanzato') <
            names.indexOf('Esercizio disponibile'),
        isTrue,
      );

      // Nessuna azione di modifica/rimozione/riordino nella vista di sola
      // lettura, solo la CTA "Modifica".
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byIcon(Icons.drag_handle), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Modifica'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );
}
