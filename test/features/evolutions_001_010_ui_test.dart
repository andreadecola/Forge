import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/app.dart';
import 'package:forge/core/routing/app_router.dart';
import 'package:forge/core/routing/app_routes.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/features/notifications/application/notification_providers.dart';
import 'package:forge/features/notifications/domain/local_notification_gateway.dart';
import 'package:forge/features/notifications/domain/pending_local_notification_reader.dart';
import 'package:forge/features/notifications/domain/pending_local_notification.dart';
import 'package:forge/features/notifications/domain/notification_permission_gateway.dart';
import 'package:forge/features/notifications/domain/notification_permission_status.dart';
import 'package:forge/features/notifications/domain/notification_payload.dart';
import 'package:forge/features/notifications/domain/notification_tap_event.dart';
import 'package:forge/features/notifications/domain/scheduled_local_notification.dart';
import 'package:forge/features/training_plan/presentation/widgets/exercise_performance_diary.dart';
import 'package:forge/features/training_plan/presentation/widgets/delete_workout_button.dart';
import 'package:forge/features/walking/presentation/widgets/delete_walking_button.dart';
import 'package:forge/features/progress/presentation/widgets/activity_dashboard_section.dart';
import 'exercise_test_fixtures.dart';

class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 11, 23, 10);
}

class _Gateway
    implements LocalNotificationGateway, PendingLocalNotificationReader {
  @override
  Future<void> initialize({
    required Future<void> Function(NotificationTapEvent) onNotificationTap,
  }) async {}
  @override
  Future<void> schedule(ScheduledLocalNotification notification) async {}
  @override
  Future<void> cancel(int id) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<List<PendingLocalNotification>> pending() async => [];
}

class _Permission implements NotificationPermissionGateway {
  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async =>
      NotificationPermissionStatus.granted;
  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.granted;
}

