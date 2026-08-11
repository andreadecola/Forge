import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/data/repositories/repository_providers.dart';
import 'package:forge/data/repositories/walking_session_providers.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/features/walking/presentation/pages/walking_statistics_page.dart';
import 'package:forge/features/walking/presentation/widgets/walking_activity_chart.dart';

import 'walking_test_helpers.dart';

final _profile = UserProfile(
  id: 1,
  name: 'Alex',
  birthDate: DateTime(1990, 1, 1),
  heightCm: 175,
  initialWeightKg: 80,
  preferredWalkMinutes: 30,
  equipmentBudgetLimit: 50,
  startDate: DateTime(2026, 1, 1),
);

Widget _app({
  required FakeWalkingSessionRepository repository,
  required FakeWalkingClock clock,
  bool largeText = false,
}) {
  final router = GoRouter(
    initialLocation: '/walking/statistics',
    routes: [
      GoRoute(
        path: '/walking/statistics',
        builder: (context, state) => const WalkingStatisticsPage(),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(clock),
      walkingSessionRepositoryProvider.overrideWithValue(repository),
      currentProfileProvider.overrideWith((ref) => Stream.value(_profile)),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => largeText
          ? MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            )
          : child!,
    ),
  );
}

WalkingSessionStatus _seedTerminal(
  FakeWalkingSessionRepository repository, {
  required WalkingSessionStatus status,
  required DateTime startedAt,
  required Duration duration,
  int? distanceMeters,
  int? steps,
  int pauseSeconds = 0,
}) {
  final session = repository.seed(
    status: status,
    startedAt: startedAt,
    distanceMeters: distanceMeters,
    steps: steps,
    accumulatedPauseSeconds: pauseSeconds,
  );
  repository.sessions[session.id!] = session.copyWith(
    endedAt: () => startedAt.add(duration),
  );
  return status;
}

void main() {
  testWidgets('empty state per periodo senza sessioni', (tester) async {
    final repository = FakeWalkingSessionRepository();
    final clock = FakeWalkingClock(DateTime(2026, 8, 10, 12));
    await tester.pumpWidget(_app(repository: repository, clock: clock));
    await tester.pumpAndSettle();
    expect(find.text('Statistiche camminate'), findsOneWidget);
    expect(
      find.text('Nessuna camminata nel periodo selezionato.'),
      findsOneWidget,
    );
  });

  testWidgets('KPI, tempi, metriche, medie, chart e cambio periodo', (
    tester,
  ) async {
    final repository = FakeWalkingSessionRepository();
    final clock = FakeWalkingClock(DateTime(2026, 8, 10, 12));
    _seedTerminal(
      repository,
      status: WalkingSessionStatus.completed,
      startedAt: DateTime(2026, 8, 10, 9),
      duration: const Duration(minutes: 30),
      pauseSeconds: 300,
      distanceMeters: 3500,
      steps: 4200,
    );
    _seedTerminal(
      repository,
      status: WalkingSessionStatus.aborted,
      startedAt: DateTime(2026, 8, 10, 11),
      duration: const Duration(minutes: 20),
      steps: 1500,
    );
    repository.seed(startedAt: DateTime(2026, 8, 10, 12));

    await tester.pumpWidget(_app(repository: repository, clock: clock));
    await tester.pumpAndSettle();
    expect(find.text('45 min'), findsOneWidget);
    expect(find.text('3,5 km'), findsOneWidget);
    expect(find.text('1 di 2 camminate'), findsOneWidget);
    expect(find.text('2'), findsWidgets);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Completate'), findsOneWidget);
    expect(find.text('Interrotte'), findsOneWidget);
    expect(find.text('50 min'), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('5.700 passi'), findsOneWidget);
    expect(find.text('Attività'), findsOneWidget);
    expect(find.byType(WalkingActivityChart), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '7 giorni'));
    await tester.pumpAndSettle();
    expect(find.text('45 min'), findsOneWidget);
  });

  testWidgets('metriche completamente assenti non diventano zeri', (
    tester,
  ) async {
    final repository = FakeWalkingSessionRepository();
    final clock = FakeWalkingClock(DateTime(2026, 8, 10, 12));
    _seedTerminal(
      repository,
      status: WalkingSessionStatus.completed,
      startedAt: DateTime(2026, 8, 10, 9),
      duration: const Duration(minutes: 10),
    );
    await tester.pumpWidget(_app(repository: repository, clock: clock));
    await tester.pumpAndSettle();
    expect(find.text('Nessun dato'), findsOneWidget);
    expect(find.text('0 km'), findsNothing);
    expect(find.text('0 passi'), findsNothing);
  });

  testWidgets('320x480 e testo grande non causano overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeWalkingSessionRepository();
    final clock = FakeWalkingClock(DateTime(2026, 8, 10, 12));
    _seedTerminal(
      repository,
      status: WalkingSessionStatus.aborted,
      startedAt: DateTime(2026, 8, 10, 9),
      duration: const Duration(minutes: 10),
      steps: 4200,
    );
    await tester.pumpWidget(
      _app(repository: repository, clock: clock, largeText: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('Statistiche camminate'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
