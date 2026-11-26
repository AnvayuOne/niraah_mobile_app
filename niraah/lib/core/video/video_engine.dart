import 'package:material_ui/material_ui.dart';

/// The video vendor as the room screens see it (decision D4: Agora; spec 014 §5, §8). The screens and their cubits
/// talk only to this interface, so they are tested with a fake; [AgoraVideoEngine] is the one real implementation.
///
/// Every channel is one the server gave a token for (`POST /appointments/{id}/room-token`,
/// `POST /classes/{id}/room-token`, `/camera-token`, `GET /classes/{id}/camera-tokens`). The app id comes from the same
/// response, never from the app's build. No media and nothing said in the room is sent to the Niraah API.
abstract class VideoEngine {
  /// What the vendor reports, tagged with the channel it concerns.
  Stream<VideoEvent> get events;

  /// Starts the engine for the app id the server returned. Safe to call again with the same id.
  Future<void> initialize(String appId);

  /// Her own camera on the screen before and during the call (spec 014 §5 "Entering" 3).
  Future<void> startPreview();
  Future<void> stopPreview();

  /// Joins the main channel. [audience] joins without sending anything (a member in a class, spec 014 §8.2).
  /// The SDK then rejoins by itself after a drop and reports [VideoLink.reconnecting] (AC25).
  Future<void> join({required String channel, required String token, required int uid, required bool camera, required bool microphone, bool audience = false});

  /// Joins a second channel beside the main one: a member's private camera channel to the instructor, or the
  /// instructor watching one student's camera (spec 014 §8.3, AC43). [send] publishes her camera; [receive]
  /// subscribes to the other side's video.
  Future<void> joinExtra({required String channel, required String token, required int uid, required bool send, required bool receive});
  Future<void> leaveExtra(String channel);

  /// The same endpoint gives a fresh token when the vendor warns the old one is about to expire (plan 014 "Rooms").
  Future<void> renewToken(String channel, String token);

  Future<void> setMicrophoneMuted(bool muted);

  /// Off stops sending and releases the camera; on starts it again.
  Future<void> setCameraOn(bool on);
  Future<void> switchCamera();

  /// Audio only: stop receiving the other side's video and keep the sound (spec 014 §5 "During" 2, AC24).
  Future<void> setRemoteVideoMuted(String channel, int uid, bool muted);

  /// Leaves every channel.
  Future<void> leave();

  /// Device check (spec 014 §4.4): the microphone's level as [VideoMicLevel], and a connection test as
  /// [VideoProbe].
  Future<void> startMicrophoneTest();
  Future<void> stopMicrophoneTest();
  Future<void> startConnectionTest();
  Future<void> stopConnectionTest();

  /// Releases the engine and the devices. The engine is not used afterwards.
  Future<void> dispose();

  Widget localView();
  Widget remoteView(String channel, int uid);
}

typedef VideoEngineFactory = VideoEngine Function();

/// The state of the link to one channel.
enum VideoLink { connecting, connected, reconnecting, disconnected, failed }

sealed class VideoEvent {
  const VideoEvent(this.channel);
  final String channel;
}

class VideoJoined extends VideoEvent {
  const VideoJoined(super.channel);
}

/// A user who sends media joined: the other participant, or the instructor.
class VideoRemoteJoined extends VideoEvent {
  const VideoRemoteJoined(super.channel, this.uid);
  final int uid;
}

class VideoRemoteLeft extends VideoEvent {
  const VideoRemoteLeft(super.channel, this.uid);
  final int uid;
}

/// The other side's video started or stopped (camera off, or audio only).
class VideoRemoteVideo extends VideoEvent {
  const VideoRemoteVideo(super.channel, this.uid, {required this.on});
  final int uid;
  final bool on;
}

class VideoLinkChanged extends VideoEvent {
  const VideoLinkChanged(super.channel, this.link, {this.byLeaving = false});
  final VideoLink link;

  /// The link closed because she left, not because it dropped.
  final bool byLeaving;
}

/// The vendor's network quality for this device: 0 unknown, 1–3 usable, 4 poor, 5 very poor, 6 down.
class VideoQuality extends VideoEvent {
  const VideoQuality(super.channel, {required this.uplink, required this.downlink});
  final int uplink;
  final int downlink;
}

class VideoTokenExpiring extends VideoEvent {
  const VideoTokenExpiring(super.channel);
}

/// Her microphone's level, 0 to 255, during the device check.
class VideoMicLevel extends VideoEvent {
  const VideoMicLevel(this.level) : super('');
  final int level;
}

/// The result of the connection test, on the same 0–6 scale as [VideoQuality].
class VideoProbe extends VideoEvent {
  const VideoProbe(this.quality) : super('');
  final int quality;
}

/// Agora's scale: 0 unknown, 1–3 usable, 4 poor, 5 very poor, 6 down.
bool isPoorQuality(int q) => q >= 4 && q <= 6;
