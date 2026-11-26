import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/video/device_permissions.dart';
import '../../../core/video/video_engine.dart';
import '../domain/consults.dart';

/// Where she is in the room (spec 014 §5), the same steps as the web room (apps/web/src/features/room/state.ts).
enum RoomPhase {
  loading,

  /// Too early: the room opens at [ConsultRoomState.opensAt].
  notOpen,

  /// Closed, or not hers: [ConsultRoomState.message] says why.
  closed,

  /// The permission explanation and her camera preview (§5 "Entering" 3).
  preview,
  joining,

  /// In the room, the other person not there yet (§5 "Entering" 4).
  waiting,
  connected,

  /// The SDK is rejoining by itself (§5 "During" 3, AC25).
  reconnecting,

  /// The link dropped for good, or did not come back within [reconnectLimit]; she can rejoin by hand.
  dropped,
  left,
  error,
}

enum Network { good, poor }

/// Spec 014 §5 "During" 3: rejoining by itself for up to 2 minutes, then by hand.
const Duration reconnectLimit = Duration(minutes: 2);

/// Quality samples in a row before the network state changes; the SDK reports about every 2 seconds, so the offer
/// does not flicker.
const int qualityRun = 3;

/// Without the server's `closesAt`: the scheduled end plus the overrun grace (spec 014 settings, default 10 minutes).
const Duration defaultGrace = Duration(minutes: 10);

sealed class RoomTimer {
  const RoomTimer();
}

class TimerRunning extends RoomTimer {
  const TimerRunning(this.remaining);
  final Duration remaining;
}

/// After the scheduled end, within the grace time (§5 "During" 6).
class TimerTimeUp extends RoomTimer {
  const TimerTimeUp(this.closesIn);
  final Duration closesIn;
}

class TimerClosed extends RoomTimer {
  const TimerClosed();
}

/// Time left to the scheduled end, then "time is up" until the room closes. The server's [closesAt] is the authority
/// (it is cut short by the clinician's next appointment).
RoomTimer roomTimer(DateTime now, DateTime endsAt, DateTime? closesAt) {
  final DateTime closes = closesAt ?? endsAt.add(defaultGrace);
  if (!now.isBefore(closes)) return const TimerClosed();
  if (!now.isBefore(endsAt)) return TimerTimeUp(closes.difference(now));
  return TimerRunning(endsAt.difference(now));
}

