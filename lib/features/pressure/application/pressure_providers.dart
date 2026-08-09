import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/pressure_measurement.dart';
import '../../../domain/use_cases/add_pressure_measurement.dart';

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

class PressureController {
  PressureController(this._ref);

  final Ref _ref;

  Future<void> addMeasurement(PressureMeasurement measurement) {
    return AddPressureMeasurement(_ref.read(pressureRepositoryProvider))(
      measurement,
    );
  }

  Future<void> deleteMeasurement(int id) {
    return _ref.read(pressureRepositoryProvider).deleteMeasurement(id);
  }
}

final pressureControllerProvider = Provider<PressureController>((ref) {
  return PressureController(ref);
});
