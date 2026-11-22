import '../../domain/entities/forge_generation_result.dart';
import '../../domain/entities/persist_generated_workout_error.dart';
import '../../domain/entities/persist_generated_workout_request.dart';
import '../../domain/entities/planned_activity.dart';
import '../../domain/entities/planned_activity_enums.dart';
import '../../domain/entities/weekly_plan_generation_proposal.dart';
import '../../domain/use_cases/add_planned_activity.dart';
import '../../domain/use_cases/persist_generated_workout.dart';
import '../database/app_database.dart';
import 'drift_planned_activity_repository.dart';
import 'drift_workout_repository.dart';

/// Lanciata se, durante la conferma di una `WeeklyPlanGenerationProposal`,
/// una singola voce non riesce a persistere: fa fallire l'intera
/// transazione (sezione 27/28), nessuna scheda né attività pianificata
/// residua a metà settimana.
class WeeklyPlanGenerationPersistException implements Exception {
  const WeeklyPlanGenerationPersistException(this.errors);

  final List<PersistGeneratedWorkoutError> errors;

  @override
  String toString() => 'WeeklyPlanGenerationPersistException: $errors';
}

/// Conferma atomica di una proposta di generazione settimanale (Milestone
/// 8.4): persiste, per ogni voce, prima il `Workout` (stesso use case della
/// Milestone 5.3, invariato) e poi la `PlannedActivity` che lo referenzia
/// (stesso use case della Milestone 8.1, invariato) — mai il piano
/// rigenerato, sempre esattamente quello già mostrato in preview.
///
/// L'intero batch vive in un'unica `database.transaction()`: se una
/// qualunque voce fallisce, Drift annulla tutto (nessun `Workout` orfano né
/// piano parziale) — verificato da un test dedicato che forza un fallimento
/// a metà lista.
class WeeklyPlanGenerationRepository {
  const WeeklyPlanGenerationRepository(this._database);

  final AppDatabase _database;

  Future<List<int>> confirmProposal({
    required int profileId,
    required WeeklyPlanGenerationProposal proposal,
  }) {
    return _database.transaction(() async {
      final workoutRepository = DriftWorkoutRepository(_database);
      final plannedActivityRepository = DriftPlannedActivityRepository(
        _database.attivitaPianificateDao,
      );
      final persistWorkout = PersistGeneratedWorkout(workoutRepository);
      final addPlannedActivity = AddPlannedActivity(plannedActivityRepository);

      final createdActivityIds = <int>[];
      final existing = await plannedActivityRepository.getForWeek(
        profileId: profileId,
        weekStart: proposal.weekStart,
        weekEnd: proposal.weekEnd,
      );
      final proposedDates = [
        ...proposal.entries.map((e) => e.scheduledDate),
        ...proposal.additionalActivities.map((a) => a.scheduledDate),
      ];
      if (proposedDates.toSet().length != proposedDates.length ||
          existing.any((a) => proposedDates.contains(a.scheduledDate))) {
        throw StateError(
          'Il piano è cambiato: genera una nuova anteprima senza sovrapposizioni.',
        );
      }
      for (final entry in proposal.entries) {
        final result = entry.generationResult;
        final generationResult = ForgeGenerationResult(
          plan: result.plan!.plan,
          errors: result.errors,
          warnings: result.warnings,
          evaluation: result.evaluation,
        );
        final persisted = await persistWorkout(
          PersistGeneratedWorkoutRequest(
            profileId: profileId,
            generationResult: generationResult,
          ),
        );
        if (!persisted.success) {
          throw WeeklyPlanGenerationPersistException(persisted.errors);
        }
        if (proposal.updateWorkoutWalkingBlock ||
            proposal.walkingBlock != null) {
          final workout = (await workoutRepository.getWorkoutById(
            persisted.workoutId!,
          ))!;
          await workoutRepository.updateWorkout(
            workout.copyWith(walkingBlock: () => proposal.walkingBlock),
          );
        }
        final activityId = await addPlannedActivity(
          PlannedActivity(
            profileId: profileId,
            scheduledDate: entry.scheduledDate,
            type: PlannedActivityType.workout,
            workoutId: persisted.workoutId,
            origin: PlannedActivityOrigin.forgeEngine,
          ),
        );
        createdActivityIds.add(activityId);
      }
      for (final activity in proposal.additionalActivities) {
        if (activity.profileId != profileId) {
          throw StateError('Profilo non valido.');
        }
        if (activity.type == PlannedActivityType.workout) {
          final details = await workoutRepository.getWorkoutDetails(
            activity.workoutId!,
          );
          if (details == null ||
              details.workout.status.code != 'READY' ||
              details.exercises.isEmpty ||
              details.workout.profileId != profileId) {
            throw StateError(
              'Scegli una scheda pronta con almeno un esercizio.',
            );
          }
          if (proposal.updateWorkoutWalkingBlock ||
              proposal.walkingBlock != null) {
            await workoutRepository.updateWorkout(
              details.workout.copyWith(
                walkingBlock: () => proposal.walkingBlock,
              ),
            );
          }
        }
        createdActivityIds.add(await addPlannedActivity(activity));
      }
      return createdActivityIds;
    });
  }
}
