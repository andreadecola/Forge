import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../data/repositories/forge_providers.dart' show clockProvider;
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/planned_activity.dart';
import '../../../../domain/entities/planned_activity_enums.dart';
import '../../../../domain/entities/weekly_plan_summary.dart';
import '../../../../domain/services/weekly_planning_date_service.dart';
import '../../application/planned_activity_providers.dart';
import '../planned_activity_presentation.dart';
import '../widgets/planned_activity_form.dart';
import '../widgets/weekly_forge_generation_sheet.dart';

/// Pianificazione manuale della settimana (Milestone 8.2): risponde a "cosa
/// è previsto?", non avvia mai una sessione reale né genera nulla
/// automaticamente (quello è M8.4/M8.5) — solo CRUD su `PlannedActivity`
/// tramite l'infrastruttura già pronta dalla Milestone 8.1.
class WeeklyPlanPage extends ConsumerStatefulWidget {
  const WeeklyPlanPage({super.key});

  @override
  ConsumerState<WeeklyPlanPage> createState() => _WeeklyPlanPageState();
}

class _WeeklyPlanPageState extends ConsumerState<WeeklyPlanPage> {
  late DateTime _weekReference;

  @override
  void initState() {
    super.initState();
    // Stato locale alla pagina, non persistito (sezione 40/61): non serve
    // un provider Riverpod condiviso solo per ricordare quale settimana è
    // visualizzata.
    _weekReference = ref.read(clockProvider).now();
  }

  void _goToPreviousWeek() {
    setState(() {
      _weekReference = _weekReference.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    setState(() {
      _weekReference = _weekReference.add(const Duration(days: 7));
    });
  }

  void _goToCurrentWeek() {
    setState(() {
      _weekReference = ref.read(clockProvider).now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Piano settimanale')),
      body: profileAsync.when(
        data: (profile) => profile == null
            ? const Center(child: Text('Completa prima l\'onboarding.'))
            : _WeeklyPlanBody(
                profileId: profile.id!,
                weekReference: _weekReference,
                onPreviousWeek: _goToPreviousWeek,
                onNextWeek: _goToNextWeek,
                onCurrentWeek: _goToCurrentWeek,
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Errore: $error')),
      ),
    );
  }
}

class _WeeklyPlanBody extends ConsumerWidget {
  const _WeeklyPlanBody({
    required this.profileId,
    required this.weekReference,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCurrentWeek,
  });

  final int profileId;
  final DateTime weekReference;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onCurrentWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = WeeklyPlanningDateService.weekStart(weekReference);
    final weekEnd = WeeklyPlanningDateService.weekEnd(weekReference);
    final activitiesAsync = ref.watch(
      plannedActivitiesForWeekProvider((
        profileId: profileId,
        weekReference: weekReference,
      )),
    );
    final today = WeeklyPlanningDateService.atMidnight(
      ref.watch(clockProvider).now(),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Settimana precedente',
                    onPressed: onPreviousWeek,
                  ),
                  Expanded(
                    child: Text(
                      formatItalianWeekRange(weekStart, weekEnd),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Settimana successiva',
                    onPressed: onNextWeek,
                  ),
                ],
              ),
              TextButton(
                onPressed: onCurrentWeek,
                child: const Text('Vai alla settimana corrente'),
              ),
            ],
          ),
        ),
        Expanded(
          child: activitiesAsync.when(
            data: (activities) => _WeekList(
              profileId: profileId,
              weekReference: weekReference,
              weekStart: weekStart,
              weekEnd: weekEnd,
              activities: activities,
              today: today,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => const _ErrorState(),
          ),
        ),
      ],
    );
  }
}

/// Riepilogo derivato della settimana (Milestone 8.7): risponde solo a
/// "com'è andata questa settimana rispetto a quello che era previsto?" —
/// mai un giudizio, un adattamento o una modifica del piano (sezione 2/3).
/// Un `FutureProvider` proprio (sezione 53): un eventuale errore nel
/// calcolo del riepilogo non deve rompere il resto di `WeeklyPlanPage`.
class _WeeklySummaryCard extends ConsumerWidget {
  const _WeeklySummaryCard({
    required this.profileId,
    required this.weekReference,
    required this.weekStart,
    required this.weekEnd,
    required this.today,
  });

