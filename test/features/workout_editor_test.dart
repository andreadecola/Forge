import 'package:flutter/gestures.dart';
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

Future<void> _pumpAppOnEditor(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const ForgeApp(),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Programma'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(TextButton, 'Modifica'));
  await tester.pumpAndSettle();
}

Future<int> _seedWorkout(
  AppDatabase database, {
  String name = 'Scheda test',
  WorkoutDefinitionStatus status = WorkoutDefinitionStatus.draft,
}) async {
  final profile = await ProfileRepositoryImpl(
    database.userProfileDao,
  ).getCurrentProfile();
  return DriftWorkoutRepository(database).createWorkout(
    Workout(
      profileId: profile!.id!,
      name: name,
      type: WorkoutType.fullBody,
      status: status,
      origin: WorkoutOrigin.user,
    ),
  );
}

Future<int> _availableExerciseId(AppDatabase database) async {
  final row = await database.eserciziDao.getByCode('EX-AVAILABLE');
  return row!.id;
}

/// Trova il pulsante "+" della tessera picker corrispondente a
/// [exerciseName]. Nel picker ogni esercizio del catalogo appare una sola
/// volta (a differenza dell'editor, dove lo stesso esercizio può ripetersi
/// come righe scheda distinte), quindi il nome identifica la tessera senza
/// ambiguità.
Finder _addButtonFor(String exerciseName) {
  return find.descendant(
    of: find
        .ancestor(of: find.text(exerciseName), matching: find.byType(Card))
        .first,
    matching: find.byIcon(Icons.add_circle_outline),
  );
}

