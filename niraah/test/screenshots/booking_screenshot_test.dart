// Renders the member screens the main harness does not cover (code, account details, practice, Me, privacy,
// notifications, care, community, messages) to PNG. Runs only when SCREENSHOT_DIR is set.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/features/consults/data/sample_consults_repository.dart';
import 'package:niraah/features/consults/domain/consults.dart';
import 'package:niraah/features/consults/presentation/appointments_page.dart';
import 'package:niraah/features/consults/presentation/confirm_page.dart';
import 'package:niraah/features/consults/presentation/specialist_page.dart';
import 'package:niraah/features/consults/presentation/specialists_page.dart';
import 'package:niraah/features/practice/domain/practice.dart';
import 'package:niraah/features/practice/presentation/practice_page.dart';
import 'package:niraah/l10n/app_localizations.dart';

import '../member_areas/member_screens_test.dart' as m;

class _Classes extends m.FakePractice {
  @override
  Future<LiveClasses> liveClasses() async {
    final DateTime d = DateTime.now().add(const Duration(days: 1));
    DateTime at(int days, int h, int min) => DateTime(d.year, d.month, d.day + days, h, min);
    return LiveClasses(access: ClassAccess.included, startsOn: null, classes: <LiveClass>[
      LiveClass(id: 'c1', title: 'Gentle hormone flow', level: 'Beginner', startsAt: at(0, 7, 0), endsAt: at(0, 7, 45), instructor: 'Kavitha Menon', placesLeft: 6),
      LiveClass(id: 'c2', title: 'Breath and calm', level: 'All levels', startsAt: at(1, 18, 30), endsAt: at(1, 19, 0), instructor: 'Kavitha Menon', placesLeft: 0),
    ]);
  }
}

// Renders the consult booking screens to PNG with sample data. Runs only when SCREENSHOT_DIR is set.
final String? _out = Platform.environment['SCREENSHOT_DIR'];
const GlobalObjectKey<State<StatefulWidget>> _boundary = GlobalObjectKey<State<StatefulWidget>>('booking-shot');

Future<void> _loadFonts() async {
  Future<ByteData> font(String file) async => ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync());
  final FontLoader sans = FontLoader('PlusJakartaSans');
  for (String w in <String>['400', '500', '600', '700', '800']) {
    sans.addFont(font('PlusJakartaSans-$w.ttf'));
  }
  await sans.load();
  final FontLoader display = FontLoader('CormorantGaramond');
  for (String w in <String>['500', '600', '700']) {
    display.addFont(font('CormorantGaramond-$w.ttf'));
  }
  await display.load();
  final File icons = File('${Platform.environment['FLUTTER_ROOT'] ?? ''}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    await (FontLoader('MaterialIcons')..addFont(Future<ByteData>.value(ByteData.sublistView(icons.readAsBytesSync())))).load();
  }
}

Widget _frame(Widget child) => RepaintBoundary(
      key: _boundary,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.current,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        routerConfig: GoRouter(routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => child)]),
      ),
    );

Future<void> _shot(WidgetTester tester, String name) async {
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  // Let every picture decode before the capture.
  for (int i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.runAsync(() async {
    final RenderRepaintBoundary rb = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await rb.toImage(pixelRatio: 2);
    final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_out!).createSync(recursive: true);
    File('${_out!}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(_loadFonts);
  final double tall = double.tryParse(Platform.environment['SCREENSHOT_TALL'] ?? '') ?? 2532;

  Future<void> size(WidgetTester t) async {
    t.view.physicalSize = Size(1170, tall);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
  }

  testWidgets('b01-specialists', (WidgetTester t) async {
    await size(t);
    await t.pumpWidget(_frame(SpecialistsPage(repository: SampleConsultsRepository())));
    await _shot(t, 'b01-specialists');
  }, skip: _out == null);

  testWidgets('b02-specialist-times', (WidgetTester t) async {
    await size(t);
    await t.pumpWidget(_frame(SpecialistPage(id: 'dr-ananya', repository: SampleConsultsRepository())));
    for (int i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 200));
    }
    await t.ensureVisible(find.textContaining(':30 pm').first);
    await t.pump();
    await t.tap(find.textContaining(':30 pm').first);
    await _shot(t, 'b02-specialist-times');
  }, skip: _out == null);

  testWidgets('b03-confirm', (WidgetTester t) async {
    await size(t);
    final SampleConsultsRepository repo = SampleConsultsRepository();
    final Specialist s = await repo.specialist('dt-sunita');
    final Appointment a = await repo.hold('dt-sunita', DateTime.now().add(const Duration(days: 2, hours: 3)));
    await t.pumpWidget(_frame(ConfirmConsultPage(id: a.id, held: a, specialist: s, repository: repo)));
    for (int i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 200));
    }
    await t.tap(find.text('Your health profile'));
    await t.tap(find.text('Your cycle and symptoms'));
    await _shot(t, 'b03-confirm');
  }, skip: _out == null);

  testWidgets('b04-appointments', (WidgetTester t) async {
    await size(t);
    final SampleConsultsRepository repo = SampleConsultsRepository();
    final Appointment a = await repo.hold('dr-ananya', DateTime.now().add(const Duration(days: 1, hours: 2)));
    await repo.confirm(a.id, share: <ShareCategory>{});
    await repo.hold('dt-sunita', DateTime.now().add(const Duration(days: 3, hours: 5)));
    await t.pumpWidget(_frame(AppointmentsPage(repository: repo)));
    await _shot(t, 'b04-appointments');
  }, skip: _out == null);

  testWidgets('b06-practice-classes', (WidgetTester t) async {
    await size(t);
    await t.pumpWidget(_frame(PracticePage(repository: _Classes())));
    await _shot(t, 'b06-practice-classes');
  }, skip: _out == null);

  testWidgets('b05-appointments-empty', (WidgetTester t) async {
    await size(t);
    await t.pumpWidget(_frame(AppointmentsPage(repository: SampleConsultsRepository())));
    await _shot(t, 'b05-appointments-empty');
  }, skip: _out == null);
}
