import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/data/repositories/repository_providers.dart';
import 'package:forge/data/repositories/walking_session_providers.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/features/walking/presentation/pages/walking_history_detail_page.dart';
import 'package:forge/features/walking/presentation/pages/walking_history_page.dart';
import 'package:forge/core/utils/italian_date_formatter.dart';

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
  bool largeText = false,
  bool detail = false,
  int detailId = 1,
}) {
  final router = GoRouter(
    initialLocation: detail ? '/walking/history/$detailId' : '/walking/history',
    routes: [
      GoRoute(
        path: '/walking/history',
        builder: (context, state) => const WalkingHistoryPage(),
      ),
      GoRoute(
        path: '/walking/history/:id',
        builder: (context, state) => WalkingHistoryDetailPage(
          sessionId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
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

WalkingSession _terminal(
  FakeWalkingSessionRepository repository, {
  required WalkingSessionStatus status,
  int? distanceMeters,
  int? steps,
  int pauseSeconds = 0,
  String? notes,
}) {
  final session = repository.seed(
    status: status,
    distanceMeters: distanceMeters,
    steps: steps,
    accumulatedPauseSeconds: pauseSeconds,
    notes: notes,
  );
  final endedAt = session.startedAt.add(const Duration(minutes: 30));
  final updated = session.copyWith(endedAt: () => endedAt);
  repository.sessions[session.id!] = updated;
  return updated;
}

void main() {
  testWidgets('lista mostra filtri, stato, metriche e ignora attive', (
    tester,
  ) async {
    final repository = FakeWalkingSessionRepository();
    _terminal(
      repository,
      status: WalkingSessionStatus.completed,
      distanceMeters: 3500,
      steps: 4200,
    );
    _terminal(repository, status: WalkingSessionStatus.aborted, steps: 1500);
    repository.seed();

    await tester.pumpWidget(_app(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Storico camminate'), findsOneWidget);
    expect(find.text('Tutti'), findsOneWidget);
    expect(find.text('Completati'), findsOneWidget);
    expect(find.text('Interrotti'), findsOneWidget);
    expect(find.text('2 camminate'), findsOneWidget);
    expect(find.text('Completata'), findsOneWidget);
    expect(find.text('Interrotta'), findsOneWidget);
    expect(find.text('3,5 km · 4.200 passi'), findsOneWidget);
    expect(find.text('1.500 passi'), findsOneWidget);
    expect(find.text('1.500 passi'), findsOneWidget);
    expect(find.text('In corso'), findsNothing);

    await tester.tap(find.text('Interrotti'));
    await tester.pumpAndSettle();
    expect(find.text('1 camminata'), findsOneWidget);
    expect(find.text('1.500 passi'), findsOneWidget);
    expect(find.text('3,5 km · 4.200 passi'), findsNothing);
  });

  testWidgets('tap card apre dettaglio con durata, pausa, metriche e note', (
    tester,
  ) async {
    final repository = FakeWalkingSessionRepository();
    final session = _terminal(
      repository,
      status: WalkingSessionStatus.completed,
      distanceMeters: 3500,
      steps: 4200,
      pauseSeconds: 300,
      notes: 'Passeggiata al parco',
    );
    await tester.pumpWidget(_app(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camminata — Completata'));
    await tester.pumpAndSettle();

    expect(find.text('Dettaglio camminata'), findsOneWidget);
    expect(find.text('Completata'), findsOneWidget);
    expect(find.text('Tempo attivo'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Durata totale'), findsOneWidget);
    expect(find.text('30:00'), findsOneWidget);
    expect(find.text('Tempo in pausa'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget);
    expect(find.text('3,5 km'), findsOneWidget);
    expect(find.text('4.200 passi'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('Passeggiata al parco'), findsOneWidget);
    expect(find.text(formatItalianDate(session.startedAt)), findsOneWidget);
  });

  testWidgets('null e zero restano distinti e le note vuote sono omesse', (
    tester,
  ) async {
    final repository = FakeWalkingSessionRepository();
    final zero = _terminal(
      repository,
      status: WalkingSessionStatus.aborted,
      distanceMeters: 0,
      steps: 0,
      notes: '   ',
    );
    await tester.pumpWidget(
      _app(repository: repository, detail: true, detailId: zero.id!),
    );
    await tester.pumpAndSettle();
    expect(find.text('0 m'), findsOneWidget);
    expect(find.text('0 passi'), findsOneWidget);
    expect(find.text('Note'), findsNothing);
  });

  testWidgets('lista e dettaglio non overflowano su schermo piccolo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeWalkingSessionRepository();
    final session = _terminal(
      repository,
      status: WalkingSessionStatus.aborted,
      distanceMeters: 850,
      steps: 4200,
    );
    await tester.pumpWidget(_app(repository: repository));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Camminata — Interrotta'));
    await tester.pumpAndSettle();
    expect(find.text('Dettaglio camminata'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(session.id, isNotNull);
  });

  testWidgets('testo grande non causa crash nel dettaglio', (tester) async {
    final repository = FakeWalkingSessionRepository();
    final session = _terminal(
      repository,
      status: WalkingSessionStatus.completed,
      notes: 'Nota lunga per il dettaglio',
    );
    await tester.pumpWidget(
      _app(
        repository: repository,
        largeText: true,
        detail: true,
        detailId: session.id!,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('record terminale legacy senza data fine non causa crash', (
    tester,
  ) async {
    final repository = FakeWalkingSessionRepository();
    final session = _terminal(
      repository,
      status: WalkingSessionStatus.completed,
      distanceMeters: 100000,
      steps: 150000,
    );
    repository.sessions[session.id!] = session.copyWith(endedAt: () => null);

    await tester.pumpWidget(
      _app(repository: repository, detail: true, detailId: session.id!),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dettaglio camminata'), findsOneWidget);
    expect(find.text('Ora fine'), findsNothing);
    expect(find.text('Tempo attivo'), findsNothing);
    expect(find.text('100,0 km'), findsOneWidget);
    expect(find.text('150.000 passi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contenuti lunghi e metriche grandi restano scrollabili', (
    tester,
  ) async {
    final repository = FakeWalkingSessionRepository();
    final session = _terminal(
      repository,
      status: WalkingSessionStatus.aborted,
      distanceMeters: 100000,
      steps: 150000,
      notes: List.filled(80, 'Nota lunga della camminata').join(' '),
    );
    await tester.pumpWidget(
      _app(repository: repository, detail: true, detailId: session.id!),
    );
    await tester.pumpAndSettle();
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('100,0 km'), findsOneWidget);
    expect(find.text('150.000 passi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
