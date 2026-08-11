import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/data/repositories/walking_session_providers.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/entities/walking_statistics_period.dart';
import 'package:forge/features/walking/application/walking_statistics_providers.dart';

import '../features/walking_test_helpers.dart';

void main() {
  test('provider ricalcola quando cambia periodo senza mutare il DB', () async {
    final clock = FakeWalkingClock(DateTime(2026, 8, 10, 12));
    final repository = FakeWalkingSessionRepository();
    repository.seed(
      startedAt: DateTime(2026, 8, 9, 10),
      status: WalkingSessionStatus.completed,
    );
    repository.seed(
      startedAt: DateTime(2026, 7, 1, 10),
      status: WalkingSessionStatus.aborted,
    );
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        walkingSessionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(walkingStatisticsHistoryProvider(1).future);
    var statistics = container.read(walkingStatisticsProvider(1)).value!;
    expect(statistics.totalSessions, 1);

    container.read(walkingStatisticsPeriodProvider.notifier).state =
        WalkingStatisticsPeriod.allTime;
    await container.read(walkingStatisticsHistoryProvider(1).future);
    statistics = container.read(walkingStatisticsProvider(1)).value!;
    expect(statistics.totalSessions, 2);
    expect(repository.sessions, hasLength(2));
  });
}
