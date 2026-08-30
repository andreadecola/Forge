import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/activity_level.dart';
import '../../../../core/utils/decimal_parser.dart';
import '../../../../core/validation/onboarding_validators.dart';
import '../../../../data/backup/backup_providers.dart';
import '../../../../data/backup/backup_restore_result.dart';
import '../../../../data/backup/backup_save_result.dart';
import '../../../../data/repositories/forge_providers.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/biological_sex.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/use_cases/save_profile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return profileAsync.when(
      data: (profile) => profile == null
          ? const _ProfileUnavailablePage()
          : _ProfileEditor(profile: profile),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Profilo')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Profilo')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Errore nel caricamento del profilo: $error'),
          ),
        ),
      ),
    );
  }
}

class _ProfileUnavailablePage extends StatelessWidget {
  const _ProfileUnavailablePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilo')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nessun profilo disponibile. Completa prima l\'onboarding.',
          ),
        ),
      ),
    );
  }
}

class _ProfileEditor extends ConsumerStatefulWidget {
  const _ProfileEditor({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends ConsumerState<_ProfileEditor> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController();
  late final _heightController = TextEditingController();
  late final _initialWeightController = TextEditingController();
  late final _targetWeightController = TextEditingController();
  late final _preferredWalkMinutesController = TextEditingController();
  late final _equipmentBudgetController = TextEditingController();

  late DateTime _birthDate;
  late BiologicalSexForFormula? _biologicalSex;
  late ActivityLevel _activityLevel;
  bool _isSaving = false;
  bool _isExportingBackup = false;
  bool _isImportingBackup = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _populate(widget.profile);
  }

  @override
  void didUpdateWidget(covariant _ProfileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.updatedAt != widget.profile.updatedAt && !_isDirty) {
      _populate(widget.profile);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _initialWeightController.dispose();
    _targetWeightController.dispose();
    _preferredWalkMinutesController.dispose();
    _equipmentBudgetController.dispose();
    super.dispose();
  }

  void _populate(UserProfile profile) {
    _nameController.text = profile.name;
    _heightController.text = _decimalText(profile.heightCm);
    _initialWeightController.text = _decimalText(profile.initialWeightKg);
    _targetWeightController.text = profile.targetWeightKg == null
        ? ''
        : _decimalText(profile.targetWeightKg!);
    _preferredWalkMinutesController.text = profile.preferredWalkMinutes
        .toString();
    _equipmentBudgetController.text = _decimalText(
      profile.equipmentBudgetLimit,
    );
    _birthDate = profile.birthDate;
    _biologicalSex = profile.biologicalSexForFormula;
    _activityLevel = profile.activityLevel;
  }

  String _decimalText(double value) {
    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);
  }

