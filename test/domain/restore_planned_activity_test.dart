import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/use_cases/add_planned_activity.dart';
import 'package:forge/domain/use_cases/postpone_planned_activity.dart';
import 'package:forge/domain/use_cases/restore_planned_activity.dart';
import 'package:forge/domain/use_cases/skip_planned_activity.dart';

import '../data/workout_test_helpers.dart' show insertProfilo;

/// Test di [RestorePlannedActivity] (Milestone 8.6, sezione 29/43/76):
/// reversibilità semplice — `SKIPPED`/`POSTPONED` -> `PLANNED`, senza
/// toccare `scheduledDate`.
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository repository;
  late RestorePlannedActivity restoreUseCase;
  late int profileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftPlannedActivityRepository(db.attivitaPianificateDao);
    restoreUseCase = RestorePlannedActivity(repository);
    profileId = await insertProfilo(db);
  });

  tearDown(() => db.close());

  Future<int> addActivity() {
    return AddPlannedActivity(repository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.recovery,
        origin: PlannedActivityOrigin.user,
      ),
    );
  }

  test('SKIPPED -> PLANNED, scheduledDate invariata', () async {
    final id = await addActivity();
    // RECOVERY non ha mai una sessione collegata (workoutSessionId/
    // walkingSessionId sempre null): i repository reali qui non vengono
    // nemmeno interrogati.
    await SkipPlannedActivity(
      repository,
      DriftWorkoutSessionRepository(db),
      DriftWalkingSessionRepository(db),
    )(id);

    await restoreUseCase(id);

    final saved = await repository.getById(id);
    expect(saved!.status, PlannedActivityStatus.planned);
    expect(saved.scheduledDate, DateTime(2026, 9, 7));
  });

  test('POSTPONED -> PLANNED', () async {
    final id = await addActivity();
    await PostponePlannedActivity(
      repository,
      DriftWorkoutSessionRepository(db),
      DriftWalkingSessionRepository(db),
    )(id);

    await restoreUseCase(id);

    final saved = await repository.getById(id);
    expect(saved!.status, PlannedActivityStatus.planned);
  });

  test('già PLANNED -> idempotente, nessun effetto', () async {
    final id = await addActivity();
    await restoreUseCase(id);
    final saved = await repository.getById(id);
    expect(saved!.status, PlannedActivityStatus.planned);
  });

  test('id inesistente -> nessuna eccezione, nessun effetto', () async {
    await restoreUseCase(999999);
  });
}
