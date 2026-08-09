import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

/// Nome fisico SQLite in italiano (Milestone 3.1).
///
/// [equipmentCode] resta testuale (non ancora una FK verso `attrezzature`):
/// il catalogo master attrezzature non ha ancora un seed in questa
/// milestone, quindi non esiste modo sicuro di risolvere i codici verso
/// `id_attrezzatura` senza inventare dati. Il collegamento reale è previsto
/// per la Milestone 3.2, quando il catalogo attrezzature sarà popolato.
class UserEquipmentTable extends Table {
  @override
  String get tableName => 'attrezzature_utente';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(UserProfilesTable, #id)();
  TextColumn get equipmentCode => text()();
  BoolColumn get owned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get acquiredAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {profileId, equipmentCode},
  ];
}
