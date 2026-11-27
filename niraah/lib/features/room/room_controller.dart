import 'dart:async';

import 'package:flutter/foundation.dart';

import 'call_engine.dart';
import 'room_repository.dart';

/// Where the room is (spec 014 §5 "Entering", "In the room", "Leaving").
enum RoomPhase {
  /// Asking the server for the consult and a token.
  loading,

  /// Too early: counts down to [RoomController.opensAt] and opens by itself.
  notOpen,

  /// The microphone was refused: a call cannot start without it.
  needsPermission,

  /// Her camera preview, mic and camera switches, "Join now".
  lobby,
  joining,
  inCall,

  /// Left, ended by the clinician, or the room closed.
  ended,

  /// Closed, not hers, cancelled, or the video service is unavailable.
  unavailable,
}

/// What the device allows. Injected so tests run without real permission prompts.
typedef PermissionAsk = Future<({bool mic, bool camera})> Function();

class RoomController extends ChangeNotifier {
  RoomController({
    required this.appointmentId,
    required this.side,
    required RoomRepository repository,
    required CallEngine Function() engineFactory,
    required PermissionAsk askPermissions,
    DateTime Function()? clock,
  })  : _repo = repository,
        _engineFactory = engineFactory,
        _ask = askPermissions,
        _now = clock ?? DateTime.now;

  final String appointmentId;
  final RoomSide side;
  final RoomRepository _repo;
  final CallEngine Function() _engineFactory;
  final PermissionAsk _ask;
  final DateTime Function() _now;

  RoomPhase phase = RoomPhase.loading;
  RoomInfo? info;
  RoomToken? _token;
  CallEngine? engine;
  String? message;
  DateTime? opensAt;

  bool micOn = true;
  bool cameraOn = true;
  bool speakerOn = true;
  bool cameraAllowed = true;

  /// The other person, once they are in the call.
  int? otherUid;
  bool otherCameraOn = true;
  bool otherMicOn = true;
  bool reconnecting = false;

  /// When both were first in the call (the timer counts from here).
  DateTime? talkingSince;

  /// How the call ended, for the closing screen.
  bool endedForBoth = false;
  bool roomClosed = false;
  bool otherEnded = false;

  StreamSubscription<CallEvent>? _sub;
  Timer? _tick;
  Timer? _retry;
  bool _disposed = false;

  String get channel => _token?.channel ?? '';
  bool get recording => (_token?.recording ?? false) || (info?.recording ?? false);
  DateTime? get closesAt => _token?.closesAt;

  /// "Room closes in N min" shows in the last two minutes.
  Duration? get closingIn {
    final DateTime? c = closesAt;
    if (c == null || phase != RoomPhase.inCall) return null;
    final Duration left = c.difference(_now());
    return left <= const Duration(minutes: 2) && !left.isNegative ? left : null;
  }

  Duration get talked => talkingSince == null ? Duration.zero : _now().difference(talkingSince!);

  Duration? get untilOpen => opensAt?.difference(_now());

  void _set(VoidCallback f) {
    if (_disposed) return;
    f();
    notifyListeners();
  }

  /// Loads the consult, then asks for a token and opens the lobby (or the countdown).
  Future<void> open() async {
    _set(() => phase = RoomPhase.loading);
    info ??= await _repo.info(appointmentId);
    await _fetchToken();
  }

  Future<void> _fetchToken() async {
    final TokenResult r = await _repo.token(appointmentId);
    if (_disposed) return;
    switch (r) {
      case TokenReady(:final RoomToken token):
        _token = token;
        await _toLobby();
      case RoomNotOpen(opensAt: final DateTime? at, :final String message):
        _set(() {
          phase = RoomPhase.notOpen;
          opensAt = at;
          this.message = message;
        });
        _startTicking();
        _retry?.cancel();
        final Duration wait = at == null ? const Duration(seconds: 30) : at.difference(_now()) + const Duration(seconds: 1);
        _retry = Timer(wait.isNegative ? Duration.zero : wait, _fetchToken);
      case RoomClosed(:final String message):
        _set(() {
          phase = RoomPhase.unavailable;
          this.message = message;
        });
      case RoomUnavailable(:final String message):
        _set(() {
          phase = RoomPhase.unavailable;
          this.message = message;
        });
    }
  }

