import '../../core/validation/onboarding_validators.dart';
import '../entities/pressure_measurement.dart';
import '../repositories/pressure_repository.dart';

class AddPressureMeasurement {
  AddPressureMeasurement(this._repository);

  final PressureRepository _repository;

  Future<int> call(PressureMeasurement measurement) {
    final error = OnboardingValidators.systolicOverDiastolic(
      measurement.systolic,
      measurement.diastolic,
    );
    if (error != null) throw ArgumentError(error);
    return _repository.addMeasurement(measurement);
  }
}
