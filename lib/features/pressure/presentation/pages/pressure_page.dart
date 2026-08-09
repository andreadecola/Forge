import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/validation/onboarding_validators.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/pressure_measurement.dart';
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
                      child: Text('Nessuna rilevazione registrata.'),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: measurements.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final m = measurements[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${m.systolic}/${m.diastolic} mmHg'),
                      subtitle: Text(
                        [
                          _formatDateTime(m.measuredAt),
                          if (m.heartRate != null) '${m.heartRate} bpm',
                          if (m.measurementContext != null &&
                              m.measurementContext!.isNotEmpty)
                            m.measurementContext!,
                        ].join(' · '),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(pressureControllerProvider)
                            .deleteMeasurement(m.id!),
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

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

Future<void> _showPressureForm(
  BuildContext context,
  WidgetRef ref,
  int profileId,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _PressureForm(profileId: profileId),
    ),
  );
}

class _PressureForm extends ConsumerStatefulWidget {
  const _PressureForm({required this.profileId});

  final int profileId;

  @override
  ConsumerState<_PressureForm> createState() => _PressureFormState();
}

class _PressureFormState extends ConsumerState<_PressureForm> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _contextController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _contextController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final measurement = PressureMeasurement(
      profileId: widget.profileId,
      measuredAt: DateTime.now(),
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
    await ref.read(pressureControllerProvider).addMeasurement(measurement);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nuova rilevazione',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
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
                labelText: 'Battiti (facoltativo)',
              ),
              keyboardType: TextInputType.number,
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
