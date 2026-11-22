import '../../../../core/theme/forge_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout.dart';
import '../workout_labels.dart';
import '../widgets/workout_status_badge.dart';
import '../widgets/delete_workout_button.dart';

/// Elenco delle schede archiviate: punto in cui l'utente può
/// rivederle dopo [WorkoutRepository.archiveWorkout], che le esclude da
/// [WorkoutListPage]. Nessuna modifica/riordino/rimozione esercizi qui
/// (si apre il dettaglio per quello), ma **eliminazione definitiva**
/// consentita: un archivio non deve diventare un accumulo permanente.
class ArchivedWorkoutsPage extends ConsumerWidget {
  const ArchivedWorkoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Allenamenti archiviati')),
      body: profileAsync.when(
        data: (profile) => profile?.id == null
            ? const Center(child: CircularProgressIndicator())
            : _ArchivedList(profileId: profile!.id!),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _ErrorState(),
      ),
    );
  }
}

class _ArchivedList extends ConsumerWidget {
  const _ArchivedList({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(watchArchivedWorkoutsProvider(profileId));

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return const _EmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return _ArchivedWorkoutCard(
              workout: workout,
              onOpen: () =>
                  context.push(AppRoutes.workoutDetailPath(workout.id!)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const _ErrorState(),
    );
  }
}

class _ArchivedWorkoutCard extends StatelessWidget {
  const _ArchivedWorkoutCard({required this.workout, required this.onOpen});

  final Workout workout;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      WorkoutLabels.type(workout.type),
      WorkoutLabels.levels(workout.effectiveSelectedLevels),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleParts.join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              WorkoutStatusBadge(status: workout.status),
              DeleteWorkoutButton(workout: workout),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.archive_outlined, size: 48),
            SizedBox(height: 16),
            Text(
              'Nessuna scheda archiviata.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ForgeTypography.bodySize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Le schede che archivi da "I tuoi allenamenti" compaiono qui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40),
            SizedBox(height: 16),
            Text('Si è verificato un errore.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
