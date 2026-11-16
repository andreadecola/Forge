import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/workout_details.dart';
import '../../../domain/entities/workout_enums.dart';
import 'workout_session_controller.dart';

enum WorkoutSessionLaunchStatus { started, notReady, empty, alreadyActive }

class WorkoutSessionLaunchResult {
  const WorkoutSessionLaunchResult._(this.status, {this.activeWorkoutId});

  const WorkoutSessionLaunchResult.started()
    : this._(WorkoutSessionLaunchStatus.started);
  const WorkoutSessionLaunchResult.notReady()
    : this._(WorkoutSessionLaunchStatus.notReady);
  const WorkoutSessionLaunchResult.empty()
    : this._(WorkoutSessionLaunchStatus.empty);
  const WorkoutSessionLaunchResult.alreadyActive({int? activeWorkoutId})
    : this._(
        WorkoutSessionLaunchStatus.alreadyActive,
        activeWorkoutId: activeWorkoutId,
      );

  final WorkoutSessionLaunchStatus status;
  final int? activeWorkoutId;
}

/// Punto unico di avvio usato dal dettaglio scheda e dalla Home. La sessione
/// viene creata solo dopo un'azione esplicita dell'utente; il controller
/// globale mantiene inoltre la guardia contro una seconda sessione attiva.
Future<WorkoutSessionLaunchResult> launchWorkoutSession(
  WidgetRef ref,
  WorkoutDetails details,
) async {
  if (details.workout.status != WorkoutDefinitionStatus.ready) {
    return const WorkoutSessionLaunchResult.notReady();
  }
  if (details.exercises.isEmpty) {
    return const WorkoutSessionLaunchResult.empty();
  }

  final controller = ref.read(workoutSessionControllerProvider.notifier);
  final started = await controller.startSession(details);
  if (started) return const WorkoutSessionLaunchResult.started();

  return WorkoutSessionLaunchResult.alreadyActive(
    activeWorkoutId: ref.read(workoutSessionControllerProvider)?.workoutId,
  );
}
