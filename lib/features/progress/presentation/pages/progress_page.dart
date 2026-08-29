import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/validation/onboarding_validators.dart';
import '../../../../data/repositories/forge_providers.dart' show clockProvider;
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/body_measurement.dart';
import '../../../../domain/entities/body_progress_summary.dart';
import '../../../../domain/entities/pressure_measurement.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/services/body_progress_service.dart';
import '../../../../domain/services/pressure_progress_service.dart';
import '../../../pressure/application/pressure_providers.dart';
import '../../../weight/application/weight_providers.dart';
import '../progress_metrics.dart';
import '../widgets/progress_charts_section.dart';

String _formatProgressDateTime(DateTime date) {
  return '${formatItalianDate(date)} · ${formatItalianTime(date)}';
}

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return profileAsync.when(
      data: (profile) => profile == null
          ? const Scaffold(
              body: Center(child: Text('Completa prima l\'onboarding.')),
            )
          : _ProgressPageBody(profile: profile),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Errore: $error'))),
    );
  }
}

class _ProgressPageBody extends ConsumerWidget {
  const _ProgressPageBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileId = profile.id!;
    final measurementsAsync = ref.watch(bodyMeasurementsProvider(profileId));
    final pressureMeasurementsAsync = ref.watch(
      pressureMeasurementsProvider(profileId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Progressi')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMeasurementForm(context, ref, profileId),
        tooltip: 'Aggiungi peso o girovita',
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Riepilogo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            measurementsAsync.when(
              data: (measurements) {
                final summary = BodyProgressService.summarize(
                  profile: profile,
                  measurements: measurements,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryCard(
                      summary: summary,
                      onAdd: () =>
                          _showMeasurementForm(context, ref, profileId),
                    ),
                    const SizedBox(height: 12),
                    _WaistSummaryCard(
                      summary: summary,
                      onAdd: () =>
                          _showMeasurementForm(context, ref, profileId),
                    ),
                    const SizedBox(height: 20),
                    _BodyHistorySection(
                      measurements: measurements,
                      profileId: profileId,
                      ref: ref,
                      context: context,
                    ),
                  ],
                );
              },
              loading: () => const _ProgressLoadingCard(
                label: 'Caricamento misurazioni corporee...',
              ),
              error: (error, _) => _ProgressErrorCard(error: error),
            ),
            const SizedBox(height: 12),
            pressureMeasurementsAsync.when(
              data: (pressureMeasurements) => _PressureSummaryCard(
                latest: PressureProgressService.latest(pressureMeasurements),
              ),
              loading: () =>
                  const _ProgressLoadingCard(label: 'Caricamento pressione...'),
              error: (error, _) => _ProgressErrorCard(error: error),
            ),
            const SizedBox(height: 20),
            ProgressChartsSection(
              bodyMeasurements: measurementsAsync,
              pressureMeasurements: pressureMeasurementsAsync,
              now: ref.watch(clockProvider).now(),
            ),
            const SizedBox(height: 20),
            _QuickActionsCard(
              onAddBody: () => _showMeasurementForm(context, ref, profileId),
              onManagePressure: () => context.push(AppRoutes.pressure),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.onAdd});

  final BodyProgressSummary summary;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              title: 'Peso',
              icon: Icons.monitor_weight_outlined,
              actionLabel: 'Aggiungi',
              onAction: onAdd,
            ),
            const SizedBox(height: 12),
            if (summary.latestWeightKg == null)
              const Text('Nessuna misurazione di peso registrata')
            else ...[
              Text(
                formatWeightKg(summary.latestWeightKg!),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Ultima misurazione'),
              Text(_formatProgressDateTime(summary.latestWeightMeasuredAt!)),
            ],
            const SizedBox(height: 12),
            const Text('Peso iniziale'),
            Text(
              formatWeightKg(summary.initialWeightKg),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (summary.weightDeltaKg != null) ...[
              const SizedBox(height: 8),
              const Text('Variazione dal peso iniziale'),
              Text(
                summary.weightDeltaKg == 0
                    ? 'Nessuna variazione'
                    : formatWeightDeltaKg(summary.weightDeltaKg!),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (summary.weightDeltaKg != 0) const Text('dal peso iniziale'),
            ],
          ],
        ),
      ),
    );
  }
}

class _WaistSummaryCard extends StatelessWidget {
  const _WaistSummaryCard({required this.summary, required this.onAdd});

  final BodyProgressSummary summary;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              title: 'Girovita',
              icon: Icons.straighten_outlined,
              actionLabel: 'Aggiungi',
              onAction: onAdd,
            ),
            const SizedBox(height: 12),
            if (summary.latestWaistCm == null)
              const Text('Nessuna misurazione del girovita registrata')
            else ...[
              Text(
                formatWaistCm(summary.latestWaistCm!),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Ultima misurazione'),
              Text(_formatProgressDateTime(summary.latestWaistMeasuredAt!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.title,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _BodyHistorySection extends StatelessWidget {
  const _BodyHistorySection({
    required this.measurements,
    required this.profileId,
    required this.ref,
    required this.context,
  });

  final List<BodyMeasurement> measurements;
  final int profileId;
  final WidgetRef ref;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Storico misurazioni',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (measurements.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('Nessuna misurazione registrata. Aggiungi la prima.'),
          )
        else
          ...measurements.map(
            (m) => _MeasurementTile(
              measurement: m,
              onTap: () =>
                  _showMeasurementForm(context, ref, profileId, existing: m),
            ),
          ),
      ],
    );
  }
}

class _ProgressLoadingCard extends StatelessWidget {
  const _ProgressLoadingCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

class _ProgressErrorCard extends StatelessWidget {
  const _ProgressErrorCard({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Errore nel caricamento: $error'),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.onAddBody,
    required this.onManagePressure,
  });

