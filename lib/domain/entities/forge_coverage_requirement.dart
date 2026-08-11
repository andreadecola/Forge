/// Requisito di copertura per un `WorkoutType` (Milestone 5.2, sezione
/// 17): "almeno [minCount] esercizio/i la cui categoria sia una di
/// [categoryCodes]". Un insieme di codici, non un singolo codice, per
/// poter esprimere "una qualunque tra queste categorie va bene" (es. il
/// gruppo MOBILITA/STRETCHING/EQUILIBRIO per RECOVERY, sezione 23) senza
/// bisogno di più requisiti identici.
///
/// Sempre codici **reali** del catalogo (mai inventati — STOP 4): vedi
/// `ForgeWorkoutTypeCoveragePolicy`.
class ForgeCoverageRequirement {
  const ForgeCoverageRequirement({
    required this.categoryCodes,
    this.minCount = 1,
  });

  final Set<String> categoryCodes;
  final int minCount;

  bool matchesCategory(String categoryCode) =>
      categoryCodes.contains(categoryCode);
}
