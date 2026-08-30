import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/data/repositories/repository_providers.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/data/repositories/workout_providers.dart';
import 'package:forge/domain/repositories/planned_activity_repository.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/domain/use_cases/add_planned_activity.dart';
import 'package:forge/domain/use_cases/postpone_planned_activity.dart';
import 'package:forge/domain/use_cases/skip_planned_activity.dart';
import 'package:forge/features/training_plan/application/workout_session_controller.dart';

import 'exercise_test_fixtures.dart';

/// Test widget della sezione "Oggi" in Dashboard (Milestone 8.3): mostra le
/// `PlannedActivity` della data corrente, con azioni "Avvia" che riusano i
/// flussi reali M4/M6 senza creare alcun collegamento persistente col piano
/// (quello è M8.5).
///
/// `fixedNow` è lo stesso mercoledì (2026-08-26) già usato in
/// `weekly_plan_page_test.dart` (Milestone 8.2).
void main() {
  final fixedNow = DateTime(2026, 8, 26, 12);

  late AppDatabase database;
  late int profileId;

  setUp(() async {
    database = memoryDatabase();
    await seedAppWith(database);
    profileId = (await ProfileRepositoryImpl(
      database.userProfileDao,
    ).getCurrentProfile())!.id!;
  });

  tearDown(() => database.close());

  Future<int> createWorkout(
    String name, {
    bool ready = true,
    int exerciseCount = 1,
  }) async {
    final repo = DriftWorkoutRepository(database);
    final workoutId = await repo.createWorkout(
      Workout(
        profileId: profileId,
        name: name,
        type: WorkoutType.fullBody,
        level: 1,
        status: WorkoutDefinitionStatus.draft,
        origin: WorkoutOrigin.user,
      ),
    );
    if (exerciseCount > 0) {
      final exerciseId = (await database.eserciziDao.getByCode(
        'EX-AVAILABLE',
      ))!.id;
      for (var i = 0; i < exerciseCount; i++) {
        await repo.addExercise(
          workoutId: workoutId,
          exercise: WorkoutExercise(
            workoutId: workoutId,
            exerciseId: exerciseId,
            order: i + 1,
            sets: 1,
            repetitions: 10,
          ),
        );
      }
    }
    if (ready) {
      final workout = (await repo.getWorkoutById(workoutId))!;
      await repo.updateWorkout(
        workout.copyWith(status: WorkoutDefinitionStatus.ready),
      );
    }
    return workoutId;
  }

  Future<int> addPlannedActivity({
    required DateTime scheduledDate,
    required PlannedActivityType type,
    int? workoutId,
    int? plannedDurationMinutes,
  }) {
    final repository = DriftPlannedActivityRepository(
      database.attivitaPianificateDao,
    );
    return AddPlannedActivity(repository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: scheduledDate,
        type: type,
        workoutId: workoutId,
        plannedDurationMinutes: plannedDurationMinutes,
        origin: PlannedActivityOrigin.user,
      ),
    );
  }

  Future<void> pumpDashboard(
    WidgetTester tester, {
    DateTime? now,
    List<Override> extraOverrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          clockProvider.overrideWithValue(_FixedClock(now ?? fixedNow)),
          ...extraOverrides,
        ],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Simula un riavvio reale dell'app: `pumpWidget` da solo aggiorna
  /// l'albero esistente invece di ricrearlo (stesso `runtimeType`/`key` di
  /// `ForgeApp`/`ProviderScope`), quindi router e controller in memoria
  /// resterebbero quelli precedenti. Smontare prima con un widget di tipo
  /// diverso forza un vero dispose/remount: solo lo stato persistito su DB
  /// sopravvive, esattamente come dopo un riavvio reale.
  Future<void> restartDashboard(WidgetTester tester, {DateTime? now}) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpDashboard(tester, now: now);
  }

  Finder todayCardFinder() => find.ancestor(
    of: find.textContaining('Oggi — '),
    matching: find.byType(Card),
  );

  /// Ogni test che la usa ha esattamente un'attività con pulsante "Avvia"
  /// visibile: nessuna ambiguità nel trovarlo senza ulteriore scoping.
  Future<void> tapAvvia(WidgetTester tester) async {
    tester
        .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Avvia'))
        .onPressed!();
    await tester.pumpAndSettle();
  }

  testWidgets('nessuna attività pianificata oggi mostra lo stato vuoto', (
    tester,
  ) async {
    await pumpDashboard(tester);

    expect(find.textContaining('Oggi — 26 agosto 2026'), findsOneWidget);
    expect(find.text('Nessuna attività pianificata per oggi.'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('attività WORKOUT pianificata oggi mostra il nome reale della '
      'scheda', (tester) async {
    final workoutId = await createWorkout('Scheda gambe');
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 26),
      type: PlannedActivityType.workout,
      workoutId: workoutId,
    );

    await pumpDashboard(tester);

    expect(
      find.descendant(
        of: todayCardFinder(),
        matching: find.text('Allenamento'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: todayCardFinder(),
        matching: find.text('Scheda gambe'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: todayCardFinder(),
        matching: find.widgetWithText(OutlinedButton, 'Avvia'),
      ),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('attività WALK pianificata oggi mostra la durata pianificata', (
    tester,
  ) async {
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 26),
      type: PlannedActivityType.walk,
      plannedDurationMinutes: 40,
    );

    await pumpDashboard(tester);

    expect(
      find.descendant(of: todayCardFinder(), matching: find.text('Camminata')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: todayCardFinder(), matching: find.text('40 min')),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('attività WALK senza durata mostra testo neutro', (tester) async {
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 26),
      type: PlannedActivityType.walk,
    );

    await pumpDashboard(tester);

    expect(
      find.descendant(
        of: todayCardFinder(),
        matching: find.text('Camminata pianificata'),
      ),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets(
    'attività RECOVERY oggi mostra testo neutro e nessun pulsante Avvia',
    (tester) async {
      await addPlannedActivity(
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.recovery,
      );

      await pumpDashboard(tester);

      expect(
        find.descendant(of: todayCardFinder(), matching: find.text('Recupero')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.text('Giorno di recupero'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.widgetWithText(OutlinedButton, 'Avvia'),
        ),
        findsNothing,
      );

      await disposeCleanly(tester);
    },
  );

  testWidgets('più attività pianificate oggi sono mostrate tutte', (
    tester,
  ) async {
    final workoutId = await createWorkout('Scheda gambe');
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 26),
      type: PlannedActivityType.workout,
      workoutId: workoutId,
    );
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 26),
      type: PlannedActivityType.walk,
      plannedDurationMinutes: 30,
    );
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 26),
      type: PlannedActivityType.recovery,
    );

    await pumpDashboard(tester);

    expect(
      find.descendant(
        of: todayCardFinder(),
        matching: find.text('Allenamento'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: todayCardFinder(), matching: find.text('Camminata')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: todayCardFinder(), matching: find.text('Recupero')),
      findsOneWidget,
    );
    // Ordinamento deterministico ereditato dal repository: creazione ASC
    // (stesso `dataPianificata`, tie-break su id) -> Allenamento, Camminata,
    // Recupero nell'ordine in cui sono stati creati sopra.
    final titles = tester
        .widgetList<Text>(
          find.descendant(of: todayCardFinder(), matching: find.byType(Text)),
        )
        .map((t) => t.data)
        .whereType<String>()
        .where((t) => ['Allenamento', 'Camminata', 'Recupero'].contains(t))
        .toList();
    expect(titles, ['Allenamento', 'Camminata', 'Recupero']);

    await disposeCleanly(tester);
  });

  testWidgets(
    'allenamento eliminato: nessun crash, nessun Avvia, copy corretta',
    (tester) async {
      final workoutId = await createWorkout('Scheda da eliminare');
      await addPlannedActivity(
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.workout,
        workoutId: workoutId,
      );
      await DriftWorkoutRepository(database).deleteWorkout(workoutId);

      await pumpDashboard(tester);
      expect(tester.takeException(), isNull);

      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.text('Allenamento non più disponibile'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.widgetWithText(OutlinedButton, 'Avvia'),
        ),
        findsNothing,
      );

      await disposeCleanly(tester);
    },
  );

  testWidgets('apre il piano settimanale dalla sezione Oggi', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byTooltip('Apri piano settimanale'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Piano settimanale'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('avvia un allenamento pianificato: naviga alla sessione, la '
      'PlannedActivity resta invariata', (tester) async {
    final workoutId = await createWorkout('Scheda gambe');
    final activityId = await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 26),
      type: PlannedActivityType.workout,
      workoutId: workoutId,
    );

    await pumpDashboard(tester);
    await tapAvvia(tester);

    expect(find.textContaining('Esercizio 1 di'), findsOneWidget);

    final repository = DriftPlannedActivityRepository(
      database.attivitaPianificateDao,
    );
    final saved = await repository.getById(activityId);
    expect(saved!.status, PlannedActivityStatus.planned);
    expect(saved.workoutId, workoutId);

    await disposeCleanly(tester);
  });

  testWidgets(
    'sessione allenamento già attiva: mostra il dialog e non la sostituisce',
    (tester) async {
      final workoutIdA = await createWorkout('Scheda A');
      final workoutIdB = await createWorkout('Scheda B');
      await addPlannedActivity(
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.workout,
        workoutId: workoutIdA,
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          clockProvider.overrideWithValue(_FixedClock(fixedNow)),
        ],
      );
      addTearDown(container.dispose);
      final detailsB = await container
          .read(workoutRepositoryProvider)
          .getWorkoutDetails(workoutIdB);
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

      await tapAvvia(tester);

      expect(find.text('Allenamento già in corso'), findsOneWidget);
      expect(
        container.read(workoutSessionControllerProvider)!.workoutId,
        workoutIdB,
      );

      await tester.tap(
        find.widgetWithText(FilledButton, 'Vai alla sessione attiva'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Scheda B'), findsWidgets);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'avvia una camminata pianificata: naviga alla sessione camminata',
    (tester) async {
      await addPlannedActivity(
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.walk,
        plannedDurationMinutes: 30,
      );

      await pumpDashboard(tester);
      await tapAvvia(tester);

      expect(find.widgetWithText(AppBar, 'Camminata'), findsOneWidget);

      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'isolamento profilo: attività di un altro profilo non compare in Oggi',
    (tester) async {
      await addPlannedActivity(
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.recovery,
      );
      // Un secondo profilo, creato dopo, diventa quello "corrente" (id più
      // alto, stesso principio di `weekly_plan_page_test.dart`).
      await ProfileRepositoryImpl(database.userProfileDao).saveProfile(
        UserProfile(
          name: 'Sam',
          birthDate: DateTime(1992, 1, 1),
          heightCm: 170,
          initialWeightKg: 70,
          preferredWalkMinutes: 20,
          equipmentBudgetLimit: 0,
          startDate: DateTime(2026, 1, 1),
        ),
      );

      await pumpDashboard(tester);

      expect(
        find.text('Nessuna attività pianificata per oggi.'),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    },
  );

  testWidgets('un\'attività pianificata per domani non compare oggi', (
    tester,
  ) async {
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 27),
      type: PlannedActivityType.recovery,
    );

    await pumpDashboard(tester);

    expect(find.text('Nessuna attività pianificata per oggi.'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('cross-month: 31 agosto mostra l\'attività pianificata di oggi', (
    tester,
  ) async {
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 31),
      type: PlannedActivityType.recovery,
    );

    await pumpDashboard(tester, now: DateTime(2026, 8, 31, 23, 45));

    expect(find.textContaining('Oggi — 31 agosto 2026'), findsOneWidget);
    expect(
      find.descendant(of: todayCardFinder(), matching: find.text('Recupero')),
      findsOneWidget,
    );

    await disposeCleanly(tester);
  });

  testWidgets('cross-year: 31 dicembre e 1 gennaio restano giorni distinti', (
    tester,
  ) async {
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 12, 31),
      type: PlannedActivityType.recovery,
    );

    await pumpDashboard(tester, now: DateTime(2027, 1, 1, 8));

    expect(find.textContaining('Oggi — 1 gennaio 2027'), findsOneWidget);
    expect(find.text('Nessuna attività pianificata per oggi.'), findsOneWidget);

    await disposeCleanly(tester);
  });

  testWidgets('responsive 320x480: nessun overflow nella sezione Oggi', (
    tester,
  ) async {
    final workoutId = await createWorkout(
      'Scheda con un nome davvero molto lungo per testare il layout',
    );
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 26),
      type: PlannedActivityType.workout,
      workoutId: workoutId,
    );

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 480));
    await pumpDashboard(tester);
    expect(tester.takeException(), isNull);

    await disposeCleanly(tester);
  });

  testWidgets('testo grande (TextScaler 2.0): nessun crash', (tester) async {
    final workoutId = await createWorkout('Scheda gambe');
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 26),
      type: PlannedActivityType.workout,
      workoutId: workoutId,
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            clockProvider.overrideWithValue(_FixedClock(fixedNow)),
          ],
          child: const ForgeApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await disposeCleanly(tester);
  });

  testWidgets('landscape: nessun overflow nella sezione Oggi', (tester) async {
    await addPlannedActivity(
      scheduledDate: DateTime(2026, 8, 26),
      type: PlannedActivityType.walk,
      plannedDurationMinutes: 30,
    );

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(800, 400));
    await pumpDashboard(tester);
    expect(tester.takeException(), isNull);

    await disposeCleanly(tester);
  });

  group('Milestone 8.5: collegamento a sessioni reali', () {
    testWidgets(
      'avvia un allenamento pianificato: il collegamento viene persistito, '
      'un riavvio della Dashboard mostra "Riprendi" e il badge "In corso"',
      (tester) async {
        final workoutId = await createWorkout('Scheda gambe');
        final activityId = await addPlannedActivity(
          scheduledDate: DateTime(2026, 8, 26),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
        );

        await pumpDashboard(tester);
        await tapAvvia(tester);

        final repository = DriftPlannedActivityRepository(
          database.attivitaPianificateDao,
        );
        final linked = await repository.getById(activityId);
        expect(linked!.workoutSessionId, isNotNull);

        await restartDashboard(tester);

        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.text('Scheda gambe · In corso'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.widgetWithText(OutlinedButton, 'Riprendi'),
          ),
          findsOneWidget,
        );

        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Riprendi'),
            )
            .onPressed!();
        await tester.pumpAndSettle();

        expect(find.textContaining('Esercizio 1 di'), findsOneWidget);

        await disposeCleanly(tester);
      },
    );

    testWidgets('sessione allenamento collegata e completata: il badge mostra '
        '"Completata" e il pulsante sparisce', (tester) async {
      final workoutId = await createWorkout('Scheda gambe');
      final activityId = await addPlannedActivity(
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.workout,
        workoutId: workoutId,
      );

      await pumpDashboard(tester);
      await tapAvvia(tester);

      final repository = DriftPlannedActivityRepository(
        database.attivitaPianificateDao,
      );
      final linked = (await repository.getById(activityId))!;
      await DriftWorkoutSessionRepository(database).completeSession(
        sessionId: linked.workoutSessionId!,
        endedAt: DateTime(2026, 8, 26, 13),
      );

      await restartDashboard(tester);

      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.text('Scheda gambe · Completata'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.byType(OutlinedButton),
        ),
        findsNothing,
      );

      await disposeCleanly(tester);
    });

    testWidgets(
      'avvia una camminata pianificata: il collegamento viene persistito, '
      'un riavvio mostra "Riprendi" e naviga direttamente alla sessione',
      (tester) async {
        final activityId = await addPlannedActivity(
          scheduledDate: DateTime(2026, 8, 26),
          type: PlannedActivityType.walk,
          plannedDurationMinutes: 30,
        );

        await pumpDashboard(tester);
        await tapAvvia(tester);

        final repository = DriftPlannedActivityRepository(
          database.attivitaPianificateDao,
        );
        final linked = await repository.getById(activityId);
        expect(linked!.walkingSessionId, isNotNull);

        await restartDashboard(tester);

        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.text('30 min · In corso'),
          ),
          findsOneWidget,
        );

        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Riprendi'),
            )
            .onPressed!();
        await tester.pumpAndSettle();

        expect(find.widgetWithText(AppBar, 'Camminata'), findsOneWidget);

        await disposeCleanly(tester);
      },
    );

    testWidgets(
      'camminata collegata e completata: il badge mostra "Completata"',
      (tester) async {
        final activityId = await addPlannedActivity(
          scheduledDate: DateTime(2026, 8, 26),
          type: PlannedActivityType.walk,
          plannedDurationMinutes: 30,
        );

        await pumpDashboard(tester);
        await tapAvvia(tester);

        final repository = DriftPlannedActivityRepository(
          database.attivitaPianificateDao,
        );
        final linked = (await repository.getById(activityId))!;
        await DriftWalkingSessionRepository(database).completeWalkingSession(
          sessionId: linked.walkingSessionId!,
          endedAt: DateTime(2026, 8, 26, 13),
        );

        await restartDashboard(tester);

        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.text('30 min · Completata'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.byType(OutlinedButton),
          ),
          findsNothing,
        );

        await disposeCleanly(tester);
      },
    );

    testWidgets(
      'sessione spontanea (senza passare da "Oggi") non viene collegata: '
      'nessun matching implicito per workoutId',
      (tester) async {
        final workoutId = await createWorkout('Scheda gambe');
        await addPlannedActivity(
          scheduledDate: DateTime(2026, 8, 26),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
        );

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(database),
            clockProvider.overrideWithValue(_FixedClock(fixedNow)),
          ],
        );
        addTearDown(container.dispose);
        final details = await container
            .read(workoutRepositoryProvider)
            .getWorkoutDetails(workoutId);
        await container
            .read(workoutSessionControllerProvider.notifier)
            .startSession(details!);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const ForgeApp(),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.widgetWithText(OutlinedButton, 'Avvia'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.text('Scheda gambe'),
          ),
          findsOneWidget,
        );

        await disposeCleanly(tester);
      },
    );
  });

  group('Milestone 8.6: saltate/rinviate', () {
    testWidgets('attività WORKOUT saltata oggi: nessun pulsante Avvia, badge '
        '"Saltata"', (tester) async {
      final workoutId = await createWorkout('Scheda gambe');
      final activityId = await addPlannedActivity(
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.workout,
        workoutId: workoutId,
      );
      await SkipPlannedActivity(
        DriftPlannedActivityRepository(database.attivitaPianificateDao),
        DriftWorkoutSessionRepository(database),
        DriftWalkingSessionRepository(database),
      )(activityId);

      await pumpDashboard(tester);

      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.text('Scheda gambe · Saltata'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.byType(OutlinedButton),
        ),
        findsNothing,
      );

      await disposeCleanly(tester);
    });

    testWidgets(
      'attività WALK rinviata oggi: nessun pulsante Avvia, badge "Rinviata"',
      (tester) async {
        final activityId = await addPlannedActivity(
          scheduledDate: DateTime(2026, 8, 26),
          type: PlannedActivityType.walk,
          plannedDurationMinutes: 30,
        );
        await PostponePlannedActivity(
          DriftPlannedActivityRepository(database.attivitaPianificateDao),
          DriftWorkoutSessionRepository(database),
          DriftWalkingSessionRepository(database),
        )(activityId);

        await pumpDashboard(tester);

        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.text('30 min · Rinviata'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.byType(OutlinedButton),
          ),
          findsNothing,
        );

        await disposeCleanly(tester);
      },
    );

    testWidgets('attività WORKOUT saltata: resta Saltata dopo un vero riavvio '
        '(Milestone 8.8)', (tester) async {
      final workoutId = await createWorkout('Scheda gambe');
      final activityId = await addPlannedActivity(
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.workout,
        workoutId: workoutId,
      );
      await SkipPlannedActivity(
        DriftPlannedActivityRepository(database.attivitaPianificateDao),
        DriftWorkoutSessionRepository(database),
        DriftWalkingSessionRepository(database),
      )(activityId);

      await restartDashboard(tester);

      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.text('Scheda gambe · Saltata'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.byType(OutlinedButton),
        ),
        findsNothing,
      );

      await disposeCleanly(tester);
    });

    testWidgets('attività WALK rinviata: resta Rinviata dopo un vero riavvio '
        '(Milestone 8.8)', (tester) async {
      final activityId = await addPlannedActivity(
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.walk,
        plannedDurationMinutes: 30,
      );
      await PostponePlannedActivity(
        DriftPlannedActivityRepository(database.attivitaPianificateDao),
        DriftWorkoutSessionRepository(database),
        DriftWalkingSessionRepository(database),
      )(activityId);

      await restartDashboard(tester);

      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.text('30 min · Rinviata'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: todayCardFinder(),
          matching: find.byType(OutlinedButton),
        ),
        findsNothing,
      );

      await disposeCleanly(tester);
    });
  });

  group('Milestone 8.7 patch: reattività sessioni reali senza riavvio', () {
    testWidgets(
      'sessione Workout completata mentre "Oggi" resta montata: il badge '
      'passa a Completata senza riavvio',
      (tester) async {
        final workoutId = await createWorkout('Scheda gambe');
        final activityId = await addPlannedActivity(
          scheduledDate: DateTime(2026, 8, 26),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
        );
        final repository = DriftPlannedActivityRepository(
          database.attivitaPianificateDao,
        );
        final details = await DriftWorkoutRepository(
          database,
        ).getWorkoutDetails(workoutId);
        final sessionRepository = DriftWorkoutSessionRepository(database);
        final sessionId = await sessionRepository.createSession(
          profileId: profileId,
          details: details!,
          startedAt: DateTime(2026, 8, 26, 8),
        );
        await repository.linkWorkoutSession(
          activityId: activityId,
          workoutSessionId: sessionId,
        );

        await pumpDashboard(tester);

        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.text('Scheda gambe · In corso'),
          ),
          findsOneWidget,
        );

        // Nessun riavvio: la sessione completa "da un'altra parte"
        // dell'app mentre la sezione "Oggi" resta montata.
        await sessionRepository.completeSession(
          sessionId: sessionId,
          endedAt: DateTime(2026, 8, 26, 9),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.text('Scheda gambe · Completata'),
          ),
          findsOneWidget,
        );

        await disposeCleanly(tester);
      },
    );

    testWidgets(
      'sessione Workout abbandonata mentre "Oggi" resta montata: torna '
      'disponibile per un nuovo Avvia, senza riavvio',
      (tester) async {
        final workoutId = await createWorkout('Scheda gambe');
        final activityId = await addPlannedActivity(
          scheduledDate: DateTime(2026, 8, 26),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
        );
        final repository = DriftPlannedActivityRepository(
          database.attivitaPianificateDao,
        );
        final details = await DriftWorkoutRepository(
          database,
        ).getWorkoutDetails(workoutId);
        final sessionRepository = DriftWorkoutSessionRepository(database);
        final sessionId = await sessionRepository.createSession(
          profileId: profileId,
          details: details!,
          startedAt: DateTime(2026, 8, 26, 8),
        );
        await repository.linkWorkoutSession(
          activityId: activityId,
          workoutSessionId: sessionId,
        );

        await pumpDashboard(tester);

        await sessionRepository.abortSession(
          sessionId: sessionId,
          endedAt: DateTime(2026, 8, 26, 9),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: todayCardFinder(),
            matching: find.widgetWithText(OutlinedButton, 'Avvia'),
          ),
          findsOneWidget,
        );

        await disposeCleanly(tester);
      },
    );
  });

  group('Milestone 8.8: hardening finale', () {
    testWidgets('link fallito dopo l\'avvio: la sessione appena creata viene '
        'abbandonata automaticamente, nessuna sessione attiva residua', (
      tester,
    ) async {
      final workoutId = await createWorkout('Scheda gambe');
      await addPlannedActivity(
        scheduledDate: DateTime(2026, 8, 26),
        type: PlannedActivityType.workout,
        workoutId: workoutId,
      );
      final realRepository = DriftPlannedActivityRepository(
        database.attivitaPianificateDao,
      );

      await pumpDashboard(
        tester,
        extraOverrides: [
          plannedActivityRepositoryProvider.overrideWithValue(
            _FailingLinkWorkoutRepository(realRepository),
          ),
        ],
      );

      await tapAvvia(tester);

      expect(
        find.text(
          'Non è stato possibile collegare la sessione al piano. Riprova.',
        ),
        findsOneWidget,
      );
      // Nessuna navigazione alla pagina sessione: resta su "Oggi".
      expect(find.textContaining('Esercizio 1 di'), findsNothing);
      // Compensazione (Milestone 8.5, sezione 16): la sessione appena
      // creata viene abbandonata subito, nessuna sessione attiva
      // orfana resta per il profilo.
      final activeSession = await DriftWorkoutSessionRepository(
        database,
      ).getActiveSession(profileId: profileId);
      expect(activeSession, isNull);

      await disposeCleanly(tester);
    });
  });
}

