import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

/// Definizione di una scheda allenamento (Milestone 4.1): solo struttura
/// dati. Nessun DAO/repository/UI applicativo: arrivano con la Milestone
/// 4.2. [stato] e [origine] riguardano la DEFINIZIONE della scheda, non la
/// sua esecuzione — la sessione (in corso/completata) è un concetto futuro
/// separato (vedi 07_Training_Engine.md).
@TableIndex(name: 'idx_allenamenti_id_profilo', columns: {#idProfilo})
@TableIndex(name: 'idx_allenamenti_attivo', columns: {#attivo})
class AllenamentiTable extends Table {
  @override
  String get tableName => 'allenamenti';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get idProfilo => integer().references(UserProfilesTable, #id)();

  TextColumn get nome => text()();
  TextColumn get descrizione => text().nullable()();

  /// Codice stabile di `WorkoutType` (`lib/domain/entities/workout_enums.dart`).
  TextColumn get tipoAllenamento => text()();

  IntColumn get livello => integer().withDefault(const Constant(1))();

  IntColumn get durataStimataMinuti => integer().nullable()();

  /// Codice stabile di `WorkoutDefinitionStatus`.
  TextColumn get stato => text()();

  /// Codice stabile di `WorkoutOrigin`.
  TextColumn get origine => text()();

  BoolColumn get attivo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (livello > 0)',
    'CHECK (durata_stimata_minuti IS NULL OR durata_stimata_minuti > 0)',
  ];
}
