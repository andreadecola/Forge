import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../data/repositories/performance_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../data/repositories/workout_session_providers.dart';
import '../../../../domain/entities/set_performance.dart';

String formatSetPerformance(SetPerformance p) =>
    'Serie ${p.setNumber}: ${[if (p.repetitions != null) '${p.repetitions} rip.', if (p.durationSeconds != null) '${p.durationSeconds} sec', if (p.loadKg != null) '${p.loadKg} kg', if (p.effort != null) 'difficoltà ${p.effort}/10'].join(' · ')}';

class ExercisePerformanceDiary extends ConsumerWidget {
  const ExercisePerformanceDiary({
    super.key,
    required this.sessionId,
    required this.order,
    required this.exerciseId,
    required this.totalSets,
    required this.timed,
  });
  final int sessionId;
  final int order;
  final int exerciseId;
  final int totalSets;
  final bool timed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(
      performedSetsProvider((sessionId: sessionId, order: order)),
    );
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    return ExpansionTile(
      title: const Text('Diario prestazioni'),
      subtitle: const Text('Valori effettivi, separati da quelli previsti'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      children: [
        sets.when(
          data: (values) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (values.isEmpty) const Text('Nessuna prestazione registrata.'),
              for (final value in values) Text(formatSetPerformance(value)),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_note),
                label: const Text('Registra prestazione'),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _PerformanceForm(
                    sessionId: sessionId,
                    order: order,
                    totalSets: totalSets,
                    timed: timed,
                    values: values,
                  ),
                ),
              ),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const Text('Impossibile leggere il diario.'),
        ),
        if (profile?.id != null)
          ref
              .watch(
                performanceHistoryProvider((
                  profileId: profile!.id!,
                  exerciseId: exerciseId,
                )),
              )
              .when(
                data: (records) {
                  final current = ref
                      .watch(persistedWorkoutSessionProvider(sessionId))
                      .valueOrNull;
                  final previous = records
                      .where(
                        (r) =>
                            current != null &&
                            r.sets.isNotEmpty &&
                            (r.startedAt.isBefore(current.startedAt) ||
                                r.startedAt == current.startedAt &&
                                    r.sessionId < sessionId),
                      )
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const Text('Confronto con le sessioni precedenti'),
                      if (previous.isEmpty)
                        const Text(
                          'Nessuna prestazione precedente registrata.',
                        ),
                      for (final record in previous)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '${formatItalianDate(record.startedAt)} ${formatItalianTime(record.startedAt)} · ${record.completedSets} serie completate\n${record.sets.map(formatSetPerformance).join('\n')}',
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Confronto non disponibile.'),
              ),
      ],
    );
  }
}

class _PerformanceForm extends ConsumerStatefulWidget {
  const _PerformanceForm({
    required this.sessionId,
    required this.order,
    required this.totalSets,
    required this.timed,
    required this.values,
  });
  final int sessionId, order, totalSets;
  final bool timed;
  final List<SetPerformance> values;
  @override
  ConsumerState<_PerformanceForm> createState() => _PerformanceFormState();
}

class _PerformanceFormState extends ConsumerState<_PerformanceForm> {
  final _quantity = TextEditingController();
  final _load = TextEditingController();
  final _effort = TextEditingController();
  int _set = 1;
  String? _error;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _fill();
  }

  void _fill() {
    final value = widget.values.where((v) => v.setNumber == _set).firstOrNull;
    _quantity.text =
        (widget.timed ? value?.durationSeconds : value?.repetitions)
            ?.toString() ??
        '';
    _load.text = value?.loadKg?.toString() ?? '';
    _effort.text = value?.effort?.toString() ?? '';
  }

  @override
  void dispose() {
    _quantity.dispose();
    _load.dispose();
    _effort.dispose();
    super.dispose();
  }

  int? _integer(TextEditingController input) {
    if (input.text.trim().isEmpty) return null;
    final value = int.tryParse(input.text.trim());
    if (value == null) {
      throw const FormatException(
        'Inserisci numeri interi per quantità e difficoltà.',
      );
    }
    return value;
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final text = _load.text.trim().replaceAll(',', '.');
      final kg = text.isEmpty ? null : double.tryParse(text);
      if (text.isNotEmpty && kg == null) {
        throw const FormatException('Carico non valido.');
      }
      final quantity = _integer(_quantity);
      await ref
          .read(performanceRepositoryProvider)
          .saveSet(
            sessionId: widget.sessionId,
            order: widget.order,
            performance: SetPerformance(
              setNumber: _set,
              repetitions: widget.timed ? null : quantity,
              durationSeconds: widget.timed ? quantity : null,
              loadKg: kg,
              effort: _integer(_effort),
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is FormatException
              ? error.message
              : 'Impossibile salvare la prestazione.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Prestazione effettiva',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Registra ciò che hai eseguito. Il salvataggio non completa automaticamente la serie e non modifica i valori previsti.',
          ),
          DropdownButtonFormField<int>(
            initialValue: _set,
            decoration: const InputDecoration(labelText: 'Serie'),
            items: [
              for (var i = 1; i <= widget.totalSets; i++)
                DropdownMenuItem(value: i, child: Text('Serie $i')),
            ],
            onChanged: _busy
                ? null
                : (v) {
                    if (v != null) {
                      setState(() {
                        _set = v;
                        _fill();
                      });
                    }
                  },
          ),
          TextField(
            controller: _quantity,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: widget.timed
                  ? 'Secondi effettivi'
                  : 'Ripetizioni effettive',
            ),
          ),
          TextField(
            controller: _load,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Carico utilizzato (kg, facoltativo)',
            ),
          ),
          TextField(
            controller: _effort,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Difficoltà percepita (1–10, facoltativa)',
            ),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: const Text('Salva prestazione'),
          ),
        ],
      ),
    ),
  );
}
