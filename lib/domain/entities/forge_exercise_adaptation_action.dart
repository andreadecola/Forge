/// Azione decisa per un singolo esercizio del piano (Milestone 5.4,
/// sezione 17).
enum ForgeExerciseAdaptationAction {
  /// Nessun cambiamento per questo esercizio.
  keep('KEEP'),

  /// Progressione applicata: parametro aumentato, oppure sostituito con
  /// l'esercizio target di una progressione esplicita del catalogo.
  progress('PROGRESS'),

  /// Sostituito con l'esercizio target di una regressione esplicita del
  /// catalogo.
  regress('REGRESS'),

  /// Sostituito con un'alternativa esplicita del catalogo (usata quando
  /// la regressione non è disponibile/appropriata, sezione 23).
  replace('REPLACE'),

  /// Segnale di difficoltà presente (skip ripetuti o completamento serie
  /// basso) ma nessuna regressione/alternativa eleggibile e non
  /// duplicata trovata: l'esercizio resta com'è, ma la decisione lo
  /// segnala esplicitamente — solo logica di questa generazione, **non**
  /// uno stato medico o permanente persistito altrove (sezione 17).
  avoidTemporarily('AVOID_TEMPORARILY');

  const ForgeExerciseAdaptationAction(this.code);

  final String code;
}
