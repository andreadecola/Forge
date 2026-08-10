import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout.dart';
import '../../application/workout_editor_controller.dart';
import '../widgets/workout_card.dart';

/// Punto di ingresso alle schede allenamento (voce "Programma" della
/// bottom navigation). Mostra solo le schede attive del profilo corrente:
/// le schede archiviate non compaiono qui (già filtrate da
/// `watchWorkoutsProvider`, che legge `attivo = true`) — restano
/// consultabili in `ArchivedWorkoutsPage`, raggiungibile dall'azione
/// "Archiviate" in alto.
class WorkoutListPage extends ConsumerWidget {
  const WorkoutListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('I tuoi allenamenti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Allenamenti archiviati',
            onPressed: () => context.push(AppRoutes.workoutArchived),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => profile?.id == null
            ? const Center(child: CircularProgressIndicator())
            : _WorkoutList(profileId: profile!.id!),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _ErrorState(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.workoutNew),
        icon: const Icon(Icons.add),
        label: const Text('Nuovo allenamento'),
      ),
    );
  }
}

class _WorkoutList extends ConsumerWidget {
  const _WorkoutList({required this.profileId});

  final int profileId;

  Future<void> _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archivia scheda'),
        content: Text(
          'Vuoi archiviare "${workout.name}"? Non comparirà più nell\'elenco, '
          'ma resterà salvata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archivia'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref
          .read(workoutEditorControllerProvider(workout.id!).notifier)
          .archive();
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Allenamento archiviato'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(watchWorkoutsProvider(profileId));

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return _EmptyState(
            onCreate: () => context.push(AppRoutes.workoutNew),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return WorkoutCard(
              workout: workout,
              onOpen: () =>
                  context.push(AppRoutes.workoutDetailPath(workout.id!)),
              onEdit: () =>
                  context.push(AppRoutes.workoutEditPath(workout.id!)),
              onArchive: () => _confirmArchive(context, ref, workout),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const _ErrorState(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center_outlined, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Non hai ancora creato allenamenti.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onCreate,
              child: const Text('Crea il primo allenamento'),
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
