import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/body_measurement.dart';
import '../../../domain/use_cases/add_body_measurement.dart';

/// Storico misure per il profilo, ordinato dal più recente.
final bodyMeasurementsProvider =
    StreamProvider.family<List<BodyMeasurement>, int>((ref, profileId) {
      return ref
          .watch(bodyMetricsRepositoryProvider)
          .watchMeasurementsByProfile(profileId);
    });

final latestWeightProvider = FutureProvider.family<BodyMeasurement?, int>((
  ref,
  profileId,
) {
  return ref.watch(bodyMetricsRepositoryProvider).getLatestWeight(profileId);
});

class WeightController {
  WeightController(this._ref);

  final Ref _ref;

  Future<void> addMeasurement(BodyMeasurement measurement) {
    return AddBodyMeasurement(_ref.read(bodyMetricsRepositoryProvider))(
      measurement,
    );
  }

  Future<void> updateMeasurement(BodyMeasurement measurement) {
    return _ref
        .read(bodyMetricsRepositoryProvider)
        .updateMeasurement(measurement);
  }

  Future<void> deleteMeasurement(int id) {
    return _ref.read(bodyMetricsRepositoryProvider).deleteMeasurement(id);
  }
}

final weightControllerProvider = Provider<WeightController>((ref) {
  return WeightController(ref);
});
