import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'models/exercise_catalog_seed_models.dart';

/// Errore sollevato quando il catalogo seed è incoerente o non importabile.
/// L'import è transazionale: se questo errore viene sollevato, nessun record
/// parziale resta nel database.
class CatalogSeedException implements Exception {
  CatalogSeedException(this.message);

  final String message;

  @override
  String toString() => 'CatalogSeedException: $message';
}

/// Esito di un import del catalogo. Se [alreadyImported] è true la versione
/// era già presente e non è stato modificato nulla.
class CatalogSeedResult {
  const CatalogSeedResult({
    required this.alreadyImported,
    this.categories = 0,
    this.muscleGroups = 0,
    this.equipment = 0,
    this.exercises = 0,
    this.muscleRelations = 0,
    this.equipmentRelations = 0,
    this.images = 0,
    this.progressions = 0,
    this.alternatives = 0,
  });

  final bool alreadyImported;
  final int categories;
  final int muscleGroups;
  final int equipment;
  final int exercises;
  final int muscleRelations;
  final int equipmentRelations;
  final int images;
  final int progressions;
  final int alternatives;
}

/// Importa il catalogo esercizi (`exercises_v1.json`) nel database.
///
/// Garanzie:
/// - **atomicità**: tutto avviene in un'unica transazione; un catalogo
///   invalido non lascia record parziali;
/// - **idempotenza**: se la versione del catalogo è già registrata in
///   `versioni_catalogo`, l'import è un no-op; i master vengono comunque
///   riconciliati per codice (upsert) e le relazioni ricreate, così che una
///   ri-esecuzione non generi duplicati.
class ExerciseCatalogSeeder {
  ExerciseCatalogSeeder(this.db);

  final AppDatabase db;

  static const String catalogTypeEsercizi = 'ESERCIZI';

  /// Effettua parsing + validazione del JSON. Solleva [CatalogSeedException]
  /// se la struttura è invalida o incoerente.
  static ExerciseCatalogSeedModel parse(String jsonString) {
    final dynamic decoded;
    try {
      decoded = json.decode(jsonString);
    } on FormatException catch (e) {
      throw CatalogSeedException('JSON non valido: ${e.message}');
    }
    if (decoded is! Map<String, dynamic>) {
      throw CatalogSeedException(
        'La radice del catalogo deve essere un oggetto.',
      );
    }
    final ExerciseCatalogSeedModel model;
    try {
      model = ExerciseCatalogSeedModel.fromJson(decoded);
    } on CatalogParseException catch (e) {
      throw CatalogSeedException(e.message);
    }
    _validate(model);
    return model;
  }

  /// Comodità: parse + [seed] a partire dalla stringa JSON grezza.
  Future<CatalogSeedResult> seedFromString(String jsonString) {
    return seed(parse(jsonString));
  }

