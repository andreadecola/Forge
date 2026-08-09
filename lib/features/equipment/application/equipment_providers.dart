import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/equipment_item.dart';
import '../../../domain/use_cases/update_equipment.dart';

/// Stato di tutti gli attrezzi del catalogo (posseduti e non) per il profilo.
final equipmentStatesProvider =
    StreamProvider.family<List<UserEquipmentState>, int>((ref, profileId) {
      return ref
          .watch(equipmentRepositoryProvider)
          .watchAllEquipmentStates(profileId);
    });

final ownedEquipmentProvider =
    FutureProvider.family<List<UserEquipmentState>, int>((ref, profileId) {
      return ref
          .watch(equipmentRepositoryProvider)
          .getOwnedEquipment(profileId);
    });

class EquipmentController {
  EquipmentController(this._ref);

  final Ref _ref;

  Future<void> setOwned({
    required int profileId,
    required EquipmentItem item,
    required bool owned,
  }) {
    return UpdateEquipment(_ref.read(equipmentRepositoryProvider))(
      profileId: profileId,
      item: item,
      owned: owned,
    );
  }
}

final equipmentControllerProvider = Provider<EquipmentController>((ref) {
  return EquipmentController(ref);
});
