import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_settings_table.dart';

part 'app_settings_dao.g.dart';

@DriftAccessor(tables: [AppSettingsTable])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(
      appSettingsTable,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watchValue(String key) {
    return (select(appSettingsTable)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<void> setValue(String key, String value) {
    return into(appSettingsTable).insertOnConflictUpdate(
      AppSettingsTableCompanion.insert(key: key, value: value),
    );
  }

  Future<void> deleteValue(String key) {
    return (delete(appSettingsTable)..where((t) => t.key.equals(key))).go();
  }
}