  /// Importa [catalog]. Assume che sia già stato validato da [parse]; ripete
  /// comunque la validazione in modo difensivo.
  Future<CatalogSeedResult> seed(ExerciseCatalogSeedModel catalog) {
    if (catalog.catalogType != catalogTypeEsercizi) {
      throw CatalogSeedException(
        'catalogType inatteso: ${catalog.catalogType} '
        '(atteso $catalogTypeEsercizi).',
      );
    }
    _validate(catalog);

    return db.transaction(() async {
      final existing =
          await (db.select(db.versioniCatalogoTable)..where(
                (t) =>
                    t.tipoCatalogo.equals(catalog.catalogType) &
                    t.versione.equals(catalog.catalogVersion),
              ))
              .getSingleOrNull();
      if (existing != null) {
        return const CatalogSeedResult(alreadyImported: true);
      }

      final now = DateTime.now();

      final categoryIdByCode = <String, int>{};
      for (final c in catalog.categories) {
        categoryIdByCode[c.code] = await _upsertCategory(c, now);
      }

      final muscleIdByCode = <String, int>{};
      for (final m in catalog.muscleGroups) {
        muscleIdByCode[m.code] = await _upsertMuscle(m, now);
      }

      for (final e in catalog.equipment) {
        await _upsertEquipment(e, catalog.catalogVersion, now);
      }

      final exerciseIdByCode = <String, int>{};
      final exerciseByCode = <String, ExerciseSeedModel>{};
      for (final e in catalog.exercises) {
        exerciseByCode[e.code] = e;
        exerciseIdByCode[e.code] = await _upsertExercise(
          e,
          categoryIdByCode[e.categoryCode]!,
          catalog.catalogVersion,
          now,
        );
      }

      var muscleRelations = 0;
      var equipmentRelations = 0;
      var images = 0;
      for (final e in catalog.exercises) {
        final exId = exerciseIdByCode[e.code]!;
        muscleRelations += await _replaceMuscleRelations(
          e,
          exId,
          muscleIdByCode,
        );
        equipmentRelations += await _replaceEquipmentRelations(e, exId);
        images += await _replaceImages(e, exId, now);
      }

      // Progressioni e alternative in un secondo passaggio: richiedono che
      // tutti gli id esercizio siano già risolti.
      var progressions = 0;
      var alternatives = 0;
      for (final e in catalog.exercises) {
        final exId = exerciseIdByCode[e.code]!;
        progressions += await _replaceProgression(
          e,
          exId,
          exerciseIdByCode,
          exerciseByCode,
          now,
        );
        alternatives += await _replaceAlternatives(
          e,
          exId,
          exerciseIdByCode,
          now,
        );
      }

      await db
          .into(db.versioniCatalogoTable)
          .insert(
            VersioniCatalogoTableCompanion.insert(
              tipoCatalogo: catalog.catalogType,
              versione: catalog.catalogVersion,
              dataImportazione: now,
              note: const Value('Import automatico exercises_v1.json'),
            ),
          );

      return CatalogSeedResult(
        alreadyImported: false,
        categories: catalog.categories.length,
        muscleGroups: catalog.muscleGroups.length,
        equipment: catalog.equipment.length,
        exercises: catalog.exercises.length,
        muscleRelations: muscleRelations,
        equipmentRelations: equipmentRelations,
        images: images,
        progressions: progressions,
        alternatives: alternatives,
      );
    });
  }

  // --- Upsert master (lookup-by-code poi insert/update) ---

  Future<int> _upsertCategory(CategorySeedModel c, DateTime now) async {
    final existing = await (db.select(
      db.categorieEserciziTable,
    )..where((t) => t.codice.equals(c.code))).getSingleOrNull();
    if (existing == null) {
      return db
          .into(db.categorieEserciziTable)
          .insert(
            CategorieEserciziTableCompanion.insert(
              codice: c.code,
              nome: c.name,
              descrizione: Value(c.description),
              ordineVisualizzazione: Value(c.displayOrder),
              attiva: Value(c.active),
              dataCreazione: now,
              dataModifica: now,
            ),
          );
    }
    await (db.update(
      db.categorieEserciziTable,
    )..where((t) => t.id.equals(existing.id))).write(
      CategorieEserciziTableCompanion(
        nome: Value(c.name),
        descrizione: Value(c.description),
        ordineVisualizzazione: Value(c.displayOrder),
        attiva: Value(c.active),
        dataModifica: Value(now),
      ),
    );
    return existing.id;
  }

  Future<int> _upsertMuscle(MuscleGroupSeedModel m, DateTime now) async {
    final existing = await (db.select(
      db.gruppiMuscolariTable,
    )..where((t) => t.codice.equals(m.code))).getSingleOrNull();
    if (existing == null) {
      return db
          .into(db.gruppiMuscolariTable)
          .insert(
            GruppiMuscolariTableCompanion.insert(
              codice: m.code,
              nome: m.name,
              attivo: Value(m.active),
              dataCreazione: now,
              dataModifica: now,
            ),
          );
    }
    await (db.update(
      db.gruppiMuscolariTable,
    )..where((t) => t.id.equals(existing.id))).write(
      GruppiMuscolariTableCompanion(
        nome: Value(m.name),
        attivo: Value(m.active),
        dataModifica: Value(now),
      ),
    );
    return existing.id;
  }

