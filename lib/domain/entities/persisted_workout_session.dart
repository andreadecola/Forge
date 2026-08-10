import 'persisted_session_timer.dart';
import 'workout_session_persistence_status.dart';

/// Riga persistita di `sessioni_allenamento` (Milestone 4.4.3): dati
/// scalari della sessione. Il progresso per esercizio è aggregato
/// separatamente in [PersistedSessionExercise] (stesso rapporto di
/// [Workout]/[WorkoutExercise] per la definizione della scheda).
class PersistedWorkoutSession {
  const PersistedWorkoutSession({
    this.id,
    this.workoutId,
    required this.profileId,
    required this.workoutNameSnapshot,
    required this.status,
    this.currentExerciseIndex = 0,
    required this.startedAt,
    this.endedAt,
    this.isPaused = false,
    this.isCompleted = false,
    this.timer,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;

  /// Nullable: `ON DELETE SET NULL` a livello DB (vedi
  /// `sessioni_allenamento_table.dart`) — la scheda originale potrebbe
  /// essere stata eliminata dopo la sessione. [workoutNameSnapshot] resta
  /// sempre leggibile anche in quel caso.
  final int? workoutId;

  final int profileId;
  final String workoutNameSnapshot;
  final WorkoutSessionPersistenceStatus status;
  final int currentExerciseIndex;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isPaused;
  final bool isCompleted;
  final PersistedSessionTimer? timer;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
