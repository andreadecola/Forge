import '../../domain/entities/planned_activity.dart';
import '../../domain/repositories/planned_activity_repository.dart';
import '../database/daos/attivita_pianificate_dao.dart';
import 'planned_activity_mappers.dart';

class DriftPlannedActivityRepository implements PlannedActivityRepository {
  DriftPlannedActivityRepository(this._dao);

  final AttivitaPianificateDao _dao;

  @override
  Future<PlannedActivity?> getById(int id) async {
    final row = await _dao.getById(id);
    return row == null ? null : PlannedActivityMappers.plannedActivity(row);
  }

  @override
  Future<List<PlannedActivity>> getForWeek({
    required int profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async {
    final rows = await _dao.getForWeek(
      profileId: profileId,
      weekStart: weekStart,
      weekEnd: weekEnd,
    );
    return rows.map(PlannedActivityMappers.plannedActivity).toList();
  }

  @override
  Stream<List<PlannedActivity>> watchForWeek({
    required int profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) {
    return _dao
        .watchForWeek(
          profileId: profileId,
          weekStart: weekStart,
          weekEnd: weekEnd,
        )
        .map(
          (rows) => rows.map(PlannedActivityMappers.plannedActivity).toList(),
        );
  }

  @override
  Future<List<PlannedActivity>> getAllForProfile({
    required int profileId,
  }) async {
    final rows = await _dao.getAllByProfile(profileId);
    return rows.map(PlannedActivityMappers.plannedActivity).toList();
  }

  @override
  Future<int> addPlannedActivity(PlannedActivity activity) {
    return _dao.create(PlannedActivityMappers.toCompanion(activity));
  }

  @override
  Future<void> updatePlannedActivity(PlannedActivity activity) {
    return _dao.updateActivity(PlannedActivityMappers.toCompanion(activity));
  }

  @override
  Future<void> deletePlannedActivity(int id) => _dao.deleteById(id);

  @override
  Future<void> linkWorkoutSession({
    required int activityId,
    required int workoutSessionId,
  }) async {
    final row = await _dao.getById(activityId);
    if (row == null) return;
    final activity = PlannedActivityMappers.plannedActivity(row);
    await _dao.updateActivity(
      PlannedActivityMappers.toCompanion(
        activity.copyWith(workoutSessionId: () => workoutSessionId),
      ),
    );
  }

  @override
  Future<void> linkWalkingSession({
    required int activityId,
    required int walkingSessionId,
  }) async {
    final row = await _dao.getById(activityId);
    if (row == null) return;
    final activity = PlannedActivityMappers.plannedActivity(row);
    await _dao.updateActivity(
      PlannedActivityMappers.toCompanion(
        activity.copyWith(walkingSessionId: () => walkingSessionId),
      ),
    );
  }
}
