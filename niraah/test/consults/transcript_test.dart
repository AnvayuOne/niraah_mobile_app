import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/consults/data/api_consults_repository.dart';
import 'package:niraah/features/consults/domain/consults.dart';
import 'package:niraah/features/consults/presentation/appointments_pages.dart';
import 'package:niraah/features/consults/presentation/booking_pages.dart';
import 'package:niraah/features/consults/presentation/transcript_page.dart';

import '../helpers/fake_api.dart';
import '../helpers/pump_app.dart';
import 'consult_cubits_test.dart' show FakeConsults;

// Spec 014 §5 "Recording" 3 and "Reading a transcript" (product owner, 2026-11-25; constitution §7.13): one transcript
// consent at booking that names her care team, and her transcript as text, unverified, speakers by role.

Appointment _appt({String status = 'held', String recordMode = 'transcript', bool ask = true, String? transcript, String providerType = 'doctor'}) => Appointment(
      id: 'a1',
      status: status,
      kind: 'included',
      providerType: providerType,
      startsAt: DateTime(2026, 11, 20, 10),
      endsAt: DateTime(2026, 11, 20, 10, 30),
      feePaise: 0,
      holdExpiresAt: status == 'held' ? DateTime.now().add(const Duration(minutes: 9)) : null,
      clinicianId: 'd1',
      clinicianName: 'Dr Asha Rao',
      pooled: false,
      reschedulesLeft: 2,
      roomOpensAt: DateTime(2026, 11, 20, 9, 50),
      recording: false,
      recordMode: recordMode,
      askTranscriptConsent: ask,
      transcript: transcript,
    );

const ConsultTranscript _ready = ConsultTranscript(
  status: 'ready',
  partial: false,
  missing: <String>[],
  lines: <TranscriptLine>[
    TranscriptLine(speaker: 'doctor', startSeconds: 0, text: 'How have your cycles been?'),
    TranscriptLine(speaker: 'member', startSeconds: 65, text: 'Longer than usual.'),
  ],
);

class _TranscriptRepo extends FakeConsults {
  _TranscriptRepo(this.result);
  final ConsultTranscript result;
  int reads = 0;

  @override
  Future<ConsultTranscript> transcript(String id) async {
    reads++;
    return result;
  }
}

