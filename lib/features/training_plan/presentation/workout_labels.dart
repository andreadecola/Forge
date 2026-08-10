import '../../../domain/entities/workout_enums.dart';

/// Traduzioni italiane per gli enum tecnici delle schede allenamento. Nessun
/// valore enum (inglese/SCREAMING_SNAKE_CASE) deve raggiungere la UI senza
/// passare da qui (stesso principio di `exercise_labels.dart`).
///
/// I messaggi di [WorkoutValidationService] sono già frasi italiane pronte
/// per la UI: non serve un mapper aggiuntivo per quelli.
abstract final class WorkoutLabels {
  static String type(WorkoutType type) {
    switch (type) {
      case WorkoutType.fullBody:
        return 'Total body';
      case WorkoutType.upperBody:
        return 'Parte superiore';
      case WorkoutType.lowerBody:
        return 'Parte inferiore';
      case WorkoutType.mobility:
        return 'Mobilità';
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.recovery:
        return 'Recupero';
      case WorkoutType.custom:
        return 'Personalizzato';
    }
  }

  static String status(WorkoutDefinitionStatus status) {
    switch (status) {
      case WorkoutDefinitionStatus.draft:
        return 'Bozza';
      case WorkoutDefinitionStatus.ready:
        return 'Pronta';
      case WorkoutDefinitionStatus.archived:
        return 'Archiviata';
    }
  }
}
