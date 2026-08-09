import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/app_constants.dart';
import 'daos/app_settings_dao.dart';
import 'daos/body_measurements_dao.dart';
import 'daos/pressure_measurements_dao.dart';
import 'daos/user_equipment_dao.dart';
import 'daos/user_profile_dao.dart';
import 'tables/app_settings_table.dart';
import 'tables/body_measurements_table.dart';
import 'tables/pressure_measurements_table.dart';
import 'tables/user_equipment_table.dart';
import 'tables/user_profiles_table.dart';

part 'app_database.g.dart';

/// Database Drift applicativo.
///
/// Milestone 2: profilo utente, misure corporee, pressione e attrezzatura.
/// Il catalogo esercizi, gli allenamenti e il Forge Engine arriveranno nelle
/// milestone successive.
@DriftDatabase(
  tables: [
    AppSettingsTable,
    UserProfilesTable,
    BodyMeasurementsTable,
    PressureMeasurementsTable,
    UserEquipmentTable,
  ],
  daos: [
    AppSettingsDao,
    UserProfileDao,
    BodyMeasurementsDao,
    PressureMeasurementsDao,
    UserEquipmentDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: AppConstants.databaseName);
  }
}