  final int profileId;
  final DateTime weekReference;
  final DateTime weekStart;
  final DateTime weekEnd;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(
      weeklyPlanSummaryProvider((
        profileId: profileId,
        weekReference: weekReference,
      )),
    );
    return summaryAsync.when(
      // Settimana vuota (sezione 37): le 7 card giorno sottostanti già
      // mostrano "Nessuna attività pianificata" — nessuna card riepilogo
      // ridondante, mai uno "0%" vistoso.
      data: (summary) => summary.total == 0
          ? const SizedBox.shrink()
          : Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleFor(
                        weekStart: weekStart,
                        weekEnd: weekEnd,
                        today: today,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _descriptionFor(
                        summary,
                        weekStart: weekStart,
                        today: today,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
      // Nessuno spinner invadente per un riepilogo secondario: la card
      // resta assente finché non è pronta, il piano sottostante non
      // aspetta.
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
    );
  }

  /// "Questa settimana" se contiene oggi, "Riepilogo" se interamente
  /// passata, "Piano della settimana" se interamente futura (sezione
  /// 34/35/36).
  static String _titleFor({
    required DateTime weekStart,
    required DateTime weekEnd,
    required DateTime today,
  }) {
    if (weekEnd.isBefore(today)) return 'Riepilogo';
    if (weekStart.isAfter(today)) return 'Piano della settimana';
    return 'Questa settimana';
  }

  static String _descriptionFor(
    WeeklyPlanSummary summary, {
    required DateTime weekStart,
    required DateTime today,
  }) {
    // Settimana futura (sezione 16/36): solo il piano previsto, mai una
    // percentuale di completamento — non c'è ancora nulla di "maturo" da
    // valutare.
    if (weekStart.isAfter(today)) {
      return '${summary.total} attività pianificate '
          '(${summary.workoutCount} allenamenti, ${summary.walkCount} '
          'camminate, ${summary.recoveryCount} recuperi)';
    }

    // Settimana corrente parziale o passata (sezione 14/15/17/39): la
    // percentuale considera solo le attività "mature" (data <= oggi) —
    // mai le attività future trattate come non completate.
    final rate = summary.matureCompletionRate;
    final buffer = StringBuffer();
    if (rate != null) {
      buffer.write(
        'Completate ${summary.matureCompleted} su ${summary.matureTotal} '
        'considerate',
      );
    } else {
      buffer.write('${summary.total} attività pianificate');
    }
    final details = <String>[
      if (summary.active > 0) '${summary.active} in corso',
      if (summary.skipped > 0) '${summary.skipped} saltate',
      if (summary.postponed > 0) '${summary.postponed} rinviate',
      if (summary.plannedRemaining > 0) '${summary.plannedRemaining} da fare',
    ];
    if (details.isNotEmpty) {
      buffer.write(' · ${details.join(', ')}');
    }
    return buffer.toString();
  }
}

/// Entry point "Genera con Forge" per la settimana (Milestone 8.4),
/// distinto dal pulsante "Aggiungi" di ogni giorno (sezione 57): stesso
/// stile di `_ForgeGeneratorEntryPoint` in `WorkoutListPage` (Milestone
/// 5.5) — card evidenziata, non un FAB.
class _ForgeWeekGeneratorEntryPoint extends StatelessWidget {
  const _ForgeWeekGeneratorEntryPoint({
    required this.profileId,
    required this.weekReference,
    required this.isPastWeek,
    required this.hasForgeActivities,
  });

  final int profileId;
  final DateTime weekReference;
  final bool isPastWeek;
  final bool hasForgeActivities;

