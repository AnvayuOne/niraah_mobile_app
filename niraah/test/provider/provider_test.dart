import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/doctor/domain/doctor.dart';
import 'package:niraah/features/doctor/presentation/review_page.dart';
import 'package:niraah/features/provider_auth/domain/provider_auth.dart';
import 'package:niraah/sample/sample_doctor.dart';
import 'package:niraah/sample/sample_provider_auth.dart';

import '../helpers/pump_app.dart';

const String doctorEmail = 'doctor@sample.niraah.in';
const String samplePassword = 'niraah-sample-pass';

void main() {
  group('provider sign-in (spec 003)', () {
    test('AC4: an unknown email and a wrong password get the same answer', () async {
      final SampleProviderAuthRepository repo = SampleProviderAuthRepository();
      final StepResult unknown = await repo.checkPassword('nobody@example.com', samplePassword);
      final StepResult wrong = await repo.checkPassword(doctorEmail, 'not-the-password');
      expect(unknown.failure, StepFailure.generic);
      expect(wrong.failure, StepFailure.generic);
    });

    test('AC20: a correct password never signs in on its own', () async {
      final SampleProviderAuthRepository repo = SampleProviderAuthRepository();
      expect((await repo.checkPassword(doctorEmail, samplePassword)).ok, isTrue);
      expect(await repo.currentSession(), isNull);
      expect(await repo.verifySecondFactor('12345', SecondFactorKind.authenticator), isNull);
      final ProviderSession? s = await repo.verifySecondFactor('123456', SecondFactorKind.authenticator);
      expect(s?.role, ProviderRole.doctor);
      expect(await repo.currentSession(), s);
    });

    test('a recovery code in the xxxx-xxxx form works in place of the authenticator', () async {
      final SampleProviderAuthRepository repo = SampleProviderAuthRepository();
      await repo.checkPassword(doctorEmail, samplePassword);
      expect(await repo.verifySecondFactor('abcd', SecondFactorKind.recovery), isNull);
      expect(await repo.verifySecondFactor('ab12-cd34', SecondFactorKind.recovery), isNotNull);
    });

    test('ten wrong passwords in 15 minutes lock password sign-in, even for the right one', () async {
      DateTime now = DateTime(2026, 11, 15, 10);
      final SampleProviderAuthRepository repo = SampleProviderAuthRepository(clock: () => now);
      for (int i = 0; i < 10; i++) {
        expect((await repo.checkPassword(doctorEmail, 'wrong-$i')).failure, StepFailure.generic);
      }
      expect((await repo.checkPassword(doctorEmail, samplePassword)).failure, StepFailure.locked);
      now = now.add(const Duration(minutes: 16));
      expect((await repo.checkPassword(doctorEmail, samplePassword)).ok, isTrue);
    });

    test('AC5 routing: each role goes to its workspace, and under review to the status page', () {
      ProviderSession s(ProviderRole r, ProviderStatus st) => ProviderSession(role: r, status: st, name: 'x', speciality: 'y');
      expect(homeFor(s(ProviderRole.doctor, ProviderStatus.active)), '/doctor');
      expect(homeFor(s(ProviderRole.dietitian, ProviderStatus.active)), '/dietitian');
      expect(homeFor(s(ProviderRole.instructor, ProviderStatus.active)), '/instructor');
      expect(homeFor(s(ProviderRole.doctor, ProviderStatus.underReview)), '/provider/status');
    });

    test('the pending sample account signs in to the status page with what is still needed', () async {
      final SampleProviderAuthRepository repo = SampleProviderAuthRepository();
      await repo.checkPassword('pending@sample.niraah.in', samplePassword);
      final ProviderSession s = (await repo.verifySecondFactor('000000', SecondFactorKind.authenticator))!;
      expect(homeFor(s), '/provider/status');
      expect(s.missing, <String>['Registration certificate', 'Two professional references']);
    });

    test('set-up: a bad invite, short and breached passwords are refused; ten codes; under review after', () async {
      final SampleProviderAuthRepository repo = SampleProviderAuthRepository();
      expect(await repo.getInvite('no-such-invite'), isNull);
      final InviteInfo invite = (await repo.getInvite('sample-invite-doctor'))!;
      expect(invite.name, 'Dr Kavitha Iyer');
      expect(await repo.setPassword('sample-invite-doctor', 'short'), PasswordRejection.tooShort);
      expect(await repo.setPassword('sample-invite-doctor', 'Password1234'), PasswordRejection.breached);
      expect(await repo.setPassword('sample-invite-doctor', 'a long enough passphrase'), isNull);
      expect(await repo.confirmAuthenticator('sample-invite-doctor', '12ab56'), isNull);
      final List<String> codes = (await repo.confirmAuthenticator('sample-invite-doctor', '123456'))!;
      expect(codes, hasLength(10));
      expect(codes.every((String c) => RegExp(r'^[a-z0-9]{4}-[a-z0-9]{4}$').hasMatch(c)), isTrue);
      final ProviderSession s = await repo.finishSetup('sample-invite-doctor');
      expect(s.status, ProviderStatus.underReview);
      expect(homeFor(s), '/provider/status');
    });
  });

  group('doctor workspace (spec 011, spec 007 §7)', () {
    test('queue order: urgent, my dedicated member, attention, then the rest oldest first', () async {
      expect((await SampleDoctorRepository().getQueue()).map((QueueItem q) => q.id), <String>['rev-1', 'rev-2', 'rev-3', 'rev-4']);
    });

    test('AC6: the reviews count equals the queue, before and after a review is completed', () async {
      final SampleDoctorRepository repo = SampleDoctorRepository();
      DoctorDashboard d = await repo.getDashboard();
      expect(d.needsMe.reviews, (await repo.getQueue()).length);
      expect(<int>[d.needsMe.urgentAlerts, d.needsMe.carePlans, d.needsMe.labResults, d.needsMe.messages, d.needsMe.draftPrescriptions], everyElement(0));
      await repo.claim('rev-1');
      await repo.complete('rev-1', ReviewOutcome.verified, '');
      d = await repo.getDashboard();
      expect(d.needsMe.reviews, 3);
      expect((await repo.getQueue()).length, 3);
    });

    test('AC47: one claim at a time; reopening her own claim is fine; a done review is gone', () async {
      final SampleDoctorRepository repo = SampleDoctorRepository();
      expect((await repo.claim('rev-1')).review, isNotNull);
      expect((await repo.claim('rev-2')).failure, ClaimFailure.holdingAnother);
      expect((await repo.claim('rev-1')).review, isNotNull);
      await repo.release('rev-1');
      expect((await repo.claim('rev-2')).review, isNotNull);
      await repo.complete('rev-2', ReviewOutcome.verified, '');
      expect((await repo.claim('rev-2')).failure, ClaimFailure.gone);
    });

    test('a claim lapses after 30 minutes', () async {
      DateTime now = DateTime(2026, 11, 15, 10);
      final SampleDoctorRepository repo = SampleDoctorRepository(clock: () => now);
      await repo.claim('rev-1');
      now = now.add(const Duration(minutes: 31));
      expect((await repo.claim('rev-2')).review, isNotNull);
    });

    test('editing keeps the original beside it; removing and restoring work', () async {
      final SampleDoctorRepository repo = SampleDoctorRepository();
      await repo.claim('rev-1');
      ReviewDetail d = await repo.editObservation('rev-1', 0, 'Please book a visit with a doctor soon.');
      expect(d.observations[0].edited, 'Please book a visit with a doctor soon.');
      expect(d.observations[0].original, "Your answers suggest a doctor's view would be helpful.");
      d = await repo.editObservation('rev-1', 1, null);
      expect(d.observations[1].removed, isTrue);
      d = await repo.editObservation('rev-1', 1, d.observations[1].original);
      expect(d.observations[1].changed, isFalse);
    });

    test('a follow-up needs a note; verify returns the next review', () async {
      final SampleDoctorRepository repo = SampleDoctorRepository();
      await repo.claim('rev-1');
      expect((await repo.complete('rev-1', ReviewOutcome.followUp, '  ')).noteRequired, isTrue);
      // As on the server, only "Verify and next" claims and returns the next review.
      expect((await repo.complete('rev-1', ReviewOutcome.verified, 'Looks right.', next: true)).next, 'rev-2');
      await repo.scoringConcern('rev-2', 'Rest seems low for her answers.');
      expect(repo.concerns.single.$1, 'rev-2');
    });

    testWidgets('the review screen leads with the AI summary and shows the locked score', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final SampleDoctorRepository repo = SampleDoctorRepository();
      await tester.pumpWidget(wrapApp(ReviewPage(reviewId: 'rev-1', repository: repo), reducedMotion: true, size: const Size(390, 2600)));
      await tester.pumpAndSettle();
      expect(find.text('AI clinician summary'), findsOneWidget);
      expect(find.text('35 out of 100 · Needs care'), findsOneWidget);
      expect(find.text("Score, band and flags come from the questionnaire's rules and can't be changed here."), findsOneWidget);
      expect(find.text('Assessment · View'), findsOneWidget);
      expect(find.text('Meals · No consent'), findsOneWidget);
      expect(find.text('Urgent · Heavy bleeding'), findsOneWidget);
      expect(tester.getTopLeft(find.text('AI clinician summary')).dy, lessThan(tester.getTopLeft(find.text('Her answers')).dy));
    });
  });
}
