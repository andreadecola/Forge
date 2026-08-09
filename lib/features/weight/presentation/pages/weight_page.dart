import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/validation/onboarding_validators.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/body_measurement.dart';
import '../../application/weight_providers.dart';

class WeightPage extends ConsumerWidget {
  const WeightPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return profileAsync.when(
      data: (profile) => profile == null
          ? const Scaffold(
              body: Center(child: Text('Completa prima l\'onboarding.')),
            )
          : _WeightPageBody(profileId: profile.id!),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Errore: $error'))),
    );
  }
}

class _WeightPageBody extends ConsumerWidget {
  const _WeightPageBody({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(bodyMeasurementsProvider(profileId));
    return Scaffold(
      appBar: AppBar(title: const Text('Peso')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMeasurementForm(context, ref, profileId),
        child: const Icon(Icons.add),
      ),
      body: measurementsAsync.when(
        data: (measurements) {
          if (measurements.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nessuna misura registrata. Aggiungi il primo peso.',
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: measurements.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final m = measurements[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${m.weightKg.toStringAsFixed(1)} kg'),
                subtitle: Text(
                  [
                    _formatDate(m.measuredAt),
                    if (m.waistCm != null)
                      'Girovita ${m.waistCm!.toStringAsFixed(1)} cm',
                    if (m.notes != null && m.notes!.isNotEmpty) m.notes!,
                  ].join(' · '),
                ),
                onTap: () =>
                    _showMeasurementForm(context, ref, profileId, existing: m),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref
                      .read(weightControllerProvider)
                      .deleteMeasurement(m.id!),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Errore: $error')),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
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
    text: widget.existing?.weightKg.toString() ?? '',
  );
  late final _waistController = TextEditingController(
    text: widget.existing?.waistCm?.toString() ?? '',
  );
  late final _notesController = TextEditingController(
    text: widget.existing?.notes ?? '',
  );

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(weightControllerProvider);
    final measurement = BodyMeasurement(
      id: widget.existing?.id,
      profileId: widget.profileId,
      measuredAt: widget.existing?.measuredAt ?? DateTime.now(),
      weightKg: double.parse(_weightController.text),
      waistCm: _waistController.text.trim().isEmpty
          ? null
          : double.parse(_waistController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    if (widget.existing == null) {
      await controller.addMeasurement(measurement);
    } else {
      await controller.updateMeasurement(measurement);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null ? 'Nuovo peso' : 'Modifica peso',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Peso',
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  OnboardingValidators.weightKg(double.tryParse(v ?? '')),
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
                onPressed: _save,
                child: const Text('Salva'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
