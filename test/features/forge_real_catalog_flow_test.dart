import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/repositories/equipment_repository_impl.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/equipment_item.dart';
import 'package:forge/domain/entities/persisted_session_exercise.dart';
import 'package:forge/domain/entities/workout_enums.dart';

import '../data/workout_test_helpers.dart';
import 'exercise_test_fixtures.dart' show disposeCleanly;

/// Test end-to-end del flusso Forge (Milestone 5.5, sezioni 60/61): catalogo
/// reale seedato (118 esercizi), profilo reale, UI reale (nessuna chiamata
/// diretta ai use case Forge) fino al `Workout` persistito e letto dal
/// repository.
Future<AppDatabase> _seedRealCatalogApp({
  Set<EquipmentItem> owned = const {},
}) async {
  final db = AppDatabase(NativeDatabase.memory());
  final raw = File('assets/data/exercises_v1.json').readAsStringSync();
  await ExerciseCatalogSeeder(db).seedFromString(raw);
  final profileId = await insertProfilo(db);
  await EquipmentRepositoryImpl(
    db.userEquipmentDao,
  ).saveInitialEquipment(profileId: profileId, owned: owned);
  await SettingsRepositoryImpl(db.appSettingsDao).setOnboardingCompleted(true);
  return db;
}

/// Lascia sparire un eventuale SnackBar di feedback prima della prossima
/// interazione (stesso fix già usato in `workout_editor_test.dart`):
/// `pumpAndSettle` da solo non basta ad attendere il Timer di chiusura.
Future<void> _letSnackBarPass(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _openForgeGenerator(WidgetTester tester) async {
  await tester.tap(find.text('Programma'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Genera con Forge'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'catalogo reale, nessuna attrezzatura, nessuno storico: genera -> anteprima -> '
    'salva -> WorkoutDetailPage con origin FORGE_ENGINE/status READY (sezione 60)',
    (tester) async {
      final db = await _seedRealCatalogApp();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const ForgeApp(),
        ),
      );
      await tester.pumpAndSettle();
      await _openForgeGenerator(tester);

      // Default già corretti per questo scenario: Total body, 30 min,
      // livello 1 (sezione 39/M5.2: full body a livello 1 senza
      // attrezzatura genera con successo sul catalogo reale).
      await tester.tap(find.text('Genera allenamento'));
      await tester.pumpAndSettle();

      expect(find.text('Anteprima allenamento'), findsOneWidget);
      expect(find.text('Forge Full Body'), findsOneWidget);
      expect(
        find.text('Piano mantenuto sulla configurazione attuale'),
        findsOneWidget,
      );
      // Nessun valore tecnico in UI.
      expect(find.text('FULL_BODY'), findsNothing);
      expect(find.text('FORGE_ENGINE'), findsNothing);

      await tester.tap(find.text('Salva allenamento'));
      await tester.pumpAndSettle();

      expect(find.text('Allenamento creato con Forge'), findsOneWidget);
      expect(find.text('Dettaglio scheda'), findsOneWidget);
      expect(find.text('Forge Full Body'), findsOneWidget);

      final workoutRepository = DriftWorkoutRepository(db);
      final workouts = await workoutRepository.getWorkouts(profileId: 1);
      expect(workouts.length, 1);
      expect(workouts.single.origin, WorkoutOrigin.forgeEngine);
      expect(workouts.single.status, WorkoutDefinitionStatus.ready);
      final details = await workoutRepository.getWorkoutDetails(
        workouts.single.id!,
      );
      expect(details!.exercises, isNotEmpty);

      await disposeCleanly(tester);
      await db.close();
    },
  );

  testWidgets(
    'doppio tap su Salva allenamento crea un solo Workout (sezione 31)',
    (tester) async {
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

      await tester.tap(find.text('Salva allenamento'));
      await tester.tap(find.text('Salva allenamento'));
      await tester.pumpAndSettle();

      final workoutRepository = DriftWorkoutRepository(db);
      final workouts = await workoutRepository.getWorkouts(profileId: 1);
      expect(workouts.length, 1);

      await disposeCleanly(tester);
      await db.close();
    },
  );

  testWidgets(
    'storico reale con alta completion: la preview rappresenta la decisione '
    'PROGRESS del domain senza ricostruirla in UI (sezione 61)',
    (tester) async {
      final db = await _seedRealCatalogApp(owned: {EquipmentItem.chair});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const ForgeApp(),
        ),
      );
      await tester.pumpAndSettle();
      await _openForgeGenerator(tester);

      await tester.tap(find.text('Mobilità'));
      await tester.tap(find.text('20 min'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Genera allenamento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salva allenamento'));
      await tester.pumpAndSettle();

      final workoutRepository = DriftWorkoutRepository(db);
      final sessionRepository = DriftWorkoutSessionRepository(db);
      final workouts = await workoutRepository.getWorkouts(profileId: 1);
      final details = await workoutRepository.getWorkoutDetails(
        workouts.single.id!,
      );

      // 5 sessioni reali completate con tutte le serie completate,
      // sufficienti a superare ogni soglia di adattamento (stessi valori
      // già validati dal test di dominio della Milestone 5.4).
      for (var i = 0; i < 5; i++) {
        final startedAt = DateTime(2026, 1, 1 + i, 8);
        final sessionId = await sessionRepository.createSession(
          profileId: 1,
          details: details!,
          startedAt: startedAt,
        );
        final sessionExercises = await sessionRepository.getSessionExercises(
          sessionId,
        );
        await sessionRepository.updateProgress(
          sessionId: sessionId,
          exercises: [
            for (final e in sessionExercises)
              SessionExerciseProgressUpdate(
                workoutExerciseId: e.workoutExerciseId!,
                completedSets: e.totalSets,
                isSkipped: false,
                isCompleted: true,
              ),
          ],
          updatedAt: startedAt.add(const Duration(minutes: 20)),
        );
        await sessionRepository.completeSession(
          sessionId: sessionId,
          endedAt: startedAt.add(const Duration(minutes: 25)),
        );
      }

      // Torna dal dettaglio della scheda salvata alla lista (Programma),
      // poi riapre Forge con la stessa configurazione: nessuna voce
      // "Programma" in barra perché il dettaglio è una rotta pushata senza
      // bottom navigation, come le altre rotte scheda (sezione 4).
      await _letSnackBarPass(tester);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Genera con Forge'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mobilità'));
      await tester.tap(find.text('20 min'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Genera allenamento'));
      await tester.pumpAndSettle();

      expect(find.text('Anteprima allenamento'), findsOneWidget);
      expect(
        find.text(
          'L\'allenamento è stato adattato in base alle sessioni recenti',
        ),
        findsOneWidget,
      );
      expect(find.text('PROGRESS'), findsNothing);

      await disposeCleanly(tester);
      await db.close();
    },
  );

  testWidgets(
    'anteprima su schermo piccolo: scrollabile, CTA Salva raggiungibile',
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
      expect(find.text('Salva allenamento'), findsOneWidget);

      await disposeCleanly(tester);
      await db.close();
    },
  );
}
