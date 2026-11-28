// Renders the doctor More, Alerts, Labs, Profile, Reviewer, Care plan and Advice screens to PNG for visual review.
// Runs only when SCREENSHOT_DIR is set:
//   SCREENSHOT_DIR=<dir> flutter test test/screenshots/doctor_b_screenshot_test.dart
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
import 'package:niraah/features/doctor/presentation/care_plan_pages.dart';
import 'package:niraah/features/doctor/presentation/doctor_more_pages.dart';
import 'package:niraah/features/doctor/presentation/wellness_advice_pages.dart';
import 'package:niraah/features/provider_work/domain/provider_work.dart';
import 'package:niraah/l10n/app_localizations.dart';
import 'package:niraah/sample/sample_doctor.dart';

final String? _out = Platform.environment['SCREENSHOT_DIR'];
const GlobalObjectKey<State<StatefulWidget>> _boundary = GlobalObjectKey<State<StatefulWidget>>('shot');

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
        routerConfig: GoRouter(routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => child)]),
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

class _FakeDoctor implements DoctorWorkRepository {
  @override
  Future<Json> profile() async => <String, dynamic>{
        'name': 'Dr Meera Iyer',
        'approvalStatus': 'approved',
        'reverifyBy': '2027-03-01',
        'clinicalReviewer': true,
        'onCall': true,
        'bio': 'Gynaecologist with twelve years of PCOS and menopause care.',
        'languages': <String>['English', 'Hindi', 'Tamil'],
        'specialities': <String>['PCOS', 'Menopause'],
        'registration': <String, dynamic>{'number': 'MMC 2014/03/1187', 'council': 'Maharashtra Medical Council'},
        'rating': <String, dynamic>{'average': 4.8, 'count': 126},
      };

  @override
  Future<List<Json>> alerts({String? status}) async => <Json>[
        <String, dynamic>{'id': 'a1', 'member': <String, dynamic>{'name': 'Asha Verma'}, 'raisedBy': 'A lab value past its urgent threshold', 'severity': 'urgent', 'status': 'open', 'onCall': true, 'opened': false, 'ageMinutes': 40},
        <String, dynamic>{'id': 'a2', 'member': <String, dynamic>{'name': 'Kavya Nair'}, 'raisedBy': 'Heavy bleeding reported in the symptom log for three days', 'severity': 'attention', 'status': 'acknowledged', 'onCall': false, 'opened': true, 'ageMinutes': 190},
        <String, dynamic>{'id': 'a3', 'member': <String, dynamic>{'name': 'Ritu Sharma'}, 'raisedBy': 'Missed follow-up after a flagged thyroid result', 'severity': 'attention', 'status': 'open', 'onCall': false, 'opened': false, 'ageMinutes': 1500},
      ];

  @override
  Future<List<Json>> labReportsToReview() async => <Json>[
        <String, dynamic>{'id': 'l1', 'member': <String, dynamic>{'name': 'Asha Verma'}, 'flagged': true, 'flaggedCount': 2, 'testDate': '2026-11-14'},
        <String, dynamic>{'id': 'l2', 'member': <String, dynamic>{'name': 'Neha Kulkarni'}, 'flagged': false, 'testDate': '2026-11-12', 'enteredByMember': true},
        <String, dynamic>{'id': 'l3', 'member': <String, dynamic>{'name': 'Priya Menon'}, 'flagged': true, 'testDate': '2026-11-10'},
      ];

  @override
  Future<Json> labReport(String id) async => <String, dynamic>{
        'id': id,
        'member': <String, dynamic>{'name': 'Asha Verma'},
        'testDate': '2026-11-14',
        'typedByMember': true,
        'reviewed': false,
        'results': <Object>[
          <String, dynamic>{'name': 'TSH', 'value': 6.8, 'unit': 'mIU/L', 'range': <String, dynamic>{'low': 0.4, 'high': 4.0}, 'flag': 'high'},
          <String, dynamic>{'name': 'Haemoglobin', 'value': 10.2, 'unit': 'g/dL', 'range': <String, dynamic>{'low': 12, 'high': 15.5}, 'flag': 'low'},
          <String, dynamic>{'name': 'Fasting glucose', 'value': 92, 'unit': 'mg/dL', 'range': <String, dynamic>{'low': 70, 'high': 100}},
          <String, dynamic>{'name': 'Vitamin D', 'value': 34, 'unit': 'ng/mL', 'range': <String, dynamic>{'low': 30, 'high': 100}},
        ],
      };

  @override
  Future<Json> reviewerTasks() async => <String, dynamic>{
        'tasks': <Object>[
          <String, dynamic>{'label': 'Content to approve', 'count': 3},
          <String, dynamic>{'label': 'Question set changes', 'count': 1},
          <String, dynamic>{'label': 'Supplement catalogue entries', 'count': 0},
        ],
      };

  @override
  Future<List<Json>> carePlanQueue() async => <Json>[
        <String, dynamic>{'id': 'p1', 'member': 'Asha Verma', 'dueAt': '2026-11-21T10:00:00Z', 'claimedByMe': true},
        <String, dynamic>{'id': 'p2', 'member': 'Kavya Nair', 'dueAt': '2026-11-22T10:00:00Z', 'offeredToMe': true, 'revision': true},
        <String, dynamic>{'id': 'p3', 'member': 'Ritu Sharma', 'generatedBy': 'empty'},
      ];