/// Lascia sparire eventuali SnackBar di feedback prima della prossima
/// interazione, così un tap successivo sulla stessa riga di pulsanti non
/// rischia di colpire il banner invece del pulsante. `pumpAndSettle` da
/// solo non basta (non aspetta il Timer di chiusura di un SnackBar, che
/// non pianifica un nuovo frame finché non scade); un singolo `pump` con
/// una durata grande non basta nemmeno lui (l'animazione di chiusura,
/// avviata dal Timer proprio in quel salto, riceve un solo frame e non
/// avanza) — servono passi incrementali.
Future<void> _letSnackBarPass(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  testWidgets(
    'aggiunta di un esercizio disponibile carica i default dal catalogo',
    (tester) async {
      final workoutId = await _seedWorkout(database);
      await _pumpAppOnEditor(tester, database);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Aggiungi esercizio'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Esercizio disponibile'), findsOneWidget);
      expect(find.text('Esercizio livello avanzato'), findsOneWidget);
      expect(find.text('Esercizio con elastico'), findsOneWidget);

      await tester.tap(_addButtonFor('Esercizio disponibile'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Aggiungi alla scheda'),
      );
      await tester.pumpAndSettle();

      // I default del catalogo (2 serie, 10 ripetizioni, recupero 45s) sono
      // stati caricati (via WorkoutExerciseFactory) e persistiti senza
      // modifiche.
      expect(find.text('Esercizio disponibile'), findsOneWidget);
      expect(find.text('2 × 10 rip. · Recupero 45 sec'), findsOneWidget);

      final details = await DriftWorkoutRepository(
        database,
      ).getWorkoutDetails(workoutId);
      final exercise = details!.exercises.single.workoutExercise;
      expect(exercise.sets, 2);
      expect(exercise.repetitions, 10);
      expect(exercise.restSeconds, 45);

      await disposeCleanly(tester);
    },
  );

  group('esercizi non consigliati (LOCKED_LEVEL / LOCKED_EQUIPMENT)', () {
    testWidgets('restano visibili con il pulsante "+" sempre disponibile', (
      tester,
    ) async {
      await _seedWorkout(database);
      await _pumpAppOnEditor(tester, database);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Aggiungi esercizio'),
      );
      await tester.pumpAndSettle();

      // 3 esercizi nel mini-catalogo: tutti mostrano il pulsante "+",
      // disponibili o no (la disponibilità resta solo informativa).
      expect(find.byIcon(Icons.add_circle_outline), findsNWidgets(3));
      expect(find.text('Livello successivo'), findsOneWidget);
      expect(find.text('Richiede attrezzatura'), findsOneWidget);

      await disposeCleanly(tester);
    });

    testWidgets(
      'LOCKED_LEVEL chiede conferma prima di aprire la configurazione',
      (tester) async {
        await _seedWorkout(database);
        await _pumpAppOnEditor(tester, database);

        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Aggiungi esercizio'),
        );
        await tester.pumpAndSettle();

        await tester.tap(_addButtonFor('Esercizio livello avanzato'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining(
            'Questo esercizio è previsto per un livello superiore.',
          ),
          findsOneWidget,
        );
        expect(find.widgetWithText(TextButton, 'Annulla'), findsOneWidget);
        expect(
          find.widgetWithText(FilledButton, 'Aggiungi comunque'),
          findsOneWidget,
        );
        // Il bottom sheet di configurazione non è ancora aperto.
        expect(
          find.widgetWithText(FilledButton, 'Aggiungi alla scheda'),
          findsNothing,
        );

        await disposeCleanly(tester);
      },
    );

    testWidgets('LOCKED_LEVEL: "Annulla" non aggiunge alcun esercizio', (
      tester,
    ) async {
      final workoutId = await _seedWorkout(database);
      await _pumpAppOnEditor(tester, database);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Aggiungi esercizio'),
      );
      await tester.pumpAndSettle();

      await tester.tap(_addButtonFor('Esercizio livello avanzato'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(FilledButton, 'Aggiungi alla scheda'),
        findsNothing,
      );

      final details = await DriftWorkoutRepository(
        database,
      ).getWorkoutDetails(workoutId);
      expect(details!.exercises, isEmpty);

      await disposeCleanly(tester);
    });

    testWidgets(
      'LOCKED_LEVEL: "Aggiungi comunque" apre la configurazione e permette '
      'di aggiungerlo',
      (tester) async {
        final workoutId = await _seedWorkout(database);
        await _pumpAppOnEditor(tester, database);

        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Aggiungi esercizio'),
        );
        await tester.pumpAndSettle();

        await tester.tap(_addButtonFor('Esercizio livello avanzato'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(FilledButton, 'Aggiungi comunque'),
        );
        await tester.pumpAndSettle();

        // Stesso bottom sheet di configurazione usato per gli esercizi
        // disponibili: nessuna logica duplicata.
        expect(
          find.widgetWithText(FilledButton, 'Aggiungi alla scheda'),
          findsOneWidget,
        );
        await tester.tap(
          find.widgetWithText(FilledButton, 'Aggiungi alla scheda'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Esercizio livello avanzato'), findsOneWidget);
        final details = await DriftWorkoutRepository(
          database,
        ).getWorkoutDetails(workoutId);
        expect(details!.exercises, hasLength(1));

        await disposeCleanly(tester);
      },
    );

    testWidgets('LOCKED_EQUIPMENT ha lo stesso comportamento (conferma poi '
        'configurazione)', (tester) async {
      final workoutId = await _seedWorkout(database);
      await _pumpAppOnEditor(tester, database);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Aggiungi esercizio'),
      );
      await tester.pumpAndSettle();

      await tester.tap(_addButtonFor('Esercizio con elastico'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('richiede attrezzatura che non risulta'),
        findsOneWidget,
      );

      // Annulla: nessuna aggiunta.
      await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
      await tester.pumpAndSettle();
      var details = await DriftWorkoutRepository(
        database,
      ).getWorkoutDetails(workoutId);
      expect(details!.exercises, isEmpty);

      // Riprova confermando.
      await tester.tap(_addButtonFor('Esercizio con elastico'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Aggiungi comunque'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Aggiungi alla scheda'),
      );
      await tester.pumpAndSettle();

      details = await DriftWorkoutRepository(
        database,
      ).getWorkoutDetails(workoutId);
      expect(details!.exercises, hasLength(1));

      await disposeCleanly(tester);
    });
  });

  testWidgets(
    'lo stesso esercizio può essere aggiunto più volte alla stessa scheda',
    (tester) async {
      final workoutId = await _seedWorkout(database);
      await _pumpAppOnEditor(tester, database);

      for (var i = 0; i < 2; i++) {
        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Aggiungi esercizio'),
        );
        await tester.pumpAndSettle();
        await tester.tap(_addButtonFor('Esercizio disponibile'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(FilledButton, 'Aggiungi alla scheda'),
        );
        await tester.pumpAndSettle();
      }

      // 2 tessere distinte con lo stesso nome nell'editor.
      expect(find.text('Esercizio disponibile'), findsNWidgets(2));

      final details = await DriftWorkoutRepository(
        database,
      ).getWorkoutDetails(workoutId);
      expect(details!.exercises, hasLength(2));
      expect(
        details.exercises.map((e) => e.workoutExercise.exerciseId).toSet(),
        hasLength(1),
      );
      expect(
        details.exercises.map((e) => e.workoutExercise.id).toSet(),
        hasLength(2),
      );
      expect(details.exercises.map((e) => e.workoutExercise.order), [1, 2]);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'la modifica dei parametri di un esercizio esistente viene persistita',
    (tester) async {
      final repo = DriftWorkoutRepository(database);
      final workoutId = await _seedWorkout(database);
      final exerciseId = await _availableExerciseId(database);
      await repo.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseId,
          order: 1,
          sets: 2,
          repetitions: 10,
          restSeconds: 45,
        ),
      );

      await _pumpAppOnEditor(tester, database);

      await tester.tap(find.text('Esercizio disponibile'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(1), '15');
      await tester.tap(find.widgetWithText(FilledButton, 'Salva'));
      await tester.pumpAndSettle();

      expect(find.text('2 × 15 rip. · Recupero 45 sec'), findsOneWidget);

      final details = await repo.getWorkoutDetails(workoutId);
      expect(details!.exercises.single.workoutExercise.repetitions, 15);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'la rimozione di un esercizio compatta gli ordini delle righe rimanenti',
    (tester) async {
      final repo = DriftWorkoutRepository(database);
      final workoutId = await _seedWorkout(database);
      final exerciseId = await _availableExerciseId(database);
      final idA = await repo.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseId,
          order: 1,
          sets: 2,
          repetitions: 10,
        ),
      );
      await repo.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseId,
          order: 2,
          sets: 3,
          repetitions: 12,
        ),
      );
      final idC = await repo.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseId,
          order: 3,
          sets: 4,
          repetitions: 15,
        ),
      );

      await _pumpAppOnEditor(tester, database);

      // Rimuove la riga di mezzo (B): 3 tessere con lo stesso nome, la
      // seconda icona "Rimuovi" corrisponde a B nell'ordine di visualizzazione.
      await tester.tap(find.byIcon(Icons.delete_outline).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Rimuovi'));
      await tester.pumpAndSettle();

      final remaining = await repo.getWorkoutDetails(workoutId);
      expect(remaining!.exercises.map((e) => e.workoutExercise.id), [idA, idC]);
      expect(remaining.exercises.map((e) => e.workoutExercise.order), [1, 2]);

      await disposeCleanly(tester);
    },
  );

  testWidgets('il riordino via drag persiste il nuovo ordine sul DB', (
    tester,
  ) async {
    final repo = DriftWorkoutRepository(database);
    final workoutId = await _seedWorkout(database);
    final exerciseId = await _availableExerciseId(database);
    final idA = await repo.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 1,
      ),
    );
    final idB = await repo.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 2,
      ),
    );
    final idC = await repo.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 3,
      ),
    );

    await _pumpAppOnEditor(tester, database);

    // `flutter test` forza sempre TargetPlatform.android (vedi
    // _platform_io.dart): ReorderableListView usa quindi il drag "mobile",
    // l'intera riga trascinabile dopo una pressione prolungata (nessuna
    // icona drag_handle separata, quella è solo per desktop/web). Sposta la
    // riga C (3 tessere con lo stesso nome, indice 2, in coda) sopra A
    // (indice 0, in testa).
    final tiles = find.text('Esercizio disponibile');
    expect(tiles, findsNWidgets(3));

    final drag = await tester.startGesture(tester.getCenter(tiles.at(2)));
    await tester.pump(kLongPressTimeout);
    await drag.moveBy(const Offset(0, -400));
    await tester.pumpAndSettle();
    await drag.up();
    await tester.pumpAndSettle();

    final details = await repo.getWorkoutDetails(workoutId);
    expect(details!.exercises.map((e) => e.workoutExercise.id), [
      idC,
      idA,
      idB,
    ]);
    expect(details.exercises.map((e) => e.workoutExercise.order), [1, 2, 3]);

    await disposeCleanly(tester);
  });

  testWidgets('"Salva bozza" mostra la conferma "Bozza salvata"', (
    tester,
  ) async {
    await _seedWorkout(database);
    await _pumpAppOnEditor(tester, database);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Salva bozza'));
    await tester.pump();

    expect(find.text('Bozza salvata'), findsOneWidget);

    await _letSnackBarPass(tester);
    await disposeCleanly(tester);
  });

  testWidgets(
    '"Segna come pronta" con esito valido mostra "Allenamento segnato come '
    'pronto"',
    (tester) async {
      final repo = DriftWorkoutRepository(database);
      final workoutId = await _seedWorkout(database);
      final exerciseId = await _availableExerciseId(database);
      await repo.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseId,
          order: 1,
          sets: 2,
          repetitions: 10,
        ),
      );

      await _pumpAppOnEditor(tester, database);

      await tester.tap(find.widgetWithText(FilledButton, 'Segna come pronta'));
      await tester.pump();

      expect(find.text('Allenamento segnato come pronto'), findsOneWidget);
      expect(find.text('Pronta'), findsOneWidget);

      await _letSnackBarPass(tester);
      await disposeCleanly(tester);
    },
  );

  testWidgets(
    '"Segna come pronta" con esito invalido non mostra alcun messaggio di '
    'successo',
    (tester) async {
      await _seedWorkout(database);
      await _pumpAppOnEditor(tester, database);

      await tester.tap(find.widgetWithText(FilledButton, 'Segna come pronta'));
      await tester.pumpAndSettle();

      expect(find.text('Allenamento segnato come pronto'), findsNothing);
      expect(find.text('La scheda non è ancora pronta'), findsOneWidget);
      await tester.tap(find.text('Ho capito'));
      await tester.pumpAndSettle();
      expect(find.text('Bozza'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'bozza vuota salvabile; senza esercizi non diventa pronta; con un '
    'esercizio valido diventa pronta',
    (tester) async {
      await _seedWorkout(database);
      await _pumpAppOnEditor(tester, database);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Salva bozza'));
      await _letSnackBarPass(tester);
      expect(find.text('Bozza'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Segna come pronta'));
      await tester.pumpAndSettle();
      expect(find.text('La scheda non è ancora pronta'), findsOneWidget);
      expect(find.textContaining('almeno un esercizio'), findsOneWidget);
      await tester.tap(find.text('Ho capito'));
      await tester.pumpAndSettle();
      expect(find.text('Bozza'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Aggiungi esercizio'),
      );
      await tester.pumpAndSettle();
      await tester.tap(_addButtonFor('Esercizio disponibile'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Aggiungi alla scheda'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Segna come pronta'));
      await tester.pumpAndSettle();
      expect(find.text('Pronta'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'una scheda pronta che diventa invalida torna automaticamente in bozza',
    (tester) async {
      final repo = DriftWorkoutRepository(database);
      final workoutId = await _seedWorkout(database);
      final exerciseId = await _availableExerciseId(database);
      await repo.addExercise(
        workoutId: workoutId,
        exercise: WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseId,
          order: 1,
          sets: 2,
          repetitions: 10,
        ),
      );
      final workout = (await repo.getWorkoutById(workoutId))!;
      await repo.updateWorkout(
        workout.copyWith(status: WorkoutDefinitionStatus.ready),
      );

      await _pumpAppOnEditor(tester, database);
      expect(find.text('Pronta'), findsOneWidget);

      await tester.tap(find.text('Esercizio disponibile'));
      await tester.pumpAndSettle();
      // Toglie le ripetizioni senza impostare una durata: l'esercizio non è
      // più eseguibile, la scheda deve tornare in bozza automaticamente.
      await tester.enterText(find.byType(TextField).at(1), '');
      await tester.tap(find.widgetWithText(FilledButton, 'Salva'));
      await tester.pumpAndSettle();

      expect(find.text('Bozza'), findsOneWidget);
      final reloaded = await repo.getWorkoutById(workoutId);
      expect(reloaded!.status, WorkoutDefinitionStatus.draft);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'archiviazione dall\'editor torna alla lista, che non la mostra più, e '
    'mostra la conferma "Allenamento archiviato"',
    (tester) async {
      final workoutId = await _seedWorkout(database);
      await _pumpAppOnEditor(tester, database);

      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Archivia'));
      // `pumpAndSettle`, non un singolo `pump`: a metà della transizione di
      // pop sono momentaneamente montate sia la pagina in uscita
      // (l'editor) sia quella in entrata (la lista), ed entrambe
      // registrate sullo stesso ScaffoldMessenger mostrerebbero due copie
      // dello stesso SnackBar per quel singolo frame.
      await tester.pumpAndSettle();

      expect(find.text('Allenamento archiviato'), findsOneWidget);
      expect(find.text('I tuoi allenamenti'), findsOneWidget);
      expect(find.text('Non hai ancora creato allenamenti.'), findsOneWidget);

      final workout = await DriftWorkoutRepository(
        database,
      ).getWorkoutById(workoutId);
      expect(workout!.status, WorkoutDefinitionStatus.archived);
      expect(workout.isActive, isFalse);

      await disposeCleanly(tester);
    },
  );
}
