import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout.dart';
import '../workout_labels.dart';
import 'workout_status_badge.dart';

/// Card di una scheda nella lista "I tuoi allenamenti". Il conteggio
/// esercizi è risolto da [workoutDetailsProvider] (già esistente dalla
/// Milestone 4.2): nessuna nuova query di conteggio nel repository.
class WorkoutCard extends ConsumerWidget {
  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onOpen,
    required this.onEdit,
    required this.onArchive,
  });

  final Workout workout;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(workoutDetailsProvider(workout.id!));
    final exerciseCount = detailsAsync.valueOrNull?.exercises.length;

    final subtitleParts = <String>[
      WorkoutLabels.type(workout.type),
      'Livello ${workout.level}',
      if (workout.estimatedDurationMinutes != null)
        '${workout.estimatedDurationMinutes} min',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 2),
              Text(
                exerciseCount == null
                    ? 'Esercizi in caricamento...'
                    : exerciseCount == 1
                    ? '1 esercizio'
                    : '$exerciseCount esercizi',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ForgeColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Modifica'),
                  ),
                  PopupMenuButton<void>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: onArchive,
                        child: const Text('Archivia'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
