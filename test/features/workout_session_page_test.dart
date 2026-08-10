import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/data/repositories/workout_providers.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/features/training_plan/application/workout_session_controller.dart';

import 'exercise_test_fixtures.dart';

Future<void> _pumpApp(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const ForgeApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openDetail(WidgetTester tester, String workoutName) async {
  await tester.tap(find.text('Programma'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(workoutName));
  await tester.pumpAndSettle();
}

Future<int> _seedWorkout(
  AppDatabase database, {
  required String name,
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

/// Crea una scheda PRONTA con [count] righe (stesso esercizio del
/// catalogo ripetuto: qui interessa solo l'identità di
/// [WorkoutExercise.id], mai `exerciseId`), e restituisce l'id della
/// scheda e gli id delle righe nell'ordine della scheda.
Future<({int workoutId, List<int> rowIds})> _seedReadyWorkout(
  AppDatabase database, {
  required String name,
  int count = 3,
}) async {
  final repo = DriftWorkoutRepository(database);
  final workoutId = await _seedWorkout(database, name: name);
  final exerciseId = await _availableExerciseId(database);
  final rowIds = <int>[];
  for (var i = 0; i < count; i++) {
    // Una sola serie e nessun recupero: qui interessa solo la navigazione
    // tra esercizi (indietro/salta/pausa/riepilogo), non la granularità
    // delle serie — coperta a parte da un test dedicato.
    final id = await repo.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: i + 1,
        sets: 1,
        repetitions: 10,
      ),
    );
    rowIds.add(id);
  }
  final workout = (await repo.getWorkoutById(workoutId))!;
  await repo.updateWorkout(
    workout.copyWith(status: WorkoutDefinitionStatus.ready),
  );
  return (workoutId: workoutId, rowIds: rowIds);
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
  });

  tearDown(() => database.close());

  testWidgets(
    '"Inizia allenamento" è presente per una scheda pronta e assente per '
    'una bozza',
    (tester) async {
      await _seedReadyWorkout(database, name: 'Scheda pronta', count: 1);
      await _seedWorkout(database, name: 'Scheda bozza');

      await _pumpApp(tester, database);

      await _openDetail(tester, 'Scheda pronta');
      expect(
        find.widgetWithText(FilledButton, 'Inizia allenamento'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Indietro'));
      await tester.pumpAndSettle();

      await _openDetail(tester, 'Scheda bozza');
      expect(
        find.widgetWithText(FilledButton, 'Inizia allenamento'),
        findsNothing,
      );

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'flusso completo: avvio, completa, indietro, salta, pausa, riepilogo, '
    'fine',
    (tester) async {
      final seeded = await _seedReadyWorkout(
        database,
        name: 'Scheda completa',
        count: 3,
      );
      final workoutId = seeded.workoutId;

      await _pumpApp(tester, database);
      await _openDetail(tester, 'Scheda completa');

      await tester.tap(find.widgetWithText(FilledButton, 'Inizia allenamento'));
      await tester.pumpAndSettle();

      expect(find.text('Esercizio 1 di 3'), findsOneWidget);

      // Completa A -> avanza a B.
      await tester.tap(find.widgetWithText(FilledButton, 'Completa serie'));
      await tester.pumpAndSettle();
      expect(find.text('Esercizio 2 di 3'), findsOneWidget);

      // Indietro -> torna ad A, che deve mostrare "Completato".
      await tester.tap(find.widgetWithText(OutlinedButton, 'Indietro'));
      await tester.pumpAndSettle();
      expect(find.text('Esercizio 1 di 3'), findsOneWidget);
      expect(find.text('Completato'), findsOneWidget);

      // Avanza di nuovo su B e saltalo -> avanza a C.
      await tester.tap(find.widgetWithText(FilledButton, 'Completa serie'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Salta'));
      await tester.pumpAndSettle();
      expect(find.text('Esercizio 3 di 3'), findsOneWidget);

      // Pausa: le azioni normali sparisce, resta solo "Riprendi".
      await tester.tap(find.widgetWithText(OutlinedButton, 'Pausa'));
      await tester.pumpAndSettle();
      expect(find.text('Allenamento in pausa'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Completa serie'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Riprendi'));
      await tester.pumpAndSettle();
      expect(find.text('Esercizio 3 di 3'), findsOneWidget);

      // Completa l'ultimo -> riepilogo.
      await tester.tap(find.widgetWithText(FilledButton, 'Completa serie'));
      await tester.pumpAndSettle();

      expect(find.text('Allenamento completato'), findsOneWidget);
      // "Scheda completa" appare sia nell'AppBar sia nel riepilogo.
      expect(find.text('Scheda completa'), findsWidgets);
      expect(find.text('2'), findsOneWidget); // completati: A e C
      expect(find.text('1'), findsOneWidget); // saltati: B

      await tester.tap(find.widgetWithText(FilledButton, 'Fine'));
      await tester.pumpAndSettle();

      // Torna al dettaglio; la sessione è pulita e può essere riavviata.
      expect(find.text('Dettaglio scheda'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Inizia allenamento'),
        findsOneWidget,
      );
      expect(container(tester).read(workoutSessionControllerProvider), isNull);

      // Nessuna persistenza dell'esito: la scheda resta PRONTA come prima.
      final workout = await DriftWorkoutRepository(
        database,
      ).getWorkoutById(workoutId);
      expect(workout!.status, WorkoutDefinitionStatus.ready);

      await disposeCleanly(tester);
    },
  );

  testWidgets('serie, recupero e timer: esercizio a ripetizioni con recupero '
      'saltabile ed esercizio a tempo con countdown reale (Milestone 4.4.2, '
      'sezione 49)', (tester) async {
    final repo = DriftWorkoutRepository(database);
    final workoutId = await _seedWorkout(database, name: 'Scheda serie');
    final exerciseId = await _availableExerciseId(database);
    // Esercizio A: 2 × 5 ripetizioni, recupero 10 sec.
    await repo.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 1,
        sets: 2,
        repetitions: 5,
        restSeconds: 10,
      ),
    );
    // Esercizio B: 2 × 10 sec, recupero 5 sec.
    await repo.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 2,
        sets: 2,
        durationSeconds: 10,
        restSeconds: 5,
      ),
    );
    final workout = (await repo.getWorkoutById(workoutId))!;
    await repo.updateWorkout(
      workout.copyWith(status: WorkoutDefinitionStatus.ready),
    );

    await _pumpApp(tester, database);
    await _openDetail(tester, 'Scheda serie');
    await tester.tap(find.widgetWithText(FilledButton, 'Inizia allenamento'));
    await tester.pumpAndSettle();

    // Esercizio A, serie 1 di 2.
    expect(find.text('Serie 1 di 2'), findsOneWidget);
    expect(find.text('5 ripetizioni'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Completa serie'));
    await tester.pumpAndSettle();

    // Recupero dopo la prima serie.
    expect(find.text('RECUPERO'), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget);
    expect(find.text('Recupero prima della serie 2'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Salta recupero'));
    await tester.pumpAndSettle();
    expect(find.text('Serie 2 di 2'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Completa serie'));
    await tester.pumpAndSettle();

    // Esercizio A risolto: avanti al B, a tempo.
    expect(find.text('Esercizio 2 di 2'), findsOneWidget);
    expect(find.text('Serie 1 di 2'), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget); // anteprima statica
    expect(find.widgetWithText(FilledButton, 'Avvia serie'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Avvia serie'));
    await tester.pump();
    expect(find.widgetWithText(FilledButton, 'Avvia serie'), findsNothing);

    // Il countdown scorre da un timestamp reale, non da un contatore:
    // un solo salto di 10 secondi lo fa arrivare a zero correttamente.
    await tester.pump(const Duration(seconds: 10));

    // Prima serie di B completata -> recupero di 5 sec.
    expect(find.text('RECUPERO'), findsOneWidget);
    expect(find.text('00:05'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));

    // Recupero terminato: serie 2 pronta, il timer non riparte da solo.
    expect(find.text('Serie 2 di 2'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Avvia serie'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Avvia serie'));
    await tester.pump(const Duration(seconds: 10));

    // Ultima serie dell'ultimo esercizio: riepilogo finale.
    expect(find.text('Allenamento completato'), findsOneWidget);
    expect(find.text('2'), findsWidgets); // completati: A e B
    expect(find.text('0'), findsOneWidget); // saltati: nessuno

    await disposeCleanly(tester);
  });

  testWidgets(
    'il tasto Indietro durante la sessione mostra il dialog di conferma',
    (tester) async {
      await _seedReadyWorkout(database, name: 'Scheda test', count: 2);
      await _pumpApp(tester, database);
      await _openDetail(tester, 'Scheda test');

      await tester.tap(find.widgetWithText(FilledButton, 'Inizia allenamento'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Indietro'));
      await tester.pumpAndSettle();

      expect(find.text('Vuoi uscire dall\'allenamento?'), findsOneWidget);
      expect(
        find.text('I progressi della sessione corrente non verranno salvati.'),
        findsOneWidget,
      );

      // "Continua allenamento": resta sulla sessione, che è ancora attiva.
      await tester.tap(find.widgetWithText(TextButton, 'Continua allenamento'));
      await tester.pumpAndSettle();
      expect(find.text('Esercizio 1 di 2'), findsOneWidget);

      // Back di nuovo, questa volta "Esci": abort e torna al dettaglio.
      await tester.tap(find.byTooltip('Indietro'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Esci'));
      await tester.pumpAndSettle();

      expect(find.text('Dettaglio scheda'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Inizia allenamento'),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    },
  );

  testWidgets('workout senza esercizi o non pronto: "Inizia allenamento" non è '
      'disponibile e non può avviare nulla', (tester) async {
    await _seedWorkout(database, name: 'Bozza senza esercizi');
    await _pumpApp(tester, database);
    await _openDetail(tester, 'Bozza senza esercizi');

    expect(
      find.widgetWithText(FilledButton, 'Inizia allenamento'),
      findsNothing,
    );
    expect(container(tester).read(workoutSessionControllerProvider), isNull);

    await disposeCleanly(tester);
  });

  testWidgets(
    'sessione già attiva: avviarne un\'altra non la sostituisce, mostra un '
    'messaggio controllato',
    (tester) async {
      final seededA = await _seedReadyWorkout(
        database,
        name: 'Scheda A',
        count: 1,
      );
      final seededB = await _seedReadyWorkout(
        database,
        name: 'Scheda B',
        count: 1,
      );

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);

      // Precondizione: la sessione di B è già attiva (equivalente ad averla
      // avviata in un momento precedente). Impostata direttamente sul
      // controller, senza passare dalla UI: qui interessa solo il
      // comportamento del dialog quando si tenta di avviarne un'altra.
      final detailsB = await container
          .read(workoutRepositoryProvider)
          .getWorkoutDetails(seededB.workoutId);
      await container
          .read(workoutSessionControllerProvider.notifier)
          .startSession(detailsB!);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ForgeApp(),
        ),
      );
      await tester.pumpAndSettle();

      await _openDetail(tester, 'Scheda A');
      await tester.tap(find.widgetWithText(FilledButton, 'Inizia allenamento'));
      await tester.pumpAndSettle();

      expect(find.text('Allenamento già in corso'), findsOneWidget);
      // Non ha sostituito la sessione attiva, che resta quella di B.
      expect(
        container.read(workoutSessionControllerProvider)!.workoutId,
        seededB.workoutId,
      );
      expect(seededA.workoutId, isNot(seededB.workoutId));

      await tester.tap(
        find.widgetWithText(FilledButton, 'Vai alla sessione attiva'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Scheda B'), findsWidgets);

      await disposeCleanly(tester);
    },
  );
}

ProviderContainer container(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return ProviderScope.containerOf(context);
}
