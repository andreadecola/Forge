import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

class UserEquipmentTable extends Table {
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
