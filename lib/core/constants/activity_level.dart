/// Livello di attività usato per stimare il TDEE a partire dal BMR.
///
/// Non viene dedotto automaticamente dagli allenamenti in questa milestone:
/// l'utente lo imposta/modifica manualmente.
enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive }

/// Fattori moltiplicativi TDEE = BMR * fattore, centralizzati in un unico
/// punto come richiesto per la Milestone 2.
abstract final class ActivityFactors {
  static const Map<ActivityLevel, double> factors = {
    ActivityLevel.sedentary: 1.2,
    ActivityLevel.lightlyActive: 1.375,
    ActivityLevel.moderatelyActive: 1.55,
    ActivityLevel.veryActive: 1.725,
  };

  /// Default prudenziale quando il livello di attività non è ancora stato impostato.
  static const ActivityLevel defaultLevel = ActivityLevel.sedentary;

  static double factorFor(ActivityLevel level) => factors[level]!;
}
