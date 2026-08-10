import '../../domain/entities/equipment.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_category.dart';
import '../../domain/entities/exercise_catalog_enums.dart';
import '../../domain/entities/exercise_image.dart';
import '../../domain/entities/muscle_group.dart';
import '../database/app_database.dart';

/// Conversioni da righe Drift a entità di dominio del catalogo. Isolano il
/// dominio dai tipi generati e centralizzano il parsing dei codici → enum.
abstract final class CatalogMappers {
  static Exercise exercise(EserciziTableData row) {
    return Exercise(
      id: row.id,
      code: row.codice,
      name: row.nome,
      description: row.descrizione,
      instructions: row.istruzioni,
      breathingInstructions: row.istruzioniRespirazione,
      safetyNotes: row.noteSicurezza,
      commonMistakes: row.erroriComuni,
      categoryId: row.idCategoria,
      minimumLevel: row.livelloMinimo,
      maximumLevel: row.livelloMassimo,
      impactLevel: ExerciseImpactLevel.fromCode(row.livelloImpatto),
      cardioIntensity: row.intensitaCardio == null
          ? null
          : ExerciseCardioIntensity.fromCode(row.intensitaCardio!),
      balanceRequired: row.richiedeEquilibrio,
      floorRequired: row.richiedePavimento,
      standingRequired: row.richiedePosizioneEretta,
      supportAllowed: row.supportoConsentito,
      defaultSets: row.seriePredefinite,
      defaultReps: row.ripetizioniPredefinite,
      defaultDurationSeconds: row.durataPredefinitaSecondi,
      defaultRestSeconds: row.recuperoPredefinitoSecondi,
      isSystem: row.esercizioSistema,
      isActive: row.attivo,
      catalogVersion: row.versioneCatalogo,
    );
  }

  static ExerciseCategory category(CategorieEserciziTableData row) {
    return ExerciseCategory(
      id: row.id,
      code: row.codice,
      name: row.nome,
      description: row.descrizione,
      displayOrder: row.ordineVisualizzazione,
      active: row.attiva,
    );
  }

  static MuscleGroup muscle(GruppiMuscolariTableData row) {
    return MuscleGroup(
      id: row.id,
      code: row.codice,
      name: row.nome,
      description: row.descrizione,
      active: row.attivo,
    );
  }

  static Equipment equipment(AttrezzatureTableData row) {
    return Equipment(
      id: row.id,
      code: row.codice,
      name: row.nome,
      description: row.descrizione,
      category: row.categoria,
      minPrice: row.prezzoMinimoIndicativo,
      maxPrice: row.prezzoMassimoIndicativo,
      priority: row.priorita,
      searchQuery: row.queryRicerca,
      active: row.attiva,
      catalogVersion: row.versioneCatalogo,
    );
  }

  static ExerciseImage image(ImmaginiEserciziTableData row) {
    return ExerciseImage(
      id: row.id,
      exerciseId: row.idEsercizio,
      sourceType: ExerciseImageSourceType.fromCode(row.tipoSorgente),
      assetPath: row.percorsoAsset,
      localFilePath: row.percorsoFileLocale,
      imageType: ExerciseImageType.fromCode(row.tipoImmagine),
      caption: row.didascalia,
      displayOrder: row.ordineVisualizzazione,
      active: row.attiva,
    );
  }
}
