import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../data/repositories/walking_session_providers.dart';
import '../../application/walking_session_controller.dart';

class WalkingEntryCard extends ConsumerStatefulWidget {
  const WalkingEntryCard({super.key, required this.profileId});

  final int profileId;

  @override
  ConsumerState<WalkingEntryCard> createState() => _WalkingEntryCardState();
}

class _WalkingEntryCardState extends ConsumerState<WalkingEntryCard> {
  bool _busy = false;

  Future<void> _openWalkingSession() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final controller = ref.read(walkingSessionControllerProvider.notifier);
      await controller.restoreActive(widget.profileId);
      if (!mounted) return;
      if (ref.read(walkingSessionControllerProvider) == null) {
        _showError('Non è stato possibile riprendere la camminata.');
        return;
      }
      context.push(AppRoutes.walkingSession);
    } catch (_) {
      if (mounted) _showError('Non è stato possibile aprire la camminata.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startWalkingSession() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final controller = ref.read(walkingSessionControllerProvider.notifier);
      await controller.start(widget.profileId);
      if (!mounted) return;
      if (ref.read(walkingSessionControllerProvider) == null) {
        _showError('Non è stato possibile avviare la camminata.');
        return;
      }
      context.push(AppRoutes.walkingSession);
    } catch (_) {
      if (mounted) _showError('Non è stato possibile avviare la camminata.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(
      activeWalkingSessionProvider(widget.profileId),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: activeAsync.when(
          loading: () => const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.directions_walk),
            title: Text('Camminata'),
            subtitle: Text('Verifica sessione in corso...'),
          ),
          error: (_, _) => _content(
            title: 'Camminata',
            subtitle: 'Registra una camminata senza tracking automatico.',
            label: 'Avvia camminata',
            onPressed: _startWalkingSession,
          ),
          data: (active) => active == null
              ? _content(
                  title: 'Camminata',
                  subtitle: 'Registra una camminata senza tracking automatico.',
                  label: 'Avvia camminata',
                  onPressed: _startWalkingSession,
                )
              : _content(
                  title: 'Camminata in corso',
                  subtitle: 'La sessione è pronta per essere ripresa.',
                  label: 'Riprendi',
                  onPressed: _openWalkingSession,
                ),
        ),
      ),
    );
  }

  Widget _content({
    required String title,
    required String subtitle,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_walk),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy ? null : onPressed,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(label),
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 4,
          runSpacing: 0,
          children: [
            TextButton.icon(
              onPressed: _busy
                  ? null
                  : () => context.push(AppRoutes.walkingHistory),
              icon: const Icon(Icons.history),
              label: const Text('Storico'),
            ),
            TextButton.icon(
              onPressed: _busy
                  ? null
                  : () => context.push(AppRoutes.walkingStatistics),
              icon: const Icon(Icons.bar_chart_outlined),
              label: const Text('Statistiche'),
            ),
          ],
        ),
      ],
    );
  }
}
