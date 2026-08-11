import 'package:flutter/material.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../domain/entities/generated_workout_exercise.dart';

/// Card di anteprima di un esercizio del piano generato (Milestone 5.5,
/// sezione 17). Mostra solo dati leggibili dall'utente: nessun
/// `exercise.code`, nessun ID di database, nessun enum tecnico — l'ordine e
/// i parametri arrivano tutti dal `WorkoutExercise` già deciso dal domain.
class ForgeExercisePreviewCard extends StatelessWidget {
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
          child: Text('$order'),
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
                  Icon(Icons.trending_up, size: 14, color: ForgeColors.copper),
                  const SizedBox(width: 4),
                  Text(
                    adaptationDetail!,
                    style: TextStyle(
                      color: ForgeColors.copper,
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
