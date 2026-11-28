import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/room/call_engine.dart';
import 'package:niraah/features/room/room_controller.dart';
import 'package:niraah/features/room/room_page.dart';
import 'package:niraah/features/room/room_repository.dart';

import '../helpers/pump_app.dart';

// Spec 014 §5 (the consult room) on mobile: lobby, joining, the call, leaving, ending, and when Join shows.

class FakeEngine implements CallEngine {
  final StreamController<CallEvent> _c = StreamController<CallEvent>.broadcast();
  final List<String> calls = <String>[];

  void emit(CallEvent e) => _c.add(e);

  @override
  Stream<CallEvent> get events => _c.stream;
  @override
  Future<void> start(String appId) async => calls.add('start:$appId');
  @override
  Future<void> join({required String token, required String channel, required int uid}) async => calls.add('join:$channel:$uid:$token');
  @override
  Future<void> renewToken(String token) async => calls.add('renew:$token');
  @override
  Future<void> setMicOn(bool on) async => calls.add('mic:$on');
  @override
  Future<void> setCameraOn(bool on) async => calls.add('camera:$on');
  @override
  Future<void> flipCamera() async => calls.add('flip');
  @override
  Future<void> setSpeakerOn(bool on) async => calls.add('speaker:$on');
  @override
  Future<void> leave() async => calls.add('leave');
  @override
  Future<void> dispose() async {
    calls.add('dispose');
    await _c.close();
  }

  @override
  Widget localView() => const ColoredBox(key: ValueKey<String>('local-video'), color: Colors.pink);
  @override
  Widget remoteView(int uid, String channel) => ColoredBox(key: ValueKey<String>('remote-video-$uid'), color: Colors.blue);
}

class FakeRooms implements RoomRepository {
  FakeRooms(this.result);
  TokenResult result;
  int tokenCalls = 0;
  int endCalls = 0;
  bool endOk = true;

  @override
  Future<RoomInfo?> info(String id) async => RoomInfo(
        id: id,
        startsAt: DateTime(2026, 11, 26, 10),
        endsAt: DateTime(2026, 11, 26, 10, 20),
        clinicianName: 'Dr. Ananya Rao',
        memberName: 'Asha',
      );

  @override
  Future<TokenResult> token(String id) async {
    tokenCalls++;
    return result;
  }

  @override
  Future<bool> end(String id) async {
    endCalls++;
    return endOk;
  }
}

RoomToken token({String t = 'tok-1', DateTime? closesAt, bool recording = false}) =>
    RoomToken(appId: 'app', channel: 'appt-1', uid: 7, token: t, expiresAt: DateTime(2026, 11, 26, 11), closesAt: closesAt, recording: recording);

