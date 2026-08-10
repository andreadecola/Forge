import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/catalog_providers.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/exercise_availability_status.dart';
import '../../../domain/entities/exercise_category.dart';
import '../../../domain/entities/exercise_details.dart';
import '../../../domain/entities/exercise_image.dart';
import '../../../domain/entities/exercise_filters.dart';
import '../../../domain/services/user_equipment_resolver.dart';

/// Elenco categorie (già in italiano nel seed: nessun mapper necessario).
final categoriesProvider = FutureProvider<List<ExerciseCategory>>((ref) {
  return ref.watch(exerciseRepositoryProvider).getCategories();
});

/// Catalogo master attrezzature (8 elementi), per i filtri e le etichette.
final equipmentCatalogProvider = FutureProvider<List<Equipment>>((ref) {
  return ref.watch(equipmentCatalogRepositoryProvider).getAllEquipment();
});

/// Attrezzatura master realmente posseduta dall'utente (dati reali M2,
/// tradotti tramite [UserEquipmentResolver]). Vuoto se non c'è ancora un
/// profilo (non dovrebbe accadere: l'onboarding lo crea sempre prima).
final ownedMasterEquipmentCodesProvider = FutureProvider<Set<String>>((
  ref,
) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile?.id == null) return const {};
  final owned = await ref
      .watch(equipmentRepositoryProvider)
      .getOwnedEquipment(profile!.id!);
  return UserEquipmentResolver.toMasterCodes(owned.map((e) => e.item.code));
});

/// Esercizio arricchito con i dati necessari alla lista/filtri, calcolati
/// una sola volta per l'intero catalogo (niente N+1 per card).
class ExerciseCatalogItem {
  const ExerciseCatalogItem({
    required this.exercise,
    required this.category,
    required this.requiredEquipmentCodes,
    required this.requiredEquipmentNames,
    required this.status,
  });

  final Exercise exercise;
  final ExerciseCategory category;
  final Set<String> requiredEquipmentCodes;
  final List<String> requiredEquipmentNames;
  final ExerciseAvailabilityStatus status;
}

/// Tutti gli esercizi con categoria, attrezzatura richiesta e disponibilità
/// già calcolate per [ExerciseFilters.userLevel] corrente.
final catalogItemsProvider = FutureProvider<List<ExerciseCatalogItem>>((
  ref,
) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  final service = ref.watch(exerciseAvailabilityServiceProvider);
  final userLevel = ref.watch(
    exerciseFiltersProvider.select((f) => f.userLevel),
  );

  final exercises = await repo.getExercises();
  final categories = await ref.watch(categoriesProvider.future);
  final equipmentCatalog = await ref.watch(equipmentCatalogProvider.future);
  final requiredByExercise = await repo.getRequiredEquipmentCodesByExercise();
  final owned = await ref.watch(ownedMasterEquipmentCodesProvider.future);

  final categoryById = {for (final c in categories) c.id: c};
  final equipmentNameByCode = {
    for (final e in equipmentCatalog) e.code: e.name,
  };

  return exercises.map((exercise) {
    final required = requiredByExercise[exercise.id] ?? const <String>{};
    final status = service.evaluate(
      exercise: exercise,
      userLevel: userLevel,
      ownedEquipmentCodes: owned,
      requiredEquipmentCodes: required,
    );
    return ExerciseCatalogItem(
      exercise: exercise,
      category: categoryById[exercise.categoryId]!,
      requiredEquipmentCodes: required,
      requiredEquipmentNames: required
          .map((code) => equipmentNameByCode[code] ?? code)
          .toList(),
      status: status,
    );
  }).toList();
});

class ExerciseFiltersController extends Notifier<ExerciseFilters> {
  @override
  ExerciseFilters build() => const ExerciseFilters();

  void setSearchQuery(String query) {
    final trimmed = query.trim();
    state = state.copyWith(searchQuery: () => trimmed.isEmpty ? null : trimmed);
  }

