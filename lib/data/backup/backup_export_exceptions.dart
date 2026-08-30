/// Lanciata dal mapper quando un `exerciseId` numerico referenziato da
/// `WorkoutExercise`/`PersistedSessionExercise` non risolve a nessun
/// esercizio del catalogo (Backup.2, sezione 16): l'export deve fallire
/// esplicitamente, mai produrre un `exerciseCode` nullo o inventato.
class BackupExerciseCodeUnresolvedException implements Exception {
  const BackupExerciseCodeUnresolvedException(this.exerciseId);

  final int exerciseId;

  @override
  String toString() =>
      'BackupExerciseCodeUnresolvedException: esercizio $exerciseId non '
      'presente nel catalogo.';
}
