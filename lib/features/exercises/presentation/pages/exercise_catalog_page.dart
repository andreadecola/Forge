import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../application/exercise_catalog_providers.dart';
import '../widgets/exercise_card.dart';
import '../widgets/exercise_filters_sheet.dart';
import '../widgets/exercise_search_field.dart';

class ExerciseCatalogPage extends ConsumerWidget {
  const ExerciseCatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(exerciseFiltersProvider);
    final itemsAsync = ref.watch(filteredExercisesProvider);
    final filterCount = activeFilterCount(filters);
    final hasActiveFilters =
        (filters.searchQuery?.isNotEmpty ?? false) || filterCount > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Catalogo esercizi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ExerciseSearchField(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => showExerciseFiltersSheet(context),
                  icon: const Icon(Icons.tune),
                  label: Text(
                    filterCount == 0 ? 'Filtri' : 'Filtri ($filterCount)',
                  ),
                ),
                if (hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () =>
                        ref.read(exerciseFiltersProvider.notifier).reset(),
                    child: const Text('Reimposta filtri'),
                  ),
                ],
                const Spacer(),
                itemsAsync.maybeWhen(
                  data: (items) => Text(
                    '${items.length} ${items.length == 1 ? 'risultato' : 'risultati'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(
                    onReset: () =>
                        ref.read(exerciseFiltersProvider.notifier).reset(),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ExerciseCard(
                      item: item,
                      onTap: () => context.push(
                        AppRoutes.exerciseDetailPath(item.exercise.id),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _ErrorState(
                onRetry: () => ref.invalidate(catalogItemsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 40),
            const SizedBox(height: 16),
            const Text(
              'Nessun esercizio corrisponde ai filtri selezionati.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onReset,
              child: const Text('Reimposta filtri'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

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
              'Non è stato possibile caricare il catalogo esercizi.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }
}
