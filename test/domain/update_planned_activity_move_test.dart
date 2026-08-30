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
import 'package:forge/domain/use_cases/skip_planned_activity.dart';
import 'package:forge/domain/use_cases/update_planned_activity.dart';

import '../data/workout_test_helpers.dart' show insertProfilo;

/// Test di "Sposta" (Milestone 8.6, sezione 16/31/71): non un use case a
/// parte, è [UpdatePlannedActivity] con una nuova `scheduledDate` — vedi il
/// commento della classe. Riporta `SKIPPED`/`POSTPONED` a `PLANNED` solo
/// quando la data cambia davvero.
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository repository;
  late int profileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftPlannedActivityRepository(db.attivitaPianificateDao);
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

  test(
    'spostare la data di un\'attività SKIPPED la riporta a PLANNED',
    () async {
      final id = await addActivity();
      await SkipPlannedActivity(
        repository,
        DriftWorkoutSessionRepository(db),
        DriftWalkingSessionRepository(db),
      )(id);
      final skipped = (await repository.getById(id))!;

      await UpdatePlannedActivity(repository)(
        skipped.copyWith(scheduledDate: DateTime(2026, 9, 10)),
      );

      final moved = await repository.getById(id);
      expect(moved!.status, PlannedActivityStatus.planned);
      expect(moved.scheduledDate, DateTime(2026, 9, 10));
    },
  );

  test(
    'spostare la data di un\'attività POSTPONED la riporta a PLANNED',
    () async {
      final id = await addActivity();
      await PostponePlannedActivity(
        repository,
        DriftWorkoutSessionRepository(db),
        DriftWalkingSessionRepository(db),
      )(id);
      final postponed = (await repository.getById(id))!;

      await UpdatePlannedActivity(repository)(
        postponed.copyWith(scheduledDate: DateTime(2026, 9, 10)),
      );

      final moved = await repository.getById(id);
      expect(moved!.status, PlannedActivityStatus.planned);
    },
  );

  test('modificare solo le note di un\'attività SKIPPED (data invariata) non '
      'la ripristina', () async {
    final id = await addActivity();
    await SkipPlannedActivity(
      repository,
      DriftWorkoutSessionRepository(db),
      DriftWalkingSessionRepository(db),
    )(id);
    final skipped = (await repository.getById(id))!;

    await UpdatePlannedActivity(repository)(
      skipped.copyWith(notes: () => 'nota'),
    );

    final saved = await repository.getById(id);
    expect(saved!.status, PlannedActivityStatus.skipped);
    expect(saved.scheduledDate, DateTime(2026, 9, 7));
  });

  test('spostare un\'attività già PLANNED resta PLANNED', () async {
    final id = await addActivity();
    final activity = (await repository.getById(id))!;

    await UpdatePlannedActivity(repository)(
      activity.copyWith(scheduledDate: DateTime(2026, 9, 10)),
    );

    final saved = await repository.getById(id);
    expect(saved!.status, PlannedActivityStatus.planned);
    expect(saved.scheduledDate, DateTime(2026, 9, 10));
  });
}
