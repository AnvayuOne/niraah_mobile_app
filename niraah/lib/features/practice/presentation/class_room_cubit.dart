import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/video/device_permissions.dart';
import '../../../core/video/video_engine.dart';
import '../domain/practice.dart';

enum ClassRoomPhase { loading, shut, ready, joining, waiting, live, reconnecting, dropped, left, error }

/// Spec 014 §5 "During" 3, applied to classes by §8.8: rejoining by itself for up to 2 minutes, then by hand.
const Duration classReconnectLimit = Duration(minutes: 2);

const Object _keep = Object();

class ClassRoomState extends Equatable {
  const ClassRoomState({
    this.phase = ClassRoomPhase.loading,
    this.token,
    this.message,
    this.notOpen = false,
    this.instructorUid,
    this.instructorVideo = false,
    this.camera,
    this.cameraBusy = false,
    this.cameraRefused = false,
    this.reconnectingSince,
  });

  final ClassRoomPhase phase;
  final ChannelToken? token;
  final String? message;
  final bool notOpen;
  final int? instructorUid;
  final bool instructorVideo;

  /// Her private camera channel while she shows her camera to the instructor (§8.3).
  final ChannelToken? camera;
  final bool cameraBusy;
  final bool cameraRefused;
  final DateTime? reconnectingSince;

  bool get inClass => phase == ClassRoomPhase.waiting || phase == ClassRoomPhase.live || phase == ClassRoomPhase.reconnecting;
  bool get sharingCamera => camera != null;

  ClassRoomState copyWith({
    ClassRoomPhase? phase,
    ChannelToken? token,
    Object? message = _keep,
    bool? notOpen,
    Object? instructorUid = _keep,
    bool? instructorVideo,
    Object? camera = _keep,
    bool? cameraBusy,
    bool? cameraRefused,
    Object? reconnectingSince = _keep,
  }) =>
      ClassRoomState(
        phase: phase ?? this.phase,
        token: token ?? this.token,
        message: identical(message, _keep) ? this.message : message as String?,
        notOpen: notOpen ?? this.notOpen,
        instructorUid: identical(instructorUid, _keep) ? this.instructorUid : instructorUid as int?,
        instructorVideo: instructorVideo ?? this.instructorVideo,
        camera: identical(camera, _keep) ? this.camera : camera as ChannelToken?,
        cameraBusy: cameraBusy ?? this.cameraBusy,
        cameraRefused: cameraRefused ?? this.cameraRefused,
        reconnectingSince: identical(reconnectingSince, _keep) ? this.reconnectingSince : reconnectingSince as DateTime?,
      );

  @override
  List<Object?> get props => <Object?>[phase, token?.token, message, notOpen, instructorUid, instructorVideo, camera?.channel, cameraBusy, cameraRefused, reconnectingSince];
}

/// A member in a live class (spec 014 §8 "The class room"). She joins the main channel as audience, with camera and
/// microphone off, and sees and hears only the instructor. Turning her camera on joins a private channel that only she
/// and the instructor may join, so no member receives another member's media or name (AC43). The tokens enforce
/// that, not this app. Classes are never recorded.
class ClassRoomCubit extends Cubit<ClassRoomState> {
  ClassRoomCubit({required PracticeRepository repository, required VideoEngineFactory engines, required DevicePermissions permissions, required this.classId, DateTime Function()? clock})
      : _repo = repository,
        _engines = engines,
        _permissions = permissions,
        _clock = clock ?? DateTime.now,
        super(const ClassRoomState());

  final PracticeRepository _repo;
  final VideoEngineFactory _engines;
  final DevicePermissions _permissions;
  final String classId;
  final DateTime Function() _clock;
  VideoEngine? _engine;
  StreamSubscription<VideoEvent>? _sub;

  VideoEngine? get engine => _engine;

  Future<ChannelToken?> _ask(ClassRoomPhase then) async {
    final ClassRoomAccess r;
    try {
      r = await _repo.roomToken(classId);
    } on Object {
      emit(state.copyWith(phase: ClassRoomPhase.error, message: null));
      return null;
    }
    switch (r) {
      case ClassRoomReady(:final ChannelToken token):
        emit(state.copyWith(phase: then, token: token, message: null, notOpen: false));
        return token;
      case ClassRoomShut(:final String message, :final bool notOpen):
        emit(state.copyWith(phase: ClassRoomPhase.shut, message: message, notOpen: notOpen));
        return null;
    }
  }

