import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/workout_session_providers.dart';
import '../../../domain/entities/workout_session_history_item.dart';
import '../../../domain/entities/workout_statistics.dart';
import '../../../domain/entities/workout_statistics_period.dart';
import 'workout_statistics_service.dart';

final workoutStatisticsPeriodProvider = StateProvider<WorkoutStatisticsPeriod>(
  (ref) => WorkoutStatisticsPeriod.last30Days,
);

/// Storico limitato al periodo selezionato (Milestone 4.5.2, sezione 40):
/// il repository filtra già `dataInizio >= since` a livello di query, per
/// non dover leggere tutto lo storico solo per mostrare "7 giorni".
final workoutStatisticsHistoryProvider =
    StreamProvider.family<List<WorkoutSessionHistoryItem>, int>((
      ref,
      profileId,
    ) {
      final period = ref.watch(workoutStatisticsPeriodProvider);
      final since = periodStartFor(period, DateTime.now());
      return ref
          .watch(workoutSessionRepositoryProvider)
          .watchSessionHistory(profileId: profileId, since: since);
    });

/// [WorkoutStatisticsService] fa tutto il calcolo: il widget legge solo il
/// risultato già pronto (sezione 38).
final workoutStatisticsProvider =
    Provider.family<AsyncValue<WorkoutStatistics>, int>((ref, profileId) {
      final period = ref.watch(workoutStatisticsPeriodProvider);
      final historyAsync = ref.watch(
        workoutStatisticsHistoryProvider(profileId),
      );
      return historyAsync.whenData(
        (sessions) => const WorkoutStatisticsService().compute(
          sessions: sessions,
          period: period,
          now: DateTime.now(),
        ),
      );
    });
