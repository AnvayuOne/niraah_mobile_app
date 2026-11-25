// Renders the doctor Patients list and a patient profile (header, summary, assessment, cycle, a locked section)
// to PNG. Runs only when SCREENSHOT_DIR is set.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/design_system/tokens/tokens.dart';
import 'package:niraah/features/doctor/domain/doctor_work.dart';
import 'package:niraah/features/doctor/presentation/patients_pages.dart';
import 'package:niraah/features/provider_work/domain/provider_work.dart';
import 'package:niraah/l10n/app_localizations.dart';

final String? _out = Platform.environment['SCREENSHOT_DIR'];
const GlobalObjectKey<State<StatefulWidget>> _boundary = GlobalObjectKey<State<StatefulWidget>>('doctor-a-shot');

/// Sample patients and one profile, shaped like the server's open records.
class _Work implements DoctorWorkRepository {
  @override
  Future<List<Json>> patients(PatientFilters filters) async => <Json>[
    <String, dynamic>{
      'id': 'm1',
      'name': 'Asha Menon',
      'ageBand': '25-29',
      'relationship': 'dedicated',
      'plan': 'Care',
      'nextAppointment': '2026-11-24T10:00:00Z',
      'openAlert': true,
      'carePlanAwaiting': false,
    },
    <String, dynamic>{'id': 'm2', 'name': 'Priya Sharma', 'ageBand': '30-34', 'relationship': 'dedicated', 'plan': 'Care Plus', 'carePlanAwaiting': true},
    <String, dynamic>{'id': 'm3', 'name': 'Kavya Iyer', 'ageBand': '20-24', 'relationship': 'consult', 'plan': 'Essential', 'nextAppointment': '2026-11-21T06:30:00Z'},
    <String, dynamic>{'id': 'm4', 'name': 'Nisha Rao', 'ageBand': '35-39', 'relationship': 'review', 'plan': 'Essential'},
    <String, dynamic>{'id': 'm5', 'name': 'Fatima Khan', 'ageBand': '25-29', 'relationship': 'consult', 'plan': 'Care'},
  ].where((Json p) => filters.kind == null || p['relationship'] == filters.kind).toList();

  @override
  Future<Json> patient(String memberId) async => <String, dynamic>{
    'id': memberId,
    'name': 'Asha Menon',
    'ageBand': '25-29',
    'plan': 'Care',
    'relationship': 'dedicated',
    'past': false,
    'dedicatedDietitian': 'Ritu Kapoor',
    'consent': <Object>[
      <String, dynamic>{'category': 'assessment', 'shared': true},
      <String, dynamic>{'category': 'cycle_symptoms', 'shared': true},
      <String, dynamic>{'category': 'meals', 'shared': false},
      <String, dynamic>{'category': 'lab_reports', 'shared': true},
      <String, dynamic>{'category': 'messages', 'shared': false},
    ],
    'flags': <Object>[
      <String, dynamic>{'name': 'Heavy bleeding', 'severity': 'urgent'},
    ],
    'sections': <String>['assessment', 'cycle_symptoms', 'care_plan', 'labs', 'meals', 'notes'],
  };

  @override
  Future<Json> section(String memberId, String section) async => switch (section) {
    'assessment' => <String, dynamic>{
      'section': 'assessment',
      'shared': true,
      'total': 35,
      'maximum': 100,
      'band': 'Needs care',
      'dimensions': <Object>[
        <String, dynamic>{'name': 'Cycle', 'points': 12, 'max': 30, 'level': 'Low'},
        <String, dynamic>{'name': 'Energy', 'points': 8, 'max': 20, 'level': 'Fair'},
        <String, dynamic>{'name': 'Sleep', 'points': 9, 'max': 25},
        <String, dynamic>{'name': 'Mood', 'points': 6, 'max': 25},
      ],
      'completedAt': '2026-11-12T09:00:00Z',
    },
    'cycle_symptoms' => <String, dynamic>{
      'section': 'cycle_symptoms',
      'shared': true,
      'cycles': <Object>[
        <String, dynamic>{'start': '2026-07-02', 'length': 31},
        <String, dynamic>{'start': '2026-08-02', 'length': 38},
        <String, dynamic>{'start': '2026-09-09', 'length': 29},
        <String, dynamic>{'start': '2026-10-08', 'length': 42},
      ],
      'symptoms': <Object>[
        <String, dynamic>{'name': 'Cramps', 'severity': 'severe'},
        <String, dynamic>{'name': 'Bloating', 'severity': 'moderate'},
        <String, dynamic>{'name': 'Acne', 'severity': 'mild'},
        <String, dynamic>{'name': 'Fatigue', 'severity': 'moderate'},
      ],
      'lastPeriod': '2026-11-19',
    },
    _ => <String, dynamic>{'section': section, 'shared': false},
  };

  @override
  Future<Json> brief(String memberId) async => <String, dynamic>{
    'label': 'AI brief',
    'points': <Object>[
      <String, dynamic>{'text': 'Cycles have lengthened over three months', 'section': 'cycle_symptoms'},
      <String, dynamic>{'text': 'Sleep and energy are the lowest dimensions', 'section': 'assessment'},
    ],
    'facts': <String, dynamic>{},
    'notShared': <String>['meals'],
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _loadFonts() async {
  Future<ByteData> font(String file) async => ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync());
  final FontLoader sans = FontLoader('PlusJakartaSans');
  for (String w in <String>['400', '500', '600', '700', '800']) {
    sans.addFont(font('PlusJakartaSans-$w.ttf'));
  }
  await sans.load();
  final FontLoader display = FontLoader('CormorantGaramond');
  for (String w in <String>['500', '600', '700', 'Italic-500']) {
    display.addFont(font('CormorantGaramond-$w.ttf'));
  }
  await display.load();
  final String root = Platform.environment['FLUTTER_ROOT'] ?? '';
  final File icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final FontLoader m = FontLoader('MaterialIcons')..addFont(Future<ByteData>.value(ByteData.sublistView(icons.readAsBytesSync())));
    await m.load();
  }
}

Widget _frame(Widget child) => RepaintBoundary(
  key: _boundary,
  child: MaterialApp.router(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.current,
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    routerConfig: GoRouter(
      routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => child)],
    ),
  ),
);

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final RenderRepaintBoundary rb = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await rb.toImage(pixelRatio: 2);
    final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_out!).createSync(recursive: true);
    File('${_out!}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  NColors.dark = Platform.environment['SCREENSHOT_DARK'] == '1';
  setUpAll(_loadFonts);

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('doctor patients list', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(PatientsPage(repository: _Work())));
    await _shot(tester, '40-doctor-patients');
  }, skip: _out == null);

  testWidgets('doctor patient profile', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(PatientPage(memberId: 'm1', repository: _Work())));
    await tester.pumpAndSettle();
    await _shot(tester, '41-doctor-patient-summary');
    await tester.tap(find.text('Show the brief'));
    await _shot(tester, '42-doctor-patient-brief');
    await tester.tap(find.widgetWithText(Tab, 'Assessment'));
    await _shot(tester, '43-doctor-patient-assessment');
    await tester.tap(find.widgetWithText(Tab, 'Cycle and symptoms'));
    await _shot(tester, '44-doctor-patient-cycle');
    await tester.ensureVisible(find.widgetWithText(Tab, 'Meals'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'Meals'));
    await _shot(tester, '45-doctor-patient-locked');
  }, skip: _out == null);
}
