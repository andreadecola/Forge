import '../../core/validation/onboarding_validators.dart';
import '../entities/pressure_measurement.dart';
import '../repositories/pressure_repository.dart';
import '../services/clock.dart';

/// Valida e corregge una misurazione pressione già persistita (Milestone
/// 7.1, sezione 17/18; validazione frequenza cardiaca aggiunta in Milestone
/// 7.3): stessa validazione di [AddPressureMeasurement].
class UpdatePressureMeasurement {
  UpdatePressureMeasurement(
    this._repository, {
    this.clock = const SystemClock(),
  });

  final PressureRepository _repository;
  final Clock clock;

  Future<void> call(PressureMeasurement measurement) {
    final error = _validate(measurement, now: clock.now());
    if (error != null) throw ArgumentError(error);
    return _repository.updateMeasurement(measurement);
  }

  static String? _validate(
    PressureMeasurement measurement, {
    required DateTime now,
  }) {
    return OnboardingValidators.profileId(measurement.profileId) ??
        OnboardingValidators.measuredAt(measurement.measuredAt, now: now) ??
        OnboardingValidators.systolicOverDiastolic(
          measurement.systolic,
          measurement.diastolic,
        ) ??
        OnboardingValidators.heartRate(measurement.heartRate);
  }
}
