import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/walking_session_providers.dart';
import '../../../domain/entities/walking_session.dart';
import '../../../domain/entities/walking_session_status.dart';

enum WalkingHistoryFilter { all, completed, aborted }

List<WalkingSession> filterWalkingHistory(
  Iterable<WalkingSession> sessions,
  WalkingHistoryFilter filter,
) {
  switch (filter) {
    case WalkingHistoryFilter.all:
      return sessions.toList();
    case WalkingHistoryFilter.completed:
      return sessions
          .where((session) => session.status == WalkingSessionStatus.completed)
          .toList();
    case WalkingHistoryFilter.aborted:
      return sessions
          .where((session) => session.status == WalkingSessionStatus.aborted)
          .toList();
  }
}

final walkingHistoryFilterProvider = StateProvider<WalkingHistoryFilter>(
  (ref) => WalkingHistoryFilter.all,
);

final filteredWalkingHistoryProvider =
    Provider.family<AsyncValue<List<WalkingSession>>, int>((ref, profileId) {
      final filter = ref.watch(walkingHistoryFilterProvider);
      final historyAsync = ref.watch(walkingHistoryProvider(profileId));
      return historyAsync.whenData(
        (sessions) => filterWalkingHistory(sessions, filter),
      );
    });

final walkingHistoryDetailsProvider =
    FutureProvider.family<WalkingSession?, int>((ref, sessionId) {
      return ref.watch(walkingSessionProvider(sessionId).future);
    });