/// The room has a live clock and a pulse, so it never "settles"; advance time in steps instead.
Future<void> settle(WidgetTester tester) async {
  for (int i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late FakeEngine engine;

  RoomController controller(FakeRooms rooms, {RoomSide side = RoomSide.member, bool mic = true, bool camera = true}) {
    engine = FakeEngine();
    return RoomController(
      appointmentId: 'appt-1',
      side: side,
      repository: rooms,
      engineFactory: () => engine,
      askPermissions: () async => (mic: mic, camera: camera),
    );
  }

  Future<RoomController> openPage(WidgetTester tester, FakeRooms rooms, {RoomSide side = RoomSide.member, bool mic = true, bool camera = true}) async {
    final RoomController c = controller(rooms, side: side, mic: mic, camera: camera);
    await tester.pumpApp(RoomPage(appointmentId: 'appt-1', side: side, controller: c));
    await tester.pump();
    await tester.pump();
    return c;
  }

  group('controller', () {
    test('a token opens the lobby with her preview, then Join puts her in the call', () async {
      final RoomController c = controller(FakeRooms(TokenReady(token())));
      await c.open();
      expect(c.phase, RoomPhase.lobby);
      expect(engine.calls, contains('start:app'));
      await c.join();
      expect(c.phase, RoomPhase.inCall);
      expect(engine.calls, contains('join:appt-1:7:tok-1'));
      c.dispose();
    });

    test('too early: counts down to when the room opens', () async {
      final DateTime at = DateTime.now().add(const Duration(minutes: 5));
      final RoomController c = controller(FakeRooms(RoomNotOpen(at, 'The room opens later.')));
      await c.open();
      expect(c.phase, RoomPhase.notOpen);
      expect(c.opensAt, at);
      c.dispose();
    });

    test('a closed or cancelled consult cannot be joined', () async {
      final RoomController c = controller(FakeRooms(const RoomClosed('This room has closed.')));
      await c.open();
      expect(c.phase, RoomPhase.unavailable);
      expect(c.message, 'This room has closed.');
      c.dispose();
    });

    test('no microphone permission: asks for it instead of starting video', () async {
      final RoomController c = controller(FakeRooms(TokenReady(token())), mic: false);
      await c.open();
      expect(c.phase, RoomPhase.needsPermission);
      expect(engine.calls, isEmpty);
      c.dispose();
    });

    test('no camera permission: joins with the camera off', () async {
      final RoomController c = controller(FakeRooms(TokenReady(token())), camera: false);
      await c.open();
      expect(c.phase, RoomPhase.lobby);
      expect(c.cameraOn, isFalse);
      expect(engine.calls, contains('camera:false'));
      c.dispose();
    });

    test('the other person joining starts the timer; their camera and mic state follow', () async {
      final RoomController c = controller(FakeRooms(TokenReady(token())));
      await c.open();
      await c.join();
      engine.emit(const OtherJoined(42));
      await Future<void>.delayed(Duration.zero);
      expect(c.otherUid, 42);
      expect(c.talkingSince, isNotNull);
      engine.emit(const OtherCamera(42, on: false));
      engine.emit(const OtherMic(42, on: false));
      await Future<void>.delayed(Duration.zero);
      expect(c.otherCameraOn, isFalse);
      expect(c.otherMicOn, isFalse);
      engine.emit(const OtherLeft(42));
      await Future<void>.delayed(Duration.zero);
      expect(c.otherUid, isNull);
      c.dispose();
    });

    test('an expiring token is renewed from the server without leaving the call', () async {
      final FakeRooms rooms = FakeRooms(TokenReady(token()));
      final RoomController c = controller(rooms);
      await c.open();
      await c.join();
      rooms.result = TokenReady(token(t: 'tok-2'));
      engine.emit(const TokenExpiring());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(engine.calls, contains('renew:tok-2'));
      expect(c.phase, RoomPhase.inCall);
      c.dispose();
    });

    test('mic, camera, flip and speaker reach the engine', () async {
      final RoomController c = controller(FakeRooms(TokenReady(token())));
      await c.open();
      await c.join();
      await c.toggleMic();
      await c.toggleCamera();
      await c.flipCamera();
      await c.toggleSpeaker();
      expect(engine.calls, containsAll(<String>['mic:false', 'camera:false', 'flip', 'speaker:false']));
      c.dispose();
    });

    test('the clinician ends the consult for both; the server is told', () async {
      final FakeRooms rooms = FakeRooms(TokenReady(token()));
      final RoomController c = controller(rooms, side: RoomSide.clinician);
      await c.open();
      await c.join();
      expect(await c.endForBoth(), isTrue);
      expect(rooms.endCalls, 1);
      expect(c.phase, RoomPhase.ended);
      expect(c.endedForBoth, isTrue);
      expect(engine.calls, contains('leave'));
      c.dispose();
    });

    test('leaving keeps the consult open, and she can join again', () async {
      final FakeRooms rooms = FakeRooms(TokenReady(token()));
      final RoomController c = controller(rooms);
      await c.open();
      await c.join();
      await c.leave();
      expect(c.phase, RoomPhase.ended);
      expect(c.endedForBoth, isFalse);
      expect(rooms.endCalls, 0);
      await c.rejoin();
      expect(c.phase, RoomPhase.lobby);
      c.dispose();
    });

    test('in the last two minutes the room warns that it is closing', () async {
      final RoomController c = controller(FakeRooms(TokenReady(token(closesAt: DateTime.now().add(const Duration(seconds: 90))))));
      await c.open();
      await c.join();
      expect(c.closingIn, isNotNull);
      c.dispose();
    });
  });

  group('screen', () {
    testWidgets('lobby shows who and when, her preview, the switches and Join now', (WidgetTester tester) async {
      await openPage(tester, FakeRooms(TokenReady(token(recording: true))));
      expect(find.text('Dr. Ananya Rao'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('local-video')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('lobby-mic')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('lobby-camera')), findsOneWidget);
      await tester.scrollUntilVisible(find.text(RoomCopy.recordingNote), 200);
      expect(find.text(RoomCopy.recordingNote), findsOneWidget);
      expect(find.text(RoomCopy.joinNow), findsOneWidget);
    });

    testWidgets('after joining she waits for the specialist, then sees them full screen with the controls', (WidgetTester tester) async {
      await openPage(tester, FakeRooms(TokenReady(token())));
      await tester.tap(find.text(RoomCopy.joinNow));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey<String>('room-waiting')), findsOneWidget);
      expect(find.textContaining('Dr. Ananya Rao'), findsWidgets);
      for (final String k in <String>['call-mic', 'call-camera', 'call-flip', 'call-speaker', 'call-leave']) {
        expect(find.byKey(ValueKey<String>(k)), findsOneWidget, reason: k);
      }
      engine.emit(const OtherJoined(42));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey<String>('remote-video-42')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('room-waiting')), findsNothing);
      expect(find.byKey(const ValueKey<String>('room-timer')), findsOneWidget);
    });

    testWidgets('a member leaving confirms first, then sees "You left" with Join again', (WidgetTester tester) async {
      await openPage(tester, FakeRooms(TokenReady(token())));
      await tester.tap(find.text(RoomCopy.joinNow));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const ValueKey<String>('call-leave')));
      await settle(tester);
      expect(find.text(RoomCopy.leaveTitle), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('room-end-both')), findsNothing, reason: 'members cannot end for both');
      await tester.tap(find.byKey(const ValueKey<String>('room-leave-confirm')));
      await settle(tester);
      expect(find.text(RoomCopy.leftTitle), findsOneWidget);
      expect(find.text(RoomCopy.joinAgain), findsOneWidget);
    });

    testWidgets('the doctor can end the consult for both or leave for now', (WidgetTester tester) async {
      final FakeRooms rooms = FakeRooms(TokenReady(token()));
      await openPage(tester, rooms, side: RoomSide.clinician);
      expect(find.text('Asha'), findsOneWidget, reason: 'the doctor sees the member');
      await tester.tap(find.text(RoomCopy.joinNow));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const ValueKey<String>('call-leave')));
      await settle(tester);
      expect(find.byKey(const ValueKey<String>('room-end-both')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('room-leave-for-now')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('room-end-both')));
      await settle(tester);
      expect(rooms.endCalls, 1);
      expect(find.text(RoomCopy.endedTitle), findsOneWidget);
    });

    testWidgets('too early shows a countdown', (WidgetTester tester) async {
      await openPage(tester, FakeRooms(RoomNotOpen(DateTime.now().add(const Duration(minutes: 3)), 'Later')));
      expect(find.text(RoomCopy.opensIn), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('room-countdown')), findsOneWidget);
    });

    testWidgets('a refused microphone explains and offers Settings', (WidgetTester tester) async {
      await openPage(tester, FakeRooms(TokenReady(token())), mic: false);
      expect(find.text(RoomCopy.needMic), findsOneWidget);
      expect(find.text(RoomCopy.openSettings), findsOneWidget);
    });
  });
}
