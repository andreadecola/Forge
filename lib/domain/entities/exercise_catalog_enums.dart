/// Value type centralizzati per il catalogo esercizi (Milestone 3.1).
///
/// Ogni enum espone [code], la stringa stabile persistita nelle colonne
/// SQLite e usata dal seed JSON (Milestone 3.2): i nomi Dart restano
/// idiomatici (lowerCamelCase), il [code] riproduce il vocabolario
/// documentato in 06_Exercise_Catalog.md (SCREAMING_SNAKE_CASE).
library;

enum ExerciseImpactLevel {
  veryLow('VERY_LOW'),
  low('LOW'),
  moderate('MODERATE'),
  high('HIGH');

  const ExerciseImpactLevel(this.code);

  final String code;

  static ExerciseImpactLevel fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}

/// Intensità cardio, centralizzata dalla Milestone 3.2 (in 3.1 era testo
/// libero). Stesso vocabolario di [ExerciseImpactLevel] ma semantica distinta
/// (carico cardiovascolare, non impatto articolare).
enum ExerciseCardioIntensity {
  veryLow('VERY_LOW'),
  low('LOW'),
  moderate('MODERATE'),
  high('HIGH');

  const ExerciseCardioIntensity(this.code);

  final String code;

  static ExerciseCardioIntensity fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}

enum ExerciseMuscleRole {
  primario('PRIMARIO'),
  secondario('SECONDARIO');

  const ExerciseMuscleRole(this.code);

  final String code;

  static ExerciseMuscleRole fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}

enum ExerciseImageSourceType {
  asset('ASSET'),
  fileLocale('FILE_LOCALE');

  const ExerciseImageSourceType(this.code);

  final String code;

  static ExerciseImageSourceType fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}

enum ExerciseImageType {
  copertina('COPERTINA'),
  posizioneIniziale('POSIZIONE_INIZIALE'),
  posizioneFinale('POSIZIONE_FINALE'),
  movimento('MOVIMENTO'),
  erroreComune('ERRORE_COMUNE'),
  sicurezza('SICUREZZA');

  const ExerciseImageType(this.code);

  final String code;

  static ExerciseImageType fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}

enum ExerciseProgressionType {
  tecnica('TECNICA'),
  ripetizioni('RIPETIZIONI'),
  durata('DURATA'),
  carico('CARICO'),
  resistenza('RESISTENZA'),
  variante('VARIANTE');

  const ExerciseProgressionType(this.code);

  final String code;

  static ExerciseProgressionType fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}

enum ExerciseAlternativeReason {
  difficolta('DIFFICOLTA'),
  attrezzatura('ATTREZZATURA'),
  posizione('POSIZIONE'),
  pavimento('PAVIMENTO'),
  equilibrio('EQUILIBRIO'),
  varianteSemplice('VARIANTE_SEMPLICE'),
  varianteEquivalente('VARIANTE_EQUIVALENTE');

  const ExerciseAlternativeReason(this.code);

  final String code;

  static ExerciseAlternativeReason fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}
