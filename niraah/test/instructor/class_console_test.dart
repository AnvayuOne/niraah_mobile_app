import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/video/video_engine.dart';
import 'package:niraah/features/instructor/class_console_cubit.dart';
import 'package:niraah/features/instructor/instructor_repository.dart';
import 'package:niraah/features/provider_work/domain/provider_work.dart';

import '../helpers/fake_api.dart';
import '../helpers/fake_video.dart';

class FakeConsoleRepo implements InstructorRepository {
  final List<String> calls = <String>[];
  Json consoleBody = <String, dynamic>{'status': 'scheduled', 'presentCount': 0, 'joined': <String>[], 'phaseCounts': null};
  List<ChannelToken> cams = <ChannelToken>[];

  @override
  Future<ClassRoomAccess> classRoomToken(String classId) async {
    calls.add('room-token');
    return const ClassRoomReady(ChannelToken(appId: 'agora-app', channel: 'Kmain', uid: 1, token: 'it'));
  }

  @override
  Future<void> startClass(String classId) async => calls.add('start');

  @override
  Future<void> endClass(String classId) async => calls.add('end');

  @override
  Future<Json> console(String classId) async => consoleBody;

  @override
  Future<List<ChannelToken>> cameraTokens(String classId, {required String appId}) async => cams;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The instructor's class console on a fake engine (spec 013 §4; spec 014 §8). Tested with fakes only.
void main() {
  late FakeConsoleRepo repo;
  late FakeVideoEngine engine;

  ClassConsoleCubit cubit() => ClassConsoleCubit(repository: repo, engines: () => engine, permissions: FakePermissions(), classId: 'c1', pollEvery: null);

  setUp(() {
    repo = FakeConsoleRepo();
    engine = FakeVideoEngine();
  });

  Future<ClassConsoleCubit> live() async {
    final ClassConsoleCubit c = cubit();
    await c.start();
    await c.allowDevices();
    await c.startClass();
    engine.emit(const VideoJoined('Kmain'));
    return c;
  }

  test('pre-class check, then Start: the class is started once and she sends camera and microphone (§8.2)', () async {
    final ClassConsoleCubit c = cubit();
    await c.start();
    expect(c.state.phase, ConsolePhase.preview);
    await c.allowDevices();
    expect(engine.calls, containsAllInOrder(<String>['initialize:agora-app', 'startPreview']));
    await c.startClass();
    expect(repo.calls, contains('start'));
    expect(engine.joined, <String, Object?>{'channel': 'Kmain', 'token': 'it', 'uid': 1, 'camera': true, 'microphone': true, 'audience': false});
    engine.emit(const VideoJoined('Kmain'));
    expect(c.state.phase, ConsolePhase.live);
    await c.close();
  });

  test('a class already live is not started again; rejoining after a leave', () async {
    repo.consoleBody = <String, dynamic>{'status': 'live'};
    final ClassConsoleCubit c = await live();
    expect(repo.calls, isNot(contains('start')));
    await c.leave();
    expect(c.state.phase, ConsolePhase.left);
    await c.startClass();
    expect(engine.calls.where((String x) => x.startsWith('join:')), hasLength(2));
    await c.close();
  });

  test('AC43, spec 013 AC21: she only receives the cameras students turned on, and stops when they turn them off', () async {
    final ClassConsoleCubit c = await live();
    repo.cams = <ChannelToken>[const ChannelToken(appId: 'agora-app', channel: 'Kmain-a', uid: 1, token: 'ca')];
    await c.refresh();
    expect(engine.extra['Kmain-a'], <String, Object?>{'token': 'ca', 'uid': 1, 'send': false, 'receive': true});
    engine.emit(const VideoRemoteJoined('Kmain-a', 55));
    expect(c.state.cameras, <String, int?>{'Kmain-a': 55});
    repo.cams = <ChannelToken>[];
    await c.refresh();
    expect(engine.calls, contains('leaveExtra:Kmain-a'));
    expect(c.state.cameras, isEmpty);
    await c.close();
  });

  test('the console counts come from the server; the phase count only as it gives it (spec 013 AC5)', () async {
    final ClassConsoleCubit c = await live();
    repo.consoleBody = <String, dynamic>{'status': 'live', 'presentCount': 6, 'joined': <String>['Asha', 'Meera'], 'phaseCounts': <String, int>{'luteal': 4}};
    await c.refresh();
    expect(c.state.console.integer('presentCount'), 6);
    expect(c.state.console.obj('phaseCounts'), <String, dynamic>{'luteal': 4});
    await c.close();
  });

  test('reconnecting, then dropped after 2 minutes; End ends the class for everyone (AC46)', () async {
    final ClassConsoleCubit c = await live();
    engine.emit(const VideoLinkChanged('Kmain', VideoLink.reconnecting));
    expect(c.state.phase, ConsolePhase.reconnecting);
    engine.emit(const VideoLinkChanged('Kmain', VideoLink.connected));
    expect(c.state.phase, ConsolePhase.live);
    expect(await c.endClass(), isNull);
    expect(repo.calls, contains('end'));
    expect(c.state.phase, ConsolePhase.ended);
    await c.close();
    expect(engine.disposed, isTrue);
  });

  test('the console endpoints the app calls', () async {
    final FakeAdapter adapter = FakeAdapter()
      ..reply(<String, dynamic>{'appId': 'agora-app', 'channel': 'Kmain', 'uid': 1, 'token': 'it', 'role': 'publisher', 'expiresAt': '2026-11-20T02:45:00.000Z'})
      ..reply(<String, dynamic>{'status': 'live'})
      ..reply(<String, dynamic>{
        'cameras': <Object>[
          <String, dynamic>{'bookingId': 'b1', 'channel': 'Kmain-a', 'uid': 1, 'token': 'ca'},
        ],
      })
      ..reply(<String, dynamic>{'status': 'completed'});
    final ApiInstructorRepository r = ApiInstructorRepository(fakeApi(adapter));
    expect(((await r.classRoomToken('c1')) as ClassRoomReady).token.appId, 'agora-app');
    expect(adapter.last.path, '/classes/c1/room-token');
    await r.startClass('c1');
    expect(adapter.last.path, '/classes/c1/start');
    final ChannelToken cam = (await r.cameraTokens('c1', appId: 'agora-app')).single;
    expect(cam.channel, 'Kmain-a');
    expect(cam.appId, 'agora-app');
    await r.endClass('c1');
    expect(adapter.last.path, '/classes/c1/end');
  });
}
