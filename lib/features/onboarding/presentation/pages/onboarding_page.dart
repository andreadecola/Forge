import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/validation/onboarding_validators.dart';
import '../../../../data/backup/backup_providers.dart';
import '../../../../data/backup/backup_restore_result.dart';
import '../../../../data/repositories/catalog_providers.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/equipment_item.dart';
import '../../application/onboarding_controller.dart';
import '../../application/onboarding_state.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static const _totalSteps = 7;

  final _pageController = PageController();
  final _formKeys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  int _step = 0;
  bool _isSaving = false;
  bool _showSetupForm = false;
  bool _isRestoringBackup = false;
  String? _restoreError;

  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _customWalkController = TextEditingController();
  final _budgetController = TextEditingController(
    text: defaultEquipmentBudgetLimit.toStringAsFixed(0),
  );

  DateTime? _birthDate;
  OnboardingSexChoice _sexChoice = OnboardingSexChoice.preferNotToSay;
  int _selectedWalkMinutes = 30;
  bool _isCustomWalk = false;
  final Set<EquipmentItem> _ownedEquipment = {...EquipmentItem.defaultOwned};

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _customWalkController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  int get _effectiveWalkMinutes {
    if (!_isCustomWalk) return _selectedWalkMinutes;
    return int.tryParse(_customWalkController.text) ?? 0;
  }

  void _commitCurrentStep() {
    final controller = ref.read(onboardingControllerProvider.notifier);
    switch (_step) {
      case 0:
        controller.updateIdentity(
          name: _nameController.text.trim(),
          birthDate: _birthDate!,
        );
      case 1:
        controller.updateBodyData(
          heightCm: double.parse(_heightController.text),
          initialWeightKg: double.parse(_weightController.text),
          targetWeightKg: _targetWeightController.text.trim().isEmpty
              ? null
              : double.parse(_targetWeightController.text),
        );
      case 2:
        controller.updateSexChoice(_sexChoice);
      case 3:
        controller.updatePreferredWalkMinutes(_effectiveWalkMinutes);
      case 4:
        controller.updateEquipment(_ownedEquipment);
      case 5:
        controller.updateBudget(double.parse(_budgetController.text));
    }
  }

  Future<void> _goNext() async {
    final formKey = _formKeys[_step];
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }
    _commitCurrentStep();
    if (_step == _totalSteps - 1) {
      await _completeOnboarding();
      return;
    }
    setState(() => _step++);
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  Future<void> _goBack() async {
    if (_step == 0) return;
    setState(() => _step--);
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(onboardingControllerProvider.notifier)
          .completeOnboarding();
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Impossibile salvare: $e')));
      }
    }
  }

  Future<void> _restoreFromBackup() async {
    if (_isRestoringBackup) return;

    setState(() {
      _isRestoringBackup = true;
      _restoreError = null;
    });

    final BackupRestoreResult result;
    try {
      result = await ref.read(importExternalBackupProvider).call();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRestoringBackup = false;
        _restoreError = 'Impossibile ripristinare il backup.';
      });
      return;
    }
    if (!mounted) return;

    switch (result.outcome) {
      case BackupRestoreOutcome.cancelled:
        setState(() => _isRestoringBackup = false);
      case BackupRestoreOutcome.failure:
        setState(() {
          _isRestoringBackup = false;
          _restoreError = _restoreFailureMessage(result);
        });
      case BackupRestoreOutcome.success:
        // Il restore aggiorna la stessa istanza Drift osservata dai provider.
        // La navigazione forza il redirect esistente a rivalutare
        // onboardingCompleted senza riavviare l'app.
        ref.invalidate(onboardingCompletedProvider);
        ref.invalidate(currentProfileProvider);
        context.go(AppRoutes.dashboard);
    }
  }

  String _restoreFailureMessage(BackupRestoreResult result) {
    return switch (result.failureReason) {
      BackupRestoreFailureReason.incompatibleVersion =>
        'Il backup non è compatibile con questa versione di Forge.',
      BackupRestoreFailureReason.catalogMismatch =>
        'Il backup contiene esercizi non disponibili in questa installazione.',
      BackupRestoreFailureReason.invalidBackup ||
      BackupRestoreFailureReason.readFailure ||
      BackupRestoreFailureReason.restoreFailure ||
      BackupRestoreFailureReason.verificationFailure ||
      null => 'Impossibile ripristinare il backup.',
    };
  }

  Widget _initialChoice(AsyncValue<Object?> catalogState) {
    final catalogReady = catalogState.hasValue;
    final catalogError = catalogState.hasError;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Icon(
                Icons.fitness_center,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Costruisci il tuo percorso.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Inizia configurando Forge oppure ripristina i tuoi dati da un backup.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              FilledButton(
                key: const ValueKey('onboarding-configure-forge'),
                onPressed: _isRestoringBackup
                    ? null
                    : () => setState(() {
                        _showSetupForm = true;
                        _restoreError = null;
                      }),
                child: const Text('Configura Forge'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('onboarding-restore-backup'),
                onPressed: !catalogReady || _isRestoringBackup
                    ? null
                    : _restoreFromBackup,
                child: _isRestoringBackup
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ripristina da backup'),
              ),
              if (catalogState.isLoading) ...[
                const SizedBox(height: 16),
                const Text(
                  'Preparazione del catalogo in corso prima del ripristino...',
                  textAlign: TextAlign.center,
                ),
              ],
              if (catalogError) ...[
                const SizedBox(height: 16),
                Text(
                  'Il catalogo non è disponibile: il ripristino non può iniziare.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (_restoreError != null) ...[
                const SizedBox(height: 24),
                Text(
                  _restoreError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogBootstrapProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showSetupForm ? 'Configurazione ${_step + 1}/$_totalSteps' : 'Forge',
        ),
        automaticallyImplyLeading: false,
      ),
      body: _showSetupForm
          ? Column(
              children: [
                LinearProgressIndicator(value: (_step + 1) / _totalSteps),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _identityStep(),
                      _bodyDataStep(),
                      _sexChoiceStep(),
                      _walkStep(),
                      _equipmentStep(),
                      _budgetStep(),
                      _summaryStep(),
                    ],
                  ),
                ),
                _buildNavigationBar(),
              ],
            )
          : _initialChoice(catalogState),
    );
  }

  Widget _buildNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _goBack,
                child: const Text('Indietro'),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _goNext,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _step == _totalSteps - 1
                          ? 'Completa configurazione'
                          : 'Avanti',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBody({required String title, required List<Widget> children}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _identityStep() {
    return Form(
      key: _formKeys[0],
      child: _stepBody(
        title: 'La tua identità',
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: OnboardingValidators.name,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _birthDate == null
                  ? 'Data di nascita'
                  : 'Data di nascita: ${_formatDate(_birthDate!)}',
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(1990),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _birthDate = picked);
            },
          ),
          if (OnboardingValidators.birthDate(_birthDate) != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                OnboardingValidators.birthDate(_birthDate)!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bodyDataStep() {
    return Form(
      key: _formKeys[1],
      child: _stepBody(
        title: 'Dati corporei',
        children: [
          TextFormField(
            controller: _heightController,
            decoration: const InputDecoration(
              labelText: 'Altezza (cm)',
              suffixText: 'cm',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) =>
                OnboardingValidators.heightCm(double.tryParse(v ?? '')),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Peso iniziale',
              suffixText: 'kg',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) =>
                OnboardingValidators.weightKg(double.tryParse(v ?? '')),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _targetWeightController,
            decoration: const InputDecoration(
              labelText: 'Peso obiettivo (facoltativo)',
              suffixText: 'kg',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => OnboardingValidators.targetWeightKg(
              v == null || v.trim().isEmpty ? null : double.tryParse(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sexChoiceStep() {
    return _stepBody(
      title: 'Parametro formula metabolica',
      children: [
        Text(
          'Usato solo per stimare BMR e TDEE (Mifflin-St Jeor). '
          'Puoi scegliere di non specificarlo: le stime metaboliche '
          'resteranno semplicemente non disponibili.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        RadioGroup<OnboardingSexChoice>(
          groupValue: _sexChoice,
          onChanged: (value) => setState(() => _sexChoice = value!),
          child: Column(
            children: const [
              RadioListTile(
                value: OnboardingSexChoice.male,
                title: Text('Maschile'),
              ),
              RadioListTile(
                value: OnboardingSexChoice.female,
                title: Text('Femminile'),
              ),
              RadioListTile(
                value: OnboardingSexChoice.preferNotToSay,
                title: Text('Preferisco non specificarlo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _walkStep() {
    return Form(
      key: _formKeys[3],
      child: _stepBody(
        title: 'Camminata',
        children: [
          const Text('Durata preferita'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ...presetWalkMinutes.map(
                (minutes) => ChoiceChip(
                  label: Text('$minutes min'),
                  selected: !_isCustomWalk && _selectedWalkMinutes == minutes,
                  onSelected: (_) => setState(() {
                    _isCustomWalk = false;
                    _selectedWalkMinutes = minutes;
                  }),
                ),
              ),
              ChoiceChip(
                label: const Text('Personalizzata'),
                selected: _isCustomWalk,
                onSelected: (_) => setState(() => _isCustomWalk = true),
              ),
            ],
          ),
          if (_isCustomWalk) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _customWalkController,
              decoration: const InputDecoration(
                labelText: 'Durata personalizzata',
                suffixText: 'min',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => OnboardingValidators.preferredWalkMinutes(
                int.tryParse(v ?? ''),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _equipmentStep() {
    return _stepBody(
      title: 'Attrezzatura iniziale',
      children: EquipmentItem.values.map((item) {
        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(item.label),
          value: _ownedEquipment.contains(item),
          onChanged: (checked) => setState(() {
            if (checked ?? false) {
              _ownedEquipment.add(item);
            } else {
              _ownedEquipment.remove(item);
            }
          }),
        );
      }).toList(),
    );
  }

  Widget _budgetStep() {
    return Form(
      key: _formKeys[5],
      child: _stepBody(
        title: 'Budget attrezzatura',
        children: [
          Text(
            'Budget massimo indicativo per l\'acquisto di nuovi attrezzi.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _budgetController,
            decoration: const InputDecoration(
              labelText: 'Budget',
              suffixText: 'EUR',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => OnboardingValidators.equipmentBudgetLimit(
              double.tryParse(v ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStep() {
    return _stepBody(
      title: 'Riepilogo',
      children: [
        _summaryRow('Nome', _nameController.text),
        _summaryRow(
          'Data di nascita',
          _birthDate == null ? '-' : _formatDate(_birthDate!),
        ),
        _summaryRow('Altezza', '${_heightController.text} cm'),
        _summaryRow('Peso iniziale', '${_weightController.text} kg'),
        _summaryRow(
          'Peso obiettivo',
          _targetWeightController.text.trim().isEmpty
              ? 'Non impostato'
              : '${_targetWeightController.text} kg',
        ),
        _summaryRow('Camminata', '$_effectiveWalkMinutes min'),
        _summaryRow(
          'Attrezzatura',
          _ownedEquipment.isEmpty
              ? 'Nessuna'
              : _ownedEquipment.map((e) => e.label).join(', '),
        ),
        _summaryRow('Budget attrezzatura', '${_budgetController.text} EUR'),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
