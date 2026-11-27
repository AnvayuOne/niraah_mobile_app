import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/doctor/data/api_doctor_work_repository.dart';
import 'package:niraah/features/doctor/domain/doctor_work.dart';
import 'package:niraah/features/messaging/messaging.dart';
import 'package:niraah/features/provider_work/data/api_provider_work_repository.dart';
import 'package:niraah/features/provider_work/domain/provider_work.dart';

import '../helpers/fake_api.dart';

void main() {
  late FakeAdapter adapter;

  setUp(() => adapter = FakeAdapter());

  test('patients send only the filters chosen (spec 011 §2 rule 3)', () async {
    final ApiDoctorWorkRepository repo = ApiDoctorWorkRepository(fakeApi(adapter));
    adapter.reply(<String, dynamic>{
      'items': <Object>[
        <String, dynamic>{'id': 'm1', 'name': 'Asha', 'ageBand': '25-34', 'relationship': 'consult', 'plan': 'Essential', 'nextAppointment': null, 'openAlert': true, 'carePlanAwaiting': false},
      ],
    });
    final List<Json> rows = await repo.patients(const PatientFilters(search: ' Asha ', kind: 'consult', openAlert: true));
    expect(adapter.last.uri.queryParameters, <String, String>{'search': 'Asha', 'kind': 'consult', 'openAlert': 'true'});
    expect(rows.single.flag('openAlert'), isTrue);
  });

  test('a section without consent reads as not shared and carries no data (AC3)', () async {
    final ApiDoctorWorkRepository repo = ApiDoctorWorkRepository(fakeApi(adapter));
    adapter.reply(<String, dynamic>{'section': 'meals', 'shared': false});
    final Json d = await repo.section('m1', 'meals');
    expect(adapter.last.path, '/doctor/patients/m1/sections/meals');
    expect(d.flag('shared'), isFalse);
    expect(d.keys, unorderedEquals(<String>['section', 'shared']));
  });

  test('a section decision sends only what it needs; the AI text is never sent back (AC11, AC12)', () async {
    final ApiDoctorWorkRepository repo = ApiDoctorWorkRepository(fakeApi(adapter));
    adapter
      ..reply(<String, dynamic>{'id': 'p1'})
      ..reply(<String, dynamic>{'id': 'p1'});
    await repo.decide('p1', 'sleep', 'edited', text: 'Lights out by 10.');
    expect(adapter.last.method, 'PUT');
    expect(adapter.last.path, '/doctor/care-plans/p1/sections/sleep');
    expect(adapter.lastBody, <String, dynamic>{'decision': 'edited', 'text': 'Lights out by 10.'});
    await repo.decide('p1', 'sleep', 'accepted');
    expect(adapter.lastBody, <String, dynamic>{'decision': 'accepted'});
  });

  test('signing wellness advice carries the fresh proof from password and authenticator (AC22)', () async {
    final ApiDoctorWorkRepository repo = ApiDoctorWorkRepository(fakeApi(adapter));
    final ApiProviderWorkRepository work = ApiProviderWorkRepository(fakeApi(adapter));
    adapter
      ..reply(<String, dynamic>{'proofId': 'proof-9'})
      ..reply(<String, dynamic>{'id': 'rx1', 'status': 'signed'});
    final String proof = await work.freshStaff('secret', '123456');
    expect(adapter.lastBody, <String, dynamic>{'password': 'secret', 'code': '123456'});
    await repo.signPrescription('rx1', proof);
    expect(adapter.last.path, '/doctor/prescriptions/rx1/sign');
    expect(adapter.lastBody, <String, dynamic>{'proofId': 'proof-9'});
  });

  test('a lab comment that reads as a dose is resent only with her confirmation (AC43)', () async {
    final ApiDoctorWorkRepository repo = ApiDoctorWorkRepository(fakeApi(adapter));
    adapter.reply(<String, dynamic>{'id': 'r1', 'reviewed': true});
    await repo.reviewLab('r1', comment: 'Keep taking your thyroxine 50 mcg', confirmMedicines: true);
    expect(adapter.lastBody, <String, dynamic>{'comment': 'Keep taking your thyroxine 50 mcg', 'confirmMedicines': true});
  });

  test('the schedule asks for a UTC range, and cash-out posts nothing else (spec 008)', () async {
    final ApiProviderWorkRepository work = ApiProviderWorkRepository(fakeApi(adapter));
    adapter
      ..reply(<String, dynamic>{'appointments': <Object>[], 'reviewHours': <Object>[], 'timeZone': 'Asia/Kolkata'})
      ..reply(<String, dynamic>{'id': 'po1', 'status': 'requested'});
    await work.schedule(DateTime.utc(2026, 11, 17), DateTime.utc(2026, 12, 1));
    expect(adapter.last.uri.queryParameters, <String, String>{'from': '2026-11-17T00:00:00.000Z', 'to': '2026-12-01T00:00:00.000Z'});
    await work.requestPayout();
    expect(adapter.last.path, '/provider/payouts');
    expect(adapter.lastBody, isEmpty);
  });

  test('a doctor\'s message naming a medicine is held for confirmation, then sent with it (spec 011 §10 rule 3)', () async {
    final ApiMessagingRepository repo = ApiMessagingRepository(fakeApi(adapter));
    adapter
      ..reply(<String, dynamic>{
        'error': <String, dynamic>{'code': 'conflict', 'message': 'This reads as a medicine instruction.', 'details': <String, dynamic>{'reason': 'needs_confirmation'}},
      }, 409)
      ..reply(<String, dynamic>{'id': 'msg1', 'safety': null});
    await expectLater(repo.send('t1', 'Take metformin', 'c1'), throwsA(isA<NeedsConfirmation>()));
    await repo.send('t1', 'Take metformin', 'c1', confirmMedicines: true);
    expect(adapter.lastBody, <String, dynamic>{'body': 'Take metformin', 'clientId': 'c1', 'confirmMedicines': true});
  });
}
