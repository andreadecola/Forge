import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/walking_session.dart';
import '../../domain/repositories/walking_session_repository.dart';
import '../database/database_provider.dart';
import 'drift_walking_session_repository.dart';

final walkingSessionRepositoryProvider = Provider<WalkingSessionRepository>((
  ref,
) {
  return DriftWalkingSessionRepository(ref.watch(databaseProvider));
});

final walkingSessionProvider = FutureProvider.family<WalkingSession?, int>((
  ref,
  id,
) {
  return ref.watch(walkingSessionRepositoryProvider).getWalkingSession(id);
});

final walkingSessionsProvider =
    FutureProvider.family<List<WalkingSession>, int>((ref, profileId) {
      return ref
          .watch(walkingSessionRepositoryProvider)
          .getWalkingSessions(profileId: profileId);
    });

final walkingHistoryProvider = StreamProvider.family<List<WalkingSession>, int>(
  (ref, profileId) {
    return ref
        .watch(walkingSessionRepositoryProvider)
        .watchWalkingHistory(profileId: profileId);
  },
);

final watchWalkingSessionsProvider =
    StreamProvider.family<List<WalkingSession>, int>((ref, profileId) {
      return ref
          .watch(walkingSessionRepositoryProvider)
          .watchWalkingSessions(profileId: profileId);
    });

final activeWalkingSessionProvider =
    FutureProvider.family<WalkingSession?, int>((ref, profileId) {
      return ref
          .watch(walkingSessionRepositoryProvider)
          .getActiveWalkingSession(profileId: profileId);
    });
