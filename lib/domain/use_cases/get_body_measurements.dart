import '../entities/body_measurement.dart';
import '../repositories/body_metrics_repository.dart';

class GetBodyMeasurements {
  GetBodyMeasurements(this._repository);

  final BodyMetricsRepository _repository;

  Future<List<BodyMeasurement>> call(int profileId) =>
      _repository.getMeasurementsByProfile(profileId);
}
