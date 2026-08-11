import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/forge_colors.dart';
import '../../../../data/repositories/forge_providers.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/walking_session_status.dart';
import '../../application/walking_session_controller.dart';
import '../../application/walking_session_runtime_state.dart';
import '../walking_metrics.dart';
import '../walking_session_formatter.dart';
import '../widgets/walking_metrics_sheet.dart';

class WalkingSessionPage extends ConsumerStatefulWidget {
  const WalkingSessionPage({super.key});

  @override
  ConsumerState<WalkingSessionPage> createState() => _WalkingSessionPageState();
}

class _WalkingSessionPageState extends ConsumerState<WalkingSessionPage> {
  bool _restoring = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_restoreIfNeeded);
  }

  Future<void> _restoreIfNeeded() async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile?.id != null) {
      await ref
          .read(walkingSessionControllerProvider.notifier)
          .restoreActive(profile!.id!);
    }
    if (mounted) setState(() => _restoring = false);
  }

  Future<void> _confirmExit() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vuoi uscire dalla schermata?'),
        content: const Text(
          'La camminata resterà in corso e potrai riprenderla dalla Home.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continua camminata'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Esci dalla schermata'),
          ),
        ],
      ),
    );
    if (exit == true && mounted) context.pop();
  }

  Future<void> _complete(WalkingSessionRuntimeState runtime) async {
    try {
      final completed = await ref
          .read(walkingSessionControllerProvider.notifier)
          .complete();
      if (!completed && mounted) {
        _showError('La camminata è già terminata.');
      }
    } catch (_) {
      if (mounted) _showError('Non è stato possibile completare la camminata.');
    }
  }

  Future<void> _confirmAbort(WalkingSessionRuntimeState runtime) async {
    final abort = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Interrompere la camminata?'),
        content: const Text('La sessione verrà conservata nello storico.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continua'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Interrompi'),
          ),
        ],
      ),
    );
    if (abort != true) return;

    try {
      final aborted = await ref
          .read(walkingSessionControllerProvider.notifier)
          .abort();
      if (!aborted) {
        if (mounted) _showError('La camminata è già terminata.');
        return;
      }
      if (!mounted) return;
      ref.read(walkingSessionControllerProvider.notifier).clear();
      final messenger = ScaffoldMessenger.of(context);
      context.go(AppRoutes.dashboard);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Camminata interrotta.')));
    } catch (_) {
      if (mounted) {
        _showError('Non è stato possibile interrompere la camminata.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editMetrics(WalkingSessionRuntimeState runtime) async {
    await _editWalkingMetrics(context, ref, runtime);
  }

  @override
  Widget build(BuildContext context) {
    final runtime = ref.watch(walkingSessionControllerProvider);
    if (_restoring && runtime == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (runtime == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camminata')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nessuna camminata attiva.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  child: const Text('Torna alla Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final terminal = runtime.isTerminal;
    return PopScope<Object?>(
      canPop: terminal,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && terminal) {
          Future.microtask(
            () => ref.read(walkingSessionControllerProvider.notifier).clear(),
          );
        } else if (!didPop && !terminal) {
          _confirmExit();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Camminata')),
        body: terminal
            ? _SummaryView(runtime: runtime)
            : _ActiveWalkingView(
                runtime: runtime,
                onPause: () =>
                    ref.read(walkingSessionControllerProvider.notifier).pause(),
                onResume: () => ref
                    .read(walkingSessionControllerProvider.notifier)
                    .resume(),
                onComplete: () => _complete(runtime),
                onAbort: () => _confirmAbort(runtime),
                onEditMetrics: () => _editMetrics(runtime),
              ),
      ),
    );
  }
}

class _ActiveWalkingView extends ConsumerWidget {
  const _ActiveWalkingView({
    required this.runtime,
    required this.onPause,
    required this.onResume,
    required this.onComplete,
    required this.onAbort,
    required this.onEditMetrics,
  });

  final WalkingSessionRuntimeState runtime;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onComplete;
  final VoidCallback onAbort;
  final VoidCallback onEditMetrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.read(clockProvider);
    final activeSeconds = runtime.activeSeconds(clock);
    final chronologicalSeconds = runtime.chronologicalSeconds(clock);
    final pauseSeconds = runtime.pauseSeconds(clock);
    final paused = runtime.isPaused;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 360),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    paused ? 'In pausa' : 'In corso',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: paused
                          ? ForgeColors.copperLight
                          : ForgeColors.success,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatWalkingDuration(activeSeconds),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tempo attivo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DurationDetails(
                chronologicalSeconds: chronologicalSeconds,
                pauseSeconds: pauseSeconds,
                showPause: paused || pauseSeconds > 0,
              ),
              const SizedBox(height: 32),
              _WalkingMetricsSection(
                distanceMeters: runtime.distanceMeters,
                steps: runtime.steps,
                onEdit: onEditMetrics,
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: paused ? onResume : onPause,
                      icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                      label: Text(paused ? 'Riprendi' : 'Pausa'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onComplete,
                      child: const Text('Completa'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: onAbort,
                    child: const Text('Interrompi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryView extends ConsumerWidget {
  const _SummaryView({required this.runtime});

  final WalkingSessionRuntimeState runtime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.read(clockProvider);
    final completed = runtime.status == WalkingSessionStatus.completed;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              completed ? Icons.check_circle_outline : Icons.info_outline,
              size: 60,
              color: completed ? ForgeColors.success : ForgeColors.copper,
            ),
            const SizedBox(height: 16),
            Text(
              completed ? 'Camminata completata' : 'Camminata interrotta',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _DurationDetails(
              chronologicalSeconds: runtime.chronologicalSeconds(clock),
              pauseSeconds: runtime.pauseSeconds(clock),
              activeSeconds: runtime.activeSeconds(clock),
              showPause: runtime.pauseSeconds(clock) > 0,
            ),
            const SizedBox(height: 12),
            _WalkingMetricsSection(
              distanceMeters: runtime.distanceMeters,
              steps: runtime.steps,
              onEdit: () => _editWalkingMetrics(context, ref, runtime),
              summary: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref.read(walkingSessionControllerProvider.notifier).clear();
                  context.go(AppRoutes.dashboard);
                },
                child: const Text('Fine'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkingMetricsSection extends StatelessWidget {
  const _WalkingMetricsSection({
    required this.distanceMeters,
    required this.steps,
    required this.onEdit,
    this.summary = false,
  });

  final int? distanceMeters;
  final int? steps;
  final VoidCallback onEdit;
  final bool summary;

  @override
  Widget build(BuildContext context) {
    final hasMetrics = distanceMeters != null || steps != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (distanceMeters != null)
          _SummaryRow(
            label: 'Distanza',
            value: formatWalkingDistance(distanceMeters!),
          ),
        if (steps != null) ...[
          if (distanceMeters != null) const SizedBox(height: 8),
          _SummaryRow(label: 'Passi', value: formatWalkingSteps(steps!)),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            onPressed: onEdit,
            icon: Icon(hasMetrics ? Icons.edit : Icons.add),
            label: Text(
              summary
                  ? (hasMetrics ? 'Modifica' : 'Aggiungi dati')
                  : (hasMetrics ? 'Modifica dati' : 'Registra dati'),
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationDetails extends StatelessWidget {
  const _DurationDetails({
    required this.chronologicalSeconds,
    required this.pauseSeconds,
    this.activeSeconds,
    this.showPause = false,
  });

  final int chronologicalSeconds;
  final int pauseSeconds;
  final int? activeSeconds;
  final bool showPause;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (activeSeconds != null)
          _SummaryRow(
            label: 'Tempo attivo',
            value: formatWalkingDuration(activeSeconds!),
          ),
        _SummaryRow(
          label: 'Durata totale',
          value: formatWalkingDuration(chronologicalSeconds),
        ),
        if (showPause)
          _SummaryRow(
            label: 'Tempo in pausa',
            value: formatWalkingDuration(pauseSeconds),
          ),
      ],
    );
  }
}

Future<void> _editWalkingMetrics(
  BuildContext context,
  WidgetRef ref,
  WalkingSessionRuntimeState runtime,
) async {
  final result = await WalkingMetricsSheet.show(
    context,
    distanceMeters: runtime.distanceMeters,
    steps: runtime.steps,
  );
  if (result == null || !context.mounted) return;

  try {
    final updated = await ref
        .read(walkingSessionControllerProvider.notifier)
        .updateMetrics(
          distanceMeters: result.distanceMeters,
          steps: result.steps,
        );
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            updated
                ? 'Dati camminata aggiornati'
                : 'Non è stato possibile aggiornare i dati camminata.',
          ),
        ),
      );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Non è stato possibile aggiornare i dati camminata.'),
          ),
        );
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
