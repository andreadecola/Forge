import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/forge_colors.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout_exercise_details.dart';
import '../workout_labels.dart';
import '../widgets/workout_status_badge.dart';

/// Vista di sola lettura di una scheda (Milestone 4.3, sezione 29): nessuna
/// azione di modifica/rimozione/riordino qui, solo la CTA "Modifica" verso
/// `WorkoutEditPage`. Non mostra "Inizia allenamento": l'esecuzione guidata
/// non è ancora parte di questa milestone (vedi 07_Training_Engine.md).
class WorkoutDetailPage extends ConsumerWidget {
  const WorkoutDetailPage({super.key, required this.workoutId});

  final int workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(workoutDetailsProvider(workoutId));

    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio scheda')),
      body: detailsAsync.when(
        data: (details) {
          if (details == null) {
            return const Center(child: Text('Scheda non trovata.'));
          }
          final workout = details.workout;
          final subtitleParts = <String>[
            WorkoutLabels.type(workout.type),
            'Livello ${workout.level}',
            if (workout.estimatedDurationMinutes != null)
              '${workout.estimatedDurationMinutes} min',
          ];

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            workout.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        WorkoutStatusBadge(status: workout.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleParts.join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (workout.description != null &&
                        workout.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(workout.description!),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Esercizi',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (details.exercises.isEmpty)
                      const Text('Nessun esercizio in questa scheda.')
                    else
                      for (var i = 0; i < details.exercises.length; i++)
                        _ReadOnlyExerciseRow(
                          index: i + 1,
                          entry: details.exercises[i],
                        ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () =>
                          context.push(AppRoutes.workoutEditPath(workoutId)),
                      child: const Text('Modifica'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Si è verificato un errore.')),
      ),
    );
  }
}

class _ReadOnlyExerciseRow extends StatelessWidget {
  const _ReadOnlyExerciseRow({required this.index, required this.entry});

  final int index;
  final WorkoutExerciseDetails entry;

  @override
  Widget build(BuildContext context) {
    final workoutExercise = entry.workoutExercise;
    final usesDuration =
        workoutExercise.durationSeconds != null &&
        workoutExercise.repetitions == null;
    final primaryLine = usesDuration
        ? '${workoutExercise.sets ?? '-'} × ${workoutExercise.durationSeconds} sec'
        : '${workoutExercise.sets ?? '-'} × ${workoutExercise.repetitions ?? '-'} rip.';
    final subtitle = workoutExercise.restSeconds == null
        ? primaryLine
        : '$primaryLine · Recupero ${workoutExercise.restSeconds} sec';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ForgeColors.anthraciteSurfaceHigh,
          child: Text('$index'),
        ),
        title: Text(
          entry.exercise.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
