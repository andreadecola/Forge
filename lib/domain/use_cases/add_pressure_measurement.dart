import '../../core/validation/onboarding_validators.dart';
import '../entities/pressure_measurement.dart';
import '../repositories/pressure_repository.dart';
import '../services/clock.dart';

/// Valida e crea una nuova misurazione pressione (Milestone 7.1, sezione
/// 14; estesa in Milestone 7.3 con la frequenza cardiaca): profilo valido,
/// data non futura, sistolica/diastolica plausibili, frequenza cardiaca
/// plausibile se presente — nessuna classificazione clinica.
class AddPressureMeasurement {
  AddPressureMeasurement(this._repository, {this.clock = const SystemClock()});

  final PressureRepository _repository;
  final Clock clock;

  Future<int> call(PressureMeasurement measurement) {
    final error = _validate(measurement, now: clock.now());
    if (error != null) throw ArgumentError(error);
    return _repository.addMeasurement(measurement);
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
