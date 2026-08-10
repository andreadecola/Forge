import 'package:flutter/material.dart';

import '../../../../domain/entities/workout_enums.dart';
import '../workout_labels.dart';

/// Valori raccolti dal form, già pronti per costruire/aggiornare un
/// [Workout] (il chiamante decide se creare o aggiornare).
class WorkoutMetadataFormResult {
  const WorkoutMetadataFormResult({
    required this.name,
    required this.description,
    required this.type,
    required this.level,
    required this.estimatedDurationMinutes,
  });

  final String name;
  final String? description;
  final WorkoutType type;
  final int level;
  final int? estimatedDurationMinutes;
}

/// Form condiviso da `CreateWorkoutPage` e dal dialog "Modifica dettagli"
/// di `WorkoutEditPage`: nome, descrizione, tipo, livello, durata stimata.
/// Nessuna logica di persistenza qui: [onSubmit] riceve solo i valori
/// raccolti, il chiamante decide come salvarli.
class WorkoutMetadataForm extends StatefulWidget {
  const WorkoutMetadataForm({
    super.key,
    this.initialName = '',
    this.initialDescription,
    this.initialType = WorkoutType.fullBody,
    this.initialLevel = 1,
    this.initialEstimatedDurationMinutes,
    required this.submitLabel,
    required this.onSubmit,
  });

  final String initialName;
  final String? initialDescription;
  final WorkoutType initialType;
  final int initialLevel;
  final int? initialEstimatedDurationMinutes;
  final String submitLabel;
  final ValueChanged<WorkoutMetadataFormResult> onSubmit;

  @override
  State<WorkoutMetadataForm> createState() => _WorkoutMetadataFormState();
}

class _WorkoutMetadataFormState extends State<WorkoutMetadataForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late WorkoutType _type;
  late int _level;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _durationController = TextEditingController(
      text: widget.initialEstimatedDurationMinutes?.toString() ?? '',
    );
    _type = widget.initialType;
    _level = widget.initialLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final description = _descriptionController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());
    widget.onSubmit(
      WorkoutMetadataFormResult(
        name: _nameController.text.trim(),
        description: description.isEmpty ? null : description,
        type: _type,
        level: _level,
        estimatedDurationMinutes: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Il nome della scheda non può essere vuoto.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrizione (facoltativa)',
            ),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<WorkoutType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: WorkoutType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(WorkoutLabels.type(type)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 16),
          Text('Livello', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var level = 1; level <= 5; level++)
                ChoiceChip(
                  label: Text('$level'),
                  selected: _level == level,
                  onSelected: (_) => setState(() => _level = level),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Durata stimata in minuti (facoltativa)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