  @override
  Widget build(BuildContext context) {
    // Settimana interamente passata: nessuna generazione automatica ha
    // senso qui (sezione 11/58) — l'entry point non viene proprio mostrato.
    if (isPastWeek) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    if (hasForgeActivities) {
      // Sezione 32/33/34: strategia minima "blocca", non sostituire/
      // duplicare silenziosamente — l'utente elimina manualmente le
      // attività Forge esistenti (flusso già disponibile, Milestone 8.2)
      // se vuole rigenerare.
      return Card(
        color: colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.bolt, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Questa settimana contiene già attività generate da '
                  'Forge. Eliminale prima di generarne di nuove.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: colorScheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showWeeklyForgeGenerationSheet(
          context,
          profileId: profileId,
          weekReference: weekReference,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.bolt, color: colorScheme.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Genera con Forge',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Genera automaticamente allenamenti per questa '
                      'settimana',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekList extends StatelessWidget {
  const _WeekList({
    required this.profileId,
    required this.weekReference,
    required this.weekStart,
    required this.weekEnd,
    required this.activities,
    required this.today,
  });

  final int profileId;
  final DateTime weekReference;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<PlannedActivity> activities;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    // Colonna eager (non `ListView.builder`), deliberato: sempre esattamente
    // 7 giorni, mai una lunga lista da virtualizzare — costruire tutte le
    // card subito evita anche la loro comparsa/scomparsa lazy fuori dal
    // cache extent, così ogni giorno resta raggiungibile scorrendo, senza
    // sorprese sul montaggio degli elementi.
    final days = List.generate(
      DateTime.daysPerWeek,
      (index) => weekStart.add(Duration(days: index)),
    );
    // Riepilogo e generatore Forge scorrono insieme ai giorni (Milestone
    // 8.7): tenerli fissi fuori dallo scroll ha causato un overflow su
    // schermi piccoli quando entrambe le card sono presenti
    // contemporaneamente (verificato con un test dedicato) — un'unica
    // area scrollabile evita il problema per costruzione, qualunque sia
    // l'altezza combinata delle card.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          _WeeklySummaryCard(
            profileId: profileId,
            weekReference: weekReference,
            weekStart: weekStart,
            weekEnd: weekEnd,
            today: today,
          ),
          const SizedBox(height: 8),
          _ForgeWeekGeneratorEntryPoint(
            profileId: profileId,
            weekReference: weekReference,
            isPastWeek: weekEnd.isBefore(today),
            hasForgeActivities: activities.any(
              (activity) =>
                  activity.origin == PlannedActivityOrigin.forgeEngine,
            ),
          ),
          const SizedBox(height: 8),
          for (final day in days)
            _DayCard(
              profileId: profileId,
              day: day,
              isToday: day == today,
              activities: activities
                  .where((activity) => activity.scheduledDate == day)
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({
    required this.profileId,
    required this.day,
    required this.isToday,
    required this.activities,
  });

  final int profileId;
  final DateTime day;
  final bool isToday;
  final List<PlannedActivity> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: isToday
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  italianWeekdayShort(day),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatItalianDate(day),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (isToday)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Chip(
                      label: Text('Oggi'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Aggiungi attività',
                  onPressed: () => showPlannedActivityForm(
                    context,
                    profileId: profileId,
                    initialDate: day,
                  ),
                ),
              ],
            ),
            if (activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Expanded(child: Text('Nessuna attività pianificata')),
                    TextButton(
                      onPressed: () => showPlannedActivityForm(
                        context,
                        profileId: profileId,
                        initialDate: day,
                      ),
                      child: const Text('Aggiungi'),
                    ),
                  ],
                ),
              )
            else
              for (final activity in activities)
                _ActivityTile(
                  activity: activity,
                  onTap: () => showPlannedActivityForm(
                    context,
                    profileId: profileId,
                    initialDate: day,
                    existing: activity,
                  ),
                  onDelete: () => _confirmDelete(context, ref, activity),
                ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PlannedActivity activity,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminare questa attività pianificata?'),
      content: const Text('L\'operazione non può essere annullata.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Elimina'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref
        .read(plannedActivityControllerProvider)
        .deletePlannedActivity(activity.id!);
  } on ArgumentError catch (e) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(e.message.toString())));
    return;
  }
  messenger
    ..clearSnackBars()
    ..showSnackBar(const SnackBar(content: Text('Attività rimossa')));
}

/// Azioni "Salta"/"Rinvia"/"Ripristina" (Milestone 8.6): stesso schema di
/// [_confirmDelete] (conferma esplicita, feedback neutro, `ArgumentError`
/// del dominio mostrato via SnackBar) — nessuna azione tenta mai di
/// "completare comunque" un'operazione rifiutata dal dominio.
Future<void> _runStatusAction(
  BuildContext context,
  WidgetRef ref, {
  required String confirmTitle,
  required String successMessage,
  required Future<void> Function() action,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(confirmTitle),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Conferma'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } on ArgumentError catch (e) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(e.message.toString())));
    return;
  }
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(successMessage)));
}

