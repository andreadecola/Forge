import '../../../domain/entities/exercise_availability_status.dart';
import '../../../domain/entities/exercise_catalog_enums.dart';

/// Traduzioni italiane per gli enum tecnici del catalogo. Nessun valore
/// enum (inglese/SCREAMING_SNAKE_CASE) deve raggiungere la UI senza passare
/// da qui.
///
/// Nomi di categorie, gruppi muscolari e attrezzature NON hanno bisogno di
/// mapper: sono già testo italiano nel seed (`nome` in DB).
abstract final class ExerciseLabels {
  static String availabilityStatus(ExerciseAvailabilityStatus status) {
    switch (status) {
      case ExerciseAvailabilityStatus.available:
        return 'Disponibile';
      case ExerciseAvailabilityStatus.lockedLevel:
        return 'Livello successivo';
      case ExerciseAvailabilityStatus.lockedEquipment:
        return 'Richiede attrezzatura';
      case ExerciseAvailabilityStatus.recommended:
        return 'Consigliato';
      case ExerciseAvailabilityStatus.temporarilyAvoided:
        return 'Da evitare temporaneamente';
      case ExerciseAvailabilityStatus.mastered:
        return 'Padroneggiato';
    }
  }

  /// Motivo sintetico mostrato nel dettaglio per un esercizio bloccato.
  static String availabilityReason(
    ExerciseAvailabilityStatus status, {
    int? requiredLevel,
    List<String>? missingEquipmentNames,
  }) {
    switch (status) {
      case ExerciseAvailabilityStatus.lockedLevel:
        return requiredLevel == null
            ? 'Questo esercizio richiede un livello più avanzato.'
            : 'Questo esercizio richiede il livello $requiredLevel.';
      case ExerciseAvailabilityStatus.lockedEquipment:
        final names = (missingEquipmentNames ?? const [])
          ..removeWhere((n) => n.trim().isEmpty);
        return names.isEmpty
            ? 'Per questo esercizio ti serve attrezzatura che non possiedi.'
            : 'Per questo esercizio ti serve: ${names.join(', ')}.';
      default:
        return '';
    }
  }

  static String alternativeReason(ExerciseAlternativeReason reason) {
    switch (reason) {
      case ExerciseAlternativeReason.difficolta:
        return 'Difficoltà';
      case ExerciseAlternativeReason.attrezzatura:
        return 'Attrezzatura';
      case ExerciseAlternativeReason.posizione:
        return 'Posizione';
      case ExerciseAlternativeReason.pavimento:
        return 'Pavimento';
      case ExerciseAlternativeReason.equilibrio:
        return 'Equilibrio';
      case ExerciseAlternativeReason.varianteSemplice:
        return 'Variante più semplice';
      case ExerciseAlternativeReason.varianteEquivalente:
        return 'Variante equivalente';
    }
  }

  static String imageType(ExerciseImageType type) {
    switch (type) {
      case ExerciseImageType.copertina:
        return 'Copertina';
      case ExerciseImageType.posizioneIniziale:
        return 'Posizione iniziale';
      case ExerciseImageType.posizioneFinale:
        return 'Posizione finale';
      case ExerciseImageType.movimento:
        return 'Movimento';
      case ExerciseImageType.erroreComune:
        return 'Errore comune';
      case ExerciseImageType.sicurezza:
        return 'Sicurezza';
    }
  }

  static String progressionType(ExerciseProgressionType type) {
    switch (type) {
      case ExerciseProgressionType.tecnica:
        return 'Tecnica';
      case ExerciseProgressionType.ripetizioni:
        return 'Ripetizioni';
      case ExerciseProgressionType.durata:
        return 'Durata';
      case ExerciseProgressionType.carico:
        return 'Carico';
      case ExerciseProgressionType.resistenza:
        return 'Resistenza';
      case ExerciseProgressionType.variante:
        return 'Variante';
    }
  }

  static String impactLevel(ExerciseImpactLevel level) =>
      _intensityLabel(switch (level) {
        ExerciseImpactLevel.veryLow => _Intensity.veryLow,
        ExerciseImpactLevel.low => _Intensity.low,
        ExerciseImpactLevel.moderate => _Intensity.moderate,
        ExerciseImpactLevel.high => _Intensity.high,
      });

  static String cardioIntensity(ExerciseCardioIntensity intensity) =>
      _intensityLabel(switch (intensity) {
        ExerciseCardioIntensity.veryLow => _Intensity.veryLow,
        ExerciseCardioIntensity.low => _Intensity.low,
        ExerciseCardioIntensity.moderate => _Intensity.moderate,
        ExerciseCardioIntensity.high => _Intensity.high,
      });

  static String _intensityLabel(_Intensity intensity) {
    switch (intensity) {
      case _Intensity.veryLow:
        return 'Molto basso';
      case _Intensity.low:
        return 'Basso';
      case _Intensity.moderate:
        return 'Moderato';
      case _Intensity.high:
        return 'Alto';
    }
  }
}

enum _Intensity { veryLow, low, moderate, high }
