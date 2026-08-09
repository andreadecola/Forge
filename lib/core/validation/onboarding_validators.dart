/// Validazioni di dominio, senza soglie mediche arbitrarie: verificano solo
/// plausibilità dei dati (numeri positivi, date non future, ecc.).
///
/// Ogni funzione ritorna `null` se il valore è valido, altrimenti un
/// messaggio d'errore in italiano utilizzabile direttamente come
/// `FormFieldValidator`.
abstract final class OnboardingValidators {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Il nome non può essere vuoto.';
    }
    return null;
  }

  static String? heightCm(double? value) {
    if (value == null) return 'Indica l\'altezza.';
    if (value <= 0 || value > 300) return 'Altezza non plausibile.';
    return null;
  }

  static String? weightKg(double? value) {
    if (value == null) return 'Indica il peso.';
    if (value <= 0 || value > 500) return 'Peso non plausibile.';
    return null;
  }

  /// Il peso obiettivo è facoltativo: `null` è sempre valido.
  static String? targetWeightKg(double? value) {
    if (value == null) return null;
    if (value <= 0 || value > 500) return 'Peso obiettivo non plausibile.';
    return null;
  }

  static String? birthDate(DateTime? value) {
    if (value == null) return 'Indica la data di nascita.';
    if (value.isAfter(DateTime.now())) {
      return 'La data di nascita non può essere futura.';
    }
    return null;
  }

  static String? preferredWalkMinutes(int? value) {
    if (value == null) return 'Indica una durata.';
    if (value <= 0) return 'La durata deve essere maggiore di zero.';
    return null;
  }

  static String? equipmentBudgetLimit(double? value) {
    if (value == null) return 'Indica un budget.';
    if (value < 0) return 'Il budget non può essere negativo.';
    return null;
  }

  static String? systolicOverDiastolic(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) {
      return 'Indica sistolica e diastolica.';
    }
    if (systolic <= 0 || diastolic <= 0) {
      return 'I valori devono essere maggiori di zero.';
    }
    if (systolic <= diastolic) {
      return 'La sistolica deve essere maggiore della diastolica.';
    }
    return null;
  }
}
