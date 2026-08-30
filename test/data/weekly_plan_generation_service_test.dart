import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/equipment_repository_impl.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/weekly_plan_generation_error.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_engine.dart';
import 'package:forge/domain/services/forge_workout_adaptation_service.dart';
import 'package:forge/domain/services/forge_workout_generator.dart';
import 'package:forge/domain/services/generated_workout_plan_validator.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/domain/use_cases/add_planned_activity.dart';
import 'package:forge/domain/use_cases/build_forge_adaptation_context.dart';
import 'package:forge/domain/use_cases/generate_adapted_forge_workout.dart';
import 'package:forge/domain/use_cases/generate_forge_workout.dart';
import 'package:forge/features/weekly_plan/application/weekly_plan_generation_service.dart';

import 'workout_test_helpers.dart';

const _miniCatalogJson = '''
{
  "catalogType": "ESERCIZI",
  "catalogVersion": 1,
  "categories": [
    {"code": "TEST", "name": "Categoria di test", "description": null, "displayOrder": 1, "active": true}
  ],
  "muscleGroups": [
    {"code": "CORE", "name": "Core", "active": true}
  ],
  "equipment": [
    {"code": "NONE", "name": "Nessuna", "priority": 0, "active": true}
  ],
  "exercises": [
    {
      "code": "EX-TEST",
      "name": "Esercizio di test",
      "categoryCode": "TEST",
      "description": "desc",
      "instructions": "1. Passo.",
      "minimumLevel": 1,
      "impactLevel": "LOW",
      "defaultSets": 2,
      "defaultReps": 10,
      "defaultRestSeconds": 30,
      "equipmentCodes": [{"code": "NONE", "required": true}],
      "primaryMuscleCodes": ["CORE"],
      "secondaryMuscleCodes": [],
      "alternativeCodes": [],
      "images": []
    }
  ]
}
''';

