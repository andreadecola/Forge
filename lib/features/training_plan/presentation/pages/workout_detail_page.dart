import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/forge_colors.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout_details.dart';
import '../../../../domain/entities/workout_enums.dart';
import '../../../../domain/entities/workout_exercise_details.dart';
import '../../application/workout_session_controller.dart';
import '../workout_labels.dart';
import '../widgets/workout_status_badge.dart';

/// Vista di sola lettura di una scheda (Milestone 4.3, sezione 29): nessuna
/// azione di modifica/rimozione/riordino qui, solo le CTA "Inizia
/// allenamento" (solo per schede PRONTE, Milestone 4.4.1) e "Modifica"
/// verso `WorkoutEditPage`.
class WorkoutDetailPage extends ConsumerWidget {
  const WorkoutDetailPage({super.key, required this.workoutId});

  final int workoutId;

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Forge permette una sola sessione runtime attiva alla volta: se ce n'è
  /// già una (per questa scheda o per un'altra) non viene sostituita in
  /// silenzio, si informa l'utente con un dialog e si offre di riprendere
  /// quella già in corso.
  Future<void> _showActiveSessionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final activeWorkoutId = ref
        .read(workoutSessionControllerProvider)!
        .workoutId;
    final goToActive = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allenamento già in corso'),
        content: const Text(
          'Hai già un allenamento in corso. Terminalo o abbandonalo prima '
          'di iniziarne un altro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Chiudi'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Vai alla sessione attiva'),
          ),
        ],
      ),
    );
    if ((goToActive ?? false) && context.mounted) {
      context.push(AppRoutes.workoutSessionPath(activeWorkoutId));
    }
  }

  Future<void> _startWorkout(
    BuildContext context,
    WidgetRef ref,
    WorkoutDetails details,
  ) async {
    if (details.workout.status != WorkoutDefinitionStatus.ready) {
      _showMessage(context, 'Solo una scheda pronta può essere avviata.');
      return;
    }
    if (details.exercises.isEmpty) {
      _showMessage(context, 'Aggiungi almeno un esercizio prima di iniziare.');
      return;
    }

    final started = await ref
        .read(workoutSessionControllerProvider.notifier)
        .startSession(details);
    if (!context.mounted) return;
    if (!started) {
      await _showActiveSessionDialog(context, ref);
      return;
    }
    if (!context.mounted) return;
    context.push(AppRoutes.workoutSessionPath(workoutId));
  }

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
