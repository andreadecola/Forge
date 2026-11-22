import '../../../../core/theme/forge_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../domain/entities/workout_session_exercise_history_item.dart';
import '../../../../domain/entities/workout_session_history_details.dart';
import '../../../exercises/presentation/widgets/exercise_image_thumbnail.dart';
import '../../application/workout_history_providers.dart';
import '../workout_session_history_labels.dart';
import '../widgets/exercise_performance_diary.dart';
import '../../../../data/repositories/walking_session_providers.dart';
import '../../../../domain/entities/workout_session_history_item.dart';
import '../../../../domain/entities/walking_session_status.dart';

/// Dettaglio di una sessione storica (Milestone 4.5.1): nome/data/stato
/// snapshot, durata totale derivata, esercizi in ordine con i parametri
/// con cui la sessione è iniziata — **mai** letti dalla scheda live
/// (sezione 22/23), che potrebbe essere stata modificata o anche
/// eliminata (sezione 24: nessun errore in quel caso, il nome resta
/// leggibile dallo snapshot).
class WorkoutHistoryDetailPage extends ConsumerWidget {
  const WorkoutHistoryDetailPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(workoutHistoryDetailsProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio allenamento')),
      body: detailsAsync.when(
        data: (details) {
          if (details == null) {
            return const Center(child: Text('Sessione non trovata.'));
          }
          return _DetailBody(details: details);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Impossibile caricare il dettaglio.')),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.details});

  final WorkoutSessionHistoryDetails details;

  @override
  Widget build(BuildContext context) {
    final session = details.session;
    final duration = formatSessionDuration(
      startedAt: session.startedAt,
      finishedAt: session.finishedAt,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          session.workoutName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(WorkoutSessionHistoryLabels.status(session.status)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: 'Data',
                  value:
                      '${formatItalianDate(session.startedAt)} · '
                      '${formatItalianTime(session.startedAt)}',
                ),
                _InfoRow(
                  label: 'Durata totale',
                  value: duration ?? 'Durata non disponibile',
                ),
                _InfoRow(
                  label: 'Esercizi completati',
                  value: '${session.completedExercises}',
                ),
                _InfoRow(
                  label: 'Esercizi saltati',
                  value: '${session.skippedExercises}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (session.walkingBlock != null)
          _SessionWalkingSummary(session: session),
        Text('Esercizi', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final exercise in details.exercises) ...[
          _ExerciseHistoryRow(exercise: exercise),
          ExercisePerformanceDiary(
            sessionId: session.sessionId,
            order: exercise.order,
            exerciseId: exercise.exerciseId,
            totalSets: exercise.totalSets,
            timed: exercise.durationSeconds != null,
          ),
        ],
      ],
    );
  }
}

class _SessionWalkingSummary extends ConsumerWidget {
  const _SessionWalkingSummary({required this.session});
  final WorkoutSessionHistoryItem session;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final block = session.walkingBlock!;
    final walking = session.walkingSessionId == null
        ? null
        : ref
              .watch(walkingSessionProvider(session.walkingSessionId!))
              .valueOrNull;
    final state = walking == null
        ? 'Non registrata'
        : walking.status == WalkingSessionStatus.completed
        ? 'Completata'
        : walking.status == WalkingSessionStatus.aborted
        ? 'Interrotta'
        : 'In corso';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.directions_walk),
        title: Text('Camminata · ${block.minutes} min previsti'),
        subtitle: Text(
          '${block.positionLabel} · $state${walking?.endedAt == null ? '' : ' · ${walking!.activeDuration(walking.endedAt!).inSeconds ~/ 60} min effettivi'}',
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ExerciseHistoryRow extends StatelessWidget {
  const _ExerciseHistoryRow({required this.exercise});

  final WorkoutSessionExerciseHistoryItem exercise;

  @override
  Widget build(BuildContext context) {
    final usesDuration = exercise.durationSeconds != null;
    final primaryLine = usesDuration
        ? '${exercise.totalSets} × ${exercise.durationSeconds} sec'
        : '${exercise.totalSets} × ${exercise.repetitions ?? '-'} rip.';
    final state = WorkoutSessionHistoryLabels.exerciseState(
      isCompleted: exercise.isCompleted,
      isSkipped: exercise.isSkipped,
      completedSets: exercise.completedSets,
    );

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
                exerciseId: exercise.exerciseId,
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
                    '${exercise.order}',
                    style: TextStyle(fontSize: ForgeTypography.badgeSize),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          exercise.exerciseName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${exercise.completedSets} di ${exercise.totalSets} serie · '
          '$primaryLine',
        ),
        trailing: Text(state),
      ),
    );
  }
}