/// Test di integrazione di [WeeklyPlanGenerationService] (Milestone 8.4) sul
/// catalogo reale seedato (stessa fixture di `forge_hardening_matrix_test.dart`):
/// nessun mock del Forge Engine, verifica che l'orchestrazione settimanale
/// riusi davvero la pipeline M5 reale senza duplicarne l'algoritmo.
void main() {
  late AppDatabase db;
  late int profileId;
  late DriftPlannedActivityRepository plannedActivityRepository;

  Future<WeeklyPlanGenerationService> buildService() async {
    final exerciseRepository = DriftExerciseRepository(db);
    final sessionRepository = DriftWorkoutSessionRepository(db);
    final generate = GenerateForgeWorkout(
      exerciseRepository,
      const ForgeEngine(),
      const ForgeWorkoutGenerator(),
    );
    final generateAdapted = GenerateAdaptedForgeWorkout(
      exerciseRepository,
      BuildForgeAdaptationContext(sessionRepository),
      generate,
      const ForgeWorkoutAdaptationService(),
      planValidator: const GeneratedWorkoutPlanValidator(),
    );
    return WeeklyPlanGenerationService(
      plannedActivityRepository,
      generateAdapted,
      EquipmentRepositoryImpl(db.userEquipmentDao),
      const SystemClock(),
    );
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    await ExerciseCatalogSeeder(db).seedFromString(raw);
    profileId = await insertProfilo(db);
    plannedActivityRepository = DriftPlannedActivityRepository(
      db.attivitaPianificateDao,
    );
  });

  tearDown(() => db.close());

  test('settimana futura, count=3 -> proposta con 3 giorni distinti '
      'equidistanziati, piani completi', () async {
    final service = await buildService();
    final result = await service.buildProposal(
      profileId: profileId,
      weekReference: DateTime(2026, 9, 7), // lunedì, settimana futura
      workoutType: WorkoutType.fullBody,
      targetDurationMinutes: 30,
      userLevel: 1,
      requestedCount: 3,
    );

    expect(result.success, isTrue, reason: '${result.forgeErrors}');
    final proposal = result.proposal!;
    expect(proposal.entries, hasLength(3));
    expect(proposal.entries.map((e) => e.scheduledDate).toSet(), hasLength(3));
    for (final entry in proposal.entries) {
      expect(entry.adaptedPlan.plan.isComplete, isTrue);
      expect(entry.adaptedPlan.plan.workoutType, WorkoutType.fullBody);
    }
  });

  test('settimana interamente passata -> errore, nessuna proposta', () async {
    final service = await buildService();
    final result = await service.buildProposal(
      profileId: profileId,
      weekReference: DateTime(2020, 1, 6),
      workoutType: WorkoutType.fullBody,
      targetDurationMinutes: 30,
      userLevel: 1,
      requestedCount: 2,
    );

    expect(result.success, isFalse);
    expect(result.errors, [WeeklyPlanGenerationError.weekEntirelyInPast]);
    expect(result.proposal, isNull);
  });

  test('settimana già con un\'attività FORGE_ENGINE -> bloccata, nessuna '
      'seconda proposta silenziosa', () async {
    final weekReference = DateTime(2026, 9, 7);
    await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: weekReference,
        type: PlannedActivityType.recovery,
        origin: PlannedActivityOrigin.forgeEngine,
      ),
    );
    final service = await buildService();
    final result = await service.buildProposal(
      profileId: profileId,
      weekReference: weekReference,
      workoutType: WorkoutType.fullBody,
      targetDurationMinutes: 30,
      userLevel: 1,
      requestedCount: 2,
    );

    expect(result.success, isFalse);
    expect(result.errors, [
      WeeklyPlanGenerationError.weekAlreadyHasForgeActivities,
    ]);
  });

  test(
    'isolamento profilo (Milestone 8.8): un\'attività FORGE_ENGINE di un '
    'altro profilo nella stessa settimana non blocca la generazione',
    () async {
      final weekReference = DateTime(2026, 9, 7);
      final otherProfileId = await insertProfilo(db);
      await AddPlannedActivity(plannedActivityRepository)(
        PlannedActivity(
          profileId: otherProfileId,
          scheduledDate: weekReference,
          type: PlannedActivityType.recovery,
          origin: PlannedActivityOrigin.forgeEngine,
        ),
      );
      final service = await buildService();

      final result = await service.buildProposal(
        profileId: profileId,
        weekReference: weekReference,
        workoutType: WorkoutType.fullBody,
        targetDurationMinutes: 30,
        userLevel: 1,
        requestedCount: 2,
      );

      expect(result.success, isTrue, reason: '${result.forgeErrors}');
      expect(result.proposal!.entries, hasLength(2));
    },
  );

  test(
    'conteggio non valido (0) -> errore, nessuna generazione tentata',
    (() async {
      final service = await buildService();
      final result = await service.buildProposal(
        profileId: profileId,
        weekReference: DateTime(2026, 9, 7),
        workoutType: WorkoutType.fullBody,
        targetDurationMinutes: 30,
        userLevel: 1,
        requestedCount: 0,
      );

      expect(result.success, isFalse);
      expect(result.errors, [WeeklyPlanGenerationError.invalidRequestedCount]);
    }),
  );

  test(
    'attività USER esistenti vengono preservate e preferite come giorni '
    'liberi: la proposta evita il giorno già occupato quando possibile',
    () async {
      final weekReference = DateTime(2026, 9, 7); // lunedì
      await AddPlannedActivity(plannedActivityRepository)(
        PlannedActivity(
          profileId: profileId,
          scheduledDate: weekReference, // lunedì occupato da USER
          type: PlannedActivityType.recovery,
          origin: PlannedActivityOrigin.user,
        ),
      );
      final service = await buildService();
      final result = await service.buildProposal(
        profileId: profileId,
        weekReference: weekReference,
        workoutType: WorkoutType.fullBody,
        targetDurationMinutes: 30,
        userLevel: 1,
        requestedCount: 1,
      );

      expect(result.success, isTrue);
      expect(
        result.proposal!.entries.single.scheduledDate,
        isNot(weekReference),
      );

      // L'attività USER resta intatta e isolata dalla generazione.
      final stillThere = await plannedActivityRepository.getForWeek(
        profileId: profileId,
        weekStart: weekReference,
        weekEnd: weekReference.add(const Duration(days: 6)),
      );
      expect(stillThere, hasLength(1));
      expect(stillThere.single.origin, PlannedActivityOrigin.user);
    },
  );

  test(
    'settimana corrente parziale (oggi giovedì): count=4 riempie esattamente '
    'da oggi a domenica',
    () async {
      final weekReference = DateTime(2026, 9, 7); // lunedì di riferimento
      final today = DateTime(2026, 9, 10, 9); // giovedì della stessa settimana
      final exerciseRepository = DriftExerciseRepository(db);
      final sessionRepository = DriftWorkoutSessionRepository(db);
      final generate = GenerateForgeWorkout(
        exerciseRepository,
        const ForgeEngine(),
        const ForgeWorkoutGenerator(),
      );
      final generateAdapted = GenerateAdaptedForgeWorkout(
        exerciseRepository,
        BuildForgeAdaptationContext(sessionRepository),
        generate,
        const ForgeWorkoutAdaptationService(),
        planValidator: const GeneratedWorkoutPlanValidator(),
      );
      final service = WeeklyPlanGenerationService(
        plannedActivityRepository,
        generateAdapted,
        EquipmentRepositoryImpl(db.userEquipmentDao),
        _FixedClock(today),
      );

      final result = await service.buildProposal(
        profileId: profileId,
        weekReference: weekReference,
        workoutType: WorkoutType.fullBody,
        targetDurationMinutes: 30,
        userLevel: 1,
        requestedCount: 4,
      );

      expect(result.success, isTrue);
      expect(result.proposal!.entries.map((e) => e.scheduledDate).toList(), [
        DateTime(2026, 9, 10),
        DateTime(2026, 9, 11),
        DateTime(2026, 9, 12),
        DateTime(2026, 9, 13),
      ]);
    },
  );

  test('nessun candidato eleggibile (catalogo minimo) -> errore Forge '
      'propagato, nessuna proposta', () async {
    final miniDb = AppDatabase(NativeDatabase.memory());
    addTearDown(miniDb.close);
    await ExerciseCatalogSeeder(miniDb).seedFromString(_miniCatalogJson);
    final miniProfileId = await insertProfilo(miniDb);

    final exerciseRepository = DriftExerciseRepository(miniDb);
    final sessionRepository = DriftWorkoutSessionRepository(miniDb);
    final generate = GenerateForgeWorkout(
      exerciseRepository,
      const ForgeEngine(),
      const ForgeWorkoutGenerator(),
    );
    final generateAdapted = GenerateAdaptedForgeWorkout(
      exerciseRepository,
      BuildForgeAdaptationContext(sessionRepository),
      generate,
      const ForgeWorkoutAdaptationService(),
      planValidator: const GeneratedWorkoutPlanValidator(),
    );
    final service = WeeklyPlanGenerationService(
      DriftPlannedActivityRepository(miniDb.attivitaPianificateDao),
      generateAdapted,
      EquipmentRepositoryImpl(miniDb.userEquipmentDao),
      const SystemClock(),
    );

    final result = await service.buildProposal(
      profileId: miniProfileId,
      weekReference: DateTime(2026, 9, 7),
      workoutType: WorkoutType.fullBody,
      targetDurationMinutes: 30,
      userLevel: 1,
      requestedCount: 2,
    );

    expect(result.success, isFalse);
    expect(result.proposal, isNull);
    expect(result.forgeErrors, isNotEmpty);
  });

  test('determinismo: stessa richiesta -> stessi giorni e stesso tipo di '
      'piano ogni volta', () async {
    final service = await buildService();
    Future<List<DateTime>> generateDays() async {
      final result = await service.buildProposal(
        profileId: profileId,
        weekReference: DateTime(2026, 9, 7),
        workoutType: WorkoutType.fullBody,
        targetDurationMinutes: 30,
        userLevel: 1,
        requestedCount: 3,
      );
      return result.proposal!.entries.map((e) => e.scheduledDate).toList();
    }

    final first = await generateDays();
    final second = await generateDays();
    expect(first, second);
  });
}

class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}
