/// Catalogo statico dell'attrezzatura domestica posseduta dall'utente
/// (Milestone 2). [code] è il codice utente storicizzato in
/// `attrezzature_utente.equipmentCode`; [masterCode] è il codice
/// corrispondente nel catalogo master `attrezzature` (Milestone 3.2).
///
/// Il collegamento avviene per codice tramite [masterCode] (mapping unico
/// e centralizzato): nessuna migration è necessaria in Milestone 3.3.
enum EquipmentItem {
  chair('chair', 'Sedia', 'CHAIR'),
  wall('wall', 'Muro', 'WALL'),
  mat('mat', 'Tappetino', 'MAT'),
  resistanceBands('resistance_bands', 'Elastici', 'BAND'),
  dumbbells10kg('dumbbells_10kg', 'Manubri fino a 10 kg', 'DUMBBELL'),
  step('step', 'Step', 'STEP');

  const EquipmentItem(this.code, this.label, this.masterCode);

  final String code;
  final String label;

  /// Codice corrispondente nel catalogo master `attrezzature`.
  final String masterCode;

  /// Attrezzatura pre-selezionata come posseduta in onboarding.
  static const Set<EquipmentItem> defaultOwned = {
    EquipmentItem.chair,
    EquipmentItem.wall,
    EquipmentItem.resistanceBands,
    EquipmentItem.dumbbells10kg,
  };

  static EquipmentItem byCode(String code) =>
      EquipmentItem.values.firstWhere((e) => e.code == code);

  /// Ritorna l'elemento con [code], o `null` se sconosciuto (non inventa
  /// attrezzature master per codici non mappati).
  static EquipmentItem? tryByCode(String code) {
    for (final item in EquipmentItem.values) {
      if (item.code == code) return item;
    }
    return null;
  }
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
