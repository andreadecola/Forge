import '../../core/validation/onboarding_validators.dart';
import '../entities/body_measurement.dart';
import '../repositories/body_metrics_repository.dart';
import '../services/clock.dart';

/// Valida e crea una nuova misurazione corporea (Milestone 7.1, sezione
/// 14; estesa in Milestone 7.2 per "solo girovita"): profilo valido, data
/// non futura, peso e girovita plausibili se presenti, almeno una delle due
/// metriche presente — nessun range clinico, solo plausibilità numerica.
class AddBodyMeasurement {
  AddBodyMeasurement(this._repository, {this.clock = const SystemClock()});

  final BodyMetricsRepository _repository;
  final Clock clock;

  Future<int> call(BodyMeasurement measurement) {
    final error = _validate(measurement, now: clock.now());
    if (error != null) throw ArgumentError(error);
    return _repository.addMeasurement(measurement);
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
