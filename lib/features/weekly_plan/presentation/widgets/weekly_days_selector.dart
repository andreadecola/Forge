import 'package:flutter/material.dart';
import '../../../../domain/services/weekly_schedule_policy.dart';

class WeeklyDaysSelector extends StatelessWidget {
  const WeeklyDaysSelector({
    super.key,
    required this.label,
    required this.days,
    required this.mode,
    required this.onChanged,
  });
  final String label;
  final Set<int> days;
  final WeeklyDayMode mode;
  final void Function(WeeklyDayMode, Set<int>) onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.titleMedium),
      Wrap(
        spacing: 8,
        children: [
          for (final entry in const {
            WeeklyDayMode.alternate: 'Giorni alterni',
            WeeklyDayMode.weekdays: 'Lunedì–venerdì',
            WeeklyDayMode.everyDay: 'Tutti i giorni',
            WeeklyDayMode.custom: 'Personalizzati',
          }.entries)
            ChoiceChip(
              label: Text(entry.value),
              selected: mode == entry.key,
              onSelected: (_) => onChanged(
                entry.key,
                WeeklySchedulePolicy.daysFor(entry.key, days),
              ),
            ),
        ],
      ),
      if (mode == WeeklyDayMode.alternate)
        const Text('Lunedì, mercoledì, venerdì e domenica.'),
      if (mode == WeeklyDayMode.custom)
        Wrap(
          spacing: 6,
          children: [
            for (var i = 1; i <= 7; i++)
              FilterChip(
                label: Text(
                  const ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'][i -
                      1],
                ),
                selected: days.contains(i),
                onSelected: (value) {
                  final next = Set<int>.of(days);
                  value ? next.add(i) : next.remove(i);
                  onChanged(WeeklyDayMode.custom, next);
                },
              ),
          ],
        ),
    ],
  );
}
