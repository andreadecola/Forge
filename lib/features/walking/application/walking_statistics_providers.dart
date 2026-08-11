import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/forge_providers.dart';
import '../../../data/repositories/walking_session_providers.dart';
import '../../../domain/entities/walking_session.dart';
import '../../../domain/entities/walking_statistics.dart';
import '../../../domain/entities/walking_statistics_period.dart';
import '../../../domain/services/walking_statistics_service.dart';

final walkingStatisticsPeriodProvider = StateProvider<WalkingStatisticsPeriod>(
  (ref) => WalkingStatisticsPeriod.last30Days,
);

final walkingStatisticsHistoryProvider =
    StreamProvider.family<List<WalkingSession>, int>((ref, profileId) {
      final period = ref.watch(walkingStatisticsPeriodProvider);
      final now = ref.watch(clockProvider).now();
      final since = walkingStatisticsPeriodStartFor(period, now);
      return ref
          .watch(walkingSessionRepositoryProvider)
          .watchWalkingHistory(profileId: profileId, since: since);
    });

final walkingStatisticsProvider =
    Provider.family<AsyncValue<WalkingStatistics>, int>((ref, profileId) {
      final period = ref.watch(walkingStatisticsPeriodProvider);
      final now = ref.watch(clockProvider).now();
      final historyAsync = ref.watch(
        walkingStatisticsHistoryProvider(profileId),
      );
      return historyAsync.whenData(
        (sessions) => const WalkingStatisticsService().compute(
          sessions: sessions,
          period: period,
          now: now,
        ),
      );
    });
