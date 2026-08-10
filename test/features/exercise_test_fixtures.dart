import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/equipment_repository_impl.dart';
import 'package:forge/data/repositories/profile_repository_impl.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/equipment_item.dart';
import 'package:forge/domain/entities/user_profile.dart';

/// Mini-catalogo condiviso dai test widget del catalogo/dettaglio, con 3
/// esercizi a stato di disponibilità noto (a userLevel 1, con solo "chair"
/// posseduto):
/// - EX-AVAILABLE: livello 1, nessuna attrezzatura -> disponibile. Ha
///   un'alternativa (EX-LOCKED-EQUIPMENT) per i test di navigazione;
/// - EX-LOCKED-LEVEL: livello 5, nessuna attrezzatura -> livello successivo;
/// - EX-LOCKED-EQUIPMENT: livello 1, richiede elastici (non posseduti)
///   -> richiede attrezzatura. Progredisce verso EX-AVAILABLE (quindi
///   EX-AVAILABLE è anche la sua "regressione" nella query inversa).
const miniCatalogJson = '''
{
  "catalogType": "ESERCIZI",
  "catalogVersion": 1,
  "categories": [
    {"code": "TEST", "name": "Categoria di test", "description": null, "displayOrder": 1, "active": true}
  ],
  "muscleGroups": [
    {"code": "CORE", "name": "Core", "active": true},
    {"code": "ADDOMINALI", "name": "Addominali", "active": true}
  ],
  "equipment": [
    {"code": "NONE", "name": "Nessuna", "priority": 0, "active": true},
    {"code": "BAND", "name": "Elastici", "priority": 1, "active": true}
  ],
  "exercises": [
    {
      "code": "EX-AVAILABLE",
      "name": "Esercizio disponibile",
      "categoryCode": "TEST",
      "description": "Descrizione dell'esercizio disponibile.",
      "instructions": "1. Primo passaggio.\\n2. Secondo passaggio.",
      "breathingInstructions": "Respira normalmente.",
      "commonMistakes": "Muoversi troppo velocemente; perdere l'allineamento.",
      "safetyNotes": "Mantieni il controllo del movimento.",
      "minimumLevel": 1,
      "impactLevel": "LOW",
      "defaultSets": 2,
      "defaultReps": 10,
      "defaultRestSeconds": 45,
      "equipmentCodes": [{"code": "NONE", "required": true}],
      "primaryMuscleCodes": ["CORE"],
      "secondaryMuscleCodes": ["ADDOMINALI"],
      "alternativeCodes": [
        {"code": "EX-LOCKED-EQUIPMENT", "reason": "ATTREZZATURA", "priority": 1}
      ],
      "images": []
    },
    {
      "code": "EX-LOCKED-LEVEL",
      "name": "Esercizio livello avanzato",
      "categoryCode": "TEST",
      "description": "Descrizione dell'esercizio di livello avanzato.",
      "instructions": "1. Unico passaggio.",
      "minimumLevel": 5,
      "impactLevel": "MODERATE",
      "equipmentCodes": [{"code": "NONE", "required": true}],
      "primaryMuscleCodes": ["CORE"],
      "secondaryMuscleCodes": [],
      "alternativeCodes": [],
      "images": []
    },
    {
      "code": "EX-LOCKED-EQUIPMENT",
      "name": "Esercizio con elastico",
      "categoryCode": "TEST",
      "description": "Descrizione dell'esercizio con elastico.",
      "instructions": "1. Unico passaggio.",
      "minimumLevel": 1,
      "impactLevel": "LOW",
      "equipmentCodes": [{"code": "BAND", "required": true}],
      "primaryMuscleCodes": ["CORE"],
      "secondaryMuscleCodes": [],
      "progressionCode": "EX-AVAILABLE",
      "progressionType": "VARIANTE",
      "alternativeCodes": [],
      "images": [
        {"type": "POSIZIONE_INIZIALE", "sourceType": "ASSET", "path": "assets/images/exercises/ex_locked_equipment/start.webp", "order": 1},
        {"type": "POSIZIONE_FINALE", "sourceType": "ASSET", "path": "assets/images/exercises/ex_locked_equipment/end.webp", "order": 2}
      ]
    }
  ]
}
''';

AppDatabase memoryDatabase() => AppDatabase(NativeDatabase.memory());

/// Semina il mini-catalogo, crea un profilo con onboarding completato e
/// possiede solo "chair" (né elastici né altro): coerente con gli stati di
/// disponibilità descritti sopra.
Future<void> seedAppWith(AppDatabase database) async {
  await ExerciseCatalogSeeder(database).seedFromString(miniCatalogJson);

  final profileId = await ProfileRepositoryImpl(database.userProfileDao)
      .saveProfile(
        UserProfile(
          name: 'Alex',
          birthDate: DateTime(1990, 1, 1),
          heightCm: 175,
          initialWeightKg: 80,
          preferredWalkMinutes: 30,
          equipmentBudgetLimit: 50,
          startDate: DateTime(2026, 1, 1),
        ),
      );
  await EquipmentRepositoryImpl(
    database.userEquipmentDao,
  ).saveInitialEquipment(profileId: profileId, owned: {EquipmentItem.chair});
  await SettingsRepositoryImpl(
    database.appSettingsDao,
  ).setOnboardingCompleted(true);
}

/// Smonta l'albero widget mentre siamo ancora nel corpo del test, in modo
/// che i timer di cleanup dello stream Drift (avviato da provider come
/// `currentProfileProvider`) possano essere scaricati con un pump esplicito
/// prima della verifica finale di flutter_test (altrimenti fallisce con
/// "Timer is still pending"). Stesso fix già usato in test/widget_test.dart.
Future<void> disposeCleanly(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}