  void setCategoryCode(String? code) {
    state = state.copyWith(categoryCode: () => code);
  }

  void setUserLevel(int level) {
    state = state.copyWith(userLevel: level);
  }

  /// `null` rimuove il filtro attrezzatura ("Tutte").
  void setEquipmentCode(String? code) {
    state = state.copyWith(equipmentCodes: () => code == null ? null : {code});
  }

  void setAvailabilityStatus(ExerciseAvailabilityStatus? status) {
    state = state.copyWith(availabilityStatus: () => status);
  }

  void reset() {
    state = const ExerciseFilters();
  }
}

final exerciseFiltersProvider =
    NotifierProvider<ExerciseFiltersController, ExerciseFilters>(
      ExerciseFiltersController.new,
    );

/// Numero di filtri attivi tra quelli del bottom sheet "Filtri" (categoria,
/// livello, attrezzatura, disponibilità). La ricerca testuale ha un proprio
/// indicatore (il campo stesso) e non viene contata qui: riusa lo stesso
/// [ExerciseFilters] già esistente, nessuno stato duplicato.
int activeFilterCount(ExerciseFilters filters) {
  var count = 0;
  if (filters.categoryCode != null) count++;
  if (filters.userLevel != ExerciseFilters.defaultUserLevel) count++;
  if (filters.equipmentCodes?.isNotEmpty ?? false) count++;
  if (filters.availabilityStatus != null) count++;
  return count;
}

/// Catalogo completo con i filtri correnti applicati (ricerca per
/// nome/codice/categoria, categoria, attrezzatura richiesta, disponibilità).
/// I filtri si combinano: sono tutti applicati in sequenza (intersezione).
final filteredExercisesProvider =
    Provider<AsyncValue<List<ExerciseCatalogItem>>>((ref) {
      final itemsAsync = ref.watch(catalogItemsProvider);
      final filters = ref.watch(exerciseFiltersProvider);
      return itemsAsync.whenData((items) => _applyFilters(items, filters));
    });

List<ExerciseCatalogItem> _applyFilters(
  List<ExerciseCatalogItem> items,
  ExerciseFilters filters,
) {
  Iterable<ExerciseCatalogItem> result = items;

  final query = filters.searchQuery?.toLowerCase();
  if (query != null && query.isNotEmpty) {
    result = result.where(
      (item) =>
          item.exercise.name.toLowerCase().contains(query) ||
          item.exercise.code.toLowerCase().contains(query) ||
          item.category.name.toLowerCase().contains(query),
    );
  }

  final categoryCode = filters.categoryCode;
  if (categoryCode != null) {
    result = result.where((item) => item.category.code == categoryCode);
  }

  final equipmentFilter = filters.equipmentCodes;
  if (equipmentFilter != null && equipmentFilter.isNotEmpty) {
    result = result.where(
      (item) => item.requiredEquipmentCodes.any(equipmentFilter.contains),
    );
  }

  final availabilityStatus = filters.availabilityStatus;
  if (availabilityStatus != null) {
    result = result.where((item) => item.status == availabilityStatus);
  }

  return result.toList();
}

/// Dettaglio completo di un esercizio (categoria, muscoli, attrezzatura,
/// immagini, progressioni, regressioni, alternative).
final exerciseDetailsProvider = FutureProvider.family<ExerciseDetails?, int>((
  ref,
  exerciseId,
) {
  return ref.watch(exerciseRepositoryProvider).getExerciseDetails(exerciseId);
});

/// Solo le immagini di un esercizio, per la thumbnail di lista (leggero:
/// evita di caricare l'intero dettaglio per ogni card visibile).
final exerciseImagesProvider = FutureProvider.family<List<ExerciseImage>, int>((
  ref,
  exerciseId,
) {
  return ref.watch(exerciseRepositoryProvider).getImages(exerciseId);
});
