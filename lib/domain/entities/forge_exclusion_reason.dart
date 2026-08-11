/// Motivo per cui un esercizio non è eleggibile per il Forge Engine
/// (Milestone 5.1, sezione 15): codici domain stabili, mai stringhe UI —
/// la traduzione in italiano sarà responsabilità della presentation layer
/// quando il Forge Engine avrà una UI (non in questa milestone).
enum ForgeExclusionReason {
  /// L'esercizio non è attivo nel catalogo.
  inactive('INACTIVE'),

  /// `exercise.minimumLevel > userLevel`: l'esercizio richiede un livello
  /// che l'utente non ha ancora.
  levelTooHigh('LEVEL_TOO_HIGH'),

  /// `exercise.maximumLevel != null && userLevel > exercise.maximumLevel`:
  /// l'utente ha superato il livello massimo previsto per l'esercizio.
  /// Nessun esercizio del catalogo attuale definisce `maximumLevel`
  /// (verificato sui dati reali), ma la regola esiste in
  /// `ExerciseLevelPolicy` ed è quindi gestita anche qui.
  levelTooLow('LEVEL_TOO_LOW'),

  /// Manca almeno un'attrezzatura obbligatoria tra quelle disponibili
  /// nella richiesta (`NONE` escluso).
  missingEquipment('MISSING_EQUIPMENT'),

  /// Né ripetizioni né durata (né default) sono presenti: il tempo
  /// dell'esercizio non è stimabile senza inventare un dato (sezione 22).
  unsupportedParameters('UNSUPPORTED_PARAMETERS');

  const ForgeExclusionReason(this.code);

  final String code;
}
