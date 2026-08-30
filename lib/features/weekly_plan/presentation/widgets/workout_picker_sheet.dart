import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout.dart';
import '../../../training_plan/presentation/workout_labels.dart';

/// Selettore di un allenamento ESISTENTE (Milestone 8.2, sezione 20/21):
/// nessun catalogo secondo, riusa `watchWorkoutsProvider` (lo stesso
/// provider di `WorkoutListPage`) — nessuna creazione di scheda da qui, solo
/// selezione.
Future<Workout?> showWorkoutPickerSheet(
  BuildContext context, {
  required int profileId,
}) {
  return showModalBottomSheet<Workout>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _WorkoutPickerSheet(profileId: profileId),
  );
}

class _WorkoutPickerSheet extends ConsumerWidget {
  const _WorkoutPickerSheet({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(watchWorkoutsProvider(profileId));
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scegli un allenamento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: workoutsAsync.when(
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return const Center(
                      child: Text('Non hai ancora creato allenamenti.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      final subtitleParts = <String>[
                        WorkoutLabels.type(workout.type),
                        'Livello ${workout.level}',
                        if (workout.estimatedDurationMinutes != null)
                          '${workout.estimatedDurationMinutes} min',
                      ];
                      return ListTile(
                        title: Text(workout.name),
                        subtitle: Text(subtitleParts.join(' · ')),
                        onTap: () => Navigator.of(context).pop(workout),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => const Center(
                  child: Text(
                    'Non è stato possibile caricare gli allenamenti.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
