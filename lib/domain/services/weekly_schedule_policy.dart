import '../entities/planned_activity.dart';
import 'weekly_planning_date_service.dart';

enum WeeklyDayMode { alternate, weekdays, everyDay, custom }

/// Giorni alterni ancorati al lunedì: lun/mer/ven/dom. Nessuna attività
/// viene spostata silenziosamente fuori dai giorni scelti o su giorni occupati.
abstract final class WeeklySchedulePolicy {
  static Set<int> daysFor(WeeklyDayMode mode, Set<int> custom) =>
      switch (mode) {
        WeeklyDayMode.alternate => {1, 3, 5, 7},
        WeeklyDayMode.weekdays => {1, 2, 3, 4, 5},
        WeeklyDayMode.everyDay => {1, 2, 3, 4, 5, 6, 7},
        WeeklyDayMode.custom => Set.of(custom),
      };

  static ({List<DateTime> workouts, List<DateTime> walks}) distribute({
    required DateTime weekReference,
    required DateTime today,
    required Set<int> workoutDays,
    required Set<int> walkingDays,
    required int workoutCount,
    required int walkCount,
    required List<PlannedActivity> existing,
  }) {
    if (workoutCount < 0 ||
        walkCount < 0 ||
        workoutCount + walkCount == 0 ||
        workoutCount + walkCount > 7 ||
        workoutDays.any((d) => d < 1 || d > 7) ||
        walkingDays.any((d) => d < 1 || d > 7) ||
        (workoutCount > 0 && workoutDays.isEmpty) ||
        (walkCount > 0 && walkingDays.isEmpty)) {
      throw ArgumentError('Configura almeno un’attività e giorni validi.');
    }
    final start = WeeklyPlanningDateService.weekStart(weekReference);
    final cutoff = WeeklyPlanningDateService.atMidnight(today);
    final occupied = existing
        .map((a) => WeeklyPlanningDateService.atMidnight(a.scheduledDate))
        .toSet();
    final free = [
      for (var i = 0; i < 7; i++)
        DateTime(start.year, start.month, start.day + i),
    ].where((d) => !d.isBefore(cutoff) && !occupied.contains(d)).toList();
    final workoutOptions = free
        .where((d) => workoutDays.contains(d.weekday))
        .toList();
    // Ricerca esaustiva limitata a sette giorni: evita scelte greedy che
    // sottrarrebbero alle camminate l'unico giorno consentito.
    List<DateTime>? chosenWorkouts;
    List<DateTime>? chosenWalks;
    int? bestScore;
    for (var mask = 0; mask < (1 << workoutOptions.length); mask++) {
      final selected = [
        for (var i = 0; i < workoutOptions.length; i++)
          if (mask & (1 << i) != 0) workoutOptions[i],
      ];
      if (selected.length != workoutCount) continue;
      final walkOptions = free
          .where(
            (d) => walkingDays.contains(d.weekday) && !selected.contains(d),
          )
          .toList();
      if (walkOptions.length < walkCount) continue;
      // Preferisce allenamenti distanziati, senza forzare quote per giorno.
      var score = 0;
      for (var i = 1; i < selected.length; i++) {
        final current = selected[i], previous = selected[i - 1];
        final gap = DateTime.utc(current.year, current.month, current.day)
            .difference(
              DateTime.utc(previous.year, previous.month, previous.day),
            )
            .inDays;
        score += gap == 1 ? 100 : (gap - 2) * (gap - 2);
      }
      if (bestScore == null || score < bestScore) {
        bestScore = score;
        chosenWorkouts = selected;
        chosenWalks = [
          for (var i = 0; i < walkCount; i++)
            walkOptions[(i * walkOptions.length / walkCount).floor()],
        ];
      }
    }
    if (chosenWorkouts == null) {
      throw StateError(
        'Attività non distribuibili nei giorni scelti. Riduci la frequenza o scegli altri giorni liberi.',
      );
    }
    return (workouts: chosenWorkouts, walks: chosenWalks!);
  }
}
