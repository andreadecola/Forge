/// Attrezzatura del catalogo master (`attrezzature`). Distinta da
/// [EquipmentItem] (Milestone 2), che rappresenta l'inventario dell'utente.
class Equipment {
  const Equipment({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.category,
    this.minPrice,
    this.maxPrice,
    required this.priority,
    this.searchQuery,
    required this.active,
    required this.catalogVersion,
  });

  final int id;
  final String code;
  final String name;
  final String? description;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final int priority;
  final String? searchQuery;
  final bool active;
  final int catalogVersion;

  /// Codice speciale: nessuna attrezzatura richiesta.
  static const String noneCode = 'NONE';
}

/// Attrezzatura richiesta da un esercizio, con flag di obbligatorietà.
class ExerciseEquipmentRequirement {
  const ExerciseEquipmentRequirement({
    required this.equipment,
    required this.required,
  });

  final Equipment equipment;
  final bool required;
}