/// "mm:ss", or "h:mm:ss" past an hour; never negative.
String clockText(Duration d) {
  final int total = d.isNegative ? 0 : (d.inMilliseconds / 1000).ceil();
  String two(int n) => n.toString().padLeft(2, '0');
  final int h = total ~/ 3600;
  final int m = (total % 3600) ~/ 60;
  final int s = total % 60;
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

const Object _keep = Object();

class ConsultRoomState extends Equatable {
  const ConsultRoomState({
    this.phase = RoomPhase.loading,
    this.appointment,
    this.room,
    this.access,
    this.asking = false,
    this.mic = true,
    this.camera = true,
    this.audioOnly = false,
    this.remoteUid,
    this.remoteVideo = false,
    this.network = Network.good,
    this.poorRun = 0,
    this.goodRun = 0,
    this.message,
    this.opensAt,
    this.recordingStopped = false,
    this.closedByTime = false,
    this.reconnectingSince,
  });

  final RoomPhase phase;
  final Appointment? appointment;

  /// The last token the server gave: the channel, the vendor's app id, when the room closes, the recording flag.
  final RoomReady? room;

  /// Null until she has been asked.
  final MediaAccess? access;
  final bool asking;

  /// Her choices. The camera is also off while audio only is on.
  final bool mic;
  final bool camera;
  final bool audioOnly;
  final int? remoteUid;
  final bool remoteVideo;
  final Network network;
  final int poorRun;
  final int goodRun;
  final String? message;
  final DateTime? opensAt;
  final bool recordingStopped;

  /// She was taken out because the room closed (§5 "During" 6).
  final bool closedByTime;
  final DateTime? reconnectingSince;

  bool get inCall => phase == RoomPhase.waiting || phase == RoomPhase.connected || phase == RoomPhase.reconnecting;

  /// Is her camera actually sending?
  bool get cameraOn => access == MediaAccess.granted && camera && !audioOnly;

  /// The recording mark, for as long as the server says recording runs and she has not stopped it (AC51, AC52).
  bool get recording => (room?.recording ?? appointment?.recording ?? false) && !recordingStopped;

  /// The member is offered audio only when the link stays weak (§5 "During" 2).
  bool get offerAudioOnly => network == Network.poor && !audioOnly && inCall;

  ConsultRoomState copyWith({
    RoomPhase? phase,
    Appointment? appointment,
    RoomReady? room,
    Object? access = _keep,
    bool? asking,
    bool? mic,
    bool? camera,
    bool? audioOnly,
    Object? remoteUid = _keep,
    bool? remoteVideo,
    Network? network,
    int? poorRun,
    int? goodRun,
    Object? message = _keep,
    Object? opensAt = _keep,
    bool? recordingStopped,
    bool? closedByTime,
    Object? reconnectingSince = _keep,
  }) =>
      ConsultRoomState(
        phase: phase ?? this.phase,
        appointment: appointment ?? this.appointment,
        room: room ?? this.room,
        access: identical(access, _keep) ? this.access : access as MediaAccess?,
        asking: asking ?? this.asking,
        mic: mic ?? this.mic,
        camera: camera ?? this.camera,
        audioOnly: audioOnly ?? this.audioOnly,
        remoteUid: identical(remoteUid, _keep) ? this.remoteUid : remoteUid as int?,
        remoteVideo: remoteVideo ?? this.remoteVideo,
        network: network ?? this.network,
        poorRun: poorRun ?? this.poorRun,
        goodRun: goodRun ?? this.goodRun,
        message: identical(message, _keep) ? this.message : message as String?,
        opensAt: identical(opensAt, _keep) ? this.opensAt : opensAt as DateTime?,
        recordingStopped: recordingStopped ?? this.recordingStopped,
        closedByTime: closedByTime ?? this.closedByTime,
        reconnectingSince: identical(reconnectingSince, _keep) ? this.reconnectingSince : reconnectingSince as DateTime?,
      );

  @override
  List<Object?> get props => <Object?>[
        phase, appointment, room?.token, room?.channel, access, asking, mic, camera, audioOnly, remoteUid, remoteVideo, network, poorRun, goodRun, message, opensAt, //
        recordingStopped, closedByTime, reconnectingSince,
      ];
}

/// The member's consult room (spec 014 §5). The server gives the token, only to the two participants inside the join
/// window (AC20, AC21), and the same call renews it. Media goes to the video vendor only; nothing from the call, and no
/// chat, is sent to the API (§5 "Privacy" 2, AC27). [VideoEngine] events are fed in as they come, so every transition
/// is tested with a fake engine.
class ConsultRoomCubit extends Cubit<ConsultRoomState> {
  ConsultRoomCubit({required ConsultsRepository repository, required VideoEngineFactory engines, required DevicePermissions permissions, required this.appointmentId, DateTime Function()? clock})
      : _repo = repository,
        _engines = engines,
        _permissions = permissions,
        _clock = clock ?? DateTime.now,
        super(const ConsultRoomState());

  final ConsultsRepository _repo;
  final VideoEngineFactory _engines;
  final DevicePermissions _permissions;
  final String appointmentId;
  final DateTime Function() _clock;
  VideoEngine? _engine;
  StreamSubscription<VideoEvent>? _sub;

  DateTime get now => _clock();

  /// The engine, once she has allowed her devices, for the screen's video views.
  VideoEngine? get engine => _engine;

  RoomTimer? get timer {
    final Appointment? a = state.appointment;
    return a == null ? null : roomTimer(now, a.endsAt, state.room?.closesAt);
  }

  /// Reads the appointment and asks for a token: ready, not open yet, or closed.
  Future<void> start() async {
    emit(state.copyWith(phase: RoomPhase.loading, message: null));
    try {
      final Appointment a = await _repo.appointment(appointmentId);
      emit(state.copyWith(appointment: a));
    } on Object {
      emit(state.copyWith(phase: RoomPhase.error, message: null));
      return;
    }
    await _askToken(then: RoomPhase.preview);
  }

  Future<RoomReady?> _askToken({required RoomPhase then}) async {
    final RoomAccess r;
    try {
      r = await _repo.roomToken(appointmentId);
    } on Object {
      emit(state.copyWith(phase: RoomPhase.error, message: null));
      return null;
    }
    switch (r) {
      case RoomReady():
        emit(state.copyWith(phase: then, room: r, opensAt: null, message: null));
        return r;
      case RoomNotOpen(:final DateTime? opensAt, :final String message):
        emit(state.copyWith(phase: RoomPhase.notOpen, opensAt: opensAt, message: message));
      case RoomClosed(:final String message) || RoomUnavailable(:final String message):
        emit(state.copyWith(phase: RoomPhase.closed, message: message));
    }
    return null;
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

  /// After the plain explanation: asks for camera and microphone, then shows her preview (§5 "Entering" 3).
  Future<void> allowDevices() async {
    final RoomReady? room = state.room;
    if (room == null || state.asking) return;
    emit(state.copyWith(asking: true));
    final MediaAccess access = await _permissions.request();
    final bool camera = access == MediaAccess.granted && state.camera;
    emit(state.copyWith(asking: false, access: access, camera: access == MediaAccess.granted ? state.camera : false, mic: access == MediaAccess.denied ? false : state.mic));
    if (access == MediaAccess.denied) return;
    try {
      final VideoEngine e = await _ready(room.appId);
      if (camera) await e.startPreview();
    } on Object {
      emit(state.copyWith(phase: RoomPhase.error, message: null));
    }
  }

  Future<void> openSettings() => _permissions.openSettings();

  Future<void> toggleMic() async {
    if (state.access == null || state.access == MediaAccess.denied) return;
    final bool mic = !state.mic;
    emit(state.copyWith(mic: mic));
    await _quietly(() => _engine?.setMicrophoneMuted(!mic));
  }

  /// No camera without permission, and none while audio only is on.
  Future<void> toggleCamera() async {
    if (state.access != MediaAccess.granted || state.audioOnly) return;
    emit(state.copyWith(camera: !state.camera));
    await _quietly(() => _engine?.setCameraOn(state.cameraOn));
    if (state.cameraOn && state.phase == RoomPhase.preview) await _quietly(() => _engine?.startPreview());
  }

  Future<void> switchCamera() => _quietly(() => _engine?.switchCamera());

  bool get canJoin => state.phase == RoomPhase.preview || state.phase == RoomPhase.dropped || (state.phase == RoomPhase.error && state.room != null);

  /// Joins with a fresh token. The call starts in "waiting" until the other person is there (§5 "Entering" 4).
  Future<void> join() async {
    if (!canJoin) return;
    emit(state.copyWith(phase: RoomPhase.joining, message: null, remoteUid: null, remoteVideo: false, reconnectingSince: null));
    final RoomReady? room = await _askToken(then: RoomPhase.joining);
    if (room == null) return;
    try {
      final VideoEngine e = await _ready(room.appId);
      await e.join(channel: room.channel, token: room.token, uid: room.uid, camera: state.cameraOn, microphone: state.access != null && state.access != MediaAccess.denied);
      await e.setMicrophoneMuted(!state.mic);
      // The SDK's own join callback moves her on; a join without one stays "joining" until it comes.
    } on Object {
      emit(state.copyWith(phase: RoomPhase.error, message: null));
    }
  }

  void _on(VideoEvent ev) {
    if (isClosed) return;
    final String? main = state.room?.channel;
    if (ev.channel.isNotEmpty && ev.channel != main) return;
    switch (ev) {
      case VideoJoined():
        if (state.phase == RoomPhase.joining) emit(state.copyWith(phase: state.remoteUid != null ? RoomPhase.connected : RoomPhase.waiting));
      case VideoRemoteJoined(:final int uid):
        emit(state.copyWith(remoteUid: uid, phase: state.phase == RoomPhase.waiting ? RoomPhase.connected : state.phase));
      case VideoRemoteLeft(:final int uid):
        if (state.remoteUid == uid) emit(state.copyWith(remoteUid: null, remoteVideo: false, phase: state.phase == RoomPhase.connected ? RoomPhase.waiting : state.phase));
      case VideoRemoteVideo(:final int uid, :final bool on):
        if (state.remoteUid == null || state.remoteUid == uid) emit(state.copyWith(remoteUid: uid, remoteVideo: on && !state.audioOnly));
      case VideoLinkChanged(:final VideoLink link, :final bool byLeaving):
        _link(link, byLeaving);
      case VideoQuality(:final int uplink, :final int downlink):
        _quality(uplink, downlink);
      case VideoTokenExpiring():
        unawaited(_renew());
      case VideoMicLevel() || VideoProbe():
        break;
    }
  }

  void _link(VideoLink link, bool byLeaving) {
    if (!state.inCall) return;
    switch (link) {
      case VideoLink.reconnecting:
        // AC25: the SDK rejoins by itself; she only sees that it is happening.
        if (state.phase != RoomPhase.reconnecting) emit(state.copyWith(phase: RoomPhase.reconnecting, reconnectingSince: now));
      case VideoLink.connected:
        emit(state.copyWith(phase: state.remoteUid != null ? RoomPhase.connected : RoomPhase.waiting, reconnectingSince: null));
      case VideoLink.failed:
        _drop();
      case VideoLink.disconnected:
        if (!byLeaving) _drop();
      case VideoLink.connecting:
        break;
    }
  }

  void _drop() {
    emit(state.copyWith(phase: RoomPhase.dropped, remoteUid: null, remoteVideo: false, reconnectingSince: null));
    unawaited(_quietly(() => _engine?.leave()));
  }

  void _quality(int up, int down) {
    // Unknown (0) says nothing either way.
    if (up == 0 && down == 0) return;
    final bool poor = isPoorQuality(up) || isPoorQuality(down);
    final int poorRun = poor ? state.poorRun + 1 : 0;
    final int goodRun = poor ? 0 : state.goodRun + 1;
    final Network network = poorRun >= qualityRun ? Network.poor : (goodRun >= qualityRun ? Network.good : state.network);
    emit(state.copyWith(poorRun: poorRun, goodRun: goodRun, network: network));
  }

  /// Renewal is the same call as the first token, still bound to the join window (plan 014 "Rooms").
  Future<void> _renew() async {
    try {
      final RoomAccess r = await _repo.roomToken(appointmentId);
      if (r is RoomReady) {
        emit(state.copyWith(room: r));
        await _engine?.renewToken(r.channel, r.token);
      }
    } on Object {
      // The old token still works until it expires; the room's close then takes her out.
    }
  }

  /// Audio only: her camera off and the other side's video paused; the call goes on by voice (AC24).
  Future<void> setAudioOnly(bool on) async {
    emit(state.copyWith(audioOnly: on, remoteVideo: on ? false : state.remoteVideo));
    final VideoEngine? e = _engine;
    final int? uid = state.remoteUid;
    final String? channel = state.room?.channel;
    if (e == null) return;
    await _quietly(() => e.setCameraOn(state.cameraOn));
    if (uid != null && channel != null) await _quietly(() => e.setRemoteVideoMuted(channel, uid, on));
  }

  /// Called once a second by the screen: closes the call when the room closes (§5 "During" 6), and stops waiting for
  /// the SDK after [reconnectLimit] so she can rejoin by hand (§5 "During" 3).
  Future<void> tick() async {
    if (isClosed) return;
    final RoomTimer? t = timer;
    if (t is TimerClosed && (state.inCall || state.phase == RoomPhase.joining)) {
      await leave(closed: true);
      return;
    }
    final DateTime? since = state.reconnectingSince;
    if (state.phase == RoomPhase.reconnecting && since != null && !now.isBefore(since.add(reconnectLimit))) _drop();
  }

  Future<void> leave({bool closed = false}) async {
    await _quietly(() => _engine?.leave());
    emit(state.copyWith(phase: RoomPhase.left, remoteUid: null, remoteVideo: false, closedByTime: closed, reconnectingSince: null));
  }

  /// After leaving, back to the preview while the room is open.
  void reenter() {
    if (state.phase != RoomPhase.left || timer is TimerClosed) return;
    emit(state.copyWith(phase: RoomPhase.preview, network: Network.good, poorRun: 0, goodRun: 0, audioOnly: false));
  }

  /// She stops the recording; what was recorded is kept as partial (§5 "Recording" 5, AC52). Returns the error, if any.
  Future<Object?> stopRecording() async {
    try {
      await _repo.stopRecording(appointmentId);
      emit(state.copyWith(recordingStopped: true));
      return null;
    } on Object catch (e) {
      return e;
    }
  }

  static Future<void> _quietly(Future<void>? Function() f) async {
    try {
      await f();
    } on Object {
      // A device that fails mid-call leaves the call going by voice.
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    final VideoEngine? e = _engine;
    _engine = null;
    if (e != null) await _quietly(e.dispose);
    return super.close();
  }
}
