import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../data/repositories/forge_providers.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../data/repositories/walking_session_providers.dart';
import '../../../../data/repositories/workout_session_providers.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/planned_activity_enums.dart';
import '../../../../domain/entities/planned_activity.dart';
import '../../../../domain/services/activity_dashboard_service.dart';
import '../../../training_plan/application/workout_history_providers.dart';
import '../../../weight/application/weight_providers.dart';

final activityDashboardPeriodProvider = StateProvider(
  (ref) => ActivityDashboardPeriod.week,
);
final _dashboardPlannedProvider =
    StreamProvider.family<
      List<PlannedActivity>,
      ({int profileId, DateTime start, DateTime end})
    >(
      (ref, args) => ref
          .watch(plannedActivityRepositoryProvider)
          .watchForWeek(
            profileId: args.profileId,
            weekStart: args.start,
            weekEnd: args.end,
          ),
    );
final activityDashboardProvider =
    FutureProvider.family<ActivityDashboardSummary, int>((
      ref,
      profileId,
    ) async {
      final period = ref.watch(activityDashboardPeriodProvider);
      final now = ref.watch(clockProvider).now();
      final range = ActivityDashboardService.compute(
        now: now,
        period: period,
        workouts: [],
        walks: [],
        planned: [],
        weights: [],
      );
      final workouts = await ref.watch(
        workoutHistoryProvider(profileId).future,
      );
      final walks = await ref.watch(walkingHistoryProvider(profileId).future);
      final weights = await ref.watch(
        bodyMeasurementsProvider(profileId).future,
      );
      final planned = await ref.watch(
        _dashboardPlannedProvider((
          profileId: profileId,
          start: range.previousStart,
          end: range.end.subtract(const Duration(days: 1)),
        )).future,
      );
      final includedWalks = <int, ({bool planned, int? walkingSessionId})>{};
      for (final activity in planned.where(
        (a) => a.type == PlannedActivityType.workout,
      )) {
        if (activity.workoutSessionId != null) {
          final parent = await ref.watch(
            persistedWorkoutSessionProvider(activity.workoutSessionId!).future,
          );
          includedWalks[activity.id!] = (
            planned: parent?.walkingBlock != null,
            walkingSessionId: parent?.walkingSessionId,
          );
        } else if (activity.workoutId != null) {
          final workout = await ref.watch(
            workoutByIdProvider(activity.workoutId!).future,
          );
          includedWalks[activity.id!] = (
            planned: workout?.walkingBlock != null,
            walkingSessionId: null,
          );
        }
      }
      return ActivityDashboardService.compute(
        now: now,
        period: period,
        workouts: workouts,
        walks: walks,
        planned: planned,
        weights: weights,
        includedWalks: includedWalks,
      );
    });

class ActivityDashboardSection extends ConsumerWidget {
  const ActivityDashboardSection({super.key, required this.profileId});
  final int profileId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(activityDashboardPeriodProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Attività e risultati',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Settimana'),
                  selected: period == ActivityDashboardPeriod.week,
                  onSelected: (_) =>
                      ref.read(activityDashboardPeriodProvider.notifier).state =
                          ActivityDashboardPeriod.week,
                ),
                ChoiceChip(
                  label: const Text('Mese'),
                  selected: period == ActivityDashboardPeriod.month,
                  onSelected: (_) =>
                      ref.read(activityDashboardPeriodProvider.notifier).state =
                          ActivityDashboardPeriod.month,
                ),
              ],
            ),
            ref
                .watch(activityDashboardProvider(profileId))
                .when(
                  data: (summary) {
                    final c = summary.current, p = summary.previous;
                    String compare(num n, num old) =>
                        '${n - old >= 0 ? '+' : ''}${(n - old).toStringAsFixed(0)} sul periodo precedente';
                    Widget metric(
                      String label,
                      String value,
                      String previous,
                    ) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '$label: $value',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(previous),
                        ],
                      ),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Hai completato ${c.workouts} allenamenti e ${c.walks} camminate in questo periodo.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        if (c.walkSeconds > p.walkSeconds)
                          Text(
                            'Hai camminato ${(c.walkSeconds - p.walkSeconds) ~/ 60} minuti in più rispetto al periodo precedente.',
                          ),
                        Text(
                          '${formatItalianDate(summary.start)} – ${formatItalianDate(summary.end.subtract(const Duration(days: 1)))}',
                        ),
                        const Text(
                          'Confronto con la settimana o il mese di calendario precedente.',
                        ),
                        metric(
                          'Allenamenti completati',
                          '${c.workouts}',
                          compare(c.workouts, p.workouts),
                        ),
                        metric(
                          'Allenamenti pianificati svolti',
                          '${c.completedPlannedWorkouts} / ${c.plannedWorkouts}',
                          'Periodo precedente: ${p.completedPlannedWorkouts} / ${p.plannedWorkouts}',
                        ),
                        metric(
                          'Minuti allenamento',
                          (c.workoutSeconds / 60).toStringAsFixed(1),
                          'Precedenti: ${(p.workoutSeconds / 60).toStringAsFixed(1)} · durata totale incluse pause',
                        ),
                        metric(
                          'Camminate completate',
                          '${c.walks}',
                          compare(c.walks, p.walks),
                        ),
                        metric(
                          'Camminate pianificate svolte',
                          '${c.completedPlannedWalks} / ${c.plannedWalks}',
                          'Periodo precedente: ${p.completedPlannedWalks} / ${p.plannedWalks}',
                        ),
                        metric(
                          'Minuti camminata',
                          (c.walkSeconds / 60).toStringAsFixed(1),
                          'Precedenti: ${(p.walkSeconds / 60).toStringAsFixed(1)} · tempo attivo',
                        ),
                        metric(
                          'Passi registrati',
                          c.steps?.toString() ?? 'Non disponibili',
                          'Precedenti: ${p.steps ?? 'non disponibili'}',
                        ),
                        metric(
                          'Distanza registrata',
                          c.meters == null
                              ? 'Non disponibile'
                              : '${(c.meters! / 1000).toStringAsFixed(2)} km',
                          'Precedente: ${p.meters == null ? 'non disponibile' : '${(p.meters! / 1000).toStringAsFixed(2)} km'}',
                        ),
                        metric(
                          'Variazione peso nel periodo',
                          c.weightChange == null
                              ? 'Non disponibile'
                              : '${c.weightChange! >= 0 ? '+' : ''}${c.weightChange!.toStringAsFixed(1)} kg',
                          'Precedente: ${p.weightChange?.toStringAsFixed(1) ?? 'non disponibile'}${p.weightChange == null ? '' : ' kg'}',
                        ),
                        const Text(
                          'Passi e distanza includono solo i valori registrati nelle camminate completate. La variazione del peso richiede almeno due misurazioni nel periodo. Le attività saltate o rinviate sono escluse dai pianificati.',
                        ),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Caricamento attività...'),
                  ),
                  error: (_, _) =>
                      const Text('Impossibile caricare il riepilogo attività.'),
                ),
          ],
        ),
      ),
    );
  }
}