void main() {
  group('transcript consent at booking (spec 014 §5 "Recording" 3, AC63)', () {
    testWidgets('asked when the server asks: draft wording, names the care team, one yes sent with no separate share choice', (WidgetTester t) async {
      final FakeConsults repo = FakeConsults();
      await t.pumpApp(ConfirmBookingPage(repository: repo, held: _appt()));
      await t.pump();
      await t.scrollUntilVisible(find.text('Yes, make a transcript of this consult'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('Draft wording, pending legal review'), findsOneWidget);
      expect(find.textContaining('your doctor or dietitian caring for you now'), findsOneWidget);
      expect(find.textContaining('read this transcript'), findsNothing);
      await t.ensureVisible(find.text('Yes, make a transcript of this consult'));
      await t.pumpAndSettle();
      await t.tap(find.text('Yes, make a transcript of this consult'));
      await t.pump();
      await t.scrollUntilVisible(find.text('Confirm consult'), 200, scrollable: find.byType(Scrollable).first);
      await t.ensureVisible(find.text('Confirm consult'));
      await t.pumpAndSettle();
      await t.tap(find.text('Confirm consult'));
      await t.pump();
      expect(repo.sentRecordConsent, isTrue);
    });

    testWidgets('not asked when the server does not ask; nothing about a record is sent', (WidgetTester t) async {
      final FakeConsults repo = FakeConsults();
      await t.pumpApp(ConfirmBookingPage(repository: repo, held: _appt(ask: false)));
      await t.pump();
      expect(find.text('A written transcript of this consult'), findsNothing);
      await t.scrollUntilVisible(find.text('Confirm consult'), 200, scrollable: find.byType(Scrollable).first);
      await t.ensureVisible(find.text('Confirm consult'));
      await t.pumpAndSettle();
      await t.tap(find.text('Confirm consult'));
      await t.pump();
      expect(repo.sentRecordConsent, isNull);
    });
  });

  group('reading her transcript (spec 014 §5 "Reading a transcript")', () {
    testWidgets('AC58, AC62: the appointment offers it; it opens only when asked, marked unverified, her lines as "You"', (WidgetTester t) async {
      final _TranscriptRepo repo = _TranscriptRepo(_ready)..current = _appt(status: 'completed', transcript: 'ready');
      await t.pumpApp(AppointmentPage(appointmentId: 'a1', repository: repo));
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.text('Read the transcript'), 200);
      expect(find.textContaining('your doctor or dietitian caring for you now can read it'), findsOneWidget);
      expect(repo.reads, 0);
      await t.tap(find.text('Read the transcript'));
      await t.pumpAndSettle();
      expect(repo.reads, 1);
      expect(find.textContaining('not checked by a person'), findsOneWidget);
      expect(find.text('Longer than usual.'), findsOneWidget);
      expect(find.text('You  ·  1:05'), findsOneWidget);
      expect(find.text('Doctor  ·  0:00'), findsOneWidget);
    });

    testWidgets('§5 "Reading a transcript" 8: still being made says so; a consult without one shows nothing', (WidgetTester t) async {
      final FakeConsults repo = FakeConsults()..current = _appt(status: 'completed', transcript: 'pending');
      await t.pumpApp(AppointmentPage(appointmentId: 'a1', repository: repo));
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.textContaining('being written up'), 200);
      expect(find.text('Read the transcript'), findsNothing);

      repo.current = _appt(status: 'completed');
      await t.pumpApp(AppointmentPage(key: UniqueKey(), appointmentId: 'a1', repository: repo));
      await t.pumpAndSettle();
      expect(find.text('Consult transcript'), findsNothing);
    });

    testWidgets('the transcript page says when a part could not be transcribed', (WidgetTester t) async {
      const ConsultTranscript partial = ConsultTranscript(status: 'ready', partial: true, missing: <String>['dietitian'], lines: <TranscriptLine>[TranscriptLine(speaker: 'member', startSeconds: null, text: 'Hello.')]);
      await t.pumpApp(TranscriptPage(appointmentId: 'a1', repository: _TranscriptRepo(partial)));
      await t.pumpAndSettle();
      expect(find.textContaining('stopped part-way'), findsOneWidget);
      expect(find.text("The dietitian's voice could not be transcribed."), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
    });
  });

  group('API (spec 014 §5)', () {
    test('reads the transcript fields, sends the record consent only when given, and parses a transcript', () async {
      final FakeAdapter adapter = FakeAdapter();
      final ApiConsultsRepository repo = ApiConsultsRepository(fakeApi(adapter));
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'a1', 'status': 'held', 'kind': 'included', 'providerType': 'doctor',
        'startsAt': '2026-11-20T05:00:00.000Z', 'endsAt': '2026-11-20T05:30:00.000Z', 'feePaise': 0,
        'holdExpiresAt': '2026-11-18T10:10:00.000Z', 'clinician': <String, dynamic>{'id': 'd1', 'name': 'Dr Asha Rao'},
        'pooled': false, 'reschedulesLeft': 2, 'roomOpensAt': '2026-11-20T04:50:00.000Z', 'recording': false,
        'recordMode': 'transcript', 'recordConsentDraft': true, 'transcript': null,
      };
      adapter.reply(json);
      final Appointment a = await repo.appointment('a1');
      expect(a.recordMode, 'transcript');
      expect(a.askTranscriptConsent, isTrue);
      expect(a.transcript, isNull);

      adapter.reply(<String, dynamic>{'status': 'confirmed', 'appointment': json});
      await repo.confirm('a1', consents: <String>['health_data'], recordConsent: true);
      expect(adapter.lastBody, containsPair('recordConsent', true));
      adapter.reply(<String, dynamic>{'status': 'confirmed', 'appointment': json});
      await repo.confirm('a1', consents: <String>['health_data']);
      expect(adapter.lastBody.containsKey('recordConsent'), isFalse);

      adapter.reply(<String, dynamic>{
        'appointmentId': 'a1', 'providerType': 'doctor', 'startsAt': '2026-11-20T05:00:00.000Z', 'access': 'member', 'status': 'ready',
        'unverified': true, 'language': 'en-IN', 'partial': false, 'missing': <String>[],
        'segments': <Map<String, dynamic>>[<String, dynamic>{'speaker': 'doctor', 'startSeconds': 1.5, 'endSeconds': 3, 'text': 'Good morning.'}],
      });
      final ConsultTranscript t = await repo.transcript('a1');
      expect(adapter.last.path, endsWith('/appointments/a1/transcript'));
      expect(t.status, 'ready');
      expect(t.lines.single, const TranscriptLine(speaker: 'doctor', startSeconds: 1.5, text: 'Good morning.'));
    });
  });
}
