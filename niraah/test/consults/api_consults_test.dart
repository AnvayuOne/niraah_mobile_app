import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/errors/api_exception.dart';
import 'package:niraah/features/consults/data/api_consults_repository.dart';
import 'package:niraah/features/consults/domain/consults.dart';
import 'package:niraah/shared/area/area_access.dart';

import '../helpers/fake_api.dart';

Map<String, dynamic> clinician({String id = 'd1', String type = 'doctor', bool dedicated = false}) => <String, dynamic>{
      'id': id,
      'type': type,
      'name': 'Dr Asha Rao',
      'title': type == 'doctor' ? 'Doctor' : 'Dietitian',
      'hasPhoto': false,
      'specialities': <String>['Gynaecology'],
      'languages': <String>['English', 'Hindi'],
      'yearsExperience': 9,
      'bio': 'Cycles and PCOS.',
      'nextSlot': '2026-11-19T04:30:00.000Z',
      'feePaise': 80000,
      'rating': <String, dynamic>{'average': 4.6, 'count': 12},
      'registration': type == 'doctor' ? <String, dynamic>{'number': 'KMC-123', 'council': 'Karnataka Medical Council'} : null,
      'dedicated': dedicated,
      'label': dedicated ? 'Your doctor' : null,
    };

Map<String, dynamic> appointment({String status = 'held', String kind = 'included', bool pooled = false}) => <String, dynamic>{
      'id': 'a1',
      'status': status,
      'kind': kind,
      'providerType': 'doctor',
      'startsAt': '2026-11-20T05:00:00.000Z',
      'endsAt': '2026-11-20T05:30:00.000Z',
      'feePaise': kind == 'paid' ? 80000 : 0,
      'holdExpiresAt': status == 'held' ? '2026-11-18T10:10:00.000Z' : null,
      'clinician': <String, dynamic>{'id': 'd1', 'name': 'Dr Asha Rao'},
      'member': <String, dynamic>{'id': 'm1', 'name': 'Meera'},
      'pooled': pooled,
      'reschedulesLeft': 2,
      'roomOpensAt': '2026-11-20T04:50:00.000Z',
      'recording': false,
    };

Map<String, dynamic> refused(String code, String message, {Map<String, dynamic>? details}) => <String, dynamic>{
      'error': <String, dynamic>{'code': code, 'message': message, 'details': ?details},
    };

