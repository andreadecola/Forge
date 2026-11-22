import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout.dart';
import '../../../notifications/application/notification_providers.dart';

/// Un solo flusso di conferma per schede disponibili e archiviate.
class DeleteWorkoutButton extends ConsumerStatefulWidget {
  const DeleteWorkoutButton({super.key, required this.workout, this.onDeleted});
  final Workout workout;
  final VoidCallback? onDeleted;

  @override
  ConsumerState<DeleteWorkoutButton> createState() =>
      _DeleteWorkoutButtonState();
}

class _DeleteWorkoutButtonState extends ConsumerState<DeleteWorkoutButton> {
  bool _busy = false;

  Future<void> _delete() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Elimina definitivamente'),
          content: Text(
            'Eliminare "${widget.workout.name}" e gli esercizi della scheda? '
            'Non puoi annullare questa operazione. Lo storico degli allenamenti '
            'completati viene conservato. Le attività pianificate rimangono senza scheda.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Elimina'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      final repository = ref.read(workoutRepositoryProvider);
      final messenger = ScaffoldMessenger.of(context);
      final reminders = ref.read(plannedActivityReminderSyncServiceProvider);
      final onDeleted = widget.onDeleted;
      final workout = widget.workout;
      await repository.deleteWorkout(workout.id!);
      container.invalidate(workoutDetailsProvider(workout.id!));
      container.invalidate(workoutByIdProvider(workout.id!));
      container.invalidate(workoutsProvider(workout.profileId));
      if (messenger.mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Allenamento eliminato'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      onDeleted?.call();
      // La cancellazione della scheda rende non avviabili i relativi promemoria.
      try {
        await reminders.syncAllPlannedActivityReminders(
          profileId: workout.profileId,
        );
      } on Object {
        /* Riconciliazione ritentata al resume. */
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile eliminare la scheda. Riprova.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Elimina definitivamente',
    icon: const Icon(Icons.delete_outline),
    onPressed: _busy ? null : _delete,
  );
}
