import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/planned_activity.dart';
import '../../../dashboard/presentation/widgets/today_planned_activities_card.dart';
import '../../../notifications/application/notification_providers.dart';
import '../../application/planned_activity_providers.dart';
import '../planned_activity_presentation.dart';

class PlannedActivityDetailPage extends ConsumerStatefulWidget {
  const PlannedActivityDetailPage({
    super.key,
    required this.activityId,
    this.chooseReminder = false,
  });
  final int activityId;
  final bool chooseReminder;
  @override
  ConsumerState<PlannedActivityDetailPage> createState() =>
      _PlannedActivityDetailPageState();
}

class _PlannedActivityDetailPageState
    extends ConsumerState<PlannedActivityDetailPage> {
  bool _opened = false;
  bool _busy = false;

  Future<void> _snooze(PlannedActivity activity) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final chosen = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'Rinvia il promemoria nello stesso giorno',
      );
      if (chosen == null || !mounted) return;
      final day = activity.scheduledDate;
      final result = await ref
          .read(plannedActivityReminderSyncServiceProvider)
          .snooze(
            activity.id!,
            DateTime(day.year, day.month, day.day, chosen.hour, chosen.minute),
          );
      ref.invalidate(plannedActivityByIdProvider(activity.id!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isSuccess
                  ? 'Promemoria aggiornato.'
                  : 'Orario salvato; verifica permessi e impostazioni delle notifiche.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is StateError
                  ? error.message
                  : error is ArgumentError
                  ? error.message.toString()
                  : 'Impossibile rinviare il promemoria.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final initial = ref.watch(plannedActivityByIdProvider(widget.activityId));
    return Scaffold(
      appBar: AppBar(title: const Text('Attività pianificata')),
      body: initial.when(
        data: (initialActivity) {
          if (initialActivity == null ||
              initialActivity.profileId != profile?.id) {
            return const Center(child: Text('Attività non più disponibile.'));
          }
          final activities = ref.watch(
            plannedActivitiesForWeekProvider((
              profileId: initialActivity.profileId,
              weekReference: initialActivity.scheduledDate,
            )),
          );
          return activities.when(
            data: (values) {
              final activity = values
                  .where((a) => a.id == widget.activityId)
                  .firstOrNull;
              if (activity == null) {
                return const Center(
                  child: Text('Attività non più disponibile.'),
                );
              }
              final available =
                  PlannedActivityPresentation.displayState(ref, activity) ==
                  PlannedActivityDisplayState.none;
              if (widget.chooseReminder && !_opened) {
                _opened = true;
                if (available) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _snooze(activity);
                  });
                }
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    formatItalianDate(activity.scheduledDate),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  PlannedActivityActionTile(
                    profileId: activity.profileId,
                    activity: activity,
                  ),
                  if (activity.reminderAt != null)
                    Text(
                      'Promemoria alle ${formatItalianTime(activity.reminderAt!)}',
                    ),
                  if (available)
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _snooze(activity),
                      icon: const Icon(Icons.snooze),
                      label: const Text('Rinvia promemoria'),
                    ),
                  if (activity.notes?.isNotEmpty ?? false)
                    Text(activity.notes!),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                const Center(child: Text('Impossibile leggere l’attività.')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Impossibile leggere l’attività.')),
      ),
    );
  }
}
