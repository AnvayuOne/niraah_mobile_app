// Renders the consult and live-class screens ("Soft blush clinic") to PNG at 360 and 412 wide for visual review.
// Runs only when SCREENSHOT_DIR is set:
//   SCREENSHOT_DIR=<dir> flutter test test/screenshots/consults_screenshot_test.dart
// A layout overflow fails the test, so a clean run also means nothing overflows at these widths.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/features/consults/domain/consults.dart';
import 'package:niraah/features/consults/presentation/appointments_pages.dart';
import 'package:niraah/features/consults/presentation/booking_pages.dart';
import 'package:niraah/features/consults/presentation/specialists_page.dart';
import 'package:niraah/features/practice/domain/practice.dart';
import 'package:niraah/features/practice/presentation/practice_page.dart';
import 'package:niraah/l10n/app_localizations.dart';

import '../consults/consult_cubits_test.dart' show FakeConsults, appt;
import '../member_areas/member_screens_test.dart' show gentle;

final String? _out = Platform.environment['SCREENSHOT_DIR'];
const GlobalObjectKey<State<StatefulWidget>> _boundary = GlobalObjectKey<State<StatefulWidget>>('consults-shot');

DateTime _at(int days, int hour, [int minute = 0]) {
  final DateTime n = DateTime.now();
  return DateTime(n.year, n.month, n.day + days, hour, minute);
}

Specialist _spec(String id, String type, String name, String title, {String? label, int fee = 80000, double? rating, int count = 0, List<String> specialities = const <String>[], List<String> languages = const <String>[], int? years, DateTime? next, String? bio}) =>
    Specialist(
      id: id,
      type: type,
      name: name,
      title: title,
      hasPhoto: false,
      specialities: specialities,
      languages: languages,
      yearsExperience: years,
      bio: bio,
      nextSlot: next,
      feePaise: fee,
      ratingAverage: rating,
      ratingCount: count,
      registrationNumber: type == 'doctor' ? 'KMC-48211' : null,
      registrationCouncil: type == 'doctor' ? 'Karnataka Medical Council' : null,
      dedicated: label != null,
      label: label,
    );

final List<Specialist> _people = <Specialist>[
  _spec('d1', 'doctor', 'Dr Asha Rao', 'Gynaecologist',
      label: 'Your doctor', rating: 4.8, count: 126, specialities: <String>['PCOS', 'Fertility', 'Menstrual health'], languages: <String>['English', 'Kannada', 'Hindi'], years: 12, next: _at(1, 10, 30),
      bio: 'Gynaecologist with twelve years of PCOS and menopause care. Gentle, unhurried consults.'),
  _spec('n1', 'dietitian', 'Ritu Kapoor', 'Clinical dietitian', fee: 60000, rating: 4.9, count: 84, specialities: <String>['PCOS nutrition', 'Thyroid'], languages: <String>['English', 'Hindi'], years: 8, next: _at(0, 17)),
];

class _Repo extends FakeConsults {
  @override
  Future<List<Specialist>> specialists(DirectoryFilters filters) async => _people;

  @override
  Future<List<IncludedConsults>> included() async => const <IncludedConsults>[IncludedConsults(type: 'doctor', remaining: 1, allowance: 2, refillsAt: null)];

  @override
  Future<Specialist> specialist(String id) async => _people.first;

  @override
  Future<SlotList> slots({String? providerId, ProviderType? type, required DateTime from, required DateTime to}) async {
    final List<Slot> s = <Slot>[];
    for (int d = 0; d < 7; d++) {
      if (d == 2 || d == 5) continue; // full days
      for (final (int h, int m) in <(int, int)>[(9, 0), (9, 30), (10, 30), (11, 0), (13, 0), (14, 30), (16, 0), (17, 30), (18, 0), (19, 30)]) {
        if ((d + h) % 4 == 0) continue;
        final DateTime t = DateTime(from.year, from.month, from.day + d, h, m);
        if (t.isAfter(DateTime.now())) s.add(Slot(startsAt: t, endsAt: t.add(const Duration(minutes: 30))));
      }
    }
    return SlotList(slots: s, feePaise: 80000, included: false);
  }

  @override
  Future<List<Appointment>> appointments() async => <Appointment>[
        appt(id: 'a1', starts: _at(1, 10, 30)),
        appt(id: 'a2', status: 'held', kind: 'paid', starts: _at(3, 17), holdUntil: DateTime.now().add(const Duration(minutes: 8))),
        appt(id: 'a3', status: 'completed', starts: _at(-6, 11)),
        appt(id: 'a4', status: 'cancelled', starts: _at(-14, 16)),
      ];
}

class _Practice implements PracticeRepository {
  @override
  Future<PracticeToday> today() async => const PracticeToday(phase: 'follicular', sessions: <PracticeSession>[gentle]);

