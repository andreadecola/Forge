import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/equipment_repository_impl.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/exercise_catalog_enums.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/forge_score.dart';
import 'package:forge/domain/entities/generated_workout_exercise.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/features/training_plan/presentation/widgets/forge_exercise_preview_card.dart';

import '../data/workout_test_helpers.dart';

Future<AppDatabase> _seedRealCatalogApp() async {
  final db = AppDatabase(NativeDatabase.memory());
  final raw = File('assets/data/exercises_v1.json').readAsStringSync();
  await ExerciseCatalogSeeder(db).seedFromString(raw);
  final profileId = await insertProfilo(db);
  await EquipmentRepositoryImpl(
    db.userEquipmentDao,
  ).saveInitialEquipment(profileId: profileId, owned: const {});
  await SettingsRepositoryImpl(db.appSettingsDao).setOnboardingCompleted(true);
  return db;
}

Future<void> _openForgeGenerator(WidgetTester tester) async {
  await tester.tap(find.text('Programma'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Genera con Forge'));
  await tester.pumpAndSettle();
}

/// Hardening (Milestone 5.6, sezioni 52/59/60/62): comportamenti UI non
/// ancora esercitati dai test della Milestone 5.5 — back navigation senza
/// salvataggio, testo grande (accessibilità), nome esercizio molto lungo,
/// piano al massimo numero di esercizi su schermo piccolo.
void main() {
  testWidgets('back dalla preview senza salvare: nessun Workout persistito, si '
      'torna alla configurazione (sezione 52)', (tester) async {
    final db = await _seedRealCatalogApp();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const ForgeApp(),
      ),
    );
    await tester.pumpAndSettle();
    await _openForgeGenerator(tester);
    await tester.tap(find.text('Genera allenamento'));
    await tester.pumpAndSettle();
    expect(find.text('Anteprima allenamento'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Genera con Forge'), findsWidgets);
    final workoutRepository = DriftWorkoutRepository(db);
    final workouts = await workoutRepository.getWorkouts(profileId: 1);
    expect(workouts, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await db.close();
  });

  testWidgets('testo grande (textScaler 2.0): generatore e anteprima restano '
      'utilizzabili, nessun crash (sezione 59)', (tester) async {
    final db = await _seedRealCatalogApp();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const ForgeApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _openForgeGenerator(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Genera allenamento'), findsOneWidget);

    await tester.tap(find.text('Genera allenamento'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Salva allenamento'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await db.close();
  });

  testWidgets(
    'piano al massimo numero di esercizi su schermo piccolo: CTA Salva '
    'resta raggiungibile (area azioni fissa, fuori dallo scroll) (sezione '
    '62)',
    (tester) async {
      final db = await _seedRealCatalogApp();
      await tester.binding.setSurfaceSize(const Size(320, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const ForgeApp(),
        ),
      );
      await tester.pumpAndSettle();
      await _openForgeGenerator(tester);
      await tester.tap(find.text('Genera allenamento'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // L'area azioni (Salva/Modifica configurazione) e' sempre visibile:
      // non serve scrollare la lista esercizi per raggiungerla.
      expect(find.text('Salva allenamento'), findsOneWidget);
      expect(find.text('Modifica configurazione'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await db.close();
    },
  );

  testWidgets(
    'nome esercizio molto lungo nella card di anteprima: nessun overflow, '
    'troncato a 2 righe (sezione 60)',
    (tester) async {
      final longName =
          'Nome esercizio estremamente lungo che dovrebbe normalmente '
          'occupare piu\' di due righe se non venisse troncato correttamente '
          'dalla card di anteprima Forge';
      final exercise = Exercise(
        id: 1,
        code: 'LONG-001',
        name: longName,
        description: 'd',
        instructions: 'i',
        categoryId: 1,
        minimumLevel: 1,
        impactLevel: ExerciseImpactLevel.low,
        balanceRequired: false,
        floorRequired: false,
        standingRequired: false,
        supportAllowed: false,
        defaultReps: 10,
        isSystem: true,
        isActive: true,
        catalogVersion: 1,
      );
      final entry = GeneratedWorkoutExercise(
        workoutExercise: const WorkoutExercise(
          workoutId: 1,
          exerciseId: 1,
          order: 1,
          repetitions: 10,
          restSeconds: 30,
        ),
        exercise: exercise,
        estimatedDurationSeconds: 40,
        score: const ForgeScore(total: 0.8, components: [], reasons: []),
        decisionReasons: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: ForgeExercisePreviewCard(
                order: 1,
                entry: entry,
                categoryName: 'Categoria',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final titleFinder = find.text(longName);
      expect(titleFinder, findsOneWidget);
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.maxLines, 2);
      expect(titleWidget.overflow, TextOverflow.ellipsis);
    },
  );
}
