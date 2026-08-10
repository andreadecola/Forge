import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/catalog_providers.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/workout_session_providers.dart';
import '../../../domain/entities/persisted_workout_session.dart';
import 'workout_session_clock.dart';
import 'workout_session_controller.dart';
import 'workout_session_restore_service.dart';

final workoutSessionRestoreServiceProvider =
    Provider<WorkoutSessionRestoreService>((ref) {
      return WorkoutSessionRestoreService(
        sessionRepository: ref.watch(workoutSessionRepositoryProvider),
        exerciseRepository: ref.watch(exerciseRepositoryProvider),
        clock: ref.watch(sessionClockProvider),
      );
    });

/// Sessione persistita ancora in corso (IN_PROGRESS/PAUSED) del profilo
/// corrente, da proporre in un banner "Allenamento in corso" (sezione
/// 30/31) — mai navigata automaticamente (sezione 32). `null` se non c'è
/// nulla da proporre, anche mentre una sessione runtime è già attiva in
/// memoria in questo stesso avvio dell'app (in quel caso la UI usa già il
/// dialog "sessione già in corso" di `WorkoutDetailPage`, non questo
/// banner, che riguarda solo il ripristino dopo una chiusura).
final activeSessionBannerProvider = FutureProvider<PersistedWorkoutSession?>((
  ref,
) async {
  if (ref.watch(workoutSessionControllerProvider) != null) return null;

  final profile = await ref.watch(currentProfileProvider.future);
  final profileId = profile?.id;
  if (profileId == null) return null;

  return ref
      .watch(workoutSessionRepositoryProvider)
      .getActiveSession(profileId: profileId);
});
