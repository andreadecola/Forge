import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/features/training_plan/presentation/workout_labels.dart';

import 'exercise_test_fixtures.dart';

Future<void> _openProgram(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const ForgeApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Programma'));
  await tester.pumpAndSettle();
}

bool _chipSelected(WidgetTester tester, String label) {
  return tester
      .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label))
      .selected;
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  testWidgets(
    'scheda manuale: seleziona, salva, riapre e modifica più livelli',
    (tester) async {
      await _openProgram(tester, database);
      await tester.tap(
        find.widgetWithText(FilledButton, 'Crea il primo allenamento'),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Scheda multi');
      await tester.tap(find.widgetWithText(ChoiceChip, '2'));
      await tester.pump();
      expect(_chipSelected(tester, '1'), isTrue);
      expect(_chipSelected(tester, '2'), isTrue);
      await tester.tap(find.widgetWithText(FilledButton, 'Crea'));
      await tester.pumpAndSettle();

      final repository = DriftWorkoutRepository(database);
      var workout = (await repository.getWorkouts(profileId: 1)).single;
      expect(workout.selectedLevels, {1, 2});
      expect(workout.level, 2);

      await tester.tap(find.byTooltip('Modifica dettagli'));
      await tester.pumpAndSettle();
      expect(_chipSelected(tester, '1'), isTrue);
      expect(_chipSelected(tester, '2'), isTrue);
      await tester.tap(find.widgetWithText(ChoiceChip, '5'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ChoiceChip, '1'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Salva'));
      await tester.pumpAndSettle();

      workout = await repository.getWorkoutById(workout.id!) ?? workout;
      expect(workout.selectedLevels, {2, 5});
      expect(workout.level, 5);

      // Riapertura completa dell'albero UI: i livelli arrivano nuovamente dal
      // record persistito, non dallo stato del form precedente.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await _openProgram(tester, database);
      await tester.tap(find.text('Scheda multi'));
      await tester.pumpAndSettle();
      expect(find.text('Dettaglio scheda'), findsOneWidget);
      expect(find.textContaining(WorkoutLabels.levels({2, 5})), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets('il selettore manuale non consente una selezione vuota', (
    tester,
  ) async {
    await _openProgram(tester, database);
    await tester.tap(
      find.widgetWithText(FilledButton, 'Crea il primo allenamento'),
    );
    await tester.pumpAndSettle();

    final levelOne = find.widgetWithText(ChoiceChip, '1');
    await tester.tap(levelOne);
    await tester.pump();
    expect(_chipSelected(tester, '1'), isTrue);

    await disposeCleanly(tester);
  });

  testWidgets('la creazione manuale supporta tutti e cinque i livelli', (
    tester,
  ) async {
    await _openProgram(tester, database);
    await tester.tap(
      find.widgetWithText(FilledButton, 'Crea il primo allenamento'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Scheda completa');

    for (final level in ['2', '3', '4', '5']) {
      await tester.tap(find.widgetWithText(ChoiceChip, level));
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(FilledButton, 'Crea'));
    await tester.pumpAndSettle();

    final workout = (await DriftWorkoutRepository(
      database,
    ).getWorkouts(profileId: 1)).single;
    expect(workout.selectedLevels, {1, 2, 3, 4, 5});
    expect(workout.level, 5);

    await disposeCleanly(tester);
  });
}
