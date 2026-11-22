import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/weekly_plan_generation_error.dart';
import '../../../../domain/entities/weekly_plan_generation_proposal.dart';
import '../../../../domain/entities/weekly_plan_generation_result.dart';
import '../../../../domain/entities/workout_enums.dart';
import '../../../../domain/entities/workout.dart';
import '../../../../domain/entities/workout_walking_block.dart';
import '../../../training_plan/presentation/widgets/workout_walking_block_fields.dart';
import '../../../../domain/entities/planned_activity_enums.dart';
import '../../../../domain/services/weekly_schedule_policy.dart';
import '../../../../data/repositories/workout_providers.dart';
import 'weekly_days_selector.dart';
import '../../../../domain/services/forge_workout_naming_policy.dart';
import '../../../../domain/services/weekly_planning_date_service.dart';
import '../../../training_plan/presentation/forge_labels.dart';
import '../../../training_plan/presentation/workout_labels.dart';
import '../../../training_plan/presentation/widgets/multi_level_choice_chips.dart';
import '../../../notifications/application/notification_providers.dart';
import '../../application/planned_activity_providers.dart';

const List<int> _durationOptions = [20, 30, 40, 50, 60];
const List<int> _countOptions = [1, 2, 3, 4, 5, 6, 7];

enum _WeeklyContents { combined, workoutOnly, walkingOnly }

/// Apre il flusso "Genera con Forge" per la settimana [weekReference]
/// (Milestone 8.4): configurazione -> anteprima -> conferma, tutto in un
/// unico bottom sheet (nessuna nuova rotta/pagina calendario, sezione 56).
Future<void> showWeeklyForgeGenerationSheet(
  BuildContext context, {
  required int profileId,
  required DateTime weekReference,
  bool manualMode = false,
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
        manualMode: manualMode,
      ),
    ),
  );
}

class _WeeklyForgeGenerationSheet extends ConsumerStatefulWidget {
  const _WeeklyForgeGenerationSheet({
    required this.profileId,
    required this.weekReference,
    this.manualMode = false,
  });

  final int profileId;
  final DateTime weekReference;
  final bool manualMode;

  @override
  ConsumerState<_WeeklyForgeGenerationSheet> createState() =>
      _WeeklyForgeGenerationSheetState();
}