  Future<void> _toLobby() async {
    final ({bool mic, bool camera}) allowed = await _ask();
    if (_disposed) return;
    if (!allowed.mic) {
      _set(() => phase = RoomPhase.needsPermission);
      return;
    }
    cameraAllowed = allowed.camera;
    cameraOn = allowed.camera;
    if (engine == null) {
      final CallEngine e = _engineFactory();
      engine = e;
      _sub = e.events.listen(_onEvent);
      try {
        await e.start(_token!.appId);
        if (!cameraOn) await e.setCameraOn(false);
      } catch (_) {
        _set(() {
          phase = RoomPhase.unavailable;
          message = "Video couldn't start on this phone. Close other apps using the camera and try again.";
        });
        return;
      }
    }
    _set(() => phase = RoomPhase.lobby);
    _startTicking();
  }

  /// After she allowed the microphone in Settings.
  Future<void> retryPermissions() => _toLobby();

  Future<void> join() async {
    final RoomToken? t = _token;
    final CallEngine? e = engine;
    if (t == null || e == null || phase != RoomPhase.lobby) return;
    _set(() => phase = RoomPhase.joining);
    try {
      await e.join(token: t.token, channel: t.channel, uid: t.uid);
      await e.setMicOn(micOn);
      // Some phones report the join late; the call is open once join() returns.
      if (phase == RoomPhase.joining) _set(() => phase = RoomPhase.inCall);
    } catch (_) {
      _set(() {
        phase = RoomPhase.lobby;
        message = "Couldn't join. Check your connection and try again.";
      });
    }
  }

  void _onEvent(CallEvent e) {
    switch (e) {
      case JoinedCall():
        _set(() => phase = RoomPhase.inCall);
      case OtherJoined(:final int uid):
        _set(() {
          otherUid = uid;
          otherCameraOn = true;
          otherMicOn = true;
          otherEnded = false;
          talkingSince ??= _now();
        });
      case OtherLeft(:final int uid):
        if (uid == otherUid) _set(() => otherUid = null);
      case OtherCamera(:final int uid, :final bool on):
        if (uid == otherUid) _set(() => otherCameraOn = on);
      case OtherMic(:final int uid, :final bool on):
        if (uid == otherUid) _set(() => otherMicOn = on);
      case ConnectionChanged(:final bool reconnecting):
        _set(() => this.reconnecting = reconnecting);
      case TokenExpiring():
        unawaited(_renew());
      case CallFailed(:final String message):
        _set(() => this.message = message);
    }
  }

  Future<void> _renew() async {
    final TokenResult r = await _repo.token(appointmentId);
    if (r is TokenReady) {
      _token = r.token;
      await engine?.renewToken(r.token.token);
    } else if (r is RoomClosed) {
      await _finish(closed: true);
    }
  }

  void _startTicking() {
    _tick ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) return;
      final DateTime? c = closesAt;
      if (phase == RoomPhase.inCall && c != null && !_now().isBefore(c)) {
        unawaited(_finish(closed: true));
        return;
      }
      notifyListeners();
    });
  }

  Future<void> toggleMic() async {
    _set(() => micOn = !micOn);
    await engine?.setMicOn(micOn);
  }

  Future<void> toggleCamera() async {
    if (!cameraAllowed) return;
    _set(() => cameraOn = !cameraOn);
    await engine?.setCameraOn(cameraOn);
  }

  Future<void> flipCamera() async => engine?.flipCamera();

  Future<void> toggleSpeaker() async {
    _set(() => speakerOn = !speakerOn);
    await engine?.setSpeakerOn(speakerOn);
  }

  /// She leaves; the consult stays open until it ends or the room closes, so she can come back.
  Future<void> leave() => _finish();

  /// The clinician ends the consult for both (spec 014 §5 "Leaving").
  Future<bool> endForBoth() async {
    final bool ok = await _repo.end(appointmentId);
    if (ok) await _finish(forBoth: true);
    return ok;
  }

  Future<void> _finish({bool forBoth = false, bool closed = false}) async {
    if (phase == RoomPhase.ended) return;
    await engine?.leave();
    _set(() {
      phase = RoomPhase.ended;
      endedForBoth = forBoth;
      roomClosed = closed;
    });
  }

  /// Back to the lobby after leaving, while the room is still open.
  Future<void> rejoin() async {
    _set(() {
      phase = RoomPhase.loading;
      otherUid = null;
      talkingSince = null;
      endedForBoth = false;
      roomClosed = false;
    });
    await _fetchToken();
  }

  @override
  void dispose() {
    _disposed = true;
    _tick?.cancel();
    _retry?.cancel();
    unawaited(_sub?.cancel());
    unawaited(engine?.dispose());
    super.dispose();
  }
}
