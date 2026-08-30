import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/planned_activity.dart';
import '../../../../domain/entities/planned_activity_enums.dart';
import '../../../../domain/services/weekly_planning_date_service.dart';
import '../../application/planned_activity_providers.dart';
import '../planned_activity_labels.dart';
import 'workout_picker_sheet.dart';

/// Apre il form di aggiunta/modifica in un bottom sheet (Milestone 8.2,
/// sezione 18), stesso pattern di `_showPressureForm`/`_showMeasurementForm`
/// (Milestone 7): scrollabile, si adatta alla tastiera con `viewInsets`.
Future<void> showPlannedActivityForm(
  BuildContext context, {
  required int profileId,
  required DateTime initialDate,
  PlannedActivity? existing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: PlannedActivityForm(
        profileId: profileId,
        initialDate: initialDate,
        existing: existing,
      ),
    ),
  );
}

class PlannedActivityForm extends ConsumerStatefulWidget {
  const PlannedActivityForm({
    super.key,
    required this.profileId,
    required this.initialDate,
    this.existing,
  });

  final int profileId;

  /// Giorno da cui è stato aperto il form (sezione 53): usato solo per una
  /// nuova attività. In modifica la data di partenza è sempre quella di
  /// [existing], mai [initialDate] (sezione 54).
  final DateTime initialDate;
  final PlannedActivity? existing;

  @override
  ConsumerState<PlannedActivityForm> createState() =>
      _PlannedActivityFormState();
}

class _PlannedActivityFormState extends ConsumerState<PlannedActivityForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _scheduledDate;
  late PlannedActivityType _type;
  int? _workoutId;
  late bool _workoutWasMissingOnOpen;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _scheduledDate =
        existing?.scheduledDate ??
        WeeklyPlanningDateService.atMidnight(widget.initialDate);
    _type = existing?.type ?? PlannedActivityType.workout;
    _workoutId = existing?.workoutId;
    // Sezione 35/36: un `Workout` referenziato può essere stato eliminato
    // (ON DELETE SET NULL, Milestone 8.1) — questo distingue "non ancora
    // scelto" (nuova attività) da "non più disponibile" (era collegato, ora
    // non lo è più), solo per il messaggio mostrato prima di una nuova
    // scelta.
    _workoutWasMissingOnOpen =
        existing != null &&
        existing.type == PlannedActivityType.workout &&
        existing.workoutId == null;
    _durationController = TextEditingController(
      text: existing?.plannedDurationMinutes?.toString() ?? '',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Normalizzazione esplicita al cambio tipo (sezione 28/67): un campo non
  /// pertinente al nuovo tipo non deve restare "attaccato" al salvataggio.
  void _changeType(PlannedActivityType type) {
    setState(() {
      _type = type;
      if (type != PlannedActivityType.workout) {
        _workoutId = null;
        _workoutWasMissingOnOpen = false;
      }
      if (type != PlannedActivityType.walk) {
        _durationController.text = '';
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _scheduledDate = WeeklyPlanningDateService.atMidnight(picked);
    });
  }

  Future<void> _pickWorkout() async {
    final workout = await showWorkoutPickerSheet(
      context,
      profileId: widget.profileId,
    );
    if (workout == null || !mounted) return;
    setState(() {
      _workoutId = workout.id;
      _workoutWasMissingOnOpen = false;
    });
  }

  Future<void> _save() async {
    // Guardia anti-doppio-submit sincrona (sezione 32), stesso pattern di
    // `_MeasurementForm`/`_PressureForm` (Milestone 7).
    if (_isSaving) return;
    setState(() => _isSaving = true);
    if (!_formKey.currentState!.validate()) {
      setState(() => _isSaving = false);
      return;
    }
    final durationText = _durationController.text.trim();
    final activity = PlannedActivity(
      id: widget.existing?.id,
      profileId: widget.profileId,
      scheduledDate: _scheduledDate,
      type: _type,
      workoutId: _type == PlannedActivityType.workout ? _workoutId : null,
      plannedDurationMinutes:
          _type == PlannedActivityType.walk && durationText.isNotEmpty
          ? int.parse(durationText)
          : null,
      status: widget.existing?.status ?? PlannedActivityStatus.planned,
      origin: widget.existing?.origin ?? PlannedActivityOrigin.user,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    final controller = ref.read(plannedActivityControllerProvider);
    final isNew = widget.existing == null;
    try {
      if (isNew) {
        await controller.addPlannedActivity(activity);
      } else {
        await controller.updatePlannedActivity(activity);
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
            isNew ? 'Attività pianificata' : 'Pianificazione aggiornata',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // Scrollabile (sezione 51): con tastiera aperta o su schermo piccolo
      // lo spazio disponibile può non bastare per mostrare tutti i campi.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null ? 'Nuova attività' : 'Modifica attività',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(formatItalianDate(_scheduledDate)),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in PlannedActivityType.values)
                  ChoiceChip(
                    label: Text(PlannedActivityLabels.type(type)),
                    selected: _type == type,
                    onSelected: (_) => _changeType(type),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTypeFields(),
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

  Widget _buildTypeFields() {
    switch (_type) {
      case PlannedActivityType.workout:
        return _buildWorkoutField();
      case PlannedActivityType.walk:
        return TextFormField(
          controller: _durationController,
          decoration: const InputDecoration(
            labelText: 'Durata pianificata (minuti, facoltativa)',
            suffixText: 'min',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            final trimmed = (value ?? '').trim();
            if (trimmed.isEmpty) return null;
            final parsed = int.tryParse(trimmed);
            if (parsed == null) return 'Inserisci un numero valido.';
            if (parsed <= 0) return 'La durata deve essere maggiore di zero.';
            return null;
          },
        );
      case PlannedActivityType.recovery:
        return const Text(
          'Giorno di recupero: nessuna scheda o sessione collegata.',
        );
    }
  }

  Widget _buildWorkoutField() {
    if (_workoutId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_workoutWasMissingOnOpen)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Allenamento non più disponibile.'),
            ),
          OutlinedButton.icon(
            onPressed: _pickWorkout,
            icon: const Icon(Icons.fitness_center_outlined),
            label: const Text('Scegli un allenamento'),
          ),
        ],
      );
    }
    final workoutAsync = ref.watch(workoutByIdProvider(_workoutId!));
    return workoutAsync.when(
      data: (workout) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.fitness_center),
        title: Text(workout?.name ?? 'Allenamento non più disponibile'),
        trailing: const Icon(Icons.edit_outlined),
        onTap: _pickWorkout,
      ),
      loading: () => const ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Caricamento...'),
      ),
      error: (error, _) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Allenamento non disponibile'),
        trailing: const Icon(Icons.edit_outlined),
        onTap: _pickWorkout,
      ),
    );
  }
}
