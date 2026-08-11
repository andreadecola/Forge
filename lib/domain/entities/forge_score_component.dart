/// Componenti dello score implementati in Milestone 5.1 (sezione 35).
/// `variety` non è qui: richiede il contesto degli esercizi già scelti in
/// una scheda, che non esiste ancora in questa milestone (sezione 40,
/// rimandato alla Milestone 5.2).
enum ForgeScoreComponentType {
  workoutTypeMatch,
  levelFit,
  equipmentSimplicity,
  durationFit,
}

/// Un singolo componente dello score (sezione 35): [value] è sempre
/// normalizzato in `0.0..1.0`, così i pesi in [ForgeEngineConfig] restano
/// comparabili tra componenti diversi.
class ForgeScoreComponent {
  const ForgeScoreComponent({required this.type, required this.value});

  final ForgeScoreComponentType type;
  final double value;
}
