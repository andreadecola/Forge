import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/forge_providers.dart' show clockProvider;
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/pressure_measurement.dart';
import '../../../domain/use_cases/add_pressure_measurement.dart';
import '../../../domain/use_cases/update_pressure_measurement.dart';

final pressureMeasurementsProvider =
    StreamProvider.family<List<PressureMeasurement>, int>((ref, profileId) {
      return ref
          .watch(pressureRepositoryProvider)
          .watchMeasurementsByProfile(profileId);
    });

final latestPressureProvider = FutureProvider.family<PressureMeasurement?, int>(
  (ref, profileId) {
    return ref.watch(pressureRepositoryProvider).getLatestPressure(profileId);
  },
);

/// Singola misurazione per id (Milestone 7.1, sezione 24), `null` se non
/// esiste.
final pressureMeasurementByIdProvider =
    FutureProvider.family<PressureMeasurement?, int>((ref, id) {
      return ref.watch(pressureRepositoryProvider).getById(id);
    });

class PressureController {
  PressureController(this._ref);

  final Ref _ref;

  Future<void> addMeasurement(PressureMeasurement measurement) {
    return AddPressureMeasurement(
      _ref.read(pressureRepositoryProvider),
      clock: _ref.read(clockProvider),
    )(measurement);
  }

  /// Nuovo in Milestone 7.1 (sezione 17): nessun percorso di modifica
  /// esisteva prima per una misurazione pressione già registrata.
  Future<void> updateMeasurement(PressureMeasurement measurement) {
    return UpdatePressureMeasurement(
      _ref.read(pressureRepositoryProvider),
      clock: _ref.read(clockProvider),
    )(measurement);
  }

  Future<void> deleteMeasurement(int id) {
    return _ref.read(pressureRepositoryProvider).deleteMeasurement(id);
  }
}

final pressureControllerProvider = Provider<PressureController>((ref) {
  return PressureController(ref);
});
