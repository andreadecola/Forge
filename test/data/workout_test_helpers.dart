import 'package:drift/drift.dart';
import 'package:forge/data/database/app_database.dart';

/// Helper di inserimento condivisi tra i test DAO/repository degli
/// allenamenti: righe minime necessarie per esercitare FK/vincoli, stesso
/// stile di `workout_schema_test.dart`.
Future<int> insertProfilo(AppDatabase db) {
  final now = DateTime.now();
  return db
      .into(db.userProfilesTable)
      .insert(
        UserProfilesTableCompanion.insert(
          name: 'Alex',
          birthDate: DateTime(1990, 1, 1),
          heightCm: 175,
          initialWeightKg: 80,
          preferredWalkMinutes: 30,
          equipmentBudgetLimit: 50,
          startDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<int> insertCategoria(AppDatabase db, {String codice = 'MOBILITA'}) {
  final now = DateTime.now();
  return db
      .into(db.categorieEserciziTable)
      .insert(
        CategorieEserciziTableCompanion.insert(
          codice: codice,
          nome: 'Mobilità',
          dataCreazione: now,
          dataModifica: now,
        ),
      );
}

Future<int> insertEsercizio(
  AppDatabase db, {
  required String codice,
  required int idCategoria,
  int? defaultSets,
  int? defaultReps,
  int? defaultDurationSeconds,
  int? defaultRestSeconds,
}) {
  final now = DateTime.now();
  return db
      .into(db.eserciziTable)
      .insert(
        EserciziTableCompanion.insert(
          codice: codice,
          nome: 'Esercizio $codice',
          descrizione: 'Descrizione',
          istruzioni: 'Istruzioni',
          idCategoria: idCategoria,
          livelloMinimo: 1,
          livelloImpatto: 'LOW',
          versioneCatalogo: 1,
          seriePredefinite: Value(defaultSets),
          ripetizioniPredefinite: Value(defaultReps),
          durataPredefinitaSecondi: Value(defaultDurationSeconds),
          recuperoPredefinitoSecondi: Value(defaultRestSeconds),
          dataCreazione: now,
          dataModifica: now,
        ),
      );
}
