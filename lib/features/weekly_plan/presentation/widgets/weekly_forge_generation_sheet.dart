import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/weekly_plan_generation_error.dart';
import '../../../../domain/entities/weekly_plan_generation_proposal.dart';
import '../../../../domain/entities/weekly_plan_generation_result.dart';
import '../../../../domain/entities/workout_enums.dart';
import '../../../../domain/services/forge_workout_naming_policy.dart';
import '../../../../domain/services/weekly_planning_date_service.dart';
import '../../../training_plan/presentation/forge_labels.dart';
import '../../../training_plan/presentation/workout_labels.dart';
import '../../../notifications/application/notification_providers.dart';
import '../../application/planned_activity_providers.dart';

const List<int> _durationOptions = [20, 30, 40, 50, 60];
const List<int> _countOptions = [1, 2, 3, 4, 5];

/// Apre il flusso "Genera con Forge" per la settimana [weekReference]
/// (Milestone 8.4): configurazione -> anteprima -> conferma, tutto in un
/// unico bottom sheet (nessuna nuova rotta/pagina calendario, sezione 56).
Future<void> showWeeklyForgeGenerationSheet(
  BuildContext context, {
  required int profileId,
  required DateTime weekReference,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _WeeklyForgeGenerationSheet(
        profileId: profileId,
        weekReference: weekReference,
      ),
    ),
  );
}

class _WeeklyForgeGenerationSheet extends ConsumerStatefulWidget {
  const _WeeklyForgeGenerationSheet({
    required this.profileId,
    required this.weekReference,
  });

  final int profileId;
  final DateTime weekReference;

  @override
  ConsumerState<_WeeklyForgeGenerationSheet> createState() =>
      _WeeklyForgeGenerationSheetState();
}

class _WeeklyForgeGenerationSheetState
    extends ConsumerState<_WeeklyForgeGenerationSheet> {
  WorkoutType _type = WorkoutType.fullBody;
  int _duration = _durationOptions[2];
  int _level = 1;
  int _count = _countOptions[2];

  bool _isGenerating = false;
  bool _isConfirming = false;
  WeeklyPlanGenerationResult? _result;

  Future<void> _generatePreview() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    final service = ref.read(weeklyPlanGenerationServiceProvider);
    final result = await service.buildProposal(
      profileId: widget.profileId,
      weekReference: widget.weekReference,
      workoutType: _type,
      targetDurationMinutes: _duration,
      userLevel: _level,
      requestedCount: _count,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _isGenerating = false;
    });
  }

  void _editConfiguration() {
    setState(() => _result = null);
  }

  Future<void> _confirm() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);
    try {
      final repository = ref.read(weeklyPlanGenerationRepositoryProvider);
      await repository.confirmProposal(
        profileId: widget.profileId,
        proposal: _result!.proposal!,
      );
      // The DB transaction is complete before projecting the newly created
      // activities to local notifications.
      try {
        await ref
            .read(plannedActivityReminderSyncServiceProvider)
            .syncAllPlannedActivityReminders(profileId: widget.profileId);
      } on Object {
        // Notification failures do not invalidate a committed plan.
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Piano generato')));
    } catch (_) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Non è stato possibile salvare il piano. Riprova.'),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genera con Forge',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            formatItalianWeekRange(
              WeeklyPlanningDateService.weekStart(widget.weekReference),
              WeeklyPlanningDateService.weekEnd(widget.weekReference),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (result == null)
            _buildConfigForm(context)
          else
            _buildResult(context, result),
        ],
      ),
    );
  }

  Widget _buildConfigForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo allenamento',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in ForgeLabels.supportedWorkoutTypes)
              ChoiceChip(
                label: Text(WorkoutLabels.type(type)),
                selected: _type == type,
                onSelected: (_) => setState(() => _type = type),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Durata', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final minutes in _durationOptions)
              ChoiceChip(
                label: Text('$minutes min'),
                selected: _duration == minutes,
                onSelected: (_) => setState(() => _duration = minutes),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Livello', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var level = 1; level <= 5; level++)
              ChoiceChip(
                label: Text('$level'),
                selected: _level == level,
                onSelected: (_) => setState(() => _level = level),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Quanti allenamenti questa settimana?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final count in _countOptions)
              ChoiceChip(
                label: Text('$count'),
                selected: _count == count,
                onSelected: (_) => setState(() => _count = count),
              ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _generatePreview,
            child: _isGenerating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Genera anteprima'),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context, WeeklyPlanGenerationResult result) {
    if (!result.success) {
      final message = result.forgeErrors.isNotEmpty
          ? ForgeLabels.generationErrorMessage(result.forgeErrors.first)
          : _orchestrationErrorMessage(result);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _editConfiguration,
              child: const Text('Modifica configurazione'),
            ),
          ),
        ],
      );
    }

    final proposal = result.proposal!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          proposal.entries.length == 1
              ? '1 allenamento proposto'
              : '${proposal.entries.length} allenamenti proposti',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final entry in proposal.entries) _ProposedEntryTile(entry: entry),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isConfirming ? null : _editConfiguration,
                child: const Text('Annulla'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isConfirming ? null : _confirm,
                child: _isConfirming
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Conferma piano'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _orchestrationErrorMessage(WeeklyPlanGenerationResult result) {
    if (result.errors.isEmpty) {
      return 'Non è stato possibile generare una proposta per questa '
          'settimana.';
    }
    // `buildProposal` restituisce un solo errore di orchestrazione alla
    // volta: il primo è sempre sufficiente.
    switch (result.errors.first) {
      case WeeklyPlanGenerationError.weekEntirelyInPast:
        return 'Questa settimana è già passata: non è possibile generare '
            'un piano nel passato.';
      case WeeklyPlanGenerationError.weekAlreadyHasForgeActivities:
        return 'Questa settimana contiene già attività generate da Forge. '
            'Eliminale prima di generarne di nuove.';
      case WeeklyPlanGenerationError.invalidRequestedCount:
        return 'Indica quanti allenamenti generare.';
    }
  }
}

class _ProposedEntryTile extends StatelessWidget {
  const _ProposedEntryTile({required this.entry});

  final ProposedForgeWorkout entry;

  @override
  Widget build(BuildContext context) {
    final plan = entry.adaptedPlan.plan;
    final name = ForgeWorkoutNamingPolicy.defaultNameFor(plan.workoutType);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.fitness_center),
      title: Text(
        '${italianWeekdayShort(entry.scheduledDate)} '
        '${formatItalianDate(entry.scheduledDate)}',
      ),
      subtitle: Text(
        '$name · ${WorkoutLabels.type(plan.workoutType)} · '
        '${plan.estimatedDurationMinutes} min',
      ),
    );
  }
}