  Future<void> start() async {
    emit(state.copyWith(phase: ClassRoomPhase.loading));
    await _ask(ClassRoomPhase.ready);
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

  bool get canJoin => state.phase == ClassRoomPhase.ready || state.phase == ClassRoomPhase.dropped || state.phase == ClassRoomPhase.left || (state.phase == ClassRoomPhase.error && state.token != null);

  /// Joins as audience: nothing of hers is sent (§8.2).
  Future<void> join() async {
    if (!canJoin) return;
    emit(state.copyWith(phase: ClassRoomPhase.joining, instructorUid: null, instructorVideo: false, reconnectingSince: null));
    final ChannelToken? t = await _ask(ClassRoomPhase.joining);
    if (t == null) return;
    try {
      final VideoEngine e = await _ready(t.appId);
      await e.join(channel: t.channel, token: t.token, uid: t.uid, camera: false, microphone: false, audience: true);
    } on Object {
      emit(state.copyWith(phase: ClassRoomPhase.error, message: null));
    }
  }

  void _on(VideoEvent ev) {
    if (isClosed) return;
    final String? main = state.token?.channel;
    if (ev is VideoTokenExpiring) {
      unawaited(_renew(ev.channel));
      return;
    }
    if (ev.channel != main) return;
    switch (ev) {
      case VideoJoined():
        if (state.phase == ClassRoomPhase.joining) emit(state.copyWith(phase: state.instructorUid != null ? ClassRoomPhase.live : ClassRoomPhase.waiting));
      // Only the instructor sends on the main channel, so the one remote user there is her.
      case VideoRemoteJoined(:final int uid):
        emit(state.copyWith(instructorUid: uid, phase: state.phase == ClassRoomPhase.waiting ? ClassRoomPhase.live : state.phase));
      case VideoRemoteLeft(:final int uid):
        if (uid == state.instructorUid) emit(state.copyWith(instructorUid: null, instructorVideo: false, phase: state.phase == ClassRoomPhase.live ? ClassRoomPhase.waiting : state.phase));
      case VideoRemoteVideo(:final int uid, :final bool on):
        emit(state.copyWith(instructorUid: uid, instructorVideo: on));
      case VideoLinkChanged(:final VideoLink link, :final bool byLeaving):
        if (!state.inClass) return;
        if (link == VideoLink.reconnecting && state.phase != ClassRoomPhase.reconnecting) emit(state.copyWith(phase: ClassRoomPhase.reconnecting, reconnectingSince: _clock()));
        if (link == VideoLink.connected) emit(state.copyWith(phase: state.instructorUid != null ? ClassRoomPhase.live : ClassRoomPhase.waiting, reconnectingSince: null));
        if (link == VideoLink.failed || (link == VideoLink.disconnected && !byLeaving)) unawaited(_drop());
      case VideoTokenExpiring() || VideoQuality() || VideoMicLevel() || VideoProbe():
        break;
    }
  }

  Future<void> _renew(String channel) async {
    try {
      if (channel == state.camera?.channel) {
        final ChannelToken c = await _repo.cameraToken(classId);
        emit(state.copyWith(camera: c));
        await _engine?.renewToken(c.channel, c.token);
      } else {
        final ClassRoomAccess r = await _repo.roomToken(classId);
        if (r is ClassRoomReady) {
          emit(state.copyWith(token: r.token));
          await _engine?.renewToken(r.token.channel, r.token.token);
        }
      }
    } on Object {
      // The old token works until it expires; the room's close then takes her out.
    }
  }

  Future<void> _drop() async {
    await _stopCamera();
    emit(state.copyWith(phase: ClassRoomPhase.dropped, instructorUid: null, instructorVideo: false, reconnectingSince: null));
    try {
      await _engine?.leave();
    } on Object {
      // Already out.
    }
  }

  /// Called once a second by the screen: after [classReconnectLimit] she rejoins by hand.
  Future<void> tick() async {
    final DateTime? since = state.reconnectingSince;
    if (!isClosed && state.phase == ClassRoomPhase.reconnecting && since != null && !_clock().isBefore(since.add(classReconnectLimit))) await _drop();
  }

  /// Her camera to the instructor only (§8.3, AC43): a token for her private channel, then she sends there alone.
  Future<void> toggleCamera() async {
    if (state.cameraBusy || !state.inClass) return;
    if (state.sharingCamera) {
      emit(state.copyWith(cameraBusy: true));
      await _stopCamera();
      emit(state.copyWith(cameraBusy: false));
      return;
    }
    emit(state.copyWith(cameraBusy: true, cameraRefused: false));
    if (!await _permissions.requestCamera()) {
      emit(state.copyWith(cameraBusy: false, cameraRefused: true));
      return;
    }
    try {
      final ChannelToken c = await _repo.cameraToken(classId);
      final VideoEngine e = _engine!;
      await e.setCameraOn(true);
      await e.joinExtra(channel: c.channel, token: c.token, uid: c.uid, send: true, receive: false);
      emit(state.copyWith(camera: c, cameraBusy: false));
    } on Object {
      emit(state.copyWith(cameraBusy: false));
      try {
        await _engine?.setCameraOn(false);
      } on Object {
        // Nothing was sent.
      }
    }
  }

  Future<void> _stopCamera() async {
    final ChannelToken? c = state.camera;
    if (c == null) return;
    emit(state.copyWith(camera: null));
    try {
      await _engine?.leaveExtra(c.channel);
      await _engine?.setCameraOn(false);
    } on Object {
      // The channel closes with the room anyway.
    }
  }

  Future<void> leave() async {
    await _stopCamera();
    try {
      await _engine?.leave();
    } on Object {
      // Leaving is best effort.
    }
    emit(state.copyWith(phase: ClassRoomPhase.left, instructorUid: null, instructorVideo: false, reconnectingSince: null));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    final VideoEngine? e = _engine;
    _engine = null;
    if (e != null) {
      try {
        await e.dispose();
      } on Object {
        // Released anyway.
      }
    }
    return super.close();
  }
}
