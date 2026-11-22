import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/walking_session_providers.dart';
import '../../../notifications/application/notification_providers.dart';

class DeleteWalkingButton extends ConsumerStatefulWidget {
  const DeleteWalkingButton({
    super.key,
    required this.sessionId,
    required this.profileId,
    this.onDeleted,
  });
  final int sessionId;
  final int profileId;
  final VoidCallback? onDeleted;

  @override
  ConsumerState<DeleteWalkingButton> createState() =>
      _DeleteWalkingButtonState();
}

class _DeleteWalkingButtonState extends ConsumerState<DeleteWalkingButton> {
  bool _busy = false;

  Future<void> _delete() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Elimina camminata'),
          content: const Text(
            'Eliminare definitivamente questa camminata? Non comparirà più nello storico né nelle statistiche. L’attività pianificata eventualmente collegata viene conservata senza sessione.',
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
      final repository = ref.read(walkingSessionRepositoryProvider);
      final reminders = ref.read(plannedActivityReminderSyncServiceProvider);
      final onDeleted = widget.onDeleted;
      final sessionId = widget.sessionId, profileId = widget.profileId;
      await repository.deleteWalkingSession(sessionId);
      container.invalidate(walkingSessionsProvider(profileId));
      onDeleted?.call();
      try {
        await reminders.syncAllPlannedActivityReminders(profileId: profileId);
      } on Object {
        /* Riconciliazione ritentata al resume. */
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is StateError
                  ? error.message
                  : 'Impossibile eliminare la camminata. Riprova.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Elimina camminata',
    icon: const Icon(Icons.delete_outline),
    onPressed: _busy ? null : _delete,
  );
}
