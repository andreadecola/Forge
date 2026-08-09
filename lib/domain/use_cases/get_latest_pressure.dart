import '../entities/pressure_measurement.dart';
import '../repositories/pressure_repository.dart';

class GetLatestPressure {
  GetLatestPressure(this._repository);

  final PressureRepository _repository;

  Future<PressureMeasurement?> call(int profileId) =>
      _repository.getLatestPressure(profileId);
}
