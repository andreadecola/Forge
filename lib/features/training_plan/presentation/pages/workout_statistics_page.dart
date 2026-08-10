import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../core/utils/statistics_formatters.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/workout_statistics.dart';
import '../../../../domain/entities/workout_statistics_period.dart';
import '../../application/workout_statistics_providers.dart';
import '../widgets/workout_activity_chart.dart';
import '../workout_statistics_labels.dart';

/// Statistiche allenamenti (Milestone 4.5.2): calcolate esclusivamente da
/// dati realmente persistiti (`sessioni_allenamento`/`sessioni_esercizi`)
/// — nessuna metrica inventata (niente calorie, carico, tempo attivo
/// preciso). Raggiungibile da "Programma", nessuna voce bottom
/// navigation.
class WorkoutStatisticsPage extends ConsumerWidget {
  const WorkoutStatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche allenamenti')),
      body: profileAsync.when(
        data: (profile) => profile?.id == null
            ? const Center(child: CircularProgressIndicator())
            : _StatisticsBody(profileId: profile!.id!),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _ErrorState(),
      ),
    );
  }
}

class _StatisticsBody extends ConsumerWidget {
  const _StatisticsBody({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(workoutStatisticsPeriodProvider);
    final statisticsAsync = ref.watch(workoutStatisticsProvider(profileId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Wrap(
            spacing: 8,
            children: [
              for (final p in WorkoutStatisticsPeriod.values)
                ChoiceChip(
                  label: Text(WorkoutStatisticsLabels.period(p)),
                  selected: period == p,
                  onSelected: (_) =>
                      ref.read(workoutStatisticsPeriodProvider.notifier).state =
                          p,
                ),
            ],
          ),
        ),
        Expanded(
          child: statisticsAsync.when(
            data: (stats) => stats.totalSessions == 0
                ? const _EmptyState()
                : _StatisticsContent(stats: stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _ErrorState(
              onRetry: () =>
                  ref.invalidate(workoutStatisticsHistoryProvider(profileId)),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({required this.stats});

  final WorkoutStatistics stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            _KpiTile(label: 'Allenamenti', value: '${stats.totalSessions}'),
            const SizedBox(width: 8),
            _KpiTile(label: 'Completati', value: '${stats.completedSessions}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _KpiTile(
              label: 'Serie completate',
              value: '${stats.totalSetsCompleted}',
            ),
            const SizedBox(width: 8),
            _KpiTile(label: 'Giorni attivi', value: '${stats.activeDays}'),
          ],
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Riepilogo',
          rows: [
            _StatRow('Allenamenti interrotti', '${stats.abortedSessions}'),
            _StatRow(
              'Tasso completamento',
              formatPercentage(stats.completionRate),
            ),
            _StatRow('Esercizi completati', '${stats.totalExercisesCompleted}'),
            _StatRow('Esercizi saltati', '${stats.totalExercisesSkipped}'),
            _StatRow('Serie pianificate', '${stats.totalPlannedSets}'),
            _StatRow(
              'Percentuale serie completate',
              stats.setCompletionRate == null
                  ? 'Non disponibile'
                  : '${stats.totalSetsCompleted} / ${stats.totalPlannedSets} '
                        '(${formatPercentage(stats.setCompletionRate!)})',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Tempo',
          footnote: 'Include le pause.',
          rows: [
            _StatRow(
              'Durata totale',
              formatStatisticsDuration(stats.totalDuration),
            ),
            _StatRow(
              'Durata media',
              stats.averageDuration == null
                  ? 'Non disponibile'
                  : formatStatisticsDuration(stats.averageDuration!),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Frequenza',
          rows: [
            _StatRow(
              'Frequenza media',
              formatWeeklyFrequency(stats.averageSessionsPerWeek),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Attività', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        WorkoutActivityChart(points: stats.activity),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ForgeColors.copper,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.rows, this.footnote});

  final String title;
  final List<_StatRow> rows;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...rows,
            if (footnote != null) ...[
              const SizedBox(height: 8),
              Text(
                footnote!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ForgeColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
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
            const Icon(Icons.bar_chart, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Nessun allenamento nel periodo selezionato.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
              'Impossibile caricare le statistiche.',
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
