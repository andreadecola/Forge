import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';

/// Hardening (Milestone 5.6, sezione 26): un codice esercizio duplicato nel
/// catalogo non deve mai essere nascosto — deve emergere come un fallimento
/// esplicito del seed, non essere silenziosamente accettato/ignorato. Il
/// vincolo `UNIQUE` su `esercizi.codice` (`EserciziTable`, Milestone 3.1) è
/// il livello a cui questa invariante è realmente garantita: il Forge
/// Engine non deve mai occuparsene, perché il caso non può raggiungerlo.
void main() {
  test('catalogo con due esercizi che condividono lo stesso code: il seed '
      'fallisce esplicitamente (vincolo UNIQUE), nessuna riga duplicata '
      'silenziosamente accettata', () async {
    final db = AppDatabase(NativeDatabase.memory());
    const duplicateCatalogJson = '''
      {
        "catalogType": "ESERCIZI",
        "catalogVersion": 1,
        "categories": [
          {"code": "TEST", "name": "Categoria di test", "description": null, "displayOrder": 1, "active": true}
        ],
        "muscleGroups": [
          {"code": "CORE", "name": "Core", "active": true}
        ],
        "equipment": [
          {"code": "NONE", "name": "Nessuna", "priority": 0, "active": true}
        ],
        "exercises": [
          {
            "code": "DUP-001",
            "name": "Primo",
            "categoryCode": "TEST",
            "description": "d",
            "instructions": "i",
            "minimumLevel": 1,
            "impactLevel": "LOW",
            "defaultReps": 10,
            "equipmentCodes": [{"code": "NONE", "required": true}],
            "primaryMuscleCodes": ["CORE"],
            "secondaryMuscleCodes": [],
            "alternativeCodes": [],
            "images": []
          },
          {
            "code": "DUP-001",
            "name": "Secondo (stesso code)",
            "categoryCode": "TEST",
            "description": "d",
            "instructions": "i",
            "minimumLevel": 1,
            "impactLevel": "LOW",
            "defaultReps": 10,
            "equipmentCodes": [{"code": "NONE", "required": true}],
            "primaryMuscleCodes": ["CORE"],
            "secondaryMuscleCodes": [],
            "alternativeCodes": [],
            "images": []
          }
        ]
      }
      ''';

    expect(
      () => ExerciseCatalogSeeder(db).seedFromString(duplicateCatalogJson),
      throwsA(anything),
    );

    final rows = await db.eserciziDao.getAll();
    expect(
      rows.where((r) => r.codice == 'DUP-001').length,
      lessThanOrEqualTo(1),
      reason:
          'nessuna riga duplicata deve restare visibile — se il seed non '
          'e\' transazionale su questo fallimento e\' un bug reale da '
          'segnalare, non da nascondere',
    );

    await db.close();
  });
}
