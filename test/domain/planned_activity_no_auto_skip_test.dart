import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/use_cases/add_planned_activity.dart';

import '../data/workout_test_helpers.dart' show insertProfilo;

/// Controprova esplicita della STOP CONDITION della Milestone 8.6, sezione
/// 9/10/67/107: `scheduledDate < oggi` non deve **mai**, da sola, mutare
/// [PlannedActivity.status] a `SKIPPED`. Nessun codice del progetto lo fa
/// (nessuna scrittura periodica/al bootstrap tocca questa colonna in base
/// alla data corrente) — questo test lo conferma leggendo di nuovo
/// l'attività dopo una query, esattamente come avverrebbe riaprendo l'app
/// il giorno dopo.
void main() {
  test('attività pianificata ieri, mai completata, resta PLANNED dopo la '
      'lettura — nessuna mutazione automatica', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftPlannedActivityRepository(
      db.attivitaPianificateDao,
    );
    final profileId = await insertProfilo(db);

    final id = await AddPlannedActivity(repository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 1),
        type: PlannedActivityType.recovery,
        origin: PlannedActivityOrigin.user,
      ),
    );

    // "Riapertura" simulata: una nuova lettura, molto dopo la data
    // pianificata (`scheduledDate` è nel passato rispetto a qualunque
    // orologio reale in questo test).
    final reloaded = await repository.getById(id);
    expect(reloaded!.status, PlannedActivityStatus.planned);

    final forWeek = await repository.getForWeek(
      profileId: profileId,
      weekStart: DateTime(2026, 9, 1),
      weekEnd: DateTime(2026, 9, 1),
    );
    expect(forWeek.single.status, PlannedActivityStatus.planned);
  });
}
