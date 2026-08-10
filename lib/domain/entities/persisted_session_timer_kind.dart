/// Tipo di timer persistito su `sessioni_allenamento` (Milestone 4.4.3):
/// al più uno dei due può essere attivo alla volta, stesso invariante di
/// `WorkoutSessionState.exerciseTimer`/`restTimer` — nessun campo "NONE"
/// esplicito, l'assenza di timer è semplicemente `null` (sezione 12).
enum PersistedSessionTimerKind {
  exercise('EXERCISE'),
  rest('REST');

  const PersistedSessionTimerKind(this.code);

  final String code;

  static PersistedSessionTimerKind fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}
