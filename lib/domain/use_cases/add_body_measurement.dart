import '../../core/validation/onboarding_validators.dart';
import '../entities/body_measurement.dart';
import '../repositories/body_metrics_repository.dart';

class AddBodyMeasurement {
  AddBodyMeasurement(this._repository);

  final BodyMetricsRepository _repository;

  Future<int> call(BodyMeasurement measurement) {
    final error = OnboardingValidators.weightKg(measurement.weightKg);
    if (error != null) throw ArgumentError(error);
    return _repository.addMeasurement(measurement);
  }
}