void main() {
  late AppDatabase db;
  late int profileId, exerciseId;
  late DriftWorkoutRepository workouts;
  late DriftWorkoutSessionRepository sessions;
  setUp(() async {
    db = memoryDatabase();
    await seedAppWith(db);
    profileId = (await ProfileRepositoryImpl(
      db.userProfileDao,
    ).getCurrentProfile())!.id!;
    exerciseId = (await db.select(db.eserciziTable).get()).first.id;
    workouts = DriftWorkoutRepository(db);
    sessions = DriftWorkoutSessionRepository(db);
  });
  tearDown(() => db.close());

  Future<int> createWorkout() => workouts.createWorkoutWithExercises(
    workout: Workout(
      profileId: profileId,
      name: 'Scheda da collaudare',
      type: WorkoutType.fullBody,
      status: WorkoutDefinitionStatus.ready,
      origin: WorkoutOrigin.user,
    ),
    exercises: [
      WorkoutExercise(
        workoutId: 0,
        exerciseId: exerciseId,
        order: 1,
        sets: 2,
        repetitions: 10,
        restSeconds: 30,
      ),
    ],
  );
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool app = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(_Clock()),
          notificationGatewayProvider.overrideWithValue(_Gateway()),
          notificationPermissionGatewayProvider.overrideWithValue(
            _Permission(),
          ),
        ],
        child: app
            ? child
            : MaterialApp(
                home: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'EVO-001 annullamento conserva la camminata, conferma aggiorna dashboard',
    (tester) async {
      final repo = DriftWalkingSessionRepository(db);
      final id = await repo.createWalkingSession(
        WalkingSession(
          profileId: profileId,
          startedAt: _Clock().now(),
          endedAt: _Clock().now().add(const Duration(minutes: 20)),
          status: WalkingSessionStatus.completed,
          steps: 1000,
        ),
      );
      await pump(
        tester,
        Column(
          children: [
            DeleteWalkingButton(sessionId: id, profileId: profileId),
            ActivityDashboardSection(profileId: profileId),
          ],
        ),
      );
      expect(find.text('Camminate completate: 1'), findsOneWidget);
      await tap(tester, find.byTooltip('Elimina camminata'));
      await tap(tester, find.text('Annulla'));
      expect(await repo.getWalkingSession(id), isNotNull);
      await tap(tester, find.byTooltip('Elimina camminata'));
      await tap(tester, find.widgetWithText(FilledButton, 'Elimina'));
      expect(await repo.getWalkingSession(id), isNull);
      expect(find.text('Camminate completate: 0'), findsOneWidget);
      expect(find.text('Passi registrati: Non disponibili'), findsOneWidget);
      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'EVO-002 conferma esplicita, sessione attiva protetta e poi eliminazione',
    (tester) async {
      final id = await createWorkout();
      final workout = (await workouts.getWorkoutById(id))!;
      final sessionId = await sessions.createSession(
        profileId: profileId,
        details: (await workouts.getWorkoutDetails(id))!,
        startedAt: _Clock().now(),
      );
      await pump(tester, DeleteWorkoutButton(workout: workout));
      await tap(tester, find.byTooltip('Elimina definitivamente'));
      await tap(tester, find.text('Annulla'));
      expect(await workouts.getWorkoutById(id), isNotNull);
      await tap(tester, find.byTooltip('Elimina definitivamente'));
      await tap(tester, find.widgetWithText(FilledButton, 'Elimina'));
      expect(find.textContaining('Termina la sessione attiva'), findsOneWidget);
      await sessions.completeSession(
        sessionId: sessionId,
        endedAt: _Clock().now().add(const Duration(minutes: 10)),
      );
      await tap(tester, find.byTooltip('Elimina definitivamente'));
      await tap(tester, find.widgetWithText(FilledButton, 'Elimina'));
      expect(await workouts.getWorkoutById(id), isNull);
      expect(await sessions.getSessionHistoryDetails(sessionId), isNotNull);
      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'EVO-009 form diario a 320x480 salva, rilegge e modifica valori effettivi',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final id = await createWorkout();
      final sessionId = await sessions.createSession(
        profileId: profileId,
        details: (await workouts.getWorkoutDetails(id))!,
        startedAt: _Clock().now(),
      );
      Widget diary() => ExercisePerformanceDiary(
        sessionId: sessionId,
        order: 1,
        exerciseId: exerciseId,
        totalSets: 2,
        timed: false,
      );
      await pump(tester, diary());
      await tap(tester, find.text('Diario prestazioni'));
      await tap(tester, find.text('Registra prestazione'));
      await tester.enterText(
        find.widgetWithText(TextField, 'Ripetizioni effettive'),
        '8',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Carico utilizzato (kg, facoltativo)'),
        '2,5',
      );
      await tester.enterText(
        find.widgetWithText(
          TextField,
          'Difficoltà percepita (1–10, facoltativa)',
        ),
        '7',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tap(tester, find.widgetWithText(FilledButton, 'Salva prestazione'));
      expect(
        find.text('Serie 1: 8 rip. · 2.5 kg · difficoltà 7/10'),
        findsOneWidget,
      );
      expect(
        (await sessions.getSessionExercises(sessionId)).single.repetitions,
        10,
      );
      await disposeCleanly(tester);
      await pump(tester, diary());
      await tap(tester, find.text('Diario prestazioni'));
      await tap(tester, find.text('Registra prestazione'));
      expect(
        tester
            .widget<TextField>(
              find.widgetWithText(TextField, 'Ripetizioni effettive'),
            )
            .controller!
            .text,
        '8',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Ripetizioni effettive'),
        '9',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tap(tester, find.widgetWithText(FilledButton, 'Salva prestazione'));
      expect(
        (await sessions.getSessionExercises(
          sessionId,
        )).single.performedSets.single.repetitions,
        9,
      );
      expect(tester.takeException(), isNull);
      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'EVO-001/002 eliminazione dai dettagli torna allo storico o alle schede',
    (tester) async {
      final walking = DriftWalkingSessionRepository(db);
      final walkId = await walking.createWalkingSession(
        WalkingSession(
          profileId: profileId,
          startedAt: _Clock().now(),
          endedAt: _Clock().now(),
          status: WalkingSessionStatus.completed,
        ),
      );
      final workoutId = await createWorkout();
      await pump(tester, const ForgeApp(), app: true);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      final router = container.read(appRouterProvider);
      router.go(AppRoutes.walkingHistoryDetailPath(walkId));
      await tester.pumpAndSettle();
      await tap(tester, find.byTooltip('Elimina camminata'));
      await tap(tester, find.widgetWithText(FilledButton, 'Elimina'));
      expect(find.text('Storico camminate'), findsOneWidget);
      expect(find.text('Nessuna camminata nello storico.'), findsOneWidget);
      router.go(AppRoutes.workoutDetailPath(workoutId));
      await tester.pumpAndSettle();
      await tap(tester, find.byTooltip('Elimina definitivamente'));
      await tap(tester, find.widgetWithText(FilledButton, 'Elimina'));
      expect(find.text('I tuoi allenamenti'), findsOneWidget);
      expect(await workouts.getWorkoutById(workoutId), isNull);
      expect(tester.takeException(), isNull);
      await disposeCleanly(tester);
    },
  );

  testWidgets(
    'EVO-003 notifica apre attività specifica senza avvio automatico',
    (tester) async {
      final workoutId = await createWorkout();
      final repo = DriftPlannedActivityRepository(db.attivitaPianificateDao);
      final id = await repo.addPlannedActivity(
        PlannedActivity(
          profileId: profileId,
          scheduledDate: DateTime(2026, 11, 23),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
          origin: PlannedActivityOrigin.user,
        ),
      );
      await pump(tester, const ForgeApp(), app: true);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      container
          .read(notificationTapEventBusProvider)
          .emit(
            NotificationTapEvent(
              rawPayload: null,
              payload: NotificationPayload(
                type: 'planned_activity',
                entityId: id,
              ),
            ),
          );
      await tester.pumpAndSettle();
      expect(find.text('Attività pianificata'), findsOneWidget);
      expect(find.text('Scheda da collaudare'), findsOneWidget);
      expect(find.text('Rinvia promemoria'), findsOneWidget);
      expect(await sessions.getActiveSession(profileId: profileId), isNull);
      await tap(tester, find.text('Avvia'));
      expect(await sessions.getActiveSession(profileId: profileId), isNotNull);
      expect((await repo.getById(id))!.workoutSessionId, isNotNull);
      await disposeCleanly(tester);
    },
  );
}
