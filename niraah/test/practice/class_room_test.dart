import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/payments/payment_checkout.dart';
import 'package:niraah/core/video/video_engine.dart';
import 'package:niraah/features/practice/data/api_practice_repository.dart';
import 'package:niraah/features/practice/domain/practice.dart';
import 'package:niraah/features/practice/presentation/class_room_cubit.dart';

import '../helpers/fake_api.dart';
import '../helpers/fake_video.dart';

class FakePractice implements PracticeRepository {
  ClassRoomAccess access = const ClassRoomReady(ChannelToken(appId: 'agora-app', channel: 'Kmain', uid: 7, token: 'mt'));
  final List<String> calls = <String>[];

  @override
  Future<ClassRoomAccess> roomToken(String classId) async {
    calls.add('room-token');
    return access;
  }

  @override
  Future<ChannelToken> cameraToken(String classId) async {
    calls.add('camera-token');
    return const ChannelToken(appId: 'agora-app', channel: 'Kmain-cam1', uid: 7, token: 'ct');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A member in a live class on a fake engine (spec 014 §8 "The class room"). Tested with fakes only.
void main() {
  late FakePractice repo;
  late FakeVideoEngine engine;
  late FakePermissions permissions;
  late DateTime now;

  ClassRoomCubit cubit() => ClassRoomCubit(repository: repo, engines: () => engine, permissions: permissions, classId: 'c1', clock: () => now);

  setUp(() {
    repo = FakePractice();
    engine = FakeVideoEngine();
    permissions = FakePermissions();
    now = DateTime(2026, 11, 20, 7);
  });

  Future<ClassRoomCubit> joined() async {
    final ClassRoomCubit c = cubit();
    await c.start();
    await c.join();
    engine.emit(const VideoJoined('Kmain'));
    return c;
  }

  test('§8.2, AC43: she joins as audience with camera and microphone off; only the instructor is seen', () async {
    final ClassRoomCubit c = await joined();
    expect(engine.joined, <String, Object?>{'channel': 'Kmain', 'token': 'mt', 'uid': 7, 'camera': false, 'microphone': false, 'audience': true});
    expect(engine.appId, 'agora-app');
    expect(c.state.phase, ClassRoomPhase.waiting);
    engine
      ..emit(const VideoRemoteJoined('Kmain', 42))
      ..emit(const VideoRemoteVideo('Kmain', 42, on: true));
    expect(c.state.phase, ClassRoomPhase.live);
    expect(c.state.instructorUid, 42);
    expect(c.state.instructorVideo, isTrue);
    await c.close();
  });

  test('outside the join window the server\'s words are shown and nothing starts', () async {
    repo.access = const ClassRoomShut('The class room is not open.', notOpen: true);
    final ClassRoomCubit c = cubit();
    await c.start();
    expect(c.state.phase, ClassRoomPhase.shut);
    expect(c.state.message, 'The class room is not open.');
    expect(engine.calls, isEmpty);
    await c.close();
  });

  test('AC43: her camera goes on a private channel to the instructor only, sending and receiving nothing else', () async {
    final ClassRoomCubit c = await joined();
    await c.toggleCamera();
    expect(repo.calls, contains('camera-token'));
    expect(engine.extra['Kmain-cam1'], <String, Object?>{'token': 'ct', 'uid': 7, 'send': true, 'receive': false});
    expect(c.state.sharingCamera, isTrue);
    expect(engine.joined!['camera'], isFalse, reason: 'nothing is sent on the main channel');
    await c.toggleCamera();
    expect(engine.calls, containsAllInOrder(<String>['leaveExtra:Kmain-cam1', 'camera:off']));
    expect(c.state.sharingCamera, isFalse);
    await c.close();
  });

  test('a refused camera permission says so and asks for no token', () async {
    permissions.camera = false;
    final ClassRoomCubit c = await joined();
    await c.toggleCamera();
    expect(c.state.cameraRefused, isTrue);
    expect(repo.calls, isNot(contains('camera-token')));
    await c.close();
  });

  test('reconnecting by itself; after 2 minutes she rejoins by hand, and her camera channel is closed', () async {
    final ClassRoomCubit c = await joined();
    await c.toggleCamera();
    engine.emit(const VideoLinkChanged('Kmain', VideoLink.reconnecting));
    expect(c.state.phase, ClassRoomPhase.reconnecting);
    now = now.add(const Duration(minutes: 2));
    await c.tick();
    expect(c.state.phase, ClassRoomPhase.dropped);
    expect(c.state.sharingCamera, isFalse);
    await c.join();
    expect(engine.calls.where((String x) => x.startsWith('join:')), hasLength(2));
    await c.close();
  });

  group('booking a place (spec 014 §8 "Booking", AC42)', () {
    test('the server chooses unit or fee; a fee comes back with the checkout to open', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..reply(<String, dynamic>{'status': 'booked', 'bookingId': 'b0'})
        ..reply(<String, dynamic>{
          'status': 'payment_needed',
          'bookingId': 'b1',
          'checkout': <String, dynamic>{'kind': 'order', 'gatewayRef': 'order_c', 'keyId': 'rzp_pub', 'amountPaise': 30000},
        });
      final ApiPracticeRepository r = ApiPracticeRepository(fakeApi(adapter));
      expect(await r.book('c1'), isA<ClassBooked>());
      expect(adapter.requests.first.data, <String, dynamic>{}, reason: 'no payWith: a unit if she has one, else the fee');
      final ClassPaymentNeeded p = await r.book('c1') as ClassPaymentNeeded;
      expect(p.bookingId, 'b1');
      expect(p.amountPaise, 30000);
      expect(p.checkout, const Checkout(kind: 'order', gatewayRef: 'order_c', keyId: 'rzp_pub', amountPaise: 30000));
    });

    test('her bookings, the room token and the give-back call', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..reply(<String, dynamic>{
          'bookings': <Object>[
            <String, dynamic>{'id': 'b1', 'classId': 'c1', 'status': 'booked', 'title': 'Slow flow', 'startsAt': '2026-11-20T01:30:00.000Z', 'endsAt': '2026-11-20T02:30:00.000Z'},
          ],
        })
        ..reply(<String, dynamic>{'appId': 'agora-app', 'channel': 'Kmain', 'uid': 7, 'token': 'mt', 'role': 'subscriber', 'expiresAt': '2026-11-20T02:45:00.000Z'})
        ..reply(<String, dynamic>{'error': <String, dynamic>{'code': 'conflict', 'message': 'The class room is not open.'}}, 409)
        ..reply(<String, dynamic>{'outcome': 'released'});
      final ApiPracticeRepository r = ApiPracticeRepository(fakeApi(adapter));
      final ClassBooking b = (await r.classBookings()).single;
      expect(b.booked, isTrue);
      expect(b.classId, 'c1');
      expect(((await r.roomToken('c1')) as ClassRoomReady).token.channel, 'Kmain');
      final ClassRoomShut shut = await r.roomToken('c1') as ClassRoomShut;
      expect(shut.notOpen, isTrue);
      expect(await r.cancelBooking('b1'), 'released');
      expect(adapter.last.path, '/class-bookings/b1/cancel');
    });
  });
}
