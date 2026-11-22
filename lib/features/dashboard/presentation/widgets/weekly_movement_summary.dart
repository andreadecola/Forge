import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/forge_providers.dart';
import '../../../../domain/services/weekly_planning_date_service.dart';
import '../../../weekly_plan/application/planned_activity_providers.dart';

class WeeklyMovementSummary extends ConsumerWidget {
  const WeeklyMovementSummary({super.key, required this.profileId});
  final int profileId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = WeeklyPlanningDateService.weekStart(
      ref.watch(clockProvider).now(),
    );
    return ref
        .watch(
          weeklyPlanSummaryProvider((
            profileId: profileId,
            weekReference: week,
          )),
        )
        .when(
          data: (summary) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'La tua settimana',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (summary.workoutCount + summary.walkCount) == 0
                        ? 'Organizza la settimana con i tempi più adatti a te.'
                        : '${summary.completed} attività completate su ${(summary.workoutCount + summary.walkCount)} in programma',
                  ),
                  if ((summary.workoutCount + summary.walkCount) > 0) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      label:
                          '${summary.completed} attività completate su ${(summary.workoutCount + summary.walkCount)}',
                      child: LinearProgressIndicator(
                        value:
                            summary.completed /
                            (summary.workoutCount + summary.walkCount),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const Text(
            'Il riepilogo settimanale non è disponibile. Puoi comunque avviare un’attività.',
          ),
        );
  }
}
