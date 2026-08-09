import '../entities/biological_sex.dart';

/// Calcoli metabolici stimati (BMI, BMR, TDEE) e variazione peso.
///
/// Le formule producono stime, non diagnosi: quando manca un dato
/// necessario (es. il parametro sesso per la formula), il servizio ritorna
/// `null` invece di inventare un valore.
abstract final class BodyMetricsService {
  static double calculateBmi({
    required double weightKg,
    required double heightCm,
  }) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Mifflin-St Jeor. Ritorna `null` se [biologicalSexForFormula] è assente:
  /// Forge non stima il BMR senza quel parametro.
  static double? calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required BiologicalSexForFormula? biologicalSexForFormula,
  }) {
    if (biologicalSexForFormula == null) return null;
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return switch (biologicalSexForFormula) {
      BiologicalSexForFormula.male => base + 5,
      BiologicalSexForFormula.female => base - 161,
    };
  }

  /// Ritorna `null` se [bmr] è `null` (propaga l'assenza del dato).
  static double? calculateTdee({
    required double? bmr,
    required double activityFactor,
  }) {
    if (bmr == null) return null;
    return bmr * activityFactor;
  }

  /// Percentuale di peso perso rispetto al peso iniziale.
  /// Positiva quando il peso attuale è inferiore al peso iniziale.
  static double calculateWeightLossPercentage({
    required double initialWeight,
    required double currentWeight,
  }) {
    return (initialWeight - currentWeight) / initialWeight * 100;
  }

  /// Variazione di peso rispetto al peso iniziale (negativa se il peso è calato).
  static double calculateWeightDifference({
    required double initialWeight,
    required double currentWeight,
  }) {
    return currentWeight - initialWeight;
  }
}