/// Azione "Sposta" (Milestone 8.6, sezione 16/31): solo un nuovo
/// `scheduledDate` — nessun form intero riaperto. Se l'attività era
/// `SKIPPED`/`POSTPONED`, `UpdatePlannedActivity` la riporta a `PLANNED`
/// (regola di dominio, non duplicata qui).
Future<void> _moveActivity(
  BuildContext context,
  WidgetRef ref,
  PlannedActivity activity,
) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: activity.scheduledDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (picked == null || !context.mounted) return;
  final newDate = WeeklyPlanningDateService.atMidnight(picked);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref
        .read(plannedActivityControllerProvider)
        .movePlannedActivity(activity: activity, newScheduledDate: newDate);
  } on ArgumentError catch (e) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(e.message.toString())));
    return;
  }
  messenger
    ..clearSnackBars()
    ..showSnackBar(const SnackBar(content: Text('Attività spostata')));
}

enum _ActivityMenuAction { move, skip, postpone, restore, delete }

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({
    required this.activity,
    required this.onTap,
    required this.onDelete,
  });

  final PlannedActivity activity;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayState = PlannedActivityPresentation.displayState(
      ref,
      activity,
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(PlannedActivityPresentation.icon(activity.type)),
      title: Text(PlannedActivityPresentation.title(activity.type)),
      subtitle: PlannedActivityPresentation.subtitle(ref, activity),
      onTap: onTap,
      trailing: PopupMenuButton<_ActivityMenuAction>(
        tooltip: 'Altre azioni',
        onSelected: (action) => _onMenuAction(context, ref, action),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: _ActivityMenuAction.move,
            child: Text('Sposta'),
          ),
          // Sezione 13/14/25: "Salta"/"Rinvia" non sono mai offerte quando
          // la sessione reale collegata è attiva o già completata — solo
          // le azioni realmente valide per lo stato corrente compaiono.
          if (displayState == PlannedActivityDisplayState.none) ...[
            const PopupMenuItem(
              value: _ActivityMenuAction.skip,
              child: Text('Salta'),
            ),
            const PopupMenuItem(
              value: _ActivityMenuAction.postpone,
              child: Text('Rinvia'),
            ),
          ],
          if (displayState == PlannedActivityDisplayState.skipped ||
              displayState == PlannedActivityDisplayState.postponed)
            const PopupMenuItem(
              value: _ActivityMenuAction.restore,
              child: Text('Ripristina nel piano'),
            ),
          const PopupMenuItem(
            value: _ActivityMenuAction.delete,
            child: Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Future<void> _onMenuAction(
    BuildContext context,
    WidgetRef ref,
    _ActivityMenuAction action,
  ) {
    switch (action) {
      case _ActivityMenuAction.move:
        return _moveActivity(context, ref, activity);
      case _ActivityMenuAction.skip:
        return _runStatusAction(
          context,
          ref,
          confirmTitle: 'Segnare questa attività come saltata?',
          successMessage: 'Attività segnata come saltata',
          action: () => ref
              .read(plannedActivityControllerProvider)
              .skipPlannedActivity(activity.id!),
        );
      case _ActivityMenuAction.postpone:
        return _runStatusAction(
          context,
          ref,
          confirmTitle: 'Rinviare questa attività?',
          successMessage: 'Attività rinviata',
          action: () => ref
              .read(plannedActivityControllerProvider)
              .postponePlannedActivity(activity.id!),
        );
      case _ActivityMenuAction.restore:
        return _runStatusAction(
          context,
          ref,
          confirmTitle: 'Ripristinare questa attività nel piano?',
          successMessage: 'Attività ripristinata nel piano',
          action: () => ref
              .read(plannedActivityControllerProvider)
              .restorePlannedActivity(activity.id!),
        );
      case _ActivityMenuAction.delete:
        onDelete();
        return Future.value();
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40),
            SizedBox(height: 16),
            Text('Si è verificato un errore.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
