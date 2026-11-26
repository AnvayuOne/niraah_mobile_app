import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:material_ui/material_ui.dart';

import 'video_engine.dart';

/// [VideoEngine] on Agora's Flutter SDK (decision D4). The only file in the app that imports the SDK.
///
/// - Main channel: live broadcasting profile, so a class member joins as audience and sends nothing (spec 014 §8.2);
///   in a consult both sides are broadcasters.
/// - Weak links: the sender also sends a low stream, and receiving falls back to the low stream, then audio only
///   (spec 014 §5 "During" 2, AC24). The SDK rejoins by itself after a drop (AC25); the cubits give up after two
///   minutes and offer rejoining by hand.
/// - Extra channels (`joinChannelEx`) carry a member's private camera to the instructor and the instructor's view of
///   each student's camera (AC43).
class AgoraVideoEngine implements VideoEngine {
  AgoraVideoEngine();

  RtcEngineEx? _engine;
  String? _appId;
  String? _main;
  int _uid = 0;
  final Map<String, RtcConnection> _extra = <String, RtcConnection>{};
  final StreamController<VideoEvent> _events = StreamController<VideoEvent>.broadcast();
  RtcEngineEventHandler? _handler;

  RtcEngineEx get _e => _engine ?? (throw StateError('Video engine not started'));

  @override
  Stream<VideoEvent> get events => _events.stream;

  String _channel(RtcConnection c) => c.channelId ?? _main ?? '';

  @override
  Future<void> initialize(String appId) async {
    if (_engine != null && _appId == appId) return;
    final RtcEngineEx e = createAgoraRtcEngineEx();
    await e.initialize(RtcEngineContext(appId: appId, channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
    _handler = RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection c, int _) => _events.add(VideoJoined(_channel(c))),
      onUserJoined: (RtcConnection c, int uid, int _) => _events.add(VideoRemoteJoined(_channel(c), uid)),
      onUserOffline: (RtcConnection c, int uid, UserOfflineReasonType _) => _events.add(VideoRemoteLeft(_channel(c), uid)),
      onRemoteVideoStateChanged: (RtcConnection c, int uid, RemoteVideoState state, RemoteVideoStateReason _, int _) {
        if (state == RemoteVideoState.remoteVideoStateDecoding || state == RemoteVideoState.remoteVideoStateStarting) {
          _events.add(VideoRemoteVideo(_channel(c), uid, on: true));
        } else if (state == RemoteVideoState.remoteVideoStateStopped || state == RemoteVideoState.remoteVideoStateFailed) {
          _events.add(VideoRemoteVideo(_channel(c), uid, on: false));
        }
      },
      onConnectionStateChanged: (RtcConnection c, ConnectionStateType state, ConnectionChangedReasonType reason) {
        final VideoLink link = switch (state) {
          ConnectionStateType.connectionStateConnecting => VideoLink.connecting,
          ConnectionStateType.connectionStateConnected => VideoLink.connected,
          ConnectionStateType.connectionStateReconnecting => VideoLink.reconnecting,
          ConnectionStateType.connectionStateFailed => VideoLink.failed,
          ConnectionStateType.connectionStateDisconnected => VideoLink.disconnected,
        };
        _events.add(VideoLinkChanged(_channel(c), link, byLeaving: reason == ConnectionChangedReasonType.connectionChangedLeaveChannel));
      },
      onNetworkQuality: (RtcConnection c, int uid, QualityType tx, QualityType rx) {
        // uid 0 is this device.
        if (uid == 0) _events.add(VideoQuality(_channel(c), uplink: tx.index, downlink: rx.index));
      },
      onTokenPrivilegeWillExpire: (RtcConnection c, String _) => _events.add(VideoTokenExpiring(_channel(c))),
      onAudioVolumeIndication: (RtcConnection c, List<AudioVolumeInfo> speakers, int _, int _) {
        for (final AudioVolumeInfo s in speakers) {
          if ((s.uid ?? 0) == 0) _events.add(VideoMicLevel(s.volume ?? 0));
        }
      },
      onLastmileQuality: (QualityType q) => _events.add(VideoProbe(q.index)),
    );
    e.registerEventHandler(_handler!);
    await e.enableVideo();
    // Video quality drops before the call does (AC24).
    await e.enableDualStreamMode(enabled: true);
    await e.setRemoteSubscribeFallbackOption(StreamFallbackOptions.streamFallbackOptionAudioOnly);
    _engine = e;
    _appId = appId;
  }

