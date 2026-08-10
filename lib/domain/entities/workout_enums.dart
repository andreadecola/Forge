/// Value type centralizzati per la definizione delle schede allenamento
/// (Milestone 4.1).
///
/// Stesso pattern di [ExerciseImpactLevel] e affini
/// (`exercise_catalog_enums.dart`): ogni enum espone [code], la stringa
/// stabile persistita nelle colonne SQLite, mentre i nomi Dart restano
/// idiomatici (lowerCamelCase).
///
/// Questi enum riguardano la DEFINIZIONE della scheda, non la sua
/// esecuzione: stati come "in corso" o "completato" apparterranno in una
/// milestone futura alla sessione di allenamento (vedi
/// 07_Training_Engine.md), non a [WorkoutDefinitionStatus].
library;

enum WorkoutType {
  fullBody('FULL_BODY'),
  upperBody('UPPER_BODY'),
  lowerBody('LOWER_BODY'),
  mobility('MOBILITY'),
  cardio('CARDIO'),
  recovery('RECOVERY'),
  custom('CUSTOM');

  const WorkoutType(this.code);

  final String code;

  static WorkoutType fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}

enum WorkoutDefinitionStatus {
  draft('DRAFT'),
  ready('READY'),
  archived('ARCHIVED');

  const WorkoutDefinitionStatus(this.code);

  final String code;

  static WorkoutDefinitionStatus fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}

enum WorkoutOrigin {
  system('SYSTEM'),
  user('USER'),
  forgeEngine('FORGE_ENGINE');

  const WorkoutOrigin(this.code);

  final String code;

  static WorkoutOrigin fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}
