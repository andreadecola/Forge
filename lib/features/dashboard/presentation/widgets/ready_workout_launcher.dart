import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout.dart';
import '../../../../domain/entities/workout_enums.dart';
import '../../../training_plan/application/workout_session_launcher.dart';
import '../../../training_plan/presentation/widgets/active_workout_dialog.dart';
import '../../../training_plan/presentation/workout_labels.dart';

class ReadyWorkoutLauncher extends ConsumerStatefulWidget {
  const ReadyWorkoutLauncher({super.key, required this.profileId});

  final int profileId;

  @override
  ConsumerState<ReadyWorkoutLauncher> createState() =>
      _ReadyWorkoutLauncherState();
}

class _ReadyWorkoutLauncherState extends ConsumerState<ReadyWorkoutLauncher> {
  int? _selectedWorkoutId;
  bool _starting = false;

  Future<void> _start(Workout workout) async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final details = await ref.read(
        workoutDetailsProvider(workout.id!).future,
      );
      if (!mounted || details == null) return;

      final result = await launchWorkoutSession(ref, details);
      if (!mounted) return;
      switch (result.status) {
        case WorkoutSessionLaunchStatus.started:
          context.push(AppRoutes.workoutSessionPath(workout.id!));
        case WorkoutSessionLaunchStatus.alreadyActive:
          setState(() => _starting = false);
          await showActiveWorkoutSessionDialog(context, ref);
        case WorkoutSessionLaunchStatus.notReady:
          _showMessage('Solo una scheda pronta può essere avviata.');
        case WorkoutSessionLaunchStatus.empty:
          _showMessage('Aggiungi almeno un esercizio prima di iniziare.');
      }
    } catch (_) {
      if (mounted) _showMessage('Impossibile avviare l\'allenamento.');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(watchWorkoutsProvider(widget.profileId));
    return workoutsAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (workouts) {
        final ready = workouts
            .where((workout) => workout.status == WorkoutDefinitionStatus.ready)
            .toList();
        if (ready.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inizia allenamento',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Non hai ancora schede pronte da avviare.'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.workoutNew),
                    icon: const Icon(Icons.add),
                    label: const Text('Crea una scheda'),
                  ),
                ],
              ),
            ),
          );
        }

        final matching = ready.where((w) => w.id == _selectedWorkoutId);
        final selected = matching.isEmpty ? ready.first : matching.first;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inizia allenamento',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: ValueKey(selected.id),
                  isExpanded: true,
                  initialValue: selected.id,
                  decoration: const InputDecoration(labelText: 'Scheda'),
                  items: [
                    for (final workout in ready)
                      DropdownMenuItem(
                        value: workout.id,
                        child: Text(
                          workout.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedWorkoutId = value),
                ),
                const SizedBox(height: 8),
                Text(
                  '${WorkoutLabels.type(selected.type)} · '
                  '${WorkoutLabels.levels(selected.effectiveSelectedLevels)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: selected.walkingBlock == null
                      ? const SizedBox.shrink()
                      : Text(
                          'Camminata ${selected.walkingBlock!.minutes} min · ${selected.walkingBlock!.positionLabel}',
                        ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _starting ? null : () => _start(selected),
                    icon: _starting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: const Text('Inizia allenamento'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
