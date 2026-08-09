import 'package:drift/drift.dart';

/// Nome fisico SQLite in italiano (Milestone 3.1); la classe Dart resta
/// idiomatica in inglese, coerentemente con il resto del codice applicativo.
class UserProfilesTable extends Table {
  @override
  String get tableName => 'profili_utente';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get birthDate => dateTime()();

  /// Nullable: assente quando l'utente sceglie "preferisco non specificarlo".
  /// In tal caso BMR/TDEE non vengono stimati.
  TextColumn get biologicalSexForFormula => text().nullable()();

  RealColumn get heightCm => real()();
  RealColumn get initialWeightKg => real()();
  RealColumn get targetWeightKg => real().nullable()();
  IntColumn get preferredWalkMinutes => integer()();
  RealColumn get equipmentBudgetLimit => real()();
  DateTimeColumn get startDate => dateTime()();

  /// Estensione rispetto allo schema documentato in 03_Database_Design.md:
  /// necessaria per stimare il TDEE (vedi 09_Roadmap M2 / 12_Body_Metrics).
  TextColumn get activityLevel => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
