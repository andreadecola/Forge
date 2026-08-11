/// Punteggio **contestuale** usato solo durante la composizione
/// (Milestone 5.2, sezione 29) per scegliere il prossimo esercizio da
/// aggiungere al piano — **non** sostituisce né modifica `ForgeScore`
/// della Milestone 5.1 (quello resta il punteggio "isolato" di un
/// esercizio, riportato invariato su ogni `GeneratedWorkoutExercise`):
/// questo è semanticamente diverso, dipende da *cosa è già stato
/// selezionato* nel piano in corso di costruzione.
class ForgeSelectionScore {
  const ForgeSelectionScore({
    required this.baseScore,
    required this.coverageBonus,
    required this.redundancyPenalty,
    required this.remainingBudgetPenalty,
  });

  /// `ForgeScore.total` della Milestone 5.1 (score isolato del candidato).
  final double baseScore;

  /// Bonus se la categoria del candidato non è ancora rappresentata nella
  /// selezione corrente (incoraggia varietà, sezione 26, senza vietare
  /// mai una categoria già presente — sezione 27).
  final double coverageBonus;

  /// Penalità proporzionale a quanti esercizi già selezionati condividono
  /// almeno un muscolo primario col candidato (sezione 28): mai una nuova
  /// regola biomeccanica, solo i muscoli primari già presenti nel
  /// catalogo.
  final double redundancyPenalty;

  /// Penalità se la durata stimata del candidato eccede sensibilmente il
  /// budget di tempo ancora disponibile nel piano in corso di
  /// costruzione — la valutazione "contro il resto della scheda" che la
  /// Milestone 5.1 aveva esplicitamente rimandato qui.
  final double remainingBudgetPenalty;

  double get total =>
      baseScore + coverageBonus - redundancyPenalty - remainingBudgetPenalty;
}
