import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/core/video/device_permissions.dart';
import 'package:niraah/core/video/video_engine.dart';
import 'package:niraah/features/consults/domain/consults.dart';
import 'package:niraah/features/consults/presentation/consult_room_cubit.dart';
import 'package:niraah/features/consults/presentation/consult_room_page.dart';

import '../helpers/fake_video.dart';
import '../helpers/pump_app.dart';
import 'consult_cubits_test.dart' show FakeConsults, appt;

/// The member's consult room on a fake video engine (spec 014 §5). Tested with fakes only: nothing here talks to
/// Agora, so audio fallback, rejoin and token renewal are checked as this app's handling of the SDK's events.
class RoomRepo extends FakeConsults {
  RoomRepo({this.recording = false, DateTime? closesAt}) : closesAt = closesAt ?? DateTime(2026, 11, 20, 10, 40);

  final bool recording;
  final DateTime closesAt;
  RoomAccess? next;
  int tokens = 0;
  int stops = 0;

  @override
  Future<RoomAccess> roomToken(String id) async {
    tokens++;
    calls.add('room-token');
    return next ?? RoomReady(appId: 'agora-app', channel: 'Xr4nd0m', uid: 1234, token: 'tok$tokens', expiresAt: closesAt.add(const Duration(minutes: 5)), closesAt: closesAt, recording: recording);
  }

  @override
  Future<void> stopRecording(String id) async {
    stops++;
    calls.add('record-stop');
  }
}

