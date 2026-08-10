import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/equipment_catalog_repository.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/services/exercise_availability_service.dart';
import '../database/database_provider.dart';
import '../seed/catalog_bootstrapper.dart';
import '../seed/exercise_catalog_seeder.dart';
import 'drift_equipment_catalog_repository.dart';
import 'drift_exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return DriftExerciseRepository(ref.watch(databaseProvider));
});

final equipmentCatalogRepositoryProvider = Provider<EquipmentCatalogRepository>(
  (ref) {
    return DriftEquipmentCatalogRepository(ref.watch(databaseProvider));
  },
);

final exerciseAvailabilityServiceProvider =
    Provider<ExerciseAvailabilityService>((ref) {
      return const ExerciseAvailabilityService();
    });

/// Esegue il seed del catalogo all'avvio, una sola volta, in modo idempotente.
/// Espone lo stato (loading/data/error) senza bloccare la UI: la si può
/// osservare per mostrare eventuali errori, ma il resto dell'app non dipende
/// dal suo completamento.
final catalogBootstrapProvider = FutureProvider<CatalogSeedResult>((ref) async {
  final db = ref.watch(databaseProvider);
  final bootstrapper = CatalogBootstrapper(db);
  return bootstrapper.run(rootBundle.loadString);
});
