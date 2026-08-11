import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../core/utils/statistics_formatters.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/walking_statistics.dart';
import '../../../../domain/entities/walking_statistics_period.dart';
import '../../application/walking_statistics_providers.dart';
import '../walking_metrics.dart';
import '../widgets/walking_activity_chart.dart';

class WalkingStatisticsPage extends ConsumerWidget {
  const WalkingStatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche camminate')),
      body: profileAsync.when(
        data: (profile) => profile?.id == null
            ? const Center(child: CircularProgressIndicator())
            : _WalkingStatisticsBody(profileId: profile!.id!),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _StatisticsError(),
      ),
    );
  }
}

class _WalkingStatisticsBody extends ConsumerWidget {
  const _WalkingStatisticsBody({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(walkingStatisticsPeriodProvider);
    final statisticsAsync = ref.watch(walkingStatisticsProvider(profileId));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Wrap(
            spacing: 8,
            children: [
              for (final value in WalkingStatisticsPeriod.values)
                ChoiceChip(
                  label: Text(_periodLabel(value)),
                  selected: period == value,
                  onSelected: (_) =>
                      ref.read(walkingStatisticsPeriodProvider.notifier).state =
                          value,
                ),
            ],
          ),
        ),
        Expanded(
          child: statisticsAsync.when(
            data: (statistics) => statistics.totalSessions == 0
                ? const _StatisticsEmpty()
                : _StatisticsContent(statistics: statistics),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _StatisticsError(
              onRetry: () =>
                  ref.invalidate(walkingStatisticsHistoryProvider(profileId)),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({required this.statistics});

  final WalkingStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final distanceValue = statistics.totalDistanceMeters == null
        ? '—'
        : formatWalkingDistance(statistics.totalDistanceMeters!);
    final distanceHint = statistics.totalDistanceMeters == null
        ? 'Nessun dato'
        : '${statistics.sessionsWithDistance} di '
              '${statistics.totalSessions} camminate';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            _KpiTile(label: 'Camminate', value: '${statistics.totalSessions}'),
            const SizedBox(width: 8),
            _KpiTile(
              label: 'Tempo attivo',
              value: formatStatisticsDuration(statistics.totalActiveDuration),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _KpiTile(label: 'Giorni attivi', value: '${statistics.activeDays}'),
            const SizedBox(width: 8),
            _KpiTile(
              label: 'Distanza',
              value: distanceValue,
              hint: distanceHint,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Riepilogo',
          rows: [
            _StatRow('Completate', '${statistics.completedSessions}'),
            _StatRow('Interrotte', '${statistics.abortedSessions}'),
            _StatRow(
              'Durata totale',
              formatStatisticsDuration(statistics.totalChronologicalDuration),
            ),
            _StatRow(
              'Tempo in pausa',
              formatStatisticsDuration(statistics.totalPauseDuration),
            ),
            _StatRow(
              'Passi',
              statistics.totalSteps == null
                  ? '— · Nessun dato'
                  : '${formatWalkingSteps(statistics.totalSteps!)} passi',
            ),
            _StatRow(
              'Frequenza media',
              formatWeeklyFrequency(statistics.averageSessionsPerWeek),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Medie',
          rows: [
            if (statistics.averageActiveDuration != null)
              _StatRow(
                'Durata attiva media',
                formatStatisticsDuration(statistics.averageActiveDuration!),
              ),
            if (statistics.averageDistanceMeters != null)
              _StatRow(
                'Distanza media',
                formatWalkingDistance(statistics.averageDistanceMeters!),
              ),
            if (statistics.averageSteps != null)
              _StatRow(
                'Passi medi',
                '${formatWalkingSteps(statistics.averageSteps!)} passi',
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Attività', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        WalkingActivityChart(points: statistics.activity),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.label, required this.value, this.hint});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ForgeColors.copper,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center),
              if (hint != null)
                Text(
                  hint!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ForgeColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.rows});

  final String title;
  final List<_StatRow> rows;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

String _periodLabel(WalkingStatisticsPeriod period) {
  switch (period) {
    case WalkingStatisticsPeriod.last7Days:
      return '7 giorni';
    case WalkingStatisticsPeriod.last30Days:
      return '30 giorni';
    case WalkingStatisticsPeriod.last90Days:
      return '90 giorni';
    case WalkingStatisticsPeriod.allTime:
      return 'Tutto';
  }
}

class _StatisticsEmpty extends StatelessWidget {
  const _StatisticsEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Nessuna camminata nel periodo selezionato.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _StatisticsError extends StatelessWidget {
  const _StatisticsError({this.onRetry});

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
            const Text('Impossibile caricare le statistiche.'),
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
