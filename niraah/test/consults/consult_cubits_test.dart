import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/errors/api_exception.dart';
import 'package:niraah/features/consults/domain/consults.dart';
import 'package:niraah/features/consults/presentation/consult_cubits.dart';
import 'package:niraah/shared/area/area_access.dart';

Appointment appt({String id = 'a1', String status = 'confirmed', DateTime? starts, DateTime? holdUntil, String kind = 'included'}) {
  final DateTime s = starts ?? DateTime(2026, 11, 20, 10);
  return Appointment(
    id: id,
    status: status,
    kind: kind,
    providerType: 'doctor',
    startsAt: s,
    endsAt: s.add(const Duration(minutes: 30)),
    feePaise: kind == 'paid' ? 80000 : 0,
    holdExpiresAt: holdUntil,
    clinicianId: 'd1',
    clinicianName: 'Dr Asha Rao',
    pooled: false,
    reschedulesLeft: 2,
    roomOpensAt: s.subtract(const Duration(minutes: 10)),
    recording: false,
  );
}

const Specialist doctor = Specialist(
  id: 'd1',
  type: 'doctor',
  name: 'Dr Asha Rao',
  title: 'Doctor',
  hasPhoto: false,
  specialities: <String>[],
  languages: <String>[],
  yearsExperience: null,
  bio: null,
  nextSlot: null,
  feePaise: 80000,
  ratingAverage: null,
  ratingCount: 0,
  registrationNumber: 'KMC-1',
  registrationCouncil: 'KMC',
  dedicated: false,
  label: null,
);

class FakeConsults implements ConsultsRepository {
  Future<List<Specialist>> Function(DirectoryFilters) onSpecialists = (_) async => const <Specialist>[doctor];
  Future<List<IncludedConsults>> Function() onIncluded = () async => const <IncludedConsults>[];
  Future<ConfirmOutcome> Function(List<String>) onConfirm = (_) async => Confirmed(appt());
  List<Appointment> list = <Appointment>[];
  Appointment current = appt();
  final List<String> calls = <String>[];
  List<String>? sentConsents;
  bool? sentRecordConsent;

  @override
  Future<List<Specialist>> specialists(DirectoryFilters filters) {
    calls.add('specialists:${filters.type}');
    return onSpecialists(filters);
  }

  @override
  Future<List<IncludedConsults>> included() => onIncluded();

  @override
  Future<ConfirmOutcome> confirm(String id, {required List<String> consents, String? reason, bool? recordConsent}) {
    sentConsents = consents;
    sentRecordConsent = recordConsent;
    return onConfirm(consents);
  }

  @override
  Future<String> cancel(String id) async {
    calls.add('cancel');
    return 'unit_returned';
  }

  @override
  Future<List<Appointment>> appointments() async => list;

  @override
  Future<Appointment> appointment(String id) async {
    calls.add('get');
    return current;
  }

  @override
  Future<Appointment> reschedule(String id, DateTime startsAt) async => throw ApiException(message: 'An appointment can be moved 2 times.', statusCode: 409);

  @override
  Future<FailureReport> reportFailure(String id) async => const FailureReport(memberChoice: true, options: <String>['rebook', 'refund']);

  @override
  Future<Appointment> rebook(String id, DateTime startsAt, {String? providerId}) async => appt(id: 'a2');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SpecialistsCubit (spec 014 §2)', () {
    test('loads the list for her filters, with her included consults (spec 010 §9.2)', () async {
      final FakeConsults repo = FakeConsults()..onIncluded = () async => const <IncludedConsults>[IncludedConsults(type: 'doctor', remaining: 1, allowance: 2, refillsAt: null)];
      final SpecialistsCubit c = SpecialistsCubit(repo);
      await c.load(const DirectoryFilters(type: 'doctor'));
      expect(c.state.status, LoadStatus.ready);
      expect(c.state.specialists.single.id, 'd1');
      expect(c.state.included.single.remaining, 1);
      expect(repo.calls, <String>['specialists:doctor']);
    });

    test('the list stands when entitlements cannot be read', () async {
      final FakeConsults repo = FakeConsults()..onIncluded = () async => throw ApiException(message: 'x');
      final SpecialistsCubit c = SpecialistsCubit(repo);
      await c.load();
      expect(c.state.status, LoadStatus.ready);
      expect(c.state.included, isEmpty);
    });

