/// Decisione globale di adattamento (Milestone 5.4, sezione 9): termini
/// tecnici, non clinici — nessuna diagnosi, nessun giudizio su
/// difficoltà/dolore/fatica.
enum ForgeAdaptationDecision {
  /// Nessun cambiamento: storico insufficiente, o evidenza nella "zona
  /// intermedia" (né chiaramente positiva né chiaramente negativa,
  /// sezione 11), o evidenza ambigua (STOP 4: la scelta conservativa
  /// prevale sempre).
  maintain('MAINTAIN'),

  /// Evidenza sufficiente e positiva: parametri/esercizi possono avanzare,
  /// sempre con le guardie di sezione 21/37-40.
  progress('PROGRESS'),

  /// Segnali di difficoltà (skip ripetuti, completamento serie basso):
  /// possono essere considerate regressione/alternativa, sempre con le
  /// stesse guardie.
  simplify('SIMPLIFY');

  const ForgeAdaptationDecision(this.code);

  final String code;
}
