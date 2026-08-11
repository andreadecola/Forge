import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/forge_colors.dart';
import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../data/repositories/walking_session_providers.dart';
import '../../../../domain/entities/walking_session.dart';
import '../../../../domain/entities/walking_session_status.dart';
import '../../application/walking_history_providers.dart';
import '../walking_metrics.dart';
import '../walking_session_formatter.dart';

class WalkingHistoryPage extends ConsumerWidget {
  const WalkingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Storico camminate')),
      body: profileAsync.when(
        data: (profile) => profile?.id == null
            ? const Center(child: CircularProgressIndicator())
            : _WalkingHistoryBody(profileId: profile!.id!),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _HistoryError(),
      ),
    );
  }
}

class _WalkingHistoryBody extends ConsumerWidget {
  const _WalkingHistoryBody({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(walkingHistoryFilterProvider);
    final historyAsync = ref.watch(filteredWalkingHistoryProvider(profileId));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tutti'),
                selected: filter == WalkingHistoryFilter.all,
                onSelected: (_) =>
                    ref.read(walkingHistoryFilterProvider.notifier).state =
                        WalkingHistoryFilter.all,
              ),
              ChoiceChip(
                label: const Text('Completati'),
                selected: filter == WalkingHistoryFilter.completed,
                onSelected: (_) =>
                    ref.read(walkingHistoryFilterProvider.notifier).state =
                        WalkingHistoryFilter.completed,
              ),
              ChoiceChip(
                label: const Text('Interrotti'),
                selected: filter == WalkingHistoryFilter.aborted,
                onSelected: (_) =>
                    ref.read(walkingHistoryFilterProvider.notifier).state =
                        WalkingHistoryFilter.aborted,
              ),
            ],
          ),
        ),
        Expanded(
          child: historyAsync.when(
            data: (sessions) {
              if (sessions.isEmpty) return const _HistoryEmpty();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      sessions.length == 1
                          ? '1 camminata'
                          : '${sessions.length} camminate',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ForgeColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) =>
                          _WalkingHistoryCard(session: sessions[index]),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _HistoryError(
              onRetry: () => ref.invalidate(walkingHistoryProvider(profileId)),
            ),
          ),
        ),
      ],
    );
  }
}

class _WalkingHistoryCard extends StatelessWidget {
  const _WalkingHistoryCard({required this.session});

  final WalkingSession session;

  @override
  Widget build(BuildContext context) {
    final completed = session.status == WalkingSessionStatus.completed;
    final duration = session.endedAt == null
        ? null
        : formatWalkingDuration(
            session.activeDuration(session.endedAt!).inSeconds,
          );
    final metricParts = <String>[
      if (session.distanceMeters != null)
        formatWalkingDistance(session.distanceMeters!),
      if (session.steps != null) '${formatWalkingSteps(session.steps!)} passi',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: session.id == null
            ? null
            : () =>
                  context.push(AppRoutes.walkingHistoryDetailPath(session.id!)),
        title: Text(
          'Camminata — ${completed ? 'Completata' : 'Interrotta'}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${formatItalianDate(session.startedAt)} · '
              '${formatItalianTime(session.startedAt)}',
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  completed
                      ? Icons.check_circle_outline
                      : Icons.pause_circle_outline,
                  size: 16,
                  color: completed ? ForgeColors.success : ForgeColors.copper,
                ),
                const SizedBox(width: 4),
                Text(completed ? 'Completata' : 'Interrotta'),
                if (duration != null) ...[
                  const SizedBox(width: 10),
                  Flexible(child: Text('Tempo attivo $duration')),
                ],
              ],
            ),
            if (metricParts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                metricParts.join(' · '),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ForgeColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Nessuna camminata nello storico.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({this.onRetry});

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
            const Text('Impossibile caricare lo storico.'),
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
