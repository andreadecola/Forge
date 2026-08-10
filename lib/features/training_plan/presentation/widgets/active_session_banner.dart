import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../data/repositories/workout_session_providers.dart';
import '../../../../domain/entities/persisted_workout_session.dart';
import '../../application/workout_session_controller.dart';
import '../../application/workout_session_restore_providers.dart';

/// Banner "Allenamento in corso" (Milestone 4.4.3, sezione 31): mostrato
/// su Dashboard e Programma quando esiste una sessione persistita ancora
/// IN_PROGRESS/PAUSED (tipicamente dopo aver chiuso l'app a metà
/// allenamento). Non naviga mai da sola alla sessione (sezione 32):
/// propone solo "Riprendi"/"Termina", la scelta resta dell'utente.
class ActiveSessionBanner extends ConsumerWidget {
  /// [padding] si applica solo quando il banner ha davvero qualcosa da
  /// mostrare: a differenza di avvolgerlo con un `Padding` esterno, non
  /// lascia uno spazio vuoto quando non c'è nessuna sessione da
  /// ripristinare (`SizedBox.shrink()`, zero-size, nessun padding).
  const ActiveSessionBanner({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeSessionBannerProvider);
    final session = activeAsync.valueOrNull;
    if (session == null) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: _ActiveSessionCard(session: session),
    );
  }
}

class _ActiveSessionCard extends ConsumerWidget {
  const _ActiveSessionCard({required this.session});

  final PersistedWorkoutSession session;

  Future<void> _resume(BuildContext context, WidgetRef ref) async {
    final restored = await ref
        .read(workoutSessionRestoreServiceProvider)
        .restore(session.id!);
    if (restored == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossibile ripristinare: la scheda originale non esiste più. '
            'Puoi comunque terminare la sessione.',
          ),
        ),
      );
      return;
    }
    ref
        .read(workoutSessionControllerProvider.notifier)
        .adoptRestoredSession(restored);
    if (!context.mounted) return;
    context.push(AppRoutes.workoutSessionPath(restored.workoutId));
  }

  Future<void> _terminate(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminare l\'allenamento in corso?'),
        content: const Text(
          'La sessione verrà segnata come interrotta. L\'operazione non può '
          'essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Termina'),
          ),
        ],
      ),
    );
    if (!(confirm ?? false)) return;

    await ref
        .read(workoutSessionRepositoryProvider)
        .abortSession(sessionId: session.id!, endedAt: DateTime.now());
    ref.invalidate(activeSessionBannerProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.secondaryContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: colors.onSecondaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Allenamento in corso',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              session.workoutNameSnapshot,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _terminate(context, ref),
                    child: const Text('Termina'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _resume(context, ref),
                    child: const Text('Riprendi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