  Future<int> _upsertEquipment(
    EquipmentSeedModel e,
    int catalogVersion,
    DateTime now,
  ) async {
    final existing = await (db.select(
      db.attrezzatureTable,
    )..where((t) => t.codice.equals(e.code))).getSingleOrNull();
    if (existing == null) {
      return db
          .into(db.attrezzatureTable)
          .insert(
            AttrezzatureTableCompanion.insert(
              codice: e.code,
              nome: e.name,
              descrizione: Value(e.description),
              categoria: Value(e.category),
              prezzoMinimoIndicativo: Value(e.minPrice),
              prezzoMassimoIndicativo: Value(e.maxPrice),
              priorita: Value(e.priority),
              queryRicerca: Value(e.searchQuery),
              attiva: Value(e.active),
              versioneCatalogo: catalogVersion,
              dataCreazione: now,
              dataModifica: now,
            ),
          );
    }
    await (db.update(
      db.attrezzatureTable,
    )..where((t) => t.id.equals(existing.id))).write(
      AttrezzatureTableCompanion(
        nome: Value(e.name),
        descrizione: Value(e.description),
        categoria: Value(e.category),
        prezzoMinimoIndicativo: Value(e.minPrice),
        prezzoMassimoIndicativo: Value(e.maxPrice),
        priorita: Value(e.priority),
        queryRicerca: Value(e.searchQuery),
        attiva: Value(e.active),
        versioneCatalogo: Value(catalogVersion),
        dataModifica: Value(now),
      ),
    );
    return existing.id;
  }

  Future<int> _upsertExercise(
    ExerciseSeedModel e,
    int idCategoria,
    int catalogVersion,
    DateTime now,
  ) async {
    final existing = await (db.select(
      db.eserciziTable,
    )..where((t) => t.codice.equals(e.code))).getSingleOrNull();
    if (existing == null) {
      return db
          .into(db.eserciziTable)
          .insert(
            EserciziTableCompanion.insert(
              codice: e.code,
              nome: e.name,
              descrizione: e.description,
              istruzioni: e.instructions,
              istruzioniRespirazione: Value(e.breathingInstructions),
              noteSicurezza: Value(e.safetyNotes),
              erroriComuni: Value(e.commonMistakes),
              idCategoria: idCategoria,
              livelloMinimo: e.minimumLevel,
              livelloMassimo: Value(e.maximumLevel),
              livelloImpatto: e.impactLevel,
              intensitaCardio: Value(e.cardioIntensity),
              richiedeEquilibrio: Value(e.balanceRequired),
              richiedePavimento: Value(e.floorRequired),
              richiedePosizioneEretta: Value(e.standingRequired),
              supportoConsentito: Value(e.supportAllowed),
              seriePredefinite: Value(e.defaultSets),
              ripetizioniPredefinite: Value(e.defaultReps),
              durataPredefinitaSecondi: Value(e.defaultDurationSeconds),
              recuperoPredefinitoSecondi: Value(e.defaultRestSeconds),
              versioneCatalogo: catalogVersion,
              dataCreazione: now,
              dataModifica: now,
            ),
          );
    }
    await (db.update(
      db.eserciziTable,
    )..where((t) => t.id.equals(existing.id))).write(
      EserciziTableCompanion(
        nome: Value(e.name),
        descrizione: Value(e.description),
        istruzioni: Value(e.instructions),
        istruzioniRespirazione: Value(e.breathingInstructions),
        noteSicurezza: Value(e.safetyNotes),
        erroriComuni: Value(e.commonMistakes),
        idCategoria: Value(idCategoria),
        livelloMinimo: Value(e.minimumLevel),
        livelloMassimo: Value(e.maximumLevel),
        livelloImpatto: Value(e.impactLevel),
        intensitaCardio: Value(e.cardioIntensity),
        richiedeEquilibrio: Value(e.balanceRequired),
        richiedePavimento: Value(e.floorRequired),
        richiedePosizioneEretta: Value(e.standingRequired),
        supportoConsentito: Value(e.supportAllowed),
        seriePredefinite: Value(e.defaultSets),
        ripetizioniPredefinite: Value(e.defaultReps),
        durataPredefinitaSecondi: Value(e.defaultDurationSeconds),
        recuperoPredefinitoSecondi: Value(e.defaultRestSeconds),
        versioneCatalogo: Value(catalogVersion),
        dataModifica: Value(now),
      ),
    );
    return existing.id;
  }

