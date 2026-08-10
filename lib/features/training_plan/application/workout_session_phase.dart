/// Fase corrente della sessione (Milestone 4.4.2), derivata da
/// [WorkoutSessionState] — non un flag indipendente: nessuno stato
/// duplicato (vedi `WorkoutSessionState.phase`).
enum WorkoutSessionPhase {
  /// Pronta per la serie corrente: per un esercizio a ripetizioni si può
  /// premere "Completa serie", per uno a tempo "Avvia serie".
  readySet,

  /// Countdown della serie a tempo in corso.
  timedSetRunning,

  /// Recupero tra due serie in corso.
  resting,

  /// Sessione in pausa (qualunque fosse la fase precedente).
  paused,

  /// Sessione completata: tutti gli esercizi risolti (completati o
  /// saltati).
  completed,
}
