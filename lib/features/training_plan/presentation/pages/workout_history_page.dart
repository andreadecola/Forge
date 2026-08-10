import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/forge_colors.dart';
import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/workout_session_history_item.dart';
import '../../../../domain/entities/workout_session_persistence_status.dart';
import '../../application/workout_history_providers.dart';
import '../workout_session_history_labels.dart';

/// Elenco delle sessioni concluse (COMPLETED/ABORTED) del profilo, più
/// recenti prima (Milestone 4.5.1). Raggiungibile da "Programma"; non è
/// una voce della bottom navigation.
class WorkoutHistoryPage extends ConsumerWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Storico allenamenti')),
      body: profileAsync.when(
        data: (profile) => profile?.id == null
            ? const Center(child: CircularProgressIndicator())
            : _HistoryBody(profileId: profile!.id!),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _ErrorState(),
      ),
    );
  }
}

class _HistoryBody extends ConsumerWidget {
  const _HistoryBody({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(workoutHistoryFilterProvider);
    final historyAsync = ref.watch(filteredWorkoutHistoryProvider(profileId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tutti'),
                selected: filter == WorkoutHistoryFilter.all,
                onSelected: (_) =>
                    ref.read(workoutHistoryFilterProvider.notifier).state =
                        WorkoutHistoryFilter.all,
              ),
              ChoiceChip(
                label: const Text('Completati'),
                selected: filter == WorkoutHistoryFilter.completed,
                onSelected: (_) =>
                    ref.read(workoutHistoryFilterProvider.notifier).state =
                        WorkoutHistoryFilter.completed,
              ),
              ChoiceChip(
                label: const Text('Interrotti'),
                selected: filter == WorkoutHistoryFilter.aborted,
                onSelected: (_) =>
                    ref.read(workoutHistoryFilterProvider.notifier).state =
                        WorkoutHistoryFilter.aborted,
              ),
            ],
          ),
        ),
        Expanded(
          child: historyAsync.when(
            data: (items) {
              if (items.isEmpty) return const _EmptyState();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      items.length == 1
                          ? '1 allenamento'
                          : '${items.length} allenamenti',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ForgeColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) =>
                          _HistoryCard(item: items[index]),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _ErrorState(
              onRetry: () => ref.invalidate(workoutHistoryProvider(profileId)),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final WorkoutSessionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        item.status == WorkoutSessionPersistenceStatus.completed;
    final skippedLine = item.skippedExercises > 0
        ? '${item.skippedExercises} ${item.skippedExercises == 1 ? 'saltato' : 'saltati'}'
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () =>
            context.push(AppRoutes.workoutHistoryDetailPath(item.sessionId)),
        title: Text(
          item.workoutName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${formatItalianDate(item.startedAt)} · '
              '${formatItalianTime(item.startedAt)}',
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle_outline
                      : Icons.pause_circle_outline,
                  size: 16,
                  color: isCompleted ? ForgeColors.success : ForgeColors.copper,
                ),
                const SizedBox(width: 4),
                Text(WorkoutSessionHistoryLabels.status(item.status)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${item.completedExercises} '
              '${item.completedExercises == 1 ? 'esercizio completato' : 'esercizi completati'}'
              '${skippedLine == null ? '' : ' · $skippedLine'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ForgeColors.textSecondary,
              ),
            ),
          ],
        ),
        isThreeLine: true,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Nessun allenamento registrato.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quando completerai un allenamento, lo troverai qui.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 16),
            const Text(
              'Impossibile caricare lo storico.',
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Riprova')),
            ],
          ],
        ),
      ),
    );
  }
}
