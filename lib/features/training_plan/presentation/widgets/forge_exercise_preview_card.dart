import '../../../../core/theme/forge_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/generated_workout_exercise.dart';
import '../../../exercises/presentation/widgets/exercise_image_thumbnail.dart';

/// Card di anteprima di un esercizio del piano generato (Milestone 5.5,
/// sezione 17). Mostra solo dati leggibili dall'utente: nessun
/// `exercise.code`, nessun ID di database, nessun enum tecnico — l'ordine e
/// i parametri arrivano tutti dal `WorkoutExercise` già deciso dal domain.
class ForgeExercisePreviewCard extends ConsumerWidget {
  const ForgeExercisePreviewCard({
    super.key,
    required this.order,
    required this.entry,
    required this.categoryName,
    this.adaptationDetail,
  });

  final int order;
  final GeneratedWorkoutExercise entry;
  final String categoryName;

  /// Etichetta discreta già tradotta da `ForgeLabels` (es. "Progressione
  /// applicata"), `null` se non c'è nulla da segnalare per questo esercizio.
  final String? adaptationDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          width: 52,
          height: 52,
          child: Stack(
            children: [
              ExerciseImageThumbnail(exerciseId: entry.exercise.id, size: 52),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ForgeTypography.badgeSize,
                      fontWeight: FontWeight.w700,
                    ),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(categoryName),
            Text(subtitle),
            if (adaptationDetail != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    adaptationDetail!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        isThreeLine: adaptationDetail != null,
      ),
    );
  }
}