  DateTime get _now => ref.read(clockProvider).now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
        actions: [
          IconButton(
            onPressed: _confirmExit,
            icon: const Icon(Icons.logout),
            tooltip: 'Esci',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        onChanged: () => _isDirty = true,
        child: SingleChildScrollView(
          key: const ValueKey('profile-form'),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Dati personali',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('profile-name'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  textInputAction: TextInputAction.next,
                  validator: OnboardingValidators.name,
                ),
                const SizedBox(height: 16),
                _birthDateField(context),
                const SizedBox(height: 16),
                _biologicalSexField(),
                const SizedBox(height: 24),
                Text(
                  'Dati corporei iniziali',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Il peso iniziale viene usato come riferimento nella sezione Progressi.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('profile-height'),
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Altezza',
                    suffixText: 'cm',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => OnboardingValidators.heightCm(
                    parseDecimalInput(value ?? ''),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('profile-initial-weight'),
                  controller: _initialWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Peso iniziale',
                    suffixText: 'kg',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => OnboardingValidators.weightKg(
                    parseDecimalInput(value ?? ''),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('profile-target-weight'),
                  controller: _targetWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Peso obiettivo (facoltativo)',
                    suffixText: 'kg',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => OnboardingValidators.targetWeightKg(
                    _optionalDecimal(value),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Preferenze',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('profile-walk-minutes'),
                  controller: _preferredWalkMinutesController,
                  decoration: const InputDecoration(
                    labelText: 'Durata camminata preferita',
                    suffixText: 'min',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      OnboardingValidators.preferredWalkMinutes(
                        int.tryParse(value ?? ''),
                      ),
                ),
                const SizedBox(height: 16),
                _activityLevelField(),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('profile-equipment-budget'),
                  controller: _equipmentBudgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget attrezzatura',
                    suffixText: 'EUR',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) =>
                      OnboardingValidators.equipmentBudgetLimit(
                        parseDecimalInput(value ?? ''),
                      ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const ValueKey('profile-save'),
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
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  key: const ValueKey('profile-export-backup'),
                  onPressed: _isExportingBackup ? null : _exportBackup,
                  icon: _isExportingBackup
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt_outlined),
                  label: const Text('Esporta backup'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  key: const ValueKey('profile-import-backup'),
                  onPressed: _isImportingBackup ? null : _importBackup,
                  icon: _isImportingBackup
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.file_open_outlined),
                  label: const Text('Importa backup'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _confirmExit,
                  icon: const Icon(Icons.logout),
                  label: const Text('Esci'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _birthDateField(BuildContext context) {
    final error = OnboardingValidators.birthDate(_birthDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Data di nascita'),
          subtitle: Text(_formatDate(_birthDate)),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: _pickBirthDate,
        ),
        if (error != null)
          Text(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }

  Widget _biologicalSexField() {
    return DropdownButtonFormField<String>(
      initialValue: _biologicalSex?.name ?? 'none',
      decoration: const InputDecoration(labelText: 'Parametro sesso'),
      items: const [
        DropdownMenuItem(
          value: 'none',
          child: Text('Preferisco non specificarlo'),
        ),
        DropdownMenuItem(value: 'male', child: Text('Maschile')),
        DropdownMenuItem(value: 'female', child: Text('Femminile')),
      ],
      isExpanded: true,
      onChanged: (value) {
        setState(() {
          _biologicalSex = value == null || value == 'none'
              ? null
              : BiologicalSexForFormula.values.byName(value);
          _isDirty = true;
        });
      },
    );
  }

  Widget _activityLevelField() {
    return DropdownButtonFormField<ActivityLevel>(
      initialValue: _activityLevel,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Livello di attività'),
      items: [
        for (final level in ActivityLevel.values)
          DropdownMenuItem(value: level, child: Text(_activityLabel(level))),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _activityLevel = value;
          _isDirty = true;
        });
      },
    );
  }

  Future<void> _pickBirthDate() async {
    final now = _now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthDate = picked;
      _isDirty = true;
    });
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final updatedProfile = widget.profile.copyWith(
      name: _nameController.text.trim(),
      birthDate: _birthDate,
      biologicalSexForFormula: () => _biologicalSex,
      heightCm: parseDecimalInput(_heightController.text)!,
      initialWeightKg: parseDecimalInput(_initialWeightController.text)!,
      targetWeightKg: () => _optionalDecimal(_targetWeightController.text),
      preferredWalkMinutes: int.parse(_preferredWalkMinutesController.text),
      equipmentBudgetLimit: parseDecimalInput(_equipmentBudgetController.text)!,
      activityLevel: _activityLevel,
    );

    try {
      await SaveProfile(ref.read(profileRepositoryProvider))(updatedProfile);
    } on ArgumentError catch (error) {
      _showError(error.message.toString());
      return;
    } catch (error) {
      _showError('Impossibile aggiornare i dati: $error');
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isDirty = false;
    });
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Dati personali aggiornati')),
      );
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Esporta un backup logico versionato su una destinazione scelta
  /// dall'utente (Backup.3): nessun percorso reale viene mostrato (mai
  /// assunto, sezione 19/20/28), solo un esito neutro. L'annullamento
  /// del picker non è un errore (sezione 29).
  Future<void> _exportBackup() async {
    if (_isExportingBackup) return;

    setState(() => _isExportingBackup = true);
    final result = await ref.read(createExternalBackupProvider).call();
    if (!mounted) return;
    setState(() => _isExportingBackup = false);

    final message = switch (result.outcome) {
      BackupSaveOutcome.success => 'Backup salvato correttamente.',
      BackupSaveOutcome.cancelled => 'Salvataggio annullato.',
      BackupSaveOutcome.failure => 'Impossibile salvare il backup.',
    };
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Importa e ripristina un backup scelto dall'utente (Backup.4):
  /// REPLACE atomico, mai un merge — la conferma esplicita è
  /// obbligatoria prima di qualunque sostituzione (sezione 67), lo
  /// stesso principio già seguito da [_confirmExit]. Nessun dettaglio
  /// tecnico né percorso esposto in caso di errore (sezione 28/65).
  Future<void> _importBackup() async {
    if (_isImportingBackup) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importa backup'),
        content: const Text(
          'L\'importazione sostituirà i dati attuali di Forge con quelli '
          'del backup selezionato. L\'operazione non può essere annullata '
          'una volta completata. Continuare?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Importa'),
          ),
        ],
      ),
    );
    if (!mounted || !(confirmed ?? false)) return;

    setState(() => _isImportingBackup = true);
    final result = await ref.read(importExternalBackupProvider).call();
    if (!mounted) return;
    setState(() => _isImportingBackup = false);

    final message = switch (result.outcome) {
      BackupRestoreOutcome.success => 'Backup importato correttamente.',
      BackupRestoreOutcome.cancelled => 'Importazione annullata.',
      BackupRestoreOutcome.failure => 'Impossibile importare il backup.',
    };
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Esci da Forge'),
        content: const Text('Vuoi chiudere l\'app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Esci'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) SystemNavigator.pop();
  }

  double? _optionalDecimal(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return parseDecimalInput(value);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _activityLabel(ActivityLevel level) => switch (level) {
    ActivityLevel.sedentary => 'Sedentario',
    ActivityLevel.lightlyActive => 'Leggermente attivo',
    ActivityLevel.moderatelyActive => 'Moderatamente attivo',
    ActivityLevel.veryActive => 'Molto attivo',
  };
}
