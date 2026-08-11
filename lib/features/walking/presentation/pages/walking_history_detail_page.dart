import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../domain/entities/walking_session.dart';
import '../../../../domain/entities/walking_session_status.dart';
import '../../application/walking_history_providers.dart';
import '../walking_metrics.dart';
import '../walking_session_formatter.dart';

class WalkingHistoryDetailPage extends ConsumerWidget {
  const WalkingHistoryDetailPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(walkingHistoryDetailsProvider(sessionId));
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio camminata')),
      body: sessionAsync.when(
        data: (session) {
          if (session == null ||
              session.status == WalkingSessionStatus.inProgress) {
            return const Center(
              child: Text('Camminata non trovata nello storico.'),
            );
          }
          return _WalkingHistoryDetailBody(session: session);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Impossibile caricare il dettaglio.')),
      ),
    );
  }
}

class _WalkingHistoryDetailBody extends StatelessWidget {
  const _WalkingHistoryDetailBody({required this.session});

  final WalkingSession session;

  @override
  Widget build(BuildContext context) {
    final endedAt = session.endedAt;
    final hasDuration = endedAt != null;
    final total = hasDuration
        ? formatWalkingDuration(
            session.chronologicalDuration(endedAt).inSeconds,
          )
        : null;
    final paused = hasDuration
        ? formatWalkingDuration(session.pauseDuration(endedAt).inSeconds)
        : null;
    final active = hasDuration
        ? formatWalkingDuration(session.activeDuration(endedAt).inSeconds)
        : null;
    final pauseSeconds = endedAt == null
        ? 0
        : session.pauseDuration(endedAt).inSeconds;
    final notes = session.notes?.trim();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Camminata', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            avatar: Icon(
              session.status == WalkingSessionStatus.completed
                  ? Icons.check_circle_outline
                  : Icons.pause_circle_outline,
              size: 18,
              color: session.status == WalkingSessionStatus.completed
                  ? ForgeColors.success
                  : ForgeColors.copper,
            ),
            label: Text(
              session.status == WalkingSessionStatus.completed
                  ? 'Completata'
                  : 'Interrotta',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: 'Data',
                  value: formatItalianDate(session.startedAt),
                ),
                _InfoRow(
                  label: 'Ora inizio',
                  value: formatItalianTime(session.startedAt),
                ),
                if (endedAt != null)
                  _InfoRow(
                    label: 'Ora fine',
                    value: formatItalianTime(endedAt),
                  ),
                if (active != null)
                  _InfoRow(label: 'Tempo attivo', value: active),
                if (total != null)
                  _InfoRow(label: 'Durata totale', value: total),
                if (paused != null && pauseSeconds > 0)
                  _InfoRow(label: 'Tempo in pausa', value: paused),
                if (session.distanceMeters != null)
                  _InfoRow(
                    label: 'Distanza',
                    value: formatWalkingDistance(session.distanceMeters!),
                  ),
                if (session.steps != null)
                  _InfoRow(
                    label: 'Passi',
                    value: '${formatWalkingSteps(session.steps!)} passi',
                  ),
              ],
            ),
          ),
        ),
        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Note', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(notes),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 16),
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
