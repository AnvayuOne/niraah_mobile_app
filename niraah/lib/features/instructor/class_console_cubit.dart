import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/api_exception.dart';
import '../../core/video/device_permissions.dart';
import '../../core/video/video_engine.dart';
import '../provider_work/domain/provider_work.dart';
import 'instructor_repository.dart';

enum ConsolePhase { loading, shut, preview, starting, live, reconnecting, dropped, ended, left, error }

const Object _keep = Object();

class ConsoleState extends Equatable {
  const ConsoleState({
    this.phase = ConsolePhase.loading,
    this.token,
    this.message,
    this.notOpen = false,
    this.access,
    this.asking = false,
    this.mic = true,
    this.camera = true,
    this.console = const <String, dynamic>{},
    this.cameras = const <String, int?>{},
    this.reconnectingSince,
  });

  final ConsolePhase phase;
  final ChannelToken? token;
  final String? message;
  final bool notOpen;
  final MediaAccess? access;
  final bool asking;
  final bool mic;
  final bool camera;

  /// The server's console: status, startsAt, endsAt, presentCount, joined, phaseCounts.
  final Json console;

  /// Students' camera channels she is watching, with the student's uid once her video arrives (AC43).
  final Map<String, int?> cameras;
  final DateTime? reconnectingSince;

  bool get cameraOn => access == MediaAccess.granted && camera;
  bool get inClass => phase == ConsolePhase.live || phase == ConsolePhase.reconnecting;

  ConsoleState copyWith({
    ConsolePhase? phase,
    ChannelToken? token,
    Object? message = _keep,
    bool? notOpen,
    Object? access = _keep,
    bool? asking,
    bool? mic,
    bool? camera,
    Json? console,
    Map<String, int?>? cameras,
    Object? reconnectingSince = _keep,
  }) =>
      ConsoleState(
        phase: phase ?? this.phase,
        token: token ?? this.token,
        message: identical(message, _keep) ? this.message : message as String?,
        notOpen: notOpen ?? this.notOpen,
        access: identical(access, _keep) ? this.access : access as MediaAccess?,
        asking: asking ?? this.asking,
        mic: mic ?? this.mic,
        camera: camera ?? this.camera,
        console: console ?? this.console,
        cameras: cameras ?? this.cameras,
        reconnectingSince: identical(reconnectingSince, _keep) ? this.reconnectingSince : reconnectingSince as DateTime?,
      );

  @override
  List<Object?> get props => <Object?>[phase, token?.token, message, notOpen, access, asking, mic, camera, console, cameras, reconnectingSince];
}

/// The instructor's live class console on the phone (spec 013 §4; spec 014 §8 "The class room" 4): a check of camera
/// and microphone before, Start inside the join window, her video and audio to everyone, mic and camera toggles, the
/// count present, who joined, the phase count only as the server gives it (5 or more present, spec 013 AC5), the
/// cameras students chose to turn on, and End. She cannot turn a student's camera or microphone on (spec 013 AC21):
/// she only receives what a student sends.
class ClassConsoleCubit extends Cubit<ConsoleState> {
  ClassConsoleCubit({
    required InstructorRepository repository,
    required VideoEngineFactory engines,
    required DevicePermissions permissions,
    required this.classId,
    DateTime Function()? clock,
    this.pollEvery = const Duration(seconds: 10),
  })  : _repo = repository,
        _engines = engines,
        _permissions = permissions,
        _clock = clock ?? DateTime.now,
        super(const ConsoleState());

  final InstructorRepository _repo;
  final VideoEngineFactory _engines;
  final DevicePermissions _permissions;
  final String classId;
  final DateTime Function() _clock;

  /// How often the console and the students' cameras are read again while live; null for never (tests).
  final Duration? pollEvery;
  VideoEngine? _engine;
  StreamSubscription<VideoEvent>? _sub;
  Timer? _poll;

  VideoEngine? get engine => _engine;

  Future<void> start() async {
    emit(state.copyWith(phase: ConsolePhase.loading));
    try {
      emit(state.copyWith(console: await _repo.console(classId)));
    } on Object {
      // The console adds the counts; the room stands without them.
    }
    await _ask(ConsolePhase.preview);
  }