  @override
  Future<LiveClasses> liveClasses() async => LiveClasses(
        access: ClassAccess.included,
        startsOn: null,
        classes: <LiveClass>[
          LiveClass(id: 'c1', title: 'Gentle luteal-phase yin', level: 'Beginner', startsAt: _at(1, 18), endsAt: _at(1, 18, 45), instructor: 'Lakshmi Rao', placesLeft: 4),
          LiveClass(id: 'c2', title: 'Breathwork and yoga nidra', level: 'All levels', startsAt: _at(2, 7), endsAt: _at(2, 7, 40), instructor: 'Kavitha Menon', placesLeft: 0),
          LiveClass(id: 'c3', title: 'Follicular power flow', level: 'Intermediate', startsAt: _at(3, 19), endsAt: _at(3, 20), instructor: 'Lakshmi Rao', placesLeft: 9),
        ],
      );

  @override
  Future<List<ClassBooking>> classBookings() async => <ClassBooking>[
        ClassBooking(id: 'b1', classId: 'c3', status: 'booked', title: 'Follicular power flow', startsAt: _at(3, 19), endsAt: _at(3, 20)),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _loadFonts() async {
  Future<ByteData> font(String file) async => ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync());
  final FontLoader sans = FontLoader('PlusJakartaSans');
  for (final String w in <String>['400', '500', '600', '700', '800']) {
    sans.addFont(font('PlusJakartaSans-$w.ttf'));
  }
  await sans.load();
  final FontLoader display = FontLoader('CormorantGaramond');
  for (final String w in <String>['500', '600', '700']) {
    display.addFont(font('CormorantGaramond-$w.ttf'));
  }
  await display.load();
  final File icons = File('${Platform.environment['FLUTTER_ROOT'] ?? ''}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    await (FontLoader('MaterialIcons')..addFont(Future<ByteData>.value(ByteData.sublistView(icons.readAsBytesSync())))).load();
  }
}

Future<void> _pump(WidgetTester t, Widget home, double width, double height) async {
  t.view.physicalSize = Size(width * 2, height * 2);
  t.view.devicePixelRatio = 2;
  await t.pumpWidget(RepaintBoundary(
    key: _boundary,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.current,
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: home,
    ),
  ));
  await t.pump();
}

Future<void> _shot(WidgetTester t, String name) async {
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  for (int i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
  await t.runAsync(() async {
    for (final Element e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await t.pump(const Duration(milliseconds: 300));
  await t.runAsync(() async {
    final RenderRepaintBoundary rb = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await rb.toImage(pixelRatio: 2);
    final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_out!).createSync(recursive: true);
    File('${_out!}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  for (final double w in <double>[360, 412]) {
    final String tag = w.toInt().toString();

    testWidgets('specialists at $tag', (WidgetTester t) async {
      await _loadFonts();
      await _pump(t, FindSpecialistPage(repository: _Repo()), w, 1900);
      await _shot(t, 'c01-specialists-$tag');
    }, skip: _out == null);

    testWidgets('specialist page at $tag', (WidgetTester t) async {
      await _loadFonts();
      await _pump(t, SpecialistPage(specialistId: 'd1', repository: _Repo()), w, 1500);
      await _shot(t, 'c02-specialist-$tag');
    }, skip: _out == null);

    testWidgets('confirm at $tag', (WidgetTester t) async {
      await _loadFonts();
      final Appointment held = Appointment(
        id: 'a1',
        status: 'held',
        kind: 'paid',
        providerType: 'doctor',
        startsAt: _at(1, 10, 30),
        endsAt: _at(1, 11),
        feePaise: 80000,
        holdExpiresAt: DateTime.now().add(const Duration(minutes: 9, seconds: 41)),
        clinicianId: 'd1',
        clinicianName: 'Dr Asha Rao',
        pooled: false,
        reschedulesLeft: 2,
        roomOpensAt: _at(1, 10, 20),
        recording: false,
        recordMode: 'transcript',
        askTranscriptConsent: true,
      );
      await _pump(t, ConfirmBookingPage(repository: _Repo(), held: held), w, 1900);
      await t.tap(find.text('My health information'));
      await t.tap(find.text('My cycle and symptoms'));
      await _shot(t, 'c03-confirm-$tag');
      await t.pumpWidget(const SizedBox());
    }, skip: _out == null);

    testWidgets('appointments at $tag', (WidgetTester t) async {
      await _loadFonts();
      await _pump(t, AppointmentsPage(repository: _Repo()), w, 1300);
      await _shot(t, 'c04-appointments-$tag');
      await _pump(t, AppointmentPage(appointmentId: 'a1', repository: FakeConsults()..current = appt(starts: _at(1, 10, 30))), w, 900);
      await _shot(t, 'c05-appointment-$tag');
    }, skip: _out == null);

    testWidgets('appointments empty at $tag', (WidgetTester t) async {
      await _loadFonts();
      await _pump(t, AppointmentsPage(repository: FakeConsults()), w, 900);
      await _shot(t, 'c06-appointments-empty-$tag');
    }, skip: _out == null);

    testWidgets('practice live classes at $tag', (WidgetTester t) async {
      await _loadFonts();
      await _pump(t, PracticePage(repository: _Practice()), w, 1900);
      await _shot(t, 'c07-practice-$tag');
    }, skip: _out == null);
  }
}
