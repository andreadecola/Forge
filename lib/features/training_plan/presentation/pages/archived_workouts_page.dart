import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/forge_colors.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout.dart';
import '../workout_labels.dart';
import '../widgets/workout_status_badge.dart';

/// Elenco delle schede archiviate: unico punto in cui l'utente può
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina definitivamente'),
        content: Text(
          'Vuoi eliminare "${workout.name}"? L\'operazione non può essere '
          'annullata: la scheda e i suoi esercizi verranno persi per '
          'sempre.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    await ref.read(workoutRepositoryProvider).deleteWorkout(workout.id!);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Allenamento eliminato'),
        duration: Duration(seconds: 2),
      ),
    );
  }

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
              onDelete: () => _confirmDelete(context, ref, workout),
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
  const _ArchivedWorkoutCard({
    required this.workout,
    required this.onOpen,
    required this.onDelete,
  });

  final Workout workout;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      WorkoutLabels.type(workout.type),
      'Livello ${workout.level}',
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
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Elimina definitivamente',
                onPressed: onDelete,
              ),
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
    return const Center(
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Le schede che archivi da "I tuoi allenamenti" compaiono qui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ForgeColors.textSecondary),
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
