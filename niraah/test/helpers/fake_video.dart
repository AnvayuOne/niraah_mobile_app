import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:niraah/core/payments/payment_checkout.dart';
import 'package:niraah/core/video/device_permissions.dart';
import 'package:niraah/core/video/video_engine.dart';

/// A [VideoEngine] that records what it was asked and lets a test play the vendor's events. No SDK is loaded.
class FakeVideoEngine implements VideoEngine {
  final StreamController<VideoEvent> _events = StreamController<VideoEvent>.broadcast(sync: true);
  final List<String> calls = <String>[];
  String? appId;
  Map<String, Object?>? joined;
  final Map<String, Map<String, Object?>> extra = <String, Map<String, Object?>>{};
  bool disposed = false;

  /// Plays an event as the SDK would send it.
  void emit(VideoEvent e) => _events.add(e);

  @override
  Stream<VideoEvent> get events => _events.stream;

  @override
  Future<void> initialize(String appId) async {
    this.appId = appId;
    calls.add('initialize:$appId');
  }

  @override
  Future<void> startPreview() async => calls.add('startPreview');

  @override
  Future<void> stopPreview() async => calls.add('stopPreview');

  @override
  Future<void> join({required String channel, required String token, required int uid, required bool camera, required bool microphone, bool audience = false}) async {
    joined = <String, Object?>{'channel': channel, 'token': token, 'uid': uid, 'camera': camera, 'microphone': microphone, 'audience': audience};
    calls.add('join:$channel');
  }

  @override
  Future<void> joinExtra({required String channel, required String token, required int uid, required bool send, required bool receive}) async {
    extra[channel] = <String, Object?>{'token': token, 'uid': uid, 'send': send, 'receive': receive};
    calls.add('joinExtra:$channel');
  }

  @override
  Future<void> leaveExtra(String channel) async {
    extra.remove(channel);
    calls.add('leaveExtra:$channel');
  }

  @override
  Future<void> renewToken(String channel, String token) async => calls.add('renew:$channel:$token');

  @override
  Future<void> setMicrophoneMuted(bool muted) async => calls.add('mic:${muted ? 'muted' : 'on'}');

  @override
  Future<void> setCameraOn(bool on) async => calls.add('camera:${on ? 'on' : 'off'}');

  @override
  Future<void> switchCamera() async => calls.add('switchCamera');

  @override
  Future<void> setRemoteVideoMuted(String channel, int uid, bool muted) async => calls.add('remoteVideo:$uid:${muted ? 'muted' : 'on'}');

  @override
  Future<void> leave() async {
    extra.clear();
    calls.add('leave');
  }

  @override
  Future<void> startMicrophoneTest() async => calls.add('micTest');

  @override
  Future<void> stopMicrophoneTest() async => calls.add('micTestStop');

  @override
  Future<void> startConnectionTest() async => calls.add('probe');

  @override
  Future<void> stopConnectionTest() async => calls.add('probeStop');

  @override
  Future<void> dispose() async {
    disposed = true;
    calls.add('dispose');
  }

  @override
  Widget localView() => const SizedBox(key: Key('local-video'));

  @override
  Widget remoteView(String channel, int uid) => SizedBox(key: Key('remote-video-$channel-$uid'));
}

class FakePermissions implements DevicePermissions {
  FakePermissions([this.answer = MediaAccess.granted, this.camera = true]);

  MediaAccess answer;
  bool camera;
  int asked = 0;

  @override
  Future<MediaAccess> request({bool camera = true, bool microphone = true}) async {
    asked++;
    return answer;
  }

  @override
  Future<bool> requestCamera() async {
    asked++;
    return camera;
  }

  @override
  Future<void> openSettings() async {}
}

/// A checkout that ends as the test says, recording what it was opened with.
class FakeCheckout implements PaymentCheckout {
  FakeCheckout([this.result = const CheckoutPaid(paymentId: 'pay_1', orderId: 'order_1', signature: 'sig')]);

  CheckoutResult result;
  final List<Checkout> opened = <Checkout>[];
  final List<String> descriptions = <String>[];

  @override
  Future<CheckoutResult> open(Checkout checkout, {required String description}) async {
    opened.add(checkout);
    descriptions.add(description);
    return result;
  }
}