void main() {
  late RoomRepo repo;
  late FakeVideoEngine engine;
  late FakePermissions permissions;
  late DateTime now;

  ConsultRoomCubit cubit() => ConsultRoomCubit(repository: repo, engines: () => engine, permissions: permissions, appointmentId: 'a1', clock: () => now);

  setUp(() {
    repo = RoomRepo()..current = appt();
    engine = FakeVideoEngine();
    permissions = FakePermissions();
    now = DateTime(2026, 11, 20, 9, 55);
  });

  Future<ConsultRoomCubit> inCall({bool remote = true}) async {
    final ConsultRoomCubit c = cubit();
    await c.start();
    await c.allowDevices();
    await c.join();
    engine.emit(const VideoJoined('Xr4nd0m'));
    if (remote) engine.emit(const VideoRemoteJoined('Xr4nd0m', 99));
    return c;
  }

  group('entering (spec 014 §5 "Entering", "Tokens")', () {
    test('a token from the server opens the preview; not open yet and closed say so (AC20, AC21)', () async {
      final ConsultRoomCubit c = cubit();
      await c.start();
      expect(c.state.phase, RoomPhase.preview);
      expect(c.state.room!.channel, 'Xr4nd0m');

      repo.next = RoomNotOpen(opensAt: DateTime(2026, 11, 20, 9, 50), message: 'The room opens at 09:50.');
      await c.start();
      expect(c.state.phase, RoomPhase.notOpen);
      expect(c.state.opensAt, DateTime(2026, 11, 20, 9, 50));

      repo.next = const RoomUnavailable('Not found.');
      await c.start();
      expect(c.state.phase, RoomPhase.closed);
      expect(c.state.message, 'Not found.');
      expect(engine.calls, isEmpty, reason: 'no video engine without a token');
      await c.close();
    });

    test('allowing devices starts the engine with the app id from the server and shows her preview', () async {
      final ConsultRoomCubit c = cubit();
      await c.start();
      await c.allowDevices();
      expect(c.state.access, MediaAccess.granted);
      expect(engine.appId, 'agora-app');
      expect(engine.calls, contains('startPreview'));
      expect(c.state.cameraOn, isTrue);
      await c.close();
      expect(engine.disposed, isTrue, reason: 'leaving the screen releases the camera and microphone');
    });

    test('microphone only: she joins by voice, the camera stays off and cannot be turned on', () async {
      permissions.answer = MediaAccess.audioOnly;
      final ConsultRoomCubit c = cubit();
      await c.start();
      await c.allowDevices();
      expect(c.state.camera, isFalse);
      expect(engine.calls, isNot(contains('startPreview')));
      await c.toggleCamera();
      expect(c.state.cameraOn, isFalse);
      await c.join();
      expect(engine.joined, containsPair('camera', false));
      expect(engine.joined, containsPair('microphone', true));
      await c.close();
    });

    test('camera and microphone are switchable in the preview before joining (§5 "Entering" 3)', () async {
      final ConsultRoomCubit c = cubit();
      await c.start();
      await c.allowDevices();
      await c.toggleMic();
      await c.toggleCamera();
      expect(c.state.mic, isFalse);
      expect(c.state.cameraOn, isFalse);
      await c.join();
      expect(engine.joined, <String, Object?>{'channel': 'Xr4nd0m', 'token': 'tok2', 'uid': 1234, 'camera': false, 'microphone': true, 'audience': false});
      expect(engine.calls, contains('mic:muted'));
      await c.close();
    });
  });

  group('during the call (spec 014 §5 "During")', () {
    test('waiting until the other person is there, then connected; back to waiting when she leaves (§5 "Entering" 4)', () async {
      final ConsultRoomCubit c = await inCall(remote: false);
      expect(c.state.phase, RoomPhase.waiting);
      engine.emit(const VideoRemoteJoined('Xr4nd0m', 99));
      expect(c.state.phase, RoomPhase.connected);
      engine.emit(const VideoRemoteVideo('Xr4nd0m', 99, on: true));
      expect(c.state.remoteVideo, isTrue);
      engine.emit(const VideoRemoteLeft('Xr4nd0m', 99));
      expect(c.state.phase, RoomPhase.waiting);
      await c.close();
    });

    test('AC25: a dropped link shows "Reconnecting" and comes back without her acting', () async {
      final ConsultRoomCubit c = await inCall();
      engine.emit(const VideoLinkChanged('Xr4nd0m', VideoLink.reconnecting));
      expect(c.state.phase, RoomPhase.reconnecting);
      now = now.add(const Duration(seconds: 90));
      await c.tick();
      expect(c.state.phase, RoomPhase.reconnecting, reason: 'still within 2 minutes');
      engine.emit(const VideoLinkChanged('Xr4nd0m', VideoLink.connected));
      expect(c.state.phase, RoomPhase.connected);
      expect(engine.calls.where((String x) => x.startsWith('join:')), hasLength(1), reason: 'the SDK rejoined; the app did not');
      await c.close();
    });

    test('after 2 minutes of reconnecting she can rejoin by hand while the room is open (§5 "During" 3)', () async {
      final ConsultRoomCubit c = await inCall();
      engine.emit(const VideoLinkChanged('Xr4nd0m', VideoLink.reconnecting));
      now = now.add(const Duration(minutes: 2));
      await c.tick();
      expect(c.state.phase, RoomPhase.dropped);
      expect(engine.calls.last, 'leave');
      await c.join();
      expect(c.state.phase, RoomPhase.joining);
      expect(engine.calls.where((String x) => x.startsWith('join:')), hasLength(2));
      await c.close();
    });

    test('a lost link that the SDK gives up on is "dropped", not a silent end; leaving on purpose is not', () async {
      final ConsultRoomCubit c = await inCall();
      engine.emit(const VideoLinkChanged('Xr4nd0m', VideoLink.disconnected, byLeaving: true));
      expect(c.state.phase, RoomPhase.connected);
      engine.emit(const VideoLinkChanged('Xr4nd0m', VideoLink.failed));
      expect(c.state.phase, RoomPhase.dropped);
      await c.close();
    });

    test('AC24: a weak link offers audio only; audio only pauses video both ways and keeps the call', () async {
      final ConsultRoomCubit c = await inCall();
      engine.emit(const VideoQuality('Xr4nd0m', uplink: 5, downlink: 2));
      engine.emit(const VideoQuality('Xr4nd0m', uplink: 4, downlink: 2));
      expect(c.state.offerAudioOnly, isFalse, reason: 'not on a short dip');
      engine.emit(const VideoQuality('Xr4nd0m', uplink: 2, downlink: 5));
      expect(c.state.offerAudioOnly, isTrue);
      await c.setAudioOnly(true);
      expect(c.state.cameraOn, isFalse);
      expect(engine.calls, containsAllInOrder(<String>['camera:off', 'remoteVideo:99:muted']));
      expect(c.state.phase, RoomPhase.connected, reason: 'the call goes on by voice');
      expect(engine.calls, isNot(contains('leave')));
      await c.setAudioOnly(false);
      expect(engine.calls, containsAllInOrder(<String>['camera:on', 'remoteVideo:99:on']));
      await c.close();
    });

    test('the token is renewed from the same endpoint when the SDK warns it will expire (plan 014 "Rooms")', () async {
      final ConsultRoomCubit c = await inCall();
      engine.emit(const VideoTokenExpiring('Xr4nd0m'));
      await Future<void>.delayed(Duration.zero);
      expect(engine.calls, contains('renew:Xr4nd0m:tok3'));
      await c.close();
    });

    test('time up, then the room closes and takes her out (§5 "During" 6)', () async {
      final ConsultRoomCubit c = await inCall();
      expect(c.timer, isA<TimerRunning>());
      now = DateTime(2026, 11, 20, 10, 31);
      expect(c.timer, isA<TimerTimeUp>());
      now = DateTime(2026, 11, 20, 10, 40);
      await c.tick();
      expect(c.state.phase, RoomPhase.left);
      expect(c.state.closedByTime, isTrue);
      c.reenter();
      expect(c.state.phase, RoomPhase.left, reason: 'no way back once the room has closed');
      await c.close();
    });

    test('leaving, then going back in while the room is open', () async {
      final ConsultRoomCubit c = await inCall();
      await c.leave();
      expect(c.state.phase, RoomPhase.left);
      c.reenter();
      expect(c.state.phase, RoomPhase.preview);
      await c.close();
    });

    test('AC51, AC52: the recording mark shows while recording runs; she stops it', () async {
      repo = RoomRepo(recording: true)..current = appt();
      final ConsultRoomCubit c = await inCall();
      expect(c.state.recording, isTrue);
      expect(await c.stopRecording(), isNull);
      expect(repo.stops, 1);
      expect(c.state.recording, isFalse);
      await c.close();
    });

    test('AC27: nothing from the call is sent to the API: only the appointment, the token and the record stop', () async {
      repo = RoomRepo(recording: true)..current = appt();
      final ConsultRoomCubit c = await inCall();
      engine.emit(const VideoQuality('Xr4nd0m', uplink: 1, downlink: 1));
      await c.stopRecording();
      await c.leave();
      expect(repo.calls.toSet(), <String>{'get', 'room-token', 'record-stop'});
      await c.close();
    });
  });

  group('timer', () {
    test('mm:ss, h:mm:ss, never negative', () {
      expect(clockText(const Duration(minutes: 4, seconds: 5)), '04:05');
      expect(clockText(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
      expect(clockText(const Duration(seconds: -3)), '00:00');
    });

    test("without the server's close time: the end plus 10 minutes' grace", () {
      final DateTime end = DateTime(2026, 11, 20, 10, 30);
      expect(roomTimer(DateTime(2026, 11, 20, 10, 35), end, null), isA<TimerTimeUp>());
      expect(roomTimer(DateTime(2026, 11, 20, 10, 40), end, null), isA<TimerClosed>());
    });
  });

  testWidgets('the call screen: the other person\'s video, her controls, the timer and the weak-link offer', (WidgetTester t) async {
    final DateTime start = DateTime.now();
    repo = RoomRepo(closesAt: start.add(const Duration(minutes: 40)))..current = appt(starts: start.subtract(const Duration(minutes: 1)));
    await t.pumpApp(ConsultRoomPage(appointmentId: 'a1', repository: repo, engines: () => engine, permissions: permissions));
    await t.pump();
    await t.pump();
    await t.tap(find.text('Allow camera and microphone'));
    await t.pump();
    expect(find.byKey(const Key('local-video')), findsOneWidget);
    await t.scrollUntilVisible(find.text('Join now'), 300);
    await t.tap(find.text('Join now'));
    await t.pump();
    engine.emit(const VideoJoined('Xr4nd0m'));
    await t.pump();
    expect(find.text('Waiting for Dr Asha Rao…'), findsOneWidget);
    engine
      ..emit(const VideoRemoteJoined('Xr4nd0m', 99))
      ..emit(const VideoRemoteVideo('Xr4nd0m', 99, on: true));
    await t.pump();
    expect(find.byKey(const Key('remote-video-Xr4nd0m-99')), findsOneWidget);
    expect(find.byTooltip('Mute microphone'), findsOneWidget);
    expect(find.byTooltip('Turn camera off'), findsOneWidget);
    expect(find.byTooltip('Switch camera'), findsOneWidget);
    expect(find.byTooltip('Leave'), findsOneWidget);
    expect(find.textContaining(' left'), findsOneWidget);
    for (int i = 0; i < 3; i++) {
      engine.emit(const VideoQuality('Xr4nd0m', uplink: 5, downlink: 5));
    }
    await t.pump();
    await t.pump();
    expect(find.textContaining('connection is weak'), findsOneWidget);
    expect(find.text('Switch to audio only'), findsOneWidget);
    engine.emit(const VideoLinkChanged('Xr4nd0m', VideoLink.reconnecting));
    await t.pump();
    await t.pump();
    expect(find.text('Reconnecting…'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
}
