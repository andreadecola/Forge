import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/workout_session_providers.dart';
import '../../../domain/entities/workout_session_history_details.dart';
import '../../../domain/entities/workout_session_history_item.dart';
import '../../../domain/entities/workout_session_persistence_status.dart';

/// Storico sessioni concluse (COMPLETED/ABORTED) del profilo, più recenti
/// prima (Milestone 4.5.1) — `Stream`, così una sessione appena
/// completata/interrotta compare senza dover ricaricare la pagina.
final workoutHistoryProvider =
    StreamProvider.family<List<WorkoutSessionHistoryItem>, int>((
      ref,
      profileId,
    ) {
      return ref
          .watch(workoutSessionRepositoryProvider)
          .watchSessionHistory(profileId: profileId);
    });

/// Filtro semplice della lista storico (sezione 17): solo stato, nessun
/// intervallo data.
enum WorkoutHistoryFilter { all, completed, aborted }

final workoutHistoryFilterProvider = StateProvider<WorkoutHistoryFilter>(
  (ref) => WorkoutHistoryFilter.all,
);

/// Vista filtrata dello storico: filtra in memoria la lista già caricata
/// da [workoutHistoryProvider] — cambiare filtro non genera una nuova
/// query.
final filteredWorkoutHistoryProvider =
    Provider.family<AsyncValue<List<WorkoutSessionHistoryItem>>, int>((
      ref,
      profileId,
    ) {
      final filter = ref.watch(workoutHistoryFilterProvider);
      final historyAsync = ref.watch(workoutHistoryProvider(profileId));
      return historyAsync.whenData((items) {
        switch (filter) {
          case WorkoutHistoryFilter.all:
            return items;
          case WorkoutHistoryFilter.completed:
            return items
                .where(
                  (i) => i.status == WorkoutSessionPersistenceStatus.completed,
                )
                .toList();
          case WorkoutHistoryFilter.aborted:
            return items
                .where(
                  (i) => i.status == WorkoutSessionPersistenceStatus.aborted,
                )
                .toList();
        }
      });
    });

final workoutHistoryDetailsProvider =
    FutureProvider.family<WorkoutSessionHistoryDetails?, int>((ref, sessionId) {
      return ref
          .watch(workoutSessionRepositoryProvider)
          .getSessionHistoryDetails(sessionId);
    });