    test('a locked area is kept as the error, to show its state (spec 010 AC48)', () async {
      final FakeConsults repo = FakeConsults()..onSpecialists = (_) async => throw const AreaLocked(message: 'Not on your plan', status: 'locked');
      final SpecialistsCubit c = SpecialistsCubit(repo);
      await c.load();
      expect(c.state.status, LoadStatus.failure);
      expect(c.state.error, isA<AreaLocked>());
    });
  });

  group('SlotsCubit', () {
    test('reads a week at a time and never past the horizon', () async {
      final List<(DateTime, DateTime)> asked = <(DateTime, DateTime)>[];
      final DateTime now = DateTime(2026, 11, 18, 9);
      final SlotsCubit c = SlotsCubit((DateTime from, DateTime to) async {
        asked.add((from, to));
        return const SlotList(slots: <Slot>[], feePaise: 0, included: true);
      }, clock: () => now, horizonDays: 14);
      await c.load();
      expect(asked.single, (now, now.add(const Duration(days: 7))));
      expect(c.canGoEarlier, isFalse);
      expect(c.canGoLater, isTrue);
      await c.later();
      expect(c.state.from, now.add(const Duration(days: 7)));
      expect(c.canGoLater, isFalse);
      await c.earlier();
      expect(c.state.from, now);
    });

    test('a failure keeps the error for "Try again"', () async {
      final SlotsCubit c = SlotsCubit((_, _) async => throw ApiException(message: 'no'));
      await c.load();
      expect(c.state.status, LoadStatus.failure);
    });
  });

  group('ConfirmCubit (spec 014 §3 "Steps" 2-5)', () {
    test('sends only the categories she agreed to, in order (AC15)', () async {
      final FakeConsults repo = FakeConsults();
      final ConfirmCubit c = ConfirmCubit(repo, appt(status: 'held', holdUntil: DateTime(2026, 11, 18, 9, 10)), clock: () => DateTime(2026, 11, 18, 9));
      c
        ..toggle('meals', true)
        ..toggle('health_data', true)
        ..toggle('meals', false)
        ..toggle('cycle_symptoms', true);
      final ConfirmOutcome? o = await c.confirm('cramps');
      expect(repo.sentConsents, <String>['health_data', 'cycle_symptoms']);
      expect(o, isA<Confirmed>());
      expect(c.state.appointment.confirmed, isTrue);
    });

    test('declining everything sends no category', () async {
      final FakeConsults repo = FakeConsults();
      await ConfirmCubit(repo, appt(status: 'held')).confirm(null);
      expect(repo.sentConsents, isEmpty);
    });

    test('the hold counts down and expires (AC10)', () {
      DateTime now = DateTime(2026, 11, 18, 9);
      final ConfirmCubit c = ConfirmCubit(FakeConsults(), appt(status: 'held', holdUntil: DateTime(2026, 11, 18, 9, 10)), clock: () => now);
      expect(c.remaining, const Duration(minutes: 10));
      expect(c.expired, isFalse);
      now = DateTime(2026, 11, 18, 9, 11);
      expect(c.remaining, Duration.zero);
      expect(c.expired, isTrue);
    });

    test('a paid consult reports payment needed, and the hold can be released', () async {
      final FakeConsults repo = FakeConsults()..onConfirm = (_) async => const PaymentNeeded(80000);
      final ConfirmCubit c = ConfirmCubit(repo, appt(status: 'held', kind: 'paid'));
      expect(await c.confirm(null), isA<PaymentNeeded>());
      await c.release();
      expect(repo.calls, contains('cancel'));
    });

    test('a refusal is kept with the server words', () async {
      final FakeConsults repo = FakeConsults()..onConfirm = (_) async => throw ApiException(message: 'Your hold has ended. Choose a time again.');
      final ConfirmCubit c = ConfirmCubit(repo, appt(status: 'held'));
      expect(await c.confirm(null), isNull);
      expect(failureText(c.state.error!, ''), 'Your hold has ended. Choose a time again.');
    });
  });

  test('AppointmentsCubit puts upcoming first, soonest first, and past newest first (spec 010 §9.3)', () async {
    final DateTime now = DateTime(2026, 11, 18, 12);
    final FakeConsults repo = FakeConsults()
      ..list = <Appointment>[
        appt(id: 'past', status: 'completed', starts: DateTime(2026, 11, 10)),
        appt(id: 'later', starts: DateTime(2026, 11, 25)),
        appt(id: 'soon', starts: DateTime(2026, 11, 19)),
        appt(id: 'gone', status: 'cancelled', starts: DateTime(2026, 11, 21)),
      ];
    final AppointmentsCubit c = AppointmentsCubit(repo, clock: () => now);
    await c.load();
    expect(c.state.upcoming.map((Appointment a) => a.id), <String>['soon', 'later']);
    expect(c.state.past.map((Appointment a) => a.id), <String>['gone', 'past']);
  });

  group('AppointmentCubit (spec 014 §6)', () {
    test('cancel reports the outcome and reads the appointment again (AC35)', () async {
      final FakeConsults repo = FakeConsults();
      final AppointmentCubit c = AppointmentCubit(repo, 'a1');
      await c.load();
      final ActionResult r = await c.cancel();
      expect(r.outcome, 'unit_returned');
      expect(repo.calls.where((String x) => x == 'get').length, 2);
    });

    test('a refused move keeps the server words (AC34)', () async {
      final AppointmentCubit c = AppointmentCubit(FakeConsults(), 'a1');
      await c.load();
      final ActionResult r = await c.reschedule(DateTime(2026, 11, 21));
      expect(r.ok, isFalse);
      expect(failureText(r.error!, ''), 'An appointment can be moved 2 times.');
      expect(c.state.busy, isFalse);
    });

    test('a failed call with too little time together offers her the choice; rebooking names the new appointment (AC38)', () async {
      final AppointmentCubit c = AppointmentCubit(FakeConsults(), 'a1');
      await c.load();
      expect((await c.reportFailure()).outcome, 'member_choice');
      expect(c.state.failure!.options, <String>['rebook', 'refund']);
      expect((await c.rebook(DateTime(2026, 11, 22))).outcome, 'a2');
    });

    test('"the call did not work" is offered from the start until a day after the end', () async {
      DateTime now = DateTime(2026, 11, 20, 9);
      final FakeConsults repo = FakeConsults()..current = appt(starts: DateTime(2026, 11, 20, 10));
      final AppointmentCubit c = AppointmentCubit(repo, 'a1', clock: () => now);
      await c.load();
      expect(c.canReportFailure, isFalse);
      now = DateTime(2026, 11, 20, 10, 5);
      expect(c.canReportFailure, isTrue);
      now = DateTime(2026, 11, 21, 11);
      expect(c.canReportFailure, isFalse);
    });
  });
}
