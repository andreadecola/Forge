import '../../../../core/theme/forge_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout_details.dart';
import '../../../../domain/entities/workout_enums.dart';
import '../../../../domain/entities/workout_walking_block.dart';
import '../../../../domain/entities/workout_exercise_details.dart';
import '../../../exercises/presentation/widgets/exercise_image_thumbnail.dart';
import '../../application/workout_session_launcher.dart';
import '../workout_labels.dart';
import '../widgets/active_workout_dialog.dart';
import '../widgets/workout_status_badge.dart';
import '../widgets/delete_workout_button.dart';

/// Dettaglio scheda: avvio per schede pronte, modifica nel relativo editor
/// ed eliminazione esplicita con conferma (EVO-002). Le singole righe restano
/// di sola lettura; lo storico delle sessioni sopravvive alla scheda.
class WorkoutDetailPage extends ConsumerWidget {
  const WorkoutDetailPage({super.key, required this.workoutId});

  final int workoutId;

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startWorkout(
    BuildContext context,
    WidgetRef ref,
    WorkoutDetails details,
  ) async {
    final result = await launchWorkoutSession(ref, details);
    if (!context.mounted) return;
    switch (result.status) {
      case WorkoutSessionLaunchStatus.started:
        context.push(AppRoutes.workoutSessionPath(workoutId));
      case WorkoutSessionLaunchStatus.alreadyActive:
        await showActiveWorkoutSessionDialog(context, ref);
      case WorkoutSessionLaunchStatus.notReady:
        _showMessage(context, 'Solo una scheda pronta può essere avviata.');
      case WorkoutSessionLaunchStatus.empty:
        _showMessage(
          context,
          'Aggiungi almeno un esercizio prima di iniziare.',
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(workoutDetailsProvider(workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio scheda'),
        actions: [
          if (detailsAsync.valueOrNull != null)
            DeleteWorkoutButton(
              workout: detailsAsync.valueOrNull!.workout,
              onDeleted: () {
                if (context.mounted) context.go(AppRoutes.workouts);
              },
            ),
        ],
      ),
      body: detailsAsync.when(
        data: (details) {
          if (details == null) {
            return const Center(child: Text('Scheda non trovata.'));
          }
          final workout = details.workout;
          final subtitleParts = <String>[
            WorkoutLabels.type(workout.type),
            WorkoutLabels.levels(workout.effectiveSelectedLevels),
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
                    if (workout.walkingBlock?.placement ==
                        WalkingPlacement.beforeExercises)
                      _walkingCard(workout.walkingBlock!),
                    if (details.exercises.isEmpty)
                      const Text('Nessun esercizio in questa scheda.')
                    else
                      for (var i = 0; i < details.exercises.length; i++)
                        _ReadOnlyExerciseRow(
                          index: i + 1,
                          entry: details.exercises[i],
                        ),
                    if (workout.walkingBlock?.placement ==
                        WalkingPlacement.afterExercises)
                      _walkingCard(workout.walkingBlock!),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      if (workout.status == WorkoutDefinitionStatus.ready) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () =>
                                _startWorkout(context, ref, details),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Inizia allenamento'),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => context.push(
                            AppRoutes.workoutEditPath(workoutId),
                          ),
                          child: const Text('Modifica'),
                        ),
                      ),
                    ],
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

Widget _walkingCard(WorkoutWalkingBlock block) => Card(
  child: ListTile(
    leading: const Icon(Icons.directions_walk),
    title: Text('Camminata · ${block.minutes} min'),
    subtitle: Text('${block.positionLabel} · inclusa nella scheda'),
  ),
);

class _ReadOnlyExerciseRow extends StatelessWidget {
  const _ReadOnlyExerciseRow({required this.index, required this.entry});

  final int index;
  final WorkoutExerciseDetails entry;

  @override
  Widget build(BuildContext context) {
    final workoutExercise = entry.workoutExercise;
    final usesDuration = workoutExercise.durationSeconds != null;
    final primaryLine = usesDuration
        ? '${workoutExercise.sets ?? '-'} × ${workoutExercise.durationSeconds} sec'
        : '${workoutExercise.sets ?? '-'} × ${workoutExercise.repetitions ?? '-'} rip.';
    final subtitle = workoutExercise.restSeconds == null
        ? primaryLine
        : '$primaryLine · Recupero ${workoutExercise.restSeconds} sec';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ExerciseImageThumbnail(
                exerciseId: workoutExercise.exerciseId,
                size: 58,
                borderRadius: 10,
              ),
              Positioned(
                left: -4,
                top: -4,
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  child: Text(
                    '$index',
                    style: TextStyle(fontSize: ForgeTypography.badgeSize),
                  ),
                ),
              ),
            ],
          ),
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
