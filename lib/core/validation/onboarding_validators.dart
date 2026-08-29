/// Validazioni di dominio, senza soglie mediche arbitrarie: verificano solo
/// plausibilità dei dati (numeri positivi, date non future, ecc.).
///
/// Ogni funzione ritorna `null` se il valore è valido, altrimenti un
/// messaggio d'errore in italiano utilizzabile direttamente come
/// `FormFieldValidator`.
///
/// Nome storico dell'onboarding, ma già condiviso da altre feature (es.
/// `systolicOverDiastolic` usato anche da `AddPressureMeasurement`, Milestone
/// 2): il modulo Progressi (Milestone 7.1) riusa questo stesso posto invece
/// di crearne uno nuovo, per non disperdere la validazione in più file.
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

  /// Il peso è facoltativo in una misurazione corporea (Milestone 7.2,
  /// "solo girovita"): `null` è sempre valido, a differenza di [weightKg]
  /// (obbligatorio in onboarding, che resta invariato).
  static String? weightKgOptional(double? value) {
    if (value == null) return null;
    if (value <= 0 || value > 500) return 'Peso non plausibile.';
    return null;
  }

  /// Una misurazione deve avere almeno una metrica (peso o girovita):
  /// entrambe assenti non ha senso da registrare (Milestone 7.2, sezione 9).
  static String? atLeastOneBodyMetric({
    required double? weightKg,
    required double? waistCm,
  }) {
    if (weightKg == null && waistCm == null) {
      return 'Indica almeno il peso o il girovita.';
    }
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

  /// Il girovita è facoltativo in una misurazione corporea: `null` è sempre
  /// valido (Milestone 7.1, sezione 7/14).
  static String? waistCm(double? value) {
    if (value == null) return null;
    if (value <= 0) return 'Il girovita deve essere maggiore di zero.';
    return null;
  }

  /// La frequenza cardiaca è facoltativa in una misurazione pressione:
  /// `null` è sempre valido, altrimenti deve essere positiva — nessuna
  /// classificazione del battito (Milestone 7.3, sezione 11).
  static String? heartRate(int? value) {
    if (value == null) return null;
    if (value <= 0) {
      return 'La frequenza cardiaca deve essere maggiore di zero.';
    }
    return null;
  }

  /// Un profilo valido è semplicemente un id già persistito (Milestone 7.1,
  /// sezione 14): l'esistenza reale del profilo resta comunque garantita a
  /// valle dal vincolo FK, questo è solo un controllo di plausibilità a
  /// monte, prima di toccare il database.
  static String? profileId(int value) {
    if (value <= 0) return 'Profilo non valido.';
    return null;
  }

  /// Una misurazione non può essere registrata per un momento futuro
  /// (Milestone 7.1, sezione 9/14) — nessun limite sul passato: l'utente
  /// potrà registrare una misurazione relativa a un momento precedente.
  static String? measuredAt(DateTime value, {required DateTime now}) {
    if (value.isAfter(now)) {
      return 'La data della misurazione non può essere futura.';
    }
    return null;
  }
}