class _WeeklyForgeGenerationSheetState
    extends ConsumerState<_WeeklyForgeGenerationSheet> {
  WorkoutType _type = WorkoutType.fullBody;
  int _duration = _durationOptions[2];
  Set<int> _selectedLevels = const {1};
  int _count = 3;
  late WorkoutWalkingBlock _walkingBlock;
  _WeeklyContents _contents = _WeeklyContents.combined;
  Workout? _manualWorkout;
  WeeklyDayMode _workoutMode = WeeklyDayMode.alternate;
  Set<int> _workoutDays = {1, 3, 5, 7};

  @override
  void initState() {
    super.initState();
    _walkingBlock = WorkoutWalkingBlock(
      minutes:
          ref.read(currentProfileProvider).valueOrNull?.preferredWalkMinutes ??
          30,
      placement: WalkingPlacement.afterExercises,
    );
  }

  bool _isGenerating = false;
  bool _isConfirming = false;
  WeeklyPlanGenerationResult? _result;

  Future<void> _generatePreview() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    try {
      final service = ref.read(weeklyPlanGenerationServiceProvider);
      final manualWorkout = widget.manualMode && _manualWorkout?.id != null
          ? await ref
                .read(workoutRepositoryProvider)
                .getWorkoutById(_manualWorkout!.id!)
          : _manualWorkout;
      final result = await service.buildProposal(
        profileId: widget.profileId,
        weekReference: widget.weekReference,
        workoutType: _type,
        targetDurationMinutes: _duration,
        userLevel: _selectedLevels.reduce((a, b) => a > b ? a : b),
        selectedLevels: _selectedLevels,
        requestedCount: _contents == _WeeklyContents.walkingOnly ? 0 : _count,
        walkCount: _contents == _WeeklyContents.walkingOnly ? _count : 0,
        walkDurationMinutes: _walkingBlock.minutes,
        workoutDays: _workoutDays,
        walkingDays: _workoutDays,
        manualMode: widget.manualMode,
        manualWorkout: _contents == _WeeklyContents.walkingOnly
            ? null
            : manualWorkout,
        walkingBlock: _contents == _WeeklyContents.combined
            ? _walkingBlock
            : null,
        updateWorkoutWalkingBlock: true,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile leggere i dati del piano. Riprova.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
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
      ref.invalidate(workoutByIdProvider);
      ref.invalidate(workoutDetailsProvider);
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
            widget.manualMode ? 'Pianifica manualmente' : 'Genera con Forge',
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
          'Composizione della scheda',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final entry in const {
              _WeeklyContents.combined: 'Allenamento e camminata',
              _WeeklyContents.workoutOnly: 'Solo allenamento',
              _WeeklyContents.walkingOnly: 'Solo camminata',
            }.entries)
              ChoiceChip(
                key: ValueKey('weekly-contents-${entry.key.name}'),
                label: Text(entry.value),
                selected: _contents == entry.key,
                onSelected: (_) => setState(() => _contents = entry.key),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.manualMode && _contents != _WeeklyContents.walkingOnly) ...[
          ref
              .watch(watchWorkoutsProvider(widget.profileId))
              .when(
                data: (workouts) {
                  final ready = workouts
                      .where((w) => w.status == WorkoutDefinitionStatus.ready)
                      .toList();
                  final selected = ready
                      .where((w) => w.id == _manualWorkout?.id)
                      .firstOrNull;
                  return DropdownButtonFormField<int>(
                    initialValue: selected?.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Scheda pronta',
                    ),
                    items: [
                      for (final workout in ready)
                        DropdownMenuItem(
                          value: workout.id,
                          child: Text(
                            workout.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (id) => setState(() {
                      _manualWorkout = ready
                          .where((w) => w.id == id)
                          .firstOrNull;
                      if (_contents == _WeeklyContents.combined &&
                          _manualWorkout?.walkingBlock != null) {
                        _walkingBlock = _manualWorkout!.walkingBlock!;
                      }
                    }),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Impossibile caricare le schede.'),
              ),
          const Text(
            'Scegli una scheda pronta con esercizi. La camminata scelta sarà salvata nella stessa scheda.',
          ),
        ],
        if (!widget.manualMode && _contents != _WeeklyContents.walkingOnly) ...[
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
          MultiLevelChoiceChips(
            selectedLevels: _selectedLevels,
            onChanged: (levels) => setState(() => _selectedLevels = levels),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Quante volte questa settimana?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final count in _countOptions)
              ChoiceChip(
                key: ValueKey('weekly-workout-count-$count'),
                label: Text('$count'),
                selected: _count == count,
                onSelected: (_) => setState(() => _count = count),
              ),
          ],
        ),
        WeeklyDaysSelector(
          label: 'Giorni della scheda',
          mode: _workoutMode,
          days: _workoutDays,
          onChanged: (mode, days) => setState(() {
            _workoutMode = mode;
            _workoutDays = days;
          }),
        ),
        const SizedBox(height: 16),
        if (_contents != _WeeklyContents.workoutOnly)
          WorkoutWalkingBlockFields(
            value: _walkingBlock,
            allowDisable: false,
            showPlacement: _contents == _WeeklyContents.combined,
            onChanged: (block) {
              if (block != null) setState(() => _walkingBlock = block);
            },
          ),
        if (_contents == _WeeklyContents.combined)
          const Text(
            'Esercizi e camminata fanno parte di un’unica scheda, negli stessi giorni. Un solo avvio e un solo promemoria.',
          ),
        const Text(
          'Una sola attività al giorno. I giorni occupati sono esclusi; le configurazioni incompatibili vengono segnalate.',
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
    final workoutCount =
        proposal.entries.length +
        proposal.additionalActivities
            .where((a) => a.type == PlannedActivityType.workout)
            .length;
    final walkCount = proposal.additionalActivities
        .where((a) => a.type == PlannedActivityType.walk)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workoutCount == 1
              ? '1 allenamento proposto'
              : '$workoutCount allenamenti proposti',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (walkCount > 0)
          Text(
            walkCount == 1
                ? '1 camminata proposta'
                : '$walkCount camminate proposte',
          ),
        for (final entry in proposal.entries)
          _ProposedEntryTile(entry: entry, walkingBlock: proposal.walkingBlock),
        for (final activity in proposal.additionalActivities)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              activity.type == PlannedActivityType.walk
                  ? Icons.directions_walk
                  : Icons.fitness_center,
            ),
            title: Text(
              '${italianWeekdayShort(activity.scheduledDate)} ${formatItalianDate(activity.scheduledDate)}',
            ),
            subtitle: Text(
              activity.type == PlannedActivityType.walk
                  ? 'Camminata · ${activity.plannedDurationMinutes} min'
                  : '${_manualWorkout?.name ?? 'Allenamento'}${proposal.walkingBlock == null ? '' : ' · Camminata ${proposal.walkingBlock!.minutes} min · ${proposal.walkingBlock!.positionLabel}'}',
            ),
          ),
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
        return 'Indica almeno un’attività e, nel percorso manuale, una scheda pronta.';
      case WeeklyPlanGenerationError.incompatibleSchedule:
        return 'Configurazione non realizzabile nei giorni liberi selezionati. Riduci il numero di attività o cambia i giorni.';
    }
  }
}

class _ProposedEntryTile extends StatelessWidget {
  const _ProposedEntryTile({required this.entry, this.walkingBlock});

  final ProposedForgeWorkout entry;
  final WorkoutWalkingBlock? walkingBlock;

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
        '${plan.estimatedDurationMinutes} min esercizi${walkingBlock == null ? '' : ' · Camminata ${walkingBlock!.minutes} min · ${walkingBlock!.positionLabel}'}',
      ),
    );
  }
}
