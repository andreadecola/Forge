/// Stato persistito di una sessione di allenamento (Milestone 4.4.3),
/// stesso pattern di [WorkoutDefinitionStatus] (`workout_enums.dart`): ogni
/// valore espone [code], la stringa stabile persistita nella colonna
/// `sessioni_allenamento.stato`.
///
/// Non va confuso con `WorkoutSessionPhase` (runtime, UI): questo enum
/// riguarda solo la persistenza (sezione 6), la fase visualizzata resta
/// sempre derivata, mai duplicata su disco (vedi
/// `sessioni_allenamento_table.dart`).
enum WorkoutSessionPersistenceStatus {
  inProgress('IN_PROGRESS'),
  paused('PAUSED'),
  completed('COMPLETED'),
  aborted('ABORTED');

  const WorkoutSessionPersistenceStatus(this.code);

  final String code;

  static WorkoutSessionPersistenceStatus fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}
