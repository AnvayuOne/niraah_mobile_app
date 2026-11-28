import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:material_ui/material_ui.dart';

/// What the room needs from a video engine. The room screen talks to this, so it can be tested with a fake
/// engine (the real one needs a camera, a microphone and the video service).
abstract class CallEngine {
  /// Events from the call: the other person joining or leaving, their camera, the connection, token expiry.
  Stream<CallEvent> get events;

  Future<void> start(String appId);
  Future<void> join({required String token, required String channel, required int uid});
  Future<void> renewToken(String token);
  Future<void> setMicOn(bool on);
  Future<void> setCameraOn(bool on);
  Future<void> flipCamera();
  Future<void> setSpeakerOn(bool on);
  Future<void> leave();
  Future<void> dispose();

  /// Her own camera.
  Widget localView();

  /// The other person's video.
  Widget remoteView(int uid, String channel);
}

sealed class CallEvent {
  const CallEvent();
}

class JoinedCall extends CallEvent {
  const JoinedCall();
}

class OtherJoined extends CallEvent {
  const OtherJoined(this.uid);
  final int uid;
}

class OtherLeft extends CallEvent {
  const OtherLeft(this.uid);
  final int uid;
}

class OtherCamera extends CallEvent {
  const OtherCamera(this.uid, {required this.on});
  final int uid;
  final bool on;
}

class OtherMic extends CallEvent {
  const OtherMic(this.uid, {required this.on});
  final int uid;
  final bool on;
}

/// Lost or regained the connection to the call.
class ConnectionChanged extends CallEvent {
  const ConnectionChanged({required this.reconnecting});
  final bool reconnecting;
}

/// The video token runs out soon: the room asks the server for a new one.
class TokenExpiring extends CallEvent {
  const TokenExpiring();
}

class CallFailed extends CallEvent {
  const CallFailed(this.message);
  final String message;
}

/// The Agora engine (the project's video service, the same as the website's rooms).
class AgoraCallEngine implements CallEngine {
  RtcEngine? _engine;
  final StreamController<CallEvent> _events = StreamController<CallEvent>.broadcast();

  @override
  Stream<CallEvent> get events => _events.stream;

  void _emit(CallEvent e) {
    if (!_events.isClosed) _events.add(e);
  }

  @override
  Future<void> start(String appId) async {
    final RtcEngine engine = createAgoraRtcEngine();
    _engine = engine;
    await engine.initialize(RtcEngineContext(appId: appId, channelProfile: ChannelProfileType.channelProfileCommunication));
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection _, int _) => _emit(const JoinedCall()),
        onUserJoined: (RtcConnection _, int uid, int _) => _emit(OtherJoined(uid)),
        onUserOffline: (RtcConnection _, int uid, UserOfflineReasonType _) => _emit(OtherLeft(uid)),
        onRemoteVideoStateChanged: (RtcConnection _, int uid, RemoteVideoState state, RemoteVideoStateReason _, int _) {
          if (state == RemoteVideoState.remoteVideoStateStopped) _emit(OtherCamera(uid, on: false));
          if (state == RemoteVideoState.remoteVideoStateDecoding || state == RemoteVideoState.remoteVideoStateStarting) _emit(OtherCamera(uid, on: true));
        },
        onUserMuteAudio: (RtcConnection _, int uid, bool muted) => _emit(OtherMic(uid, on: !muted)),
        onConnectionStateChanged: (RtcConnection _, ConnectionStateType state, ConnectionChangedReasonType _) {
          if (state == ConnectionStateType.connectionStateReconnecting) _emit(const ConnectionChanged(reconnecting: true));
          if (state == ConnectionStateType.connectionStateConnected) _emit(const ConnectionChanged(reconnecting: false));
        },
        onTokenPrivilegeWillExpire: (RtcConnection _, String _) => _emit(const TokenExpiring()),
        onError: (ErrorCodeType err, String msg) {
          if (err == ErrorCodeType.errInvalidToken || err == ErrorCodeType.errTokenExpired) _emit(const TokenExpiring());
        },
      ),
    );
    await engine.enableVideo();
    await engine.startPreview();
  }

  @override
  Future<void> join({required String token, required String channel, required int uid}) async {
    await _engine?.joinChannel(
      token: token,
      channelId: channel,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
    await _engine?.setEnableSpeakerphone(true);
  }

  @override
  Future<void> renewToken(String token) async => _engine?.renewToken(token);

  @override
  Future<void> setMicOn(bool on) async => _engine?.muteLocalAudioStream(!on);

  @override
  Future<void> setCameraOn(bool on) async {
    await _engine?.muteLocalVideoStream(!on);
    await _engine?.enableLocalVideo(on);
  }

  @override
  Future<void> flipCamera() async => _engine?.switchCamera();

  @override
  Future<void> setSpeakerOn(bool on) async => _engine?.setEnableSpeakerphone(on);

  @override
  Future<void> leave() async {
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    final RtcEngine? engine = _engine;
    _engine = null;
    await _events.close();
    if (engine == null) return;
    try {
      await engine.leaveChannel();
    } catch (_) {}
    await engine.release();
  }

  @override
  Widget localView() {
    final RtcEngine? engine = _engine;
    if (engine == null) return const SizedBox.shrink();
    return AgoraVideoView(controller: VideoViewController(rtcEngine: engine, canvas: const VideoCanvas(uid: 0)));
  }

  @override
  Widget remoteView(int uid, String channel) {
    final RtcEngine? engine = _engine;
    if (engine == null) return const SizedBox.shrink();
    return AgoraVideoView(
      controller: VideoViewController.remote(rtcEngine: engine, canvas: VideoCanvas(uid: uid), connection: RtcConnection(channelId: channel)),
    );
  }
}
