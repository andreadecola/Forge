import '../../../domain/entities/planned_activity_enums.dart';

/// Etichette italiane per `PlannedActivityType` (Milestone 8.2, sezione 19):
/// la UI non mostra mai i codici tecnici WORKOUT/WALK/RECOVERY, stesso
/// principio già seguito da `WorkoutLabels` (Milestone 4.3).
abstract final class PlannedActivityLabels {
  static String type(PlannedActivityType type) => switch (type) {
    PlannedActivityType.workout => 'Allenamento',
    PlannedActivityType.walk => 'Camminata',
    PlannedActivityType.recovery => 'Recupero',
  };
}