  @override
  Future<void> startPreview() async {
    await _e.enableLocalVideo(true);
    await _e.startPreview();
  }

  @override
  Future<void> stopPreview() => _e.stopPreview();

  @override
  Future<void> join({required String channel, required String token, required int uid, required bool camera, required bool microphone, bool audience = false}) async {
    _main = channel;
    _uid = uid;
    await _e.joinChannel(
      token: token,
      channelId: channel,
      uid: uid,
      options: ChannelMediaOptions(
        clientRoleType: audience ? ClientRoleType.clientRoleAudience : ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        publishCameraTrack: !audience && camera,
        publishMicrophoneTrack: !audience && microphone,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  @override
  Future<void> joinExtra({required String channel, required String token, required int uid, required bool send, required bool receive}) async {
    final RtcConnection c = RtcConnection(channelId: channel, localUid: uid);
    _extra[channel] = c;
    await _e.joinChannelEx(
      token: token,
      connection: c,
      options: ChannelMediaOptions(
        clientRoleType: send ? ClientRoleType.clientRoleBroadcaster : ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        publishCameraTrack: send,
        publishMicrophoneTrack: false,
        autoSubscribeAudio: false,
        autoSubscribeVideo: receive,
      ),
    );
  }

  @override
  Future<void> leaveExtra(String channel) async {
    final RtcConnection? c = _extra.remove(channel);
    if (c != null) await _e.leaveChannelEx(connection: c);
  }

  @override
  Future<void> renewToken(String channel, String token) async {
    final RtcConnection? c = _extra[channel];
    if (c != null) {
      await _e.updateChannelMediaOptionsEx(options: ChannelMediaOptions(token: token), connection: c);
    } else {
      await _e.renewToken(token);
    }
  }

  @override
  Future<void> setMicrophoneMuted(bool muted) => _e.muteLocalAudioStream(muted);

  @override
  Future<void> setCameraOn(bool on) async {
    await _e.enableLocalVideo(on);
    await _e.muteLocalVideoStream(!on);
  }

  @override
  Future<void> switchCamera() => _e.switchCamera();

  @override
  Future<void> setRemoteVideoMuted(String channel, int uid, bool muted) async {
    final RtcConnection? c = _extra[channel];
    if (c != null) {
      await _e.muteRemoteVideoStreamEx(uid: uid, mute: muted, connection: c);
    } else {
      await _e.muteRemoteVideoStream(uid: uid, mute: muted);
    }
  }

  @override
  Future<void> leave() async {
    _extra.clear();
    await _engine?.leaveChannel();
  }

  @override
  Future<void> startMicrophoneTest() async {
    await _e.enableAudioVolumeIndication(interval: 300, smooth: 3, reportVad: false);
    await _e.getAudioDeviceManager().startRecordingDeviceTest(300);
  }

  @override
  Future<void> stopMicrophoneTest() => _e.getAudioDeviceManager().stopRecordingDeviceTest();

  @override
  Future<void> startConnectionTest() => _e.startLastmileProbeTest(const LastmileProbeConfig(probeUplink: true, probeDownlink: true, expectedUplinkBitrate: 500000, expectedDownlinkBitrate: 500000));

  @override
  Future<void> stopConnectionTest() => _e.stopLastmileProbeTest();

  @override
  Future<void> dispose() async {
    final RtcEngineEx? e = _engine;
    _engine = null;
    if (e != null) {
      if (_handler != null) e.unregisterEventHandler(_handler!);
      try {
        await e.leaveChannel();
      } on Object {
        // Not in a channel.
      }
      await e.release();
    }
    await _events.close();
  }

  @override
  Widget localView() {
    final RtcEngineEx? e = _engine;
    if (e == null) return const SizedBox.shrink();
    return AgoraVideoView(controller: VideoViewController(rtcEngine: e, canvas: const VideoCanvas(uid: 0)));
  }

  @override
  Widget remoteView(String channel, int uid) {
    final RtcEngineEx? e = _engine;
    if (e == null || uid == 0) return const SizedBox.shrink();
    final RtcConnection c = _extra[channel] ?? RtcConnection(channelId: channel, localUid: _uid);
    return AgoraVideoView(controller: VideoViewController.remote(rtcEngine: e, canvas: VideoCanvas(uid: uid), connection: c));
  }
}