  // --- Relazioni: cancella per esercizio poi reinserisci (idempotente) ---

  Future<int> _replaceMuscleRelations(
    ExerciseSeedModel e,
    int exId,
    Map<String, int> muscleIdByCode,
  ) async {
    await (db.delete(
      db.eserciziGruppiMuscolariTable,
    )..where((t) => t.idEsercizio.equals(exId))).go();
    var count = 0;
    for (final code in e.primaryMuscleCodes) {
      await db
          .into(db.eserciziGruppiMuscolariTable)
          .insert(
            EserciziGruppiMuscolariTableCompanion.insert(
              idEsercizio: exId,
              idGruppoMuscolare: muscleIdByCode[code]!,
              tipoCoinvolgimento: 'PRIMARIO',
            ),
          );
      count++;
    }
    for (final code in e.secondaryMuscleCodes) {
      await db
          .into(db.eserciziGruppiMuscolariTable)
          .insert(
            EserciziGruppiMuscolariTableCompanion.insert(
              idEsercizio: exId,
              idGruppoMuscolare: muscleIdByCode[code]!,
              tipoCoinvolgimento: 'SECONDARIO',
            ),
          );
      count++;
    }
    return count;
  }

  Future<int> _replaceEquipmentRelations(ExerciseSeedModel e, int exId) async {
    await (db.delete(
      db.attrezzatureEserciziTable,
    )..where((t) => t.idEsercizio.equals(exId))).go();
    var count = 0;
    for (final eq in e.equipmentCodes) {
      final equipRow = await (db.select(
        db.attrezzatureTable,
      )..where((t) => t.codice.equals(eq.code))).getSingle();
      await db
          .into(db.attrezzatureEserciziTable)
          .insert(
            AttrezzatureEserciziTableCompanion.insert(
              idEsercizio: exId,
              idAttrezzatura: equipRow.id,
              obbligatoria: Value(eq.required),
            ),
          );
      count++;
    }
    return count;
  }

  Future<int> _replaceImages(
    ExerciseSeedModel e,
    int exId,
    DateTime now,
  ) async {
    await (db.delete(
      db.immaginiEserciziTable,
    )..where((t) => t.idEsercizio.equals(exId))).go();
    var count = 0;
    for (final img in e.images) {
      await db
          .into(db.immaginiEserciziTable)
          .insert(
            ImmaginiEserciziTableCompanion.insert(
              idEsercizio: exId,
              tipoSorgente: img.sourceType,
              percorsoAsset: Value(img.sourceType == 'ASSET' ? img.path : null),
              percorsoFileLocale: Value(
                img.sourceType == 'FILE_LOCALE' ? img.path : null,
              ),
              tipoImmagine: img.type,
              didascalia: Value(img.caption),
              ordineVisualizzazione: Value(img.order),
              dataCreazione: now,
              dataModifica: now,
            ),
          );
      count++;
    }
    return count;
  }

