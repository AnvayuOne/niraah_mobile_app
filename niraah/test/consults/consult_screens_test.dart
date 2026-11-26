import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/core/errors/api_exception.dart';
import 'package:niraah/features/consults/domain/consults.dart';
import 'package:niraah/features/consults/presentation/appointments_pages.dart';
import 'package:niraah/features/consults/presentation/booking_pages.dart';
import 'package:niraah/features/consults/presentation/consult_room_page.dart';
import 'package:niraah/features/consults/presentation/specialists_page.dart';
import 'package:niraah/shared/area/area_access.dart';

import '../helpers/fake_video.dart';
import '../helpers/pump_app.dart';
import 'consult_cubits_test.dart' show FakeConsults, appt;

class _RoomRepo extends FakeConsults {
  _RoomRepo(this.access);

  final RoomAccess access;

  @override
  Future<RoomAccess> roomToken(String id) async => access;
}

void main() {
  testWidgets('Find a specialist shows the wellness line, included consults left and each clinician with fee incl. GST (spec 010 §9, AC51)', (WidgetTester t) async {
    final FakeConsults repo = FakeConsults()..onIncluded = () async => const <IncludedConsults>[IncludedConsults(type: 'doctor', remaining: 1, allowance: 2, refillsAt: null)];
    await t.pumpApp(FindSpecialistPage(repository: repo));
    await t.pumpAndSettle();
    expect(find.textContaining('does not replace your own doctor'), findsOneWidget);
    expect(find.text('Doctor consults included: 1 left'), findsOneWidget);
    await t.scrollUntilVisible(find.text('₹800 incl. GST'), 200);
    expect(find.text('Dr Asha Rao'), findsOneWidget);
    expect(find.text('₹800 incl. GST'), findsOneWidget);
    expect(find.text('Not sure who to see?'), findsOneWidget);
  });

  testWidgets('Find a specialist: empty, error and locked states (spec 010 AC3, AC48)', (WidgetTester t) async {
    final FakeConsults repo = FakeConsults()..onSpecialists = (_) async => const <Specialist>[];
    await t.pumpApp(FindSpecialistPage(repository: repo));
    await t.pumpAndSettle();
    expect(find.textContaining('No specialist has free time'), findsOneWidget);

    repo.onSpecialists = (_) async => throw ApiException(message: 'x');
    await t.pumpApp(FindSpecialistPage(key: UniqueKey(), repository: repo));
    await t.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);

    repo.onSpecialists = (_) async => throw const AreaLocked(message: "Specialists isn't on your plan.", status: 'locked', plans: <String>['Complete']);
    await t.pumpApp(FindSpecialistPage(key: UniqueKey(), repository: repo));
    await t.pumpAndSettle();
    expect(find.text("Specialists isn't on your plan."), findsOneWidget);
    expect(find.text('See plans'), findsOneWidget);
  });

  testWidgets('a confirmed upcoming consult offers join, move, cancel and the proposal link (spec 014 §5, §6)', (WidgetTester t) async {
    final FakeConsults repo = FakeConsults()..current = appt(starts: DateTime.now().add(const Duration(days: 2)));
    await t.pumpApp(AppointmentPage(appointmentId: 'a1', repository: repo));
    await t.pumpAndSettle();
    expect(find.text('Booked'), findsOneWidget);
    expect(find.text('Join the consult'), findsOneWidget);
    expect(find.text('Move to another time'), findsOneWidget);
    expect(find.text('Cancel consult'), findsOneWidget);
    expect(find.text('My clinician suggested another time'), findsOneWidget);
    expect(find.text('Rate this consult'), findsNothing);
  });

  testWidgets('cancelling says what she gets back, then the outcome (AC35)', (WidgetTester t) async {
    final FakeConsults repo = FakeConsults()..current = appt(starts: DateTime.now().add(const Duration(days: 2)));
    await t.pumpApp(AppointmentPage(appointmentId: 'a1', repository: repo));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Cancel consult'));
    await t.tap(find.text('Cancel consult'));
    await t.pumpAndSettle();
    expect(find.textContaining('goes back to your plan'), findsOneWidget);
    await t.tap(find.widgetWithText(FilledButton, 'Cancel consult'));
    await t.pumpAndSettle();
    expect(find.text('Cancelled. The consult is back in your plan.'), findsOneWidget);
  });

  testWidgets('a finished consult can be rated and leads to wellness advice (AC33; spec 010 §9.3)', (WidgetTester t) async {
    final FakeConsults repo = FakeConsults()..current = appt(status: 'completed', starts: DateTime.now().subtract(const Duration(days: 3)));
    await t.pumpApp(AppointmentPage(appointmentId: 'a1', repository: repo));
    await t.pumpAndSettle();
    expect(find.text('Rate this consult'), findsOneWidget);
    expect(find.text('Wellness advice from your doctor'), findsOneWidget);
    expect(find.text('Join the consult'), findsNothing);
  });

  testWidgets('confirming shows the hold time and the consent choices; a pooled clinician is not named yet (§3)', (WidgetTester t) async {
    final Appointment held = Appointment(
      id: 'a1',
      status: 'held',
      kind: 'included',
      providerType: 'doctor',
      startsAt: DateTime(2026, 11, 20, 10),
      endsAt: DateTime(2026, 11, 20, 10, 30),
      feePaise: 0,
      holdExpiresAt: DateTime.now().add(const Duration(minutes: 9, seconds: 30)),
      clinicianId: 'd1',
      clinicianName: 'Dr Asha Rao',
      pooled: true,
      reschedulesLeft: 2,
      roomOpensAt: DateTime(2026, 11, 20, 9, 50),
      recording: false,
    );
    await t.pumpApp(ConfirmBookingPage(repository: FakeConsults(), held: held));
    await t.pump();
    expect(find.text('Dr Asha Rao'), findsNothing);
    expect(find.textContaining('named when you confirm'), findsOneWidget);
    expect(find.textContaining('This time is held for you for 9:'), findsOneWidget);
    expect(find.text('Included in your plan'), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, 'My health information'), findsOneWidget);
    await t.scrollUntilVisible(find.widgetWithText(CheckboxListTile, 'My messages'), 200);
    expect(find.byType(CheckboxListTile), findsWidgets);
  });

  testWidgets('the room says when it opens; with a token it explains and asks for camera and microphone, with the recording mark (AC20, AC51; §5 "Entering" 3)', (WidgetTester t) async {
    await t.pumpApp(ConsultRoomPage(appointmentId: 'a1', repository: _RoomRepo(RoomNotOpen(opensAt: DateTime(2026, 11, 20, 9, 50), message: 'x')), engines: FakeVideoEngine.new, permissions: FakePermissions()));
    await t.pumpAndSettle();
    expect(find.text("The room isn't open yet"), findsOneWidget);
    expect(find.text('Check again'), findsOneWidget);

    await t.pumpApp(ConsultRoomPage(
      key: UniqueKey(),
      appointmentId: 'a1',
      repository: _RoomRepo(RoomReady(appId: 'a', channel: 'c', uid: 1, token: 't', expiresAt: DateTime(2026, 11, 20, 11), closesAt: DateTime(2026, 11, 20, 10, 40), recording: true)),
      engines: FakeVideoEngine.new,
      permissions: FakePermissions(),
    ));
    await t.pumpAndSettle();
    expect(find.text('Camera and microphone'), findsOneWidget);
    expect(find.text('Allow camera and microphone'), findsOneWidget);
    expect(find.text('Recording'), findsOneWidget);
    expect(find.text('Stop recording'), findsOneWidget);
  });
}