  @override
  Future<Json> carePlan(String id) async => <String, dynamic>{
        'id': id,
        'member': 'Asha Verma',
        'status': 'in_review',
        'generatedBy': 'model',
        'dueAt': '2026-11-21T10:00:00Z',
        'canReturn': true,
        'sections': <Object>[
          <String, dynamic>{'kind': 'nutrition', 'aiSuggestion': 'Add a protein source to breakfast, such as eggs, paneer or dal, and keep refined sugar for weekends.', 'decision': 'accepted'},
          <String, dynamic>{'kind': 'movement', 'aiSuggestion': 'Walk for 30 minutes after dinner five days a week.', 'doctorVersion': 'Walk for 20 minutes after dinner, building to 30 over three weeks.', 'decision': 'edited'},
          <String, dynamic>{'kind': 'sleep', 'aiSuggestion': 'Wind down by 10 pm with screens off.', 'decision': null},
          <String, dynamic>{'kind': 'supplements', 'aiSuggestion': 'Vitamin D3 60,000 IU once a week for eight weeks.', 'decision': null, 'needsDoseConfirmation': true},
        ],
        'tasks': <Object>[
          <String, dynamic>{'id': 't1', 'kind': 'movement', 'title': 'Evening walk', 'frequency': 'daily', 'proposedByAi': true},
          <String, dynamic>{'id': 't2', 'kind': 'sleep', 'title': 'Screens off by 10 pm', 'frequency': 'weekdays'},
        ],
        'wellnessStatement': 'Niraah is a wellness service. This plan does not replace care from her own doctor.',
      };

  @override
  Future<List<Json>> prescriptionDrafts() async => <Json>[
        <String, dynamic>{'id': 'd1', 'memberName': 'Asha Verma', 'updatedAt': '2026-11-19T10:00:00Z'},
        <String, dynamic>{'id': 'd2', 'memberName': 'Neha Kulkarni', 'updatedAt': '2026-11-18T10:00:00Z', 'isCorrection': true},
      ];

  @override
  Future<Json> prescription(String id) async => <String, dynamic>{
        'id': id,
        'memberId': 'm1',
        'status': 'draft',
        'assessment': 'Irregular cycles with fatigue; thyroid result is above range.',
        'advice': 'Regular meals with protein at breakfast, a short walk after dinner.',
        'seeDoctorLine': 'See a doctor in person if bleeding is heavy for more than a week.',
        'testsAdvised': <String>['TSH', 'Free T4'],
        'followUpOn': '2026-12-20',
        'lines': <Object>[
          <String, dynamic>{'supplementId': 's1', 'supplement': 'Vitamin D3', 'form': 'Sachet', 'strength': '60,000 IU', 'dosePattern': '0-0-1', 'timing': 'after_food', 'duration': '8 weeks'},
        ],
        'wording': <Object>[<String, dynamic>{'field': 'advice', 'label': 'Advice', 'confirmed': false}],
      };

  @override
  Future<Json> medicines(String memberId) async => <String, dynamic>{'shared': true, 'recorded': true, 'medicines': <String>['Metformin 500 mg'], 'allergies': <String>['None']};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWork implements ProviderWorkRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  NColors.dark = Platform.environment['SCREENSHOT_DARK'] == '1';
  setUpAll(_loadFonts);

  void phone(WidgetTester tester, {double height = 844}) {
    tester.view.physicalSize = Size(1170, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  final _FakeDoctor repo = _FakeDoctor();
  final Map<String, (double, Widget Function())> screens = <String, (double, Widget Function())>{
    'b01-more': (1000, () => DoctorMorePage(repository: repo, dashboard: SampleDoctorRepository())),
    'b02-alerts': (844, () => AlertsPage(repository: repo)),
    'b03-labs': (844, () => LabResultsPage(repository: repo)),
    'b04-lab-report': (1250, () => LabReportReviewPage(reportId: 'l1', repository: repo)),
    'b05-profile': (1350, () => DoctorProfilePage(repository: repo)),
    'b06-reviewer': (844, () => ReviewerTasksPage(repository: repo)),
    'b07-care-plans': (844, () => CarePlanQueuePage(repository: repo)),
    'b08-care-plan-review': (1900, () => CarePlanReviewPage(planId: 'p1', repository: repo)),
    'b08b-care-plan-review-phone': (844, () => CarePlanReviewPage(planId: 'p1', repository: repo)),
    'b09-advice-drafts': (844, () => AdviceDraftsPage(repository: repo)),
    'b10-advice-editor': (1750, () => AdviceEditorPage(adviceId: 'd1', repository: repo, providerWork: _FakeWork())),
  };
  for (MapEntry<String, (double, Widget Function())> e in screens.entries) {
    testWidgets(e.key, (WidgetTester tester) async {
      phone(tester, height: e.value.$1);
      await tester.pumpWidget(_frame(e.value.$2()));
      await _shot(tester, e.key);
    }, skip: _out == null);
  }

  testWidgets('b11-alert-sheet', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(AlertsPage(repository: _SheetDoctor())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Asha Verma'));
    await _shot(tester, 'b11-alert-sheet');
  }, skip: _out == null);
}

class _SheetDoctor extends _FakeDoctor {
  @override
  Future<Json> openAlert(String id) async => <String, dynamic>{
        'id': id,
        'memberId': 'm1',
        'raisedBy': 'A lab value past its urgent threshold',
        'severity': 'urgent',
        'status': 'open',
        'createdAt': '2026-11-20T08:00:00Z',
        'actions': <String>['acknowledge', 'ask_to_book', 'resolve'],
      };
}
