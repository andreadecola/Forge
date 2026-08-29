import '../../core/validation/onboarding_validators.dart';
import '../entities/body_measurement.dart';
import '../repositories/body_metrics_repository.dart';
import '../services/clock.dart';

/// Valida e corregge una misurazione corporea già persistita (Milestone
/// 7.1, sezione 17/18): stessa validazione di [AddBodyMeasurement] — prima
/// di questa milestone `WeightController.updateMeasurement` scriveva senza
/// alcun controllo.
class UpdateBodyMeasurement {
  UpdateBodyMeasurement(this._repository, {this.clock = const SystemClock()});

  final BodyMetricsRepository _repository;
  final Clock clock;

  Future<void> call(BodyMeasurement measurement) {
    final error = _validate(measurement, now: clock.now());
    if (error != null) throw ArgumentError(error);
    return _repository.updateMeasurement(measurement);
  }

  static String? _validate(
    BodyMeasurement measurement, {
    required DateTime now,
  }) {
    return OnboardingValidators.profileId(measurement.profileId) ??
        OnboardingValidators.measuredAt(measurement.measuredAt, now: now) ??
        OnboardingValidators.weightKgOptional(measurement.weightKg) ??
        OnboardingValidators.waistCm(measurement.waistCm) ??
        OnboardingValidators.atLeastOneBodyMetric(
          weightKg: measurement.weightKg,
          waistCm: measurement.waistCm,
        );
  }
}
