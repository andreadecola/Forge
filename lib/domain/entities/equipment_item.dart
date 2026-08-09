/// Catalogo statico dell'attrezzatura domestica gestita in questa milestone.
/// Il catalogo completo/estendibile arriverà con la Milestone Attrezzatura (M11).
enum EquipmentItem {
  chair('chair', 'Sedia'),
  wall('wall', 'Muro'),
  mat('mat', 'Tappetino'),
  resistanceBands('resistance_bands', 'Elastici'),
  dumbbells10kg('dumbbells_10kg', 'Manubri fino a 10 kg'),
  step('step', 'Step');

  const EquipmentItem(this.code, this.label);

  final String code;
  final String label;

  /// Attrezzatura pre-selezionata come posseduta in onboarding.
  static const Set<EquipmentItem> defaultOwned = {
    EquipmentItem.chair,
    EquipmentItem.wall,
    EquipmentItem.resistanceBands,
    EquipmentItem.dumbbells10kg,
  };

  static EquipmentItem byCode(String code) =>
      EquipmentItem.values.firstWhere((e) => e.code == code);
}

/// Stato di possesso di un attrezzo per il profilo corrente.
class UserEquipmentState {
  const UserEquipmentState({
    this.id,
    required this.profileId,
    required this.item,
    required this.owned,
    this.acquiredAt,
    this.notes,
  });

  final int? id;
  final int profileId;
  final EquipmentItem item;
  final bool owned;
  final DateTime? acquiredAt;
  final String? notes;

  UserEquipmentState copyWith({bool? owned}) {
    return UserEquipmentState(
      id: id,
      profileId: profileId,
      item: item,
      owned: owned ?? this.owned,
      acquiredAt: acquiredAt,
      notes: notes,
    );
  }
}
