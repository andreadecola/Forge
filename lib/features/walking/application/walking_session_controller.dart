import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/forge_providers.dart';
import '../../../data/repositories/walking_session_providers.dart';
import '../../../domain/entities/walking_session.dart';
import '../../../domain/entities/walking_session_status.dart';
import '../../../domain/repositories/walking_session_repository.dart';
import '../../../domain/services/clock.dart';
import 'walking_session_runtime_state.dart';

class WalkingSessionController extends Notifier<WalkingSessionRuntimeState?> {
  Timer? _ticker;
  late final WalkingSessionRepository _repository;
  late final Clock _clock;
  bool _transitionInProgress = false;

  @override
  WalkingSessionRuntimeState? build() {
    _repository = ref.read(walkingSessionRepositoryProvider);
    _clock = ref.read(clockProvider);
    ref.onDispose(_stopTicker);
    return null;
  }

  /// Starts a new persisted session, or adopts the already active one.
  Future<bool> start(int profileId) async {
    if (state?.isTerminal == true) clear();
    if (_transitionInProgress || state != null) return false;
    _transitionInProgress = true;
    _stopTicker();
    try {
      final active = await _repository.getActiveWalkingSession(
        profileId: profileId,
      );
      if (active != null) {
        _adopt(active);
        return false;
      }

      final startedAt = _clock.now();
      final sessionId = await _repository.createWalkingSession(
        WalkingSession(
          profileId: profileId,
          startedAt: startedAt,
          status: WalkingSessionStatus.inProgress,
        ),
      );
      state = WalkingSessionRuntimeState(
        sessionId: sessionId,
        profileId: profileId,
        startedAt: startedAt,
        status: WalkingSessionStatus.inProgress,
      );
      _startTicker();
      ref.invalidate(activeWalkingSessionProvider(profileId));
      return true;
    } on ActiveWalkingSessionAlreadyExistsException {
      final active = await _repository.getActiveWalkingSession(
        profileId: profileId,
      );
      if (active == null) rethrow;
      _adopt(active);
      return false;
    } finally {
      _transitionInProgress = false;
    }
  }

  /// Reconstructs all persisted state, including an open pause.
  Future<bool> restoreActive(int profileId) async {
    if (state?.isTerminal == true) clear();
    final current = state;
    if (current != null &&
        current.profileId == profileId &&
        !current.isTerminal) {
      _startTicker();
      return true;
    }
    if (current != null && current.profileId != profileId) {
      clear();
    }
    if (_transitionInProgress) return false;

    _transitionInProgress = true;
    try {
      final active = await _repository.getActiveWalkingSession(
        profileId: profileId,
      );
      if (active == null) return false;
      _adopt(active);
      return true;
    } finally {
      _transitionInProgress = false;
    }
  }

  Future<bool> pause() async {
    final current = state;
    if (current == null || current.isTerminal || current.isPaused) {
      return false;
    }
    if (_transitionInProgress) return false;
    _transitionInProgress = true;
    try {
      final pausedAt = _clock.now();
      final updated = await _repository.pauseWalkingSession(
        sessionId: current.sessionId,
        pausedAt: pausedAt,
      );
      if (updated == null) return false;
      state = current.copyWith(
        isPaused: true,
        pauseStartedAt: () => updated.pauseStartedAt,
        accumulatedPauseSeconds: updated.accumulatedPauseSeconds,
      );
      return true;
    } finally {
      _transitionInProgress = false;
    }
  }

  Future<bool> resume() async {
    final current = state;
    if (current == null || current.isTerminal || !current.isPaused) {
      return false;
    }
    if (_transitionInProgress) return false;
    _transitionInProgress = true;
    try {
      final resumedAt = _clock.now();
      final updated = await _repository.resumeWalkingSession(
        sessionId: current.sessionId,
        resumedAt: resumedAt,
      );
      if (updated == null) return false;
      state = current.copyWith(
        isPaused: false,
        pauseStartedAt: () => null,
        accumulatedPauseSeconds: updated.accumulatedPauseSeconds,
      );
      return true;
    } finally {
      _transitionInProgress = false;
    }
  }

  Future<bool> complete() async {
    final current = state;
    if (current == null || current.isTerminal || _transitionInProgress) {
      return false;
    }
    _transitionInProgress = true;
    final endedAt = _clock.now();
    try {
      await _repository.completeWalkingSession(
        sessionId: current.sessionId,
        endedAt: endedAt,
      );
      state = _terminalState(
        current,
        status: WalkingSessionStatus.completed,
        endedAt: endedAt,
      );
      _stopTicker();
      ref.invalidate(activeWalkingSessionProvider(current.profileId));
      return true;
    } finally {
      _transitionInProgress = false;
    }
  }

  Future<bool> abort() async {
    final current = state;
    if (current == null || current.isTerminal || _transitionInProgress) {
      return false;
    }
    _transitionInProgress = true;
    final endedAt = _clock.now();
    try {
      await _repository.abortWalkingSession(
        sessionId: current.sessionId,
        endedAt: endedAt,
      );
      state = _terminalState(
        current,
        status: WalkingSessionStatus.aborted,
        endedAt: endedAt,
      );
      _stopTicker();
      ref.invalidate(activeWalkingSessionProvider(current.profileId));
      return true;
    } finally {
      _transitionInProgress = false;
    }
  }

  Future<bool> updateMetrics({
    required int? distanceMeters,
    required int? steps,
  }) async {
    final current = state;
    if (current == null || _transitionInProgress) return false;
    _transitionInProgress = true;
    try {
      final session = await _repository.getWalkingSession(current.sessionId);
      if (session == null) {
        throw WalkingSessionNotFoundException(current.sessionId);
      }
      final updatedSession = session.copyWith(
        distanceMeters: () => distanceMeters,
        steps: () => steps,
      );
      await _repository.updateWalkingMetrics(
        sessionId: current.sessionId,
        distanceMeters: distanceMeters,
        steps: steps,
      );
      state = current.copyWith(
        distanceMeters: () => updatedSession.distanceMeters,
        steps: () => updatedSession.steps,
      );
      return true;
    } finally {
      _transitionInProgress = false;
    }
  }

  void clear() {
    _stopTicker();
    state = null;
  }

  WalkingSessionRuntimeState _terminalState(
    WalkingSessionRuntimeState current, {
    required WalkingSessionStatus status,
    required DateTime endedAt,
  }) {
    return current.copyWith(
      isPaused: false,
      pauseStartedAt: () => null,
      accumulatedPauseSeconds: current
          .toWalkingSession()
          .pauseDuration(endedAt)
          .inSeconds,
      status: status,
      endedAt: () => endedAt,
    );
  }

  void _adopt(WalkingSession session) {
    state = WalkingSessionRuntimeState(
      sessionId: session.id!,
      profileId: session.profileId,
      startedAt: session.startedAt,
      status: session.status,
      isPaused: session.isPaused,
      pauseStartedAt: session.pauseStartedAt,
      accumulatedPauseSeconds: session.accumulatedPauseSeconds,
      endedAt: session.endedAt,
      distanceMeters: session.distanceMeters,
      steps: session.steps,
    );
    _startTicker();
  }

  void _onTick() {
    final current = state;
    if (current == null || current.isTerminal) {
      _stopTicker();
      return;
    }
    // The clock/timestamps remain the source of truth; this only refreshes UI.
    state = current.copyWith();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

final walkingSessionControllerProvider =
    NotifierProvider<WalkingSessionController, WalkingSessionRuntimeState?>(
      WalkingSessionController.new,
    );