  Future<ChannelToken?> _ask(ConsolePhase then) async {
    final ClassRoomAccess r;
    try {
      r = await _repo.classRoomToken(classId);
    } on Object {
      emit(state.copyWith(phase: ConsolePhase.error, message: null));
      return null;
    }
    switch (r) {
      case ClassRoomReady(:final ChannelToken token):
        emit(state.copyWith(phase: then, token: token, message: null, notOpen: false));
        return token;
      case ClassRoomShut(:final String message, :final bool notOpen):
        emit(state.copyWith(phase: ConsolePhase.shut, message: message, notOpen: notOpen));
        return null;
    }
  }

  Future<VideoEngine> _ready(String appId) async {
    VideoEngine? e = _engine;
    if (e == null) {
      e = _engines();
      _engine = e;
      _sub = e.events.listen(_on);
    }
    await e.initialize(appId);
    return e;
  }

  /// The pre-class check (spec 013 §4.1): permissions, then her preview.
  Future<void> allowDevices() async {
    final ChannelToken? t = state.token;
    if (t == null || state.asking) return;
    emit(state.copyWith(asking: true));
    final MediaAccess access = await _permissions.request();
    emit(state.copyWith(asking: false, access: access, camera: access == MediaAccess.granted, mic: access != MediaAccess.denied));
    if (access == MediaAccess.denied) return;
    try {
      final VideoEngine e = await _ready(t.appId);
      if (access == MediaAccess.granted) await e.startPreview();
    } on Object {
      emit(state.copyWith(phase: ConsolePhase.error));
    }
  }

  Future<void> openSettings() => _permissions.openSettings();

  Future<void> toggleMic() async {
    if (state.access == null || state.access == MediaAccess.denied) return;
    emit(state.copyWith(mic: !state.mic));
    await _quietly(() => _engine?.setMicrophoneMuted(!state.mic));
  }

  Future<void> toggleCamera() async {
    if (state.access != MediaAccess.granted) return;
    emit(state.copyWith(camera: !state.camera));
    await _quietly(() => _engine?.setCameraOn(state.cameraOn));
    if (state.cameraOn && state.phase == ConsolePhase.preview) await _quietly(() => _engine?.startPreview());
  }

  Future<void> switchCamera() => _quietly(() => _engine?.switchCamera());

  /// Starts the class (once) and joins as the one who sends (§8.2).
  Future<void> startClass() async {
    if (state.phase != ConsolePhase.preview && state.phase != ConsolePhase.dropped && state.phase != ConsolePhase.left) return;
    emit(state.copyWith(phase: ConsolePhase.starting, reconnectingSince: null, cameras: const <String, int?>{}));
    try {
      if (state.console.str('status') != 'live') await _repo.startClass(classId);
    } on ApiException catch (e) {
      emit(state.copyWith(phase: ConsolePhase.preview, message: e.message));
      return;
    } on Object {
      emit(state.copyWith(phase: ConsolePhase.error));
      return;
    }
    final ChannelToken? t = await _ask(ConsolePhase.starting);
    if (t == null) return;
    try {
      final VideoEngine e = await _ready(t.appId);
      await e.join(channel: t.channel, token: t.token, uid: t.uid, camera: state.cameraOn, microphone: state.access != null && state.access != MediaAccess.denied);
      await e.setMicrophoneMuted(!state.mic);
    } on Object {
      emit(state.copyWith(phase: ConsolePhase.error));
      return;
    }
    await refresh();
    final Duration? every = pollEvery;
    _poll?.cancel();
    if (every != null) _poll = Timer.periodic(every, (_) => unawaited(refresh()));
  }

