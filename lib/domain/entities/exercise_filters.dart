import 'exercise_availability_status.dart';

/// Modello riutilizzabile per filtrare il catalogo (nessuna logica UI).
class ExerciseFilters {
  const ExerciseFilters({
    this.searchQuery,
    this.categoryCode,
    this.userLevel = defaultUserLevel,
    this.equipmentCodes,
    this.availabilityStatus,
  });

  /// Livello utente di default finché non esiste un livello persistente
  /// (vedi Milestone Forge Engine/progressione).
  static const int defaultUserLevel = 1;

  final String? searchQuery;
  final String? categoryCode;
  final int userLevel;

  /// Codici attrezzatura master posseduti dall'utente (già risolti dal
  /// mapping M2 → master).
  final Set<String>? equipmentCodes;

  final ExerciseAvailabilityStatus? availabilityStatus;

  ExerciseFilters copyWith({
    String? Function()? searchQuery,
    String? Function()? categoryCode,
    int? userLevel,
    Set<String>? Function()? equipmentCodes,
    ExerciseAvailabilityStatus? Function()? availabilityStatus,
  }) {
    return ExerciseFilters(
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
      categoryCode: categoryCode != null ? categoryCode() : this.categoryCode,
      userLevel: userLevel ?? this.userLevel,
      equipmentCodes: equipmentCodes != null
          ? equipmentCodes()
          : this.equipmentCodes,
      availabilityStatus: availabilityStatus != null
          ? availabilityStatus()
          : this.availabilityStatus,
    );
  }
}