  Future<int> _replaceProgression(
    ExerciseSeedModel e,
    int exId,
    Map<String, int> exerciseIdByCode,
    Map<String, ExerciseSeedModel> exerciseByCode,
    DateTime now,
  ) async {
    await (db.delete(
      db.progressioniEserciziTable,
    )..where((t) => t.idEsercizio.equals(exId))).go();
    final code = e.progressionCode;
    if (code == null) return 0;
    final target = exerciseByCode[code]!;
    await db
        .into(db.progressioniEserciziTable)
        .insert(
          ProgressioniEserciziTableCompanion.insert(
            idEsercizio: exId,
            idEsercizioSuccessivo: exerciseIdByCode[code]!,
            tipoProgressione: e.progressionType ?? 'VARIANTE',
            livelloMinimo: target.minimumLevel,
            dataCreazione: now,
            dataModifica: now,
          ),
        );
    return 1;
  }

  Future<int> _replaceAlternatives(
    ExerciseSeedModel e,
    int exId,
    Map<String, int> exerciseIdByCode,
    DateTime now,
  ) async {
    await (db.delete(
      db.alternativeEserciziTable,
    )..where((t) => t.idEsercizio.equals(exId))).go();
    var count = 0;
    for (final alt in e.alternativeCodes) {
      await db
          .into(db.alternativeEserciziTable)
          .insert(
            AlternativeEserciziTableCompanion.insert(
              idEsercizio: exId,
              idEsercizioAlternativo: exerciseIdByCode[alt.code]!,
              codiceMotivo: alt.reason,
              priorita: Value(alt.priority),
              dataCreazione: now,
              dataModifica: now,
            ),
          );
      count++;
    }
    return count;
  }

  // --- Validazione referenziale ---

  static void _validate(ExerciseCatalogSeedModel c) {
    void ensure(bool condition, String message) {
      if (!condition) throw CatalogSeedException(message);
    }

    ensure(c.catalogVersion > 0, 'catalogVersion deve essere positivo.');

    final categoryCodes = c.categories.map((e) => e.code).toSet();
    ensure(
      categoryCodes.length == c.categories.length,
      'Codici categoria duplicati.',
    );
    final muscleCodes = c.muscleGroups.map((e) => e.code).toSet();
    ensure(
      muscleCodes.length == c.muscleGroups.length,
      'Codici gruppo muscolare duplicati.',
    );
    final equipmentCodes = c.equipment.map((e) => e.code).toSet();
    ensure(
      equipmentCodes.length == c.equipment.length,
      'Codici attrezzatura duplicati.',
    );

    final exerciseCodes = c.exercises.map((e) => e.code).toSet();
    ensure(
      exerciseCodes.length == c.exercises.length,
      'Codici esercizio duplicati.',
    );

    for (final e in c.exercises) {
      ensure(
        categoryCodes.contains(e.categoryCode),
        '${e.code}: categoria inesistente ${e.categoryCode}.',
      );
      for (final eq in e.equipmentCodes) {
        ensure(
          equipmentCodes.contains(eq.code),
          '${e.code}: attrezzatura inesistente ${eq.code}.',
        );
      }
      for (final m in [...e.primaryMuscleCodes, ...e.secondaryMuscleCodes]) {
        ensure(
          muscleCodes.contains(m),
          '${e.code}: gruppo muscolare inesistente $m.',
        );
      }
      final prog = e.progressionCode;
      if (prog != null) {
        ensure(
          exerciseCodes.contains(prog),
          '${e.code}: progressionCode inesistente $prog.',
        );
        ensure(prog != e.code, '${e.code}: progressione verso se stesso.');
      }
      for (final alt in e.alternativeCodes) {
        ensure(
          exerciseCodes.contains(alt.code),
          '${e.code}: alternativeCode inesistente ${alt.code}.',
        );
        ensure(alt.code != e.code, '${e.code}: alternativa verso se stesso.');
      }
    }
  }
}
