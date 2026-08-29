import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/validation/onboarding_validators.dart';
import '../../../../data/repositories/forge_providers.dart' show clockProvider;
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/pressure_measurement.dart';
import '../../../progress/presentation/progress_metrics.dart';
import '../../application/pressure_providers.dart';

class PressurePage extends ConsumerWidget {
  const PressurePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return profileAsync.when(
      data: (profile) => profile == null
          ? const Scaffold(
              body: Center(child: Text('Completa prima l\'onboarding.')),
            )
          : _PressurePageBody(profileId: profile.id!),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Errore: $error'))),
    );
  }
}

class _PressurePageBody extends ConsumerWidget {
  const _PressurePageBody({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(
      pressureMeasurementsProvider(profileId),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Pressione')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPressureForm(context, ref, profileId),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'L\'app registra valori misurati con uno strumento esterno. '
              'Forge non misura la pressione.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          Expanded(
            child: measurementsAsync.when(
              data: (measurements) {
                if (measurements.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nessuna rilevazione registrata. Aggiungi la prima.',
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: measurements.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final m = measurements[index];
                    return _PressureTile(
                      measurement: m,
                      onTap: () => _showPressureForm(
                        context,
                        ref,
                        profileId,
                        existing: m,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Errore: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PressureTile extends ConsumerWidget {
  const _PressureTile({required this.measurement, required this.onTap});

  final PressureMeasurement measurement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleParts = <String>[
      _formatDateTime(measurement.measuredAt),
      if (measurement.heartRate != null)
        formatHeartRate(measurement.heartRate!),
      if (measurement.measurementContext != null &&
          measurement.measurementContext!.isNotEmpty)
        measurement.measurementContext!,
      if (measurement.notes != null && measurement.notes!.isNotEmpty)
        measurement.notes!,
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        formatBloodPressure(measurement.systolic, measurement.diastolic),
      ),
      subtitle: Text(subtitleParts.join(' · ')),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, ref, measurement),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PressureMeasurement measurement,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminare questa misurazione?'),
      content: const Text('L\'operazione non può essere annullata.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Elimina'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  await ref.read(pressureControllerProvider).deleteMeasurement(measurement.id!);
  messenger
    ..clearSnackBars()
    ..showSnackBar(const SnackBar(content: Text('Misurazione eliminata')));
}

Future<void> _showPressureForm(
  BuildContext context,
  WidgetRef ref,
  int profileId, {
  PressureMeasurement? existing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _PressureForm(profileId: profileId, existing: existing),
    ),
  );
}

class _PressureForm extends ConsumerStatefulWidget {
  const _PressureForm({required this.profileId, this.existing});

  final int profileId;
  final PressureMeasurement? existing;

  @override
  ConsumerState<_PressureForm> createState() => _PressureFormState();
}

class _PressureFormState extends ConsumerState<_PressureForm> {
  final _formKey = GlobalKey<FormState>();
  late final _systolicController = TextEditingController(
    text: widget.existing?.systolic.toString() ?? '',
  );
  late final _diastolicController = TextEditingController(
    text: widget.existing?.diastolic.toString() ?? '',
  );
  late final _heartRateController = TextEditingController(
    text: widget.existing?.heartRate?.toString() ?? '',
  );
  late final _contextController = TextEditingController(
    text: widget.existing?.measurementContext ?? '',
  );
  late final _notesController = TextEditingController(
    text: widget.existing?.notes ?? '',
  );
  late DateTime _measuredAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Stesso `Clock` usato da `AddPressureMeasurement`/
    // `UpdatePressureMeasurement` per validare "non futura" (non
    // `DateTime.now()` diretto): era un limite noto di M7.1, corretto qui
    // con lo stesso approccio già adottato per peso/girovita in M7.2.
    _measuredAt = widget.existing?.measuredAt ?? ref.read(clockProvider).now();
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _contextController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _measuredAt,
      firstDate: DateTime(2000),
      lastDate: ref.read(clockProvider).now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_measuredAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _measuredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    // Guardia anti-doppio-submit: imposta il flag in modo sincrono, prima
    // ancora di validare, così un secondo tap arrivato prima del prossimo
    // frame trova già `_isSaving == true` e ritorna subito (sezione 37/49).
    if (_isSaving) return;
    setState(() => _isSaving = true);
    if (!_formKey.currentState!.validate()) {
      setState(() => _isSaving = false);
      return;
    }
    final controller = ref.read(pressureControllerProvider);
    final measurement = PressureMeasurement(
      id: widget.existing?.id,
      profileId: widget.profileId,
      measuredAt: _measuredAt,
      systolic: int.parse(_systolicController.text),
      diastolic: int.parse(_diastolicController.text),
      heartRate: _heartRateController.text.trim().isEmpty
          ? null
          : int.parse(_heartRateController.text),
      measurementContext: _contextController.text.trim().isEmpty
          ? null
          : _contextController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    final isNew = widget.existing == null;
    try {
      if (isNew) {
        await controller.addMeasurement(measurement);
      } else {
        await controller.updateMeasurement(measurement);
      }
    } on ArgumentError catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(e.message.toString())));
      }
      return;
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isNew ? 'Misurazione salvata' : 'Misurazione aggiornata',
          ),
        ),
      );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // Scrollabile (sezione 41): con più campi del form peso/girovita
      // (sistolica, diastolica, frequenza, contesto, note, oltre a
      // data/ora), lo spazio disponibile con la tastiera aperta o su uno
      // schermo piccolo può non bastare per mostrarli tutti in una volta.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null
                  ? 'Nuova rilevazione'
                  : 'Modifica rilevazione',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(_formatDateTime(_measuredAt)),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _systolicController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Sistolica'),
                    keyboardType: TextInputType.number,
                    validator: (_) =>
                        OnboardingValidators.systolicOverDiastolic(
                          int.tryParse(_systolicController.text),
                          int.tryParse(_diastolicController.text),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _diastolicController,
                    decoration: const InputDecoration(labelText: 'Diastolica'),
                    keyboardType: TextInputType.number,
                    validator: (_) =>
                        OnboardingValidators.systolicOverDiastolic(
                          int.tryParse(_systolicController.text),
                          int.tryParse(_diastolicController.text),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heartRateController,
              decoration: const InputDecoration(
                labelText: 'Frequenza cardiaca (facoltativa)',
                suffixText: 'bpm',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                final trimmed = (v ?? '').trim();
                if (trimmed.isEmpty) return null;
                final parsed = int.tryParse(trimmed);
                if (parsed == null) return 'Inserisci un numero valido.';
                return OnboardingValidators.heartRate(parsed);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contextController,
              decoration: const InputDecoration(
                labelText: 'Contesto (facoltativo)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Note (facoltative)',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salva'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
