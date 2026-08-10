import '../database/app_database.dart';
import 'exercise_catalog_seeder.dart';

/// Firma di un loader di asset (astrae `rootBundle.loadString`, così il
/// bootstrap è testabile leggendo il file da disco).
typedef AssetStringLoader = Future<String> Function(String key);

/// Esegue il seed del catalogo all'avvio dell'app.
///
/// - idempotente (delega la garanzia a [ExerciseCatalogSeeder]);
/// - asincrono;
/// - gli errori NON vengono ingoiati: [run] li rilancia, il chiamante decide
///   come gestirli (log/stato di errore), senza mai bloccare la UI.
class CatalogBootstrapper {
  CatalogBootstrapper(
    this.db, {
    this.assetKey = 'assets/data/exercises_v1.json',
  });

  final AppDatabase db;
  final String assetKey;

  Future<CatalogSeedResult> run(AssetStringLoader loadAsset) async {
    final raw = await loadAsset(assetKey);
    return ExerciseCatalogSeeder(db).seedFromString(raw);
  }
}
