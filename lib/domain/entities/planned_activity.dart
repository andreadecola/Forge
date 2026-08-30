import 'planned_activity_enums.dart';

/// Un'attività pianificata per una data (Milestone 8.1): risponde a "cosa
/// era previsto?", mai a "cosa è realmente successo?" — quella domanda
/// resta di competenza di `WorkoutSession`/`WalkingSession` (Milestone 4/6),
/// che questa entità non duplica né sostituisce.
///
/// [workoutId] referenzia una scheda [Workout] esistente (Milestone 4) senza
/// copiarne esercizi/serie/ripetizioni: obbligatorio quando [type] è
/// [PlannedActivityType.workout], sempre `null` altrimenti (validato dagli
/// use case, non da un vincolo SQL — stesso principio già seguito per
/// `allenamenti_esercizi`, dove i vincoli che dipendono da un altro campo
/// applicativo restano nel dominio).
///
/// [workoutSessionId]/[walkingSessionId] (Milestone 8.5): collegamento
/// esplicito alla sessione reale nata avviando questa attività — mai
/// dedotto da data/workoutId/durata. Il completamento non è un valore
/// persistito su [status] (che resta sempre `planned`): si deriva sempre
/// leggendo lo stato della sessione collegata, unica fonte di verità
/// (nessuna doppia fonte da tenere sincronizzata).
class PlannedActivity {
  const PlannedActivity({
    this.id,
    required this.profileId,
    required this.scheduledDate,
    required this.type,
    this.workoutId,
    this.plannedDurationMinutes,
    this.status = PlannedActivityStatus.planned,
    required this.origin,
    this.notes,
    this.workoutSessionId,
    this.walkingSessionId,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int profileId;

  /// Il giorno pianificato, non l'istante di creazione del record (vedi
  /// [createdAt]) — sempre troncato a mezzanotte locale (sezione 25/48):
  /// due attività nello stesso giorno hanno lo stesso [scheduledDate], mai
  /// un timestamp che dipende dall'ora in cui sono state create.
  final DateTime scheduledDate;

  final PlannedActivityType type;

  /// Riferimento a `Workout.id` (Milestone 4). Obbligatorio se [type] è
  /// [PlannedActivityType.workout], sempre `null` per [PlannedActivityType.walk]
  /// e [PlannedActivityType.recovery].
  final int? workoutId;

  /// Parametro pianificato minimo per [PlannedActivityType.walk] (sezione
  /// 16): solo la durata prevista, mai un target di distanza/passi/percorso
  /// — nessuna duplicazione dei campi reali di `WalkingSession`.
  final int? plannedDurationMinutes;

  final PlannedActivityStatus status;

  final PlannedActivityOrigin origin;

  final String? notes;

  /// Id di `sessioni_allenamento` (Milestone 8.5): valorizzato solo se
  /// [type] è [PlannedActivityType.workout], `null` altrimenti (stessa
  /// regola di [workoutId], validata negli use case).
  final int? workoutSessionId;

  /// Id di `camminate` (Milestone 8.5): valorizzato solo se [type] è
  /// [PlannedActivityType.walk].
  final int? walkingSessionId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  PlannedActivity copyWith({
    int? id,
    int? profileId,
    DateTime? scheduledDate,
    PlannedActivityType? type,
    int? Function()? workoutId,
    int? Function()? plannedDurationMinutes,
    PlannedActivityStatus? status,
    PlannedActivityOrigin? origin,
    String? Function()? notes,
    int? Function()? workoutSessionId,
    int? Function()? walkingSessionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlannedActivity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      type: type ?? this.type,
      workoutId: workoutId != null ? workoutId() : this.workoutId,
      plannedDurationMinutes: plannedDurationMinutes != null
          ? plannedDurationMinutes()
          : this.plannedDurationMinutes,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      notes: notes != null ? notes() : this.notes,
      workoutSessionId: workoutSessionId != null
          ? workoutSessionId()
          : this.workoutSessionId,
      walkingSessionId: walkingSessionId != null
          ? walkingSessionId()
          : this.walkingSessionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