  /// Reads the console again, and watches each student camera that is on (AC43); stops watching those turned off.
  Future<void> refresh() async {
    try {
      final Json c = await _repo.console(classId);
      if (!isClosed) emit(state.copyWith(console: c));
    } on Object {
      // Shown again on the next read.
    }
    final VideoEngine? e = _engine;
    final ChannelToken? main = state.token;
    if (e == null || main == null || !state.inClass && state.phase != ConsolePhase.starting) return;
    try {
      final List<ChannelToken> cams = await _repo.cameraTokens(classId, appId: main.appId);
      final Map<String, int?> next = <String, int?>{};
      for (final ChannelToken c in cams) {
        if (!state.cameras.containsKey(c.channel)) await e.joinExtra(channel: c.channel, token: c.token, uid: c.uid, send: false, receive: true);
        next[c.channel] = state.cameras[c.channel];
      }
      for (final String gone in state.cameras.keys.where((String k) => !next.containsKey(k))) {
        await e.leaveExtra(gone);
      }
      if (!isClosed) emit(state.copyWith(cameras: next));
    } on Object {
      // Students' cameras come back on the next read.
    }
  }

  void _on(VideoEvent ev) {
    if (isClosed) return;
    final String? main = state.token?.channel;
    if (ev.channel != main) {
      // A student's camera channel: her uid, once her video arrives.
      if (state.cameras.containsKey(ev.channel)) {
        if (ev is VideoRemoteJoined) emit(state.copyWith(cameras: <String, int?>{...state.cameras, ev.channel: ev.uid}));
        if (ev is VideoRemoteLeft) emit(state.copyWith(cameras: <String, int?>{...state.cameras, ev.channel: null}));
      }
      return;
    }
    switch (ev) {
      case VideoJoined():
        if (state.phase == ConsolePhase.starting) emit(state.copyWith(phase: ConsolePhase.live));
      case VideoLinkChanged(:final VideoLink link, :final bool byLeaving):
        if (!state.inClass) return;
        if (link == VideoLink.reconnecting && state.phase != ConsolePhase.reconnecting) emit(state.copyWith(phase: ConsolePhase.reconnecting, reconnectingSince: _clock()));
        if (link == VideoLink.connected) emit(state.copyWith(phase: ConsolePhase.live, reconnectingSince: null));
        if (link == VideoLink.failed || (link == VideoLink.disconnected && !byLeaving)) unawaited(_drop());
      case VideoTokenExpiring():
        unawaited(_renew());
      case VideoRemoteJoined() || VideoRemoteLeft() || VideoRemoteVideo() || VideoQuality() || VideoMicLevel() || VideoProbe():
        break;
    }
  }

  Future<void> _renew() async {
    try {
      final ClassRoomAccess r = await _repo.classRoomToken(classId);
      if (r is ClassRoomReady) {
        emit(state.copyWith(token: r.token));
        await _engine?.renewToken(r.token.channel, r.token.token);
      }
    } on Object {
      // The old token works until the room closes.
    }
  }

  Future<void> _drop() async {
    _poll?.cancel();
    emit(state.copyWith(phase: ConsolePhase.dropped, cameras: const <String, int?>{}, reconnectingSince: null));
    await _quietly(() => _engine?.leave());
  }

  /// Called once a second: after two minutes of reconnecting she rejoins by hand (spec 014 §5 "During" 3).
  Future<void> tick() async {
    final DateTime? since = state.reconnectingSince;
    if (!isClosed && state.phase == ConsolePhase.reconnecting && since != null && !_clock().isBefore(since.add(const Duration(minutes: 2)))) await _drop();
  }

  /// Ends the class for everyone; attendance and earnings follow from the room record on the server (AC46).
  Future<Object?> endClass() async {
    try {
      await _repo.endClass(classId);
    } on Object catch (e) {
      return e;
    }
    _poll?.cancel();
    await _quietly(() => _engine?.leave());
    emit(state.copyWith(phase: ConsolePhase.ended, cameras: const <String, int?>{}));
    return null;
  }

  /// Leaves without ending; she can come back while the room is open.
  Future<void> leave() async {
    _poll?.cancel();
    await _quietly(() => _engine?.leave());
    emit(state.copyWith(phase: ConsolePhase.left, cameras: const <String, int?>{}, reconnectingSince: null));
  }

  static Future<void> _quietly(Future<void>? Function() f) async {
    try {
      await f();
    } on Object {
      // A device that fails leaves the class going.
    }
  }

  @override
  Future<void> close() async {
    _poll?.cancel();
    await _sub?.cancel();
    final VideoEngine? e = _engine;
    _engine = null;
    if (e != null) await _quietly(e.dispose);
    return super.close();
  }
}