  final VoidCallback onAddBody;
  final VoidCallback onManagePressure;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registra', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onAddBody,
                  icon: const Icon(Icons.monitor_weight_outlined),
                  label: const Text('Peso / Girovita'),
                ),
                OutlinedButton.icon(
                  onPressed: onManagePressure,
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Registra pressione'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Riepilogo pressione mostrato in Progressi (Milestone 7.3, sezione 27):
/// solo l'ultima misurazione e la sua data, nessuna interpretazione
/// clinica. Lo storico completo e le azioni add/edit/delete restano su
/// [PressurePage] (evoluta, non duplicata) raggiungibile dalla CTA.
class _PressureSummaryCard extends StatelessWidget {
  const _PressureSummaryCard({required this.latest});

  final PressureMeasurement? latest;

  @override
  Widget build(BuildContext context) {
    final m = latest;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              title: 'Pressione',
              icon: Icons.favorite_border,
              actionLabel: 'Gestisci',
              onAction: () => context.push(AppRoutes.pressure),
            ),
            const SizedBox(height: 12),
            if (m == null)
              const Text('Nessuna misurazione della pressione registrata')
            else ...[
              Text(
                formatBloodPressure(m.systolic, m.diastolic),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (m.heartRate != null) ...[
                const SizedBox(height: 8),
                const Text('Frequenza cardiaca'),
                Text(formatHeartRate(m.heartRate!)),
              ],
              const SizedBox(height: 8),
              const Text('Ultima misurazione'),
              Text(
                _formatProgressDateTime(m.measuredAt),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeasurementTile extends ConsumerWidget {
  const _MeasurementTile({required this.measurement, required this.onTap});

  final BodyMeasurement measurement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleParts = <String>[
      if (measurement.weightKg != null) formatWeightKg(measurement.weightKg!),
      if (measurement.waistCm != null)
        'Girovita ${formatWaistCm(measurement.waistCm!)}',
    ];
    final subtitleParts = <String>[
      _formatDateTime(measurement.measuredAt),
      if (measurement.notes != null && measurement.notes!.isNotEmpty)
        measurement.notes!,
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(titleParts.join(' · ')),
      subtitle: Text(subtitleParts.join(' · ')),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, ref, measurement),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return _formatProgressDateTime(date);
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  BodyMeasurement measurement,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminare la misurazione?'),
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
  await ref.read(weightControllerProvider).deleteMeasurement(measurement.id!);
  // Rimuove subito un eventuale SnackBar ancora in coda (es. "Misurazione
  // salvata" di un salvataggio appena fatto): senza questo, il messaggio di
  // conferma dell'eliminazione resterebbe in coda fino allo scadere del
  // precedente invece di sostituirlo subito.
  messenger
    ..clearSnackBars()
    ..showSnackBar(const SnackBar(content: Text('Misurazione eliminata')));
}

Future<void> _showMeasurementForm(
  BuildContext context,
  WidgetRef ref,
  int profileId, {
  BodyMeasurement? existing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _MeasurementForm(profileId: profileId, existing: existing),
    ),
  );
}

class _MeasurementForm extends ConsumerStatefulWidget {
  const _MeasurementForm({required this.profileId, this.existing});

  final int profileId;
  final BodyMeasurement? existing;

  @override
  ConsumerState<_MeasurementForm> createState() => _MeasurementFormState();
}

class _MeasurementFormState extends ConsumerState<_MeasurementForm> {
  final _formKey = GlobalKey<FormState>();
  late final _weightController = TextEditingController(
    text: widget.existing?.weightKg?.toString() ?? '',
  );
  late final _waistController = TextEditingController(
    text: widget.existing?.waistCm?.toString() ?? '',
  );
  late final _notesController = TextEditingController(
    text: widget.existing?.notes ?? '',
  );
  late DateTime _measuredAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Stesso `Clock` usato da `AddBodyMeasurement`/`UpdateBodyMeasurement`
    // per validare "non futura" (non `DateTime.now()` diretto): altrimenti
    // nei test, che girano dentro una zona a orologio finto, i due "adesso"
    // possono divergere e una misurazione appena creata risulterebbe
    // erroneamente "futura".
    _measuredAt = widget.existing?.measuredAt ?? ref.read(clockProvider).now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
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
    // frame trova già `_isSaving == true` e ritorna subito — stesso pattern
    // già usato da PressurePage/ProfilePage.
    if (_isSaving) return;
    setState(() => _isSaving = true);
    if (!_formKey.currentState!.validate()) {
      setState(() => _isSaving = false);
      return;
    }
    final controller = ref.read(weightControllerProvider);
    final measurement = BodyMeasurement(
      id: widget.existing?.id,
      profileId: widget.profileId,
      measuredAt: _measuredAt,
      weightKg: parseDecimalInput(_weightController.text),
      waistCm: parseDecimalInput(_waistController.text),
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
    return _formatProgressDateTime(date);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // Scrollabile (Milestone 7.7, sezione 6): stesso fix già applicato a
      // PressurePage in Milestone 7.3 — con tastiera aperta o su uno schermo
      // piccolo lo spazio disponibile può non bastare per mostrare tutti i
      // campi in una volta.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null
                  ? 'Nuova misurazione'
                  : 'Modifica misurazione',
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
            TextFormField(
              controller: _weightController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Peso (facoltativo)',
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => OnboardingValidators.weightKgOptional(
                parseDecimalInput(v ?? ''),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _waistController,
              decoration: const InputDecoration(
                labelText: 'Girovita (facoltativo)',
                suffixText: 'cm',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  OnboardingValidators.waistCm(parseDecimalInput(v ?? '')),
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
