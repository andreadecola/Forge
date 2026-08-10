import '../../domain/entities/equipment.dart';
import '../../domain/repositories/equipment_catalog_repository.dart';
import '../database/app_database.dart';
import 'catalog_mappers.dart';

class DriftEquipmentCatalogRepository implements EquipmentCatalogRepository {
  DriftEquipmentCatalogRepository(this.db);

  final AppDatabase db;

  @override
  Future<List<Equipment>> getAllEquipment() async {
    final rows = await db.attrezzatureDao.getAll();
    return rows.map(CatalogMappers.equipment).toList();
  }

  @override
  Future<Equipment?> getEquipmentByCode(String code) async {
    final row = await db.attrezzatureDao.getByCode(code);
    return row == null ? null : CatalogMappers.equipment(row);
  }

  @override
  Future<List<Equipment>> getRequiredEquipmentForExercise(
    int exerciseId,
  ) async {
    final rows = await db.attrezzatureDao.getRequiredEquipmentForExercise(
      exerciseId,
    );
    return rows.map(CatalogMappers.equipment).toList();
  }
}
