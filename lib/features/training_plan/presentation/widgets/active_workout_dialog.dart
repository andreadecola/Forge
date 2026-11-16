import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../data/repositories/workout_session_providers.dart';
import '../../application/workout_session_controller.dart';
import '../../application/workout_session_restore_providers.dart';

Future<void> showActiveWorkoutSessionDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final runtimeSession = ref.read(workoutSessionControllerProvider);
  final persistedSession = runtimeSession == null
      ? await ref
            .read(workoutSessionRepositoryProvider)
            .getActiveSession(
              profileId: (await ref.read(currentProfileProvider.future))!.id!,
            )
      : null;
  final activeWorkoutId =
      runtimeSession?.workoutId ?? persistedSession?.workoutId;

  if (!context.mounted) return;
  final goToActive = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Allenamento già in corso'),
      content: const Text(
        'Hai già un allenamento in corso. Terminalo o abbandonalo prima '
        'di iniziarne un altro.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Chiudi'),
        ),
        if (activeWorkoutId != null)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Vai alla sessione attiva'),
          ),
      ],
    ),
  );
  if ((goToActive ?? false) && activeWorkoutId != null && context.mounted) {
    if (ref.read(workoutSessionControllerProvider) == null &&
        persistedSession != null) {
      final restored = await ref
          .read(workoutSessionRestoreServiceProvider)
          .restore(persistedSession.id!);
      if (!context.mounted) return;
      if (restored == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossibile ripristinare la sessione. Puoi terminarla dalla Home.',
            ),
          ),
        );
        return;
      }
      ref
          .read(workoutSessionControllerProvider.notifier)
          .adoptRestoredSession(restored);
    }
    final active = ref.read(workoutSessionControllerProvider);
    if (active != null && context.mounted) {
      context.push(AppRoutes.workoutSessionPath(active.workoutId));
    }
  }
}
