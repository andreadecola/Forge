import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/forge_providers.dart' show clockProvider;
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/body_measurement.dart';
import '../../../domain/use_cases/add_body_measurement.dart';
import '../../../domain/use_cases/update_body_measurement.dart';

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

/// Speculare a [latestWeightProvider] per il girovita (Milestone 7.2).
final latestWaistProvider = FutureProvider.family<BodyMeasurement?, int>((
  ref,
  profileId,
) {
  return ref.watch(bodyMetricsRepositoryProvider).getLatestWaist(profileId);
});

/// Singola misurazione per id (Milestone 7.1, sezione 24), `null` se non
/// esiste (es. già eliminata).
final bodyMeasurementByIdProvider =
    FutureProvider.family<BodyMeasurement?, int>((ref, id) {
      return ref.watch(bodyMetricsRepositoryProvider).getById(id);
    });

class WeightController {
  WeightController(this._ref);

  final Ref _ref;

  Future<void> addMeasurement(BodyMeasurement measurement) {
    return AddBodyMeasurement(
      _ref.read(bodyMetricsRepositoryProvider),
      clock: _ref.read(clockProvider),
    )(measurement);
  }

  /// Ora validata come [addMeasurement] (Milestone 7.1, sezione 17/18):
  /// prima di questa milestone scriveva senza alcun controllo.
  Future<void> updateMeasurement(BodyMeasurement measurement) {
    return UpdateBodyMeasurement(
      _ref.read(bodyMetricsRepositoryProvider),
      clock: _ref.read(clockProvider),
    )(measurement);
  }

  Future<void> deleteMeasurement(int id) {
    return _ref.read(bodyMetricsRepositoryProvider).deleteMeasurement(id);
  }
}

final weightControllerProvider = Provider<WeightController>((ref) {
  return WeightController(ref);
});
