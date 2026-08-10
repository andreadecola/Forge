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

import 'exercise_test_fixtures.dart';

Future<void> _pumpAppOnProgram(
  WidgetTester tester,
  AppDatabase database,
) async {
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

Future<int> _seedWorkout(
  AppDatabase database, {
  String name = 'Scheda test',
}) async {
  final profile = await ProfileRepositoryImpl(
    database.userProfileDao,
  ).getCurrentProfile();
  return DriftWorkoutRepository(database).createWorkout(
    Workout(
      profileId: profile!.id!,
      name: name,
      type: WorkoutType.fullBody,
      status: WorkoutDefinitionStatus.draft,
      origin: WorkoutOrigin.user,
    ),
  );
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  testWidgets('nessun allenamento: mostra l\'empty state con la CTA', (
    tester,
  ) async {
    await _pumpAppOnProgram(tester, database);

    expect(find.text('I tuoi allenamenti'), findsOneWidget);
    expect(find.text('Non hai ancora creato allenamenti.'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Crea il primo allenamento'),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets(
    'crea un nuovo allenamento dalla lista vuota e lo mostra come bozza',
    (tester) async {
      await _pumpAppOnProgram(tester, database);

      await tester.tap(
        find.widgetWithText(FilledButton, 'Crea il primo allenamento'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nuovo allenamento'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Scheda gambe');
      await tester.tap(find.widgetWithText(FilledButton, 'Crea'));
      await tester.pumpAndSettle();

      // Naviga direttamente alla composizione della scheda appena creata.
      expect(find.text('Scheda gambe'), findsWidgets);
      expect(find.text('Nessun esercizio aggiunto.'), findsOneWidget);

      await tester.tap(find.byTooltip('Indietro'));
      await tester.pumpAndSettle();

      expect(find.text('I tuoi allenamenti'), findsOneWidget);
      expect(find.text('Scheda gambe'), findsOneWidget);
      expect(find.text('Bozza'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets('archivia una scheda dalla lista: non è più visibile', (
    tester,
  ) async {
    await _seedWorkout(database, name: 'Scheda da archiviare');
    await _pumpAppOnProgram(tester, database);

    expect(find.text('Scheda da archiviare'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archivia'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Archivia'));
    await tester.pump();

    expect(find.text('Allenamento archiviato'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Scheda da archiviare'), findsNothing);
    expect(find.text('Non hai ancora creato allenamenti.'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets(
    'una scheda archiviata compare in "Allenamenti archiviati" e si apre '
    'nel dettaglio',
    (tester) async {
      await _pumpAppOnProgram(tester, database);

      // Vuota prima di archiviare qualcosa.
      await tester.tap(find.byTooltip('Allenamenti archiviati'));
      await tester.pumpAndSettle();
      expect(find.text('Nessuna scheda archiviata.'), findsOneWidget);
      await tester.tap(find.byTooltip('Indietro'));
      await tester.pumpAndSettle();

      await _seedWorkout(database, name: 'Scheda da archiviare');
      // La lista principale osserva lo stream: la nuova scheda compare
      // senza bisogno di un altro giro di navigazione.
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archivia'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Archivia'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Allenamenti archiviati'));
      await tester.pumpAndSettle();

      expect(find.text('Scheda da archiviare'), findsOneWidget);
      expect(find.text('Archiviata'), findsOneWidget);

      await tester.tap(find.text('Scheda da archiviare'));
      await tester.pumpAndSettle();

      expect(find.text('Dettaglio scheda'), findsOneWidget);
      expect(find.text('Scheda da archiviare'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'una scheda archiviata è eliminabile definitivamente da "Allenamenti '
    'archiviati"',
    (tester) async {
      final repo = DriftWorkoutRepository(database);
      final workoutId = await _seedWorkout(database, name: 'Scheda vecchia');
      await repo.archiveWorkout(workoutId);

      await _pumpAppOnProgram(tester, database);
      await tester.tap(find.byTooltip('Allenamenti archiviati'));
      await tester.pumpAndSettle();
      expect(find.text('Scheda vecchia'), findsOneWidget);

      // Annulla: la scheda resta.
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
      await tester.pumpAndSettle();
      expect(find.text('Scheda vecchia'), findsOneWidget);
      expect(await repo.getWorkoutById(workoutId), isNotNull);

      // Elimina: la scheda scompare dall'elenco ed è eliminata dal DB.
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Elimina'));
      await tester.pumpAndSettle();

      expect(find.text('Allenamento eliminato'), findsOneWidget);
      expect(find.text('Scheda vecchia'), findsNothing);
      expect(find.text('Nessuna scheda archiviata.'), findsOneWidget);
      expect(await repo.getWorkoutById(workoutId), isNull);

      await disposeCleanly(tester);
    },
  );
}
