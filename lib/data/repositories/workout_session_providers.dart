import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/persisted_workout_session.dart';
import '../../domain/repositories/workout_session_repository.dart';
import '../database/database_provider.dart';
import 'drift_workout_session_repository.dart';

final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>((
  ref,
) {
  return DriftWorkoutSessionRepository(ref.watch(databaseProvider));
});

/// Sessione per id, qualunque sia il suo stato (Milestone 8.5): usata per
/// derivare lo stato di completamento di una `PlannedActivity` collegata,
/// senza persistere un secondo campo che potrebbe divergere.
///
/// `StreamProvider` (non `FutureProvider`, Milestone 8.7 patch): riemette
/// automaticamente quando la sessione cambia stato (completa/abbandona),
/// così Today/WeeklyPlan/il riepilogo settimanale restano coerenti anche
/// mentre la pagina resta montata — prima (`FutureProvider`, one-shot) lo
/// stato restava "congelato" finché la pagina non veniva ricreata da zero.
final persistedWorkoutSessionProvider =
    StreamProvider.family<PersistedWorkoutSession?, int>((ref, sessionId) {
      return ref
          .watch(workoutSessionRepositoryProvider)
          .watchSessionById(sessionId);
    });