class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

/// Fake di dominio (Milestone 8.8, sezione 16): delega tutto a un
/// repository reale, tranne `linkWorkoutSession` che fallisce sempre —
/// riproduce deterministicamente il percorso di compensazione già
/// accettato in Milestone 8.5 ("se il link fallisce, abbandona la
/// sessione appena creata"), mai testato prima con un fallimento reale.
class _FailingLinkWorkoutRepository implements PlannedActivityRepository {
  _FailingLinkWorkoutRepository(this._delegate);

  final PlannedActivityRepository _delegate;

  @override
  Future<void> linkWorkoutSession({
    required int activityId,
    required int workoutSessionId,
  }) {
    throw Exception('link fallito (simulato per il test)');
  }

  @override
  Future<PlannedActivity?> getById(int id) => _delegate.getById(id);

  @override
  Future<List<PlannedActivity>> getForWeek({
    required int profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) => _delegate.getForWeek(
    profileId: profileId,
    weekStart: weekStart,
    weekEnd: weekEnd,
  );

  @override
  Stream<List<PlannedActivity>> watchForWeek({
    required int profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) => _delegate.watchForWeek(
    profileId: profileId,
    weekStart: weekStart,
    weekEnd: weekEnd,
  );

  @override
  Future<int> addPlannedActivity(PlannedActivity activity) =>
      _delegate.addPlannedActivity(activity);

  @override
  Future<void> updatePlannedActivity(PlannedActivity activity) =>
      _delegate.updatePlannedActivity(activity);

  @override
  Future<void> deletePlannedActivity(int id) =>
      _delegate.deletePlannedActivity(id);

  @override
  Future<void> linkWalkingSession({
    required int activityId,
    required int walkingSessionId,
  }) => _delegate.linkWalkingSession(
    activityId: activityId,
    walkingSessionId: walkingSessionId,
  );
}
