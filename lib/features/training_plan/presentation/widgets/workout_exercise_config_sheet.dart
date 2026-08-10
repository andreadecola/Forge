import 'package:flutter/material.dart';

/// Valori scelti dall'utente per una riga scheda (serie/ripetizioni/
/// durata/recupero/note). Tutti facoltativi: la validazione READY decide se
/// bastano per rendere l'esercizio eseguibile.
class WorkoutExerciseConfigResult {
  const WorkoutExerciseConfigResult({
    this.sets,
    this.repetitions,
    this.durationSeconds,
    this.restSeconds,
    this.notes,
  });

  final int? sets;
  final int? repetitions;
  final int? durationSeconds;
  final int? restSeconds;
  final String? notes;
}

/// Mostra la configurazione di una riga scheda. Riutilizzato sia per
/// l'aggiunta (valori pre-compilati dai default del catalogo tramite
/// [WorkoutExerciseFactory]) sia per la modifica di una riga già presente
/// (valori correnti della scheda) — nessuna duplicazione tra i due flussi.
///
/// Regola UX (Milestone 4.3, sezione 15): se l'esercizio ha di default solo
/// una durata (nessuna ripetizione), il campo Durata viene messo in
/// evidenza al posto di Ripetizioni. Nessuno dei due campi è obbligatorio
/// qui: lo diventa solo per passare la scheda a PRONTA.
Future<WorkoutExerciseConfigResult?> showWorkoutExerciseConfigSheet({
  required BuildContext context,
  required String exerciseName,
  int? initialSets,
  int? initialRepetitions,
  int? initialDurationSeconds,
  int? initialRestSeconds,
  String? initialNotes,
  required String submitLabel,
}) {
  return showModalBottomSheet<WorkoutExerciseConfigResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _WorkoutExerciseConfigSheet(
      exerciseName: exerciseName,
      initialSets: initialSets,
      initialRepetitions: initialRepetitions,
      initialDurationSeconds: initialDurationSeconds,
      initialRestSeconds: initialRestSeconds,
      initialNotes: initialNotes,
      submitLabel: submitLabel,
    ),
  );
}

class _WorkoutExerciseConfigSheet extends StatefulWidget {
  const _WorkoutExerciseConfigSheet({
    required this.exerciseName,
    this.initialSets,
    this.initialRepetitions,
    this.initialDurationSeconds,
    this.initialRestSeconds,
    this.initialNotes,
    required this.submitLabel,
  });

  final String exerciseName;
  final int? initialSets;
  final int? initialRepetitions;
  final int? initialDurationSeconds;
  final int? initialRestSeconds;
  final String? initialNotes;
  final String submitLabel;

  @override
  State<_WorkoutExerciseConfigSheet> createState() =>
      _WorkoutExerciseConfigSheetState();
}

class _WorkoutExerciseConfigSheetState
    extends State<_WorkoutExerciseConfigSheet> {
  late final TextEditingController _sets;
  late final TextEditingController _repetitions;
  late final TextEditingController _duration;
  late final TextEditingController _rest;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _sets = TextEditingController(text: widget.initialSets?.toString() ?? '');
    _repetitions = TextEditingController(
      text: widget.initialRepetitions?.toString() ?? '',
    );
    _duration = TextEditingController(
      text: widget.initialDurationSeconds?.toString() ?? '',
    );
    _rest = TextEditingController(
      text: widget.initialRestSeconds?.toString() ?? '',
    );
    _notes = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _sets.dispose();
    _repetitions.dispose();
    _duration.dispose();
    _rest.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    final notes = _notes.text.trim();
    Navigator.of(context).pop(
      WorkoutExerciseConfigResult(
        sets: int.tryParse(_sets.text.trim()),
        repetitions: int.tryParse(_repetitions.text.trim()),
        durationSeconds: int.tryParse(_duration.text.trim()),
        restSeconds: int.tryParse(_rest.text.trim()),
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emphasizeDuration =
        widget.initialDurationSeconds != null &&
        widget.initialRepetitions == null;
    final emphasisStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.exerciseName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sets,
              decoration: const InputDecoration(labelText: 'Serie'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _repetitions,
              decoration: InputDecoration(
                labelText: 'Ripetizioni',
                labelStyle: emphasizeDuration ? null : emphasisStyle,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _duration,
              decoration: InputDecoration(
                labelText: 'Durata in secondi',
                labelStyle: emphasizeDuration ? emphasisStyle : null,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rest,
              decoration: const InputDecoration(
                labelText: 'Recupero in secondi (facoltativo)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Note (facoltative)',
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: Text(widget.submitLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
