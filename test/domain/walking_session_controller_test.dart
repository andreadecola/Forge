import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/data/repositories/walking_session_providers.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/features/walking/application/walking_session_controller.dart';

import '../features/walking_test_helpers.dart';

void main() {
  late FakeWalkingClock clock;
  late FakeWalkingSessionRepository repository;
  late ProviderContainer container;

  setUp(() {
    clock = FakeWalkingClock();
    repository = FakeWalkingSessionRepository();
    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        walkingSessionRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() => container.dispose());

  WalkingSessionController controller() =>
      container.read(walkingSessionControllerProvider.notifier);

  test('start crea una sessione e calcola elapsed da timestamp', () async {
    expect(await controller().start(1), isTrue);
    clock.advance(const Duration(seconds: 65));
    final runtime = container.read(walkingSessionControllerProvider)!;
    expect(runtime.elapsedSeconds(clock), 65);
    expect(repository.sessions, hasLength(1));
    expect(
      repository.sessions.values.single.status,
      WalkingSessionStatus.inProgress,
    );
  });

  test('double start crea una sola sessione', () async {
    expect(await controller().start(1), isTrue);
    expect(await controller().start(1), isFalse);
    expect(repository.sessions, hasLength(1));
  });

  test(
    'active existing viene adottata invece di crearne una seconda',
    () async {
      final active = repository.seed();
      expect(await controller().start(1), isFalse);
      expect(
        container.read(walkingSessionControllerProvider)!.sessionId,
        active.id,
      );
      expect(repository.sessions, hasLength(1));
    },
  );

  test('restore active ricostruisce lo stato dopo restart', () async {
    final active = repository.seed(
      startedAt: clock.now(),
      distanceMeters: 2400,
      steps: 3200,
    );
    expect(await controller().restoreActive(1), isTrue);
    clock.advance(const Duration(minutes: 2));
    expect(
      container.read(walkingSessionControllerProvider)!.elapsedSeconds(clock),
      120,
    );
    expect(
      container.read(walkingSessionControllerProvider)!.sessionId,
      active.id,
    );
    expect(
      container.read(walkingSessionControllerProvider)!.distanceMeters,
      2400,
    );
    expect(container.read(walkingSessionControllerProvider)!.steps, 3200);
  });

  test('restore di un altro profilo adotta la sessione corretta', () async {
    await controller().start(1);
    final otherProfileSession = repository.seed(profileId: 2);

    expect(await controller().restoreActive(2), isTrue);
    final runtime = container.read(walkingSessionControllerProvider)!;
    expect(runtime.profileId, 2);
    expect(runtime.sessionId, otherProfileSession.id);
  });

  test(
    'restore di un profilo senza attiva non conserva stato obsoleto',
    () async {
      await controller().start(1);

      expect(await controller().restoreActive(2), isFalse);
      expect(container.read(walkingSessionControllerProvider), isNull);
    },
  );

  test('pause/resume mantiene il tempo cronologico', () async {
    await controller().start(1);
    clock.advance(const Duration(seconds: 30));
    expect(await controller().pause(), isTrue);
    expect(container.read(walkingSessionControllerProvider)!.isPaused, isTrue);
    clock.advance(const Duration(seconds: 30));
    expect(
      container.read(walkingSessionControllerProvider)!.elapsedSeconds(clock),
      60,
    );
    expect(
      container.read(walkingSessionControllerProvider)!.activeSeconds(clock),
      30,
    );
    expect(await controller().pause(), isFalse);
    expect(await controller().resume(), isTrue);
    expect(container.read(walkingSessionControllerProvider)!.isPaused, isFalse);
    expect(await controller().resume(), isFalse);
  });

  test(
    'complete e abort mentre in pausa chiudono lo stato correttamente',
    () async {
      await controller().start(1);
      clock.advance(const Duration(minutes: 20));
      await controller().pause();
      clock.advance(const Duration(minutes: 10));
      expect(await controller().complete(), isTrue);
      var runtime = container.read(walkingSessionControllerProvider)!;
      expect(runtime.status, WalkingSessionStatus.completed);
      expect(runtime.isPaused, isFalse);
      expect(runtime.accumulatedPauseSeconds, 600);

      controller().clear();
      await controller().start(1);
      clock.advance(const Duration(minutes: 20));
      await controller().pause();
      clock.advance(const Duration(minutes: 5));
      expect(await controller().abort(), isTrue);
      runtime = container.read(walkingSessionControllerProvider)!;
      expect(runtime.status, WalkingSessionStatus.aborted);
      expect(runtime.isPaused, isFalse);
      expect(runtime.accumulatedPauseSeconds, 300);
    },
  );

  test(
    'restore ricostruisce una pausa persistita dopo restart provider',
    () async {
      await controller().start(1);
      clock.advance(const Duration(minutes: 20));
      await controller().pause();
      clock.advance(const Duration(minutes: 10));
      container.dispose();
      container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          walkingSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );

      expect(
        await container
            .read(walkingSessionControllerProvider.notifier)
            .restoreActive(1),
        isTrue,
      );
      final runtime = container.read(walkingSessionControllerProvider)!;
      expect(runtime.isPaused, isTrue);
      expect(runtime.chronologicalSeconds(clock), 1800);
      expect(runtime.pauseSeconds(clock), 600);
      expect(runtime.activeSeconds(clock), 1200);
    },
  );

  test('complete è terminale e aggiorna il repository', () async {
    await controller().start(1);
    clock.advance(const Duration(minutes: 3));
    expect(await controller().complete(), isTrue);
    expect(
      container.read(walkingSessionControllerProvider)!.status,
      WalkingSessionStatus.completed,
    );
    expect(await controller().complete(), isFalse);
    expect(
      repository.sessions.values.single.status,
      WalkingSessionStatus.completed,
    );
  });

  test('abort è terminale e complete dopo abort è ignorato', () async {
    await controller().start(1);
    expect(await controller().abort(), isTrue);
    expect(
      container.read(walkingSessionControllerProvider)!.status,
      WalkingSessionStatus.aborted,
    );
    expect(await controller().complete(), isFalse);
    expect(
      repository.sessions.values.single.status,
      WalkingSessionStatus.aborted,
    );
  });

  test('uscire dalla pagina non equivale ad abortire la sessione', () async {
    await controller().start(1);
    final before = container.read(walkingSessionControllerProvider);
    controller().clear();
    expect(
      repository.sessions.values.single.status,
      WalkingSessionStatus.inProgress,
    );
    expect(before!.status, WalkingSessionStatus.inProgress);
  });

  test(
    'update metrics aggiorna runtime e consente modifica post-complete',
    () async {
      await controller().start(1);
      expect(
        await controller().updateMetrics(distanceMeters: 2400, steps: 3200),
        isTrue,
      );
      var runtime = container.read(walkingSessionControllerProvider)!;
      expect(runtime.distanceMeters, 2400);
      expect(runtime.steps, 3200);

      await controller().complete();
      expect(
        await controller().updateMetrics(distanceMeters: 2600, steps: 3400),
        isTrue,
      );
      runtime = container.read(walkingSessionControllerProvider)!;
      expect(runtime.status, WalkingSessionStatus.completed);
      expect(runtime.distanceMeters, 2600);
      expect(runtime.steps, 3400);
      expect(repository.sessions.values.single.distanceMeters, 2600);
    },
  );

  test('errore repository non altera lo stato runtime', () async {
    await controller().start(1);
    final before = container.read(walkingSessionControllerProvider)!;
    repository.failMetricsUpdate = true;

    expect(
      () => controller().updateMetrics(distanceMeters: 1000, steps: 1000),
      throwsA(isA<StateError>()),
    );
    final after = container.read(walkingSessionControllerProvider)!;
    expect(after.distanceMeters, before.distanceMeters);
    expect(after.steps, before.steps);
    expect(after.status, WalkingSessionStatus.inProgress);
  });
}
