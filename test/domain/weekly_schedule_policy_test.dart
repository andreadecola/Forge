import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/services/weekly_schedule_policy.dart';

void main() {
  final monday = DateTime(2026, 11, 23);
  ({List<DateTime> workouts, List<DateTime> walks}) build({
    int workouts = 3,
    int walks = 2,
    Set<int> days = const {1, 3, 5, 7},
    Set<int> walkingDays = const {1, 2, 3, 4, 5, 6, 7},
    List<PlannedActivity> existing = const [],
    DateTime? today,
  }) => WeeklySchedulePolicy.distribute(
    weekReference: monday,
    today: today ?? monday,
    workoutDays: days,
    walkingDays: walkingDays,
    workoutCount: workouts,
    walkCount: walks,
    existing: existing,
  );
  test('preset alterni, lun-ven, tutti e personalizzati', () {
    expect(WeeklySchedulePolicy.daysFor(WeeklyDayMode.alternate, {}), {
      1,
      3,
      5,
      7,
    });
    expect(WeeklySchedulePolicy.daysFor(WeeklyDayMode.weekdays, {}), {
      1,
      2,
      3,
      4,
      5,
    });
    expect(WeeklySchedulePolicy.daysFor(WeeklyDayMode.everyDay, {}), {
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    });
    expect(WeeklySchedulePolicy.daysFor(WeeklyDayMode.custom, {2, 6}), {2, 6});
  });
  test('piano misto deterministico, distanziato e senza sovrapposizioni', () {
    final a = build(), b = build();
    expect(a.workouts, b.workouts);
    expect(a.walks, b.walks);
    expect(a.workouts.map((d) => d.weekday), [1, 3, 5]);
    expect({...a.workouts, ...a.walks}.length, 5);
  });
  test('giorni limitati delle camminate non consumati da scelta greedy', () {
    final a = build(workouts: 1, walks: 1, days: {1, 2}, walkingDays: {1});
    expect(a.workouts.single.weekday, 2);
    expect(a.walks.single.weekday, 1);
  });
  test(
    'configurazioni impossibili, nessun giorno e zero attività rifiutati',
    () {
      expect(() => build(workouts: 5, walks: 3), throwsArgumentError);
      expect(() => build(days: {}), throwsArgumentError);
      expect(() => build(workouts: 0, walks: 0), throwsArgumentError);
      expect(
        () => build(workouts: 4, walks: 0, days: {1, 2}),
        throwsStateError,
      );
    },
  );
  test('giorni passati e occupati esclusi, nessuna modifica del piano', () {
    final existing = [
      PlannedActivity(
        profileId: 1,
        scheduledDate: DateTime(2026, 11, 25),
        type: PlannedActivityType.recovery,
        origin: PlannedActivityOrigin.user,
      ),
    ];
    final a = build(
      workouts: 1,
      walks: 1,
      today: DateTime(2026, 11, 25),
      existing: existing,
    );
    expect(
      [
        ...a.workouts,
        ...a.walks,
      ].every((d) => d.isAfter(DateTime(2026, 11, 25))),
      isTrue,
    );
    expect(existing.single.type, PlannedActivityType.recovery);
  });
  test(
    'solo camminate senza allenamenti',
    () => expect(build(workouts: 0, walks: 7).walks.length, 7),
  );
}
