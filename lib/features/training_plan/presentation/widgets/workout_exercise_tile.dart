import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../domain/entities/workout_exercise_details.dart';
import '../../../exercises/application/exercise_catalog_providers.dart';
import '../../../exercises/presentation/widgets/exercise_image_placeholder.dart';

/// Riga di un esercizio nella composizione scheda (Milestone 4.3, sezione
/// 17-18): mostra ordine, nome, thumbnail (riusa il sistema immagini del
/// catalogo, nessun nuovo sistema), serie×ripetizioni o serie×durata e
/// recupero. Tap sulla riga apre la configurazione dei parametri — NON il
/// dettaglio catalogo, che ha una propria icona separata.
class WorkoutExerciseTile extends ConsumerWidget {
  const WorkoutExerciseTile({
    super.key,
    required this.index,
    required this.entry,
    required this.onEdit,
    required this.onRemove,
    required this.onShowDetail,
  });

  final int index;
  final WorkoutExerciseDetails entry;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onShowDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutExercise = entry.workoutExercise;
    final exercise = entry.exercise;
    final imagesAsync = ref.watch(exerciseImagesProvider(exercise.id));

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
        onTap: onEdit,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              child: Text(
                '$index',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: imagesAsync.when(
                  data: (images) {
                    final path = images.isEmpty ? null : images.first.path;
                    if (path == null) return const ExerciseImagePlaceholder();
                    return Image.asset(
                      path,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ExerciseImagePlaceholder(),
                    );
                  },
                  loading: () =>
                      Container(color: ForgeColors.anthraciteSurfaceHigh),
                  error: (error, stackTrace) =>
                      const ExerciseImagePlaceholder(),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          exercise.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Dettaglio esercizio',
              onPressed: onShowDetail,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Rimuovi',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