void main() {
  late FakeAdapter adapter;
  late ApiConsultsRepository repo;

  setUp(() {
    adapter = FakeAdapter();
    repo = ApiConsultsRepository(fakeApi(adapter));
  });

  group('Find a specialist (spec 014 §2)', () {
    test('sends only the filters chosen and keeps the server order, with a doctor registration (AC6)', () async {
      adapter.reply(<String, dynamic>{
        'clinicians': <Object>[clinician(id: 'd2', dedicated: true), clinician(id: 'n1', type: 'dietitian')],
      });
      final List<Specialist> list = await repo.specialists(const DirectoryFilters(type: 'doctor', language: 'Hindi', speciality: ''));
      expect(adapter.last.uri.path, endsWith('/specialists'));
      expect(adapter.last.uri.queryParameters, <String, String>{'type': 'doctor', 'language': 'Hindi'});
      expect(list.map((Specialist x) => x.id), <String>['d2', 'n1']);
      expect(list.first.label, 'Your doctor');
      expect(list.first.registrationNumber, 'KMC-123');
      expect(list.last.registrationNumber, isNull);
      expect(list.first.feePaise, 80000);
      expect(list.first.ratingCount, 12);
    });

    test('a profile reached by a direct link can say no times are available (§2.4)', () async {
      adapter.reply(<String, dynamic>{...clinician(), 'nextSlot': null, 'feePaise': null, 'available': false, 'horizonDays': 30});
      final Specialist x = await repo.specialist('d1');
      expect(adapter.last.path, '/specialists/d1');
      expect(x.available, isFalse);
      expect(x.horizonDays, 30);
    });

    test('a locked area arrives as AreaLocked, never with data (spec 010 AC48)', () async {
      adapter.reply(lockedBody('specialists'), 403);
      expect(repo.specialists(const DirectoryFilters()), throwsA(isA<AreaLocked>()));
    });

    test('the specialist guide sends her words and returns kinds only (AC7)', () async {
      adapter.reply(<String, dynamic>{
        'specialists': <Object>[<String, dynamic>{'kind': 'Gynaecologist', 'reason': 'Cycle concerns.'}],
        'note': 'AI insights do not replace medical advice.',
        'madeByModel': true,
      });
      final SpecialistGuide g = await repo.guide('  irregular periods ');
      expect(adapter.last.path, '/me/specialist-guide');
      expect(adapter.lastBody, <String, dynamic>{'concern': 'irregular periods'});
      expect(g.suggestions.single.kind, 'Gynaecologist');
      expect(g.madeByModel, isTrue);
    });

    test('included consults come from entitlements, only those her plan includes (spec 010 §9.2)', () async {
      adapter.reply(<String, dynamic>{
        'source': 'subscription',
        'status': 'active',
        'features': <Object>[
          <String, dynamic>{'key': 'consults.doctor_included', 'included': true, 'remaining': 1, 'allowance': 2, 'refillsAt': '2026-12-01T00:00:00Z'},
          <String, dynamic>{'key': 'consults.dietitian_included', 'included': false, 'remaining': 0, 'allowance': null, 'refillsAt': null},
          <String, dynamic>{'key': 'ai_chat.messages', 'included': true, 'remaining': 10, 'allowance': 20, 'refillsAt': null},
        ],
      });
      final List<IncludedConsults> i = await repo.included();
      expect(i, const <IncludedConsults>[IncludedConsults(type: 'doctor', remaining: 1, allowance: 2, refillsAt: '2026-12-01T00:00:00Z')]);
      expect(i.single.usable, isTrue);
    });
  });

  group('Booking (spec 014 §3)', () {
    test('slots for a clinician send her id and a range; the dedicated fallback is read (AC14)', () async {
      adapter.reply(<String, dynamic>{
        'slots': <Object>[<String, dynamic>{'startsAt': '2026-11-20T05:00:00.000Z', 'endsAt': '2026-11-20T05:30:00.000Z'}],
        'feePaise': 80000,
        'included': true,
        'fallback': <String, dynamic>{'reason': 'Your doctor has no free time in the next few days.', 'type': 'doctor'},
      });
      final SlotList l = await repo.slots(providerId: 'd1', type: 'doctor', from: DateTime.utc(2026, 11, 18), to: DateTime.utc(2026, 11, 25));
      expect(adapter.last.uri.queryParameters, <String, String>{'providerId': 'd1', 'from': '2026-11-18T00:00:00.000Z', 'to': '2026-11-25T00:00:00.000Z'});
      expect(l.slots.single.startsAt.toUtc(), DateTime.utc(2026, 11, 20, 5));
      expect(l.included, isTrue);
      expect(l.fallbackType, 'doctor');
    });

    test('pooled slots ask by type and carry no clinician (§3 "Pooled assignment" 1)', () async {
      adapter.reply(<String, dynamic>{'slots': <Object>[<String, dynamic>{'startsAt': '2026-11-20T05:00:00.000Z'}], 'feePaise': null, 'included': true, 'fallback': null});
      final SlotList l = await repo.slots(type: 'dietitian', from: DateTime.utc(2026, 11, 18), to: DateTime.utc(2026, 11, 25));
      expect(adapter.last.uri.queryParameters['type'], 'dietitian');
      expect(adapter.last.uri.queryParameters.containsKey('providerId'), isFalse);
      expect(l.slots.single.endsAt, isNull);
    });

    test('a pooled hold asks for an included consult by type; the hold carries its end time (AC8, AC10)', () async {
      adapter.reply(appointment(pooled: true));
      final Appointment a = await repo.hold(type: 'doctor', startsAt: DateTime.utc(2026, 11, 20, 5), includedOnly: true);
      expect(adapter.last.path, '/me/appointments');
      expect(adapter.lastBody, <String, dynamic>{'type': 'doctor', 'startsAt': '2026-11-20T05:00:00.000Z', 'payWith': 'included'});
      expect(a.held, isTrue);
      expect(a.holdExpiresAt!.toUtc(), DateTime.utc(2026, 11, 18, 10, 10));
      expect(a.pooled, isTrue);
    });

    test('a time just taken by someone else is refused with the server words (AC8)', () async {
      adapter.reply(refused('conflict', 'This time has just been taken. Choose another time.'), 409);
      await expectLater(
        repo.hold(providerId: 'd1', startsAt: DateTime.utc(2026, 11, 20, 5)),
        throwsA(isA<ApiException>().having((ApiException e) => e.message, 'message', 'This time has just been taken. Choose another time.')),
      );
      expect(adapter.lastBody.containsKey('payWith'), isFalse);
    });

    test('at the limit of upcoming consults, the limit is named (AC17)', () async {
      adapter.reply(refused('conflict', 'You can have up to 2 upcoming doctor consults.', details: <String, dynamic>{'limit': 2}), 409);
      expect(repo.hold(providerId: 'd1', startsAt: DateTime.utc(2026, 11, 20, 5)), throwsA(isA<ApiException>()));
    });

    test('confirm sends only the categories she agreed to and her reason; an included consult is confirmed (AC11, AC15)', () async {
      adapter.reply(<String, dynamic>{'status': 'confirmed', 'appointment': appointment(status: 'confirmed')});
      final ConfirmOutcome o = await repo.confirm('a1', consents: <String>['cycle_symptoms'], reason: ' cramps ');
      expect(adapter.last.path, '/appointments/a1/confirm');
      expect(adapter.lastBody, <String, dynamic>{'consents': <String>['cycle_symptoms'], 'reason': 'cramps'});
      expect(o, isA<Confirmed>());
      expect((o as Confirmed).appointment.confirmed, isTrue);
    });

    test('a paid consult returns a checkout, read as payment needed (AC11, AC18)', () async {
      adapter.reply(<String, dynamic>{'status': 'payment_needed', 'checkout': <String, dynamic>{'kind': 'order', 'gatewayRef': 'o1', 'keyId': 'k', 'amountPaise': 80000}});
      final ConfirmOutcome o = await repo.confirm('a1', consents: const <String>[]);
      expect(adapter.lastBody, <String, dynamic>{'consents': <String>[]});
      expect((o as PaymentNeeded).amountPaise, 80000);
    });

    test('a trial member asking for an included consult is refused and offered the paid route (AC12)', () async {
      adapter.reply(refused('forbidden', 'Included consults begin when your first payment goes through. You can book a paid consult now.', details: <String, dynamic>{'paidOption': true}), 403);
      expect(repo.hold(type: 'doctor', startsAt: DateTime.utc(2026, 11, 20, 5), includedOnly: true), throwsA(isA<ApiException>()));
    });
  });

  group('Appointments and changes (spec 014 §4-§6)', () {
    test('her list is read from /appointments', () async {
      adapter.reply(<String, dynamic>{'appointments': <Object>[appointment(status: 'confirmed'), appointment(status: 'completed', kind: 'paid')]});
      final List<Appointment> list = await repo.appointments();
      expect(adapter.last.path, '/appointments');
      expect(list.map((Appointment a) => a.status), <String>['confirmed', 'completed']);
      expect(list.last.feePaise, 80000);
      expect(list.first.clinicianName, 'Dr Asha Rao');
    });

    test('cancel returns the outcome the server decided (AC35)', () async {
      adapter.reply(<String, dynamic>{'outcome': 'unit_returned'});
      expect(await repo.cancel('a1'), 'unit_returned');
      expect(adapter.last.path, '/appointments/a1/cancel');
    });

    test('reschedule sends the new start; a third move is refused (AC34)', () async {
      adapter.reply(appointment(status: 'confirmed'));
      await repo.reschedule('a1', DateTime.utc(2026, 11, 21, 6));
      expect(adapter.lastBody, <String, dynamic>{'startsAt': '2026-11-21T06:00:00.000Z'});
      adapter.reply(refused('conflict', 'An appointment can be moved 2 times.'), 409);
      expect(repo.reschedule('a1', DateTime.utc(2026, 11, 22, 6)), throwsA(isA<ApiException>()));
    });

    test('accepting a proposal, declining an offer and rebooking call their endpoints (AC37, AC38)', () async {
      adapter
        ..reply(appointment(status: 'confirmed'))
        ..reply(<String, dynamic>{'outcome': 'refunded'})
        ..reply(<String, dynamic>{...appointment(status: 'confirmed'), 'id': 'a2'});
      await repo.acceptProposal('a1');
      expect(adapter.last.path, '/appointments/a1/accept-proposal');
      expect(await repo.declineOffer('a1'), 'refunded');
      expect(adapter.last.path, '/appointments/a1/decline-offer');
      final Appointment next = await repo.rebook('a1', DateTime.utc(2026, 11, 22, 6));
      expect(adapter.last.path, '/appointments/a1/rebook');
      expect(adapter.lastBody, <String, dynamic>{'startsAt': '2026-11-22T06:00:00.000Z'});
      expect(next.id, 'a2');
    });

    test('a failed call with too little time together lets her choose (AC38)', () async {
      adapter.reply(<String, dynamic>{'outcome': 'member_choice', 'options': <String>['rebook', 'refund']});
      final FailureReport r = await repo.reportFailure('a1');
      expect(r.memberChoice, isTrue);
      expect(r.options, <String>['rebook', 'refund']);
      adapter.reply(<String, dynamic>{'outcome': 'waiting', 'options': <String>[]});
      expect((await repo.reportFailure('a1')).memberChoice, isFalse);
    });

    test('a rating is 1 to 5 with an optional comment, sent once (AC33)', () async {
      adapter.reply(<String, dynamic>{'rated': true});
      await repo.rate('a1', 5, '  ');
      expect(adapter.last.path, '/appointments/a1/rating');
      expect(adapter.lastBody, <String, dynamic>{'rating': 5});
      adapter.reply(refused('conflict', 'You have already rated this consult.'), 409);
      expect(repo.rate('a1', 4, 'Kind.'), throwsA(isA<ApiException>()));
    });
  });

  group('Room token (spec 014 §5 "Tokens")', () {
    test('a participant inside the window gets a token for that channel (AC20)', () async {
      adapter.reply(<String, dynamic>{
        'appId': 'app',
        'channel': 'R4nd0mR00mId0123456789',
        'uid': 12345,
        'token': 'tok',
        'expiresAt': '2026-11-20T05:45:00.000Z',
        'closesAt': '2026-11-20T05:40:00.000Z',
        'recording': true,
      });
      final RoomAccess r = await repo.roomToken('a1');
      expect(adapter.last.path, '/appointments/a1/room-token');
      expect(r, isA<RoomReady>());
      expect((r as RoomReady).uid, 12345);
      expect(r.recording, isTrue);
    });

    test('too early says when the room opens; closed and not hers are read apart (AC21)', () async {
      adapter
        ..reply(refused('conflict', 'The room opens at 2026-11-20T04:50:00.000Z.', details: <String, dynamic>{'opensAt': '2026-11-20T04:50:00.000Z'}), 409)
        ..reply(refused('conflict', 'This room has closed.'), 409)
        ..reply(refused('not_found', 'Not found.'), 404);
      final RoomAccess early = await repo.roomToken('a1');
      expect((early as RoomNotOpen).opensAt!.toUtc(), DateTime.utc(2026, 11, 20, 4, 50));
      expect(await repo.roomToken('a1'), isA<RoomClosed>());
      expect(await repo.roomToken('a1'), isA<RoomUnavailable>());
    });

    test('she can stop the recording (AC52)', () async {
      adapter.reply(<String, dynamic>{'status': 'done'});
      await repo.stopRecording('a1');
      expect(adapter.last.path, '/appointments/a1/record/stop');
    });
  });
}
