// Renders the instructor workspace screens to PNG for visual review.
// Runs only when SCREENSHOT_DIR is set:
//   SCREENSHOT_DIR=<dir> flutter test test/screenshots/instructor_screenshot_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/design_system/tokens/tokens.dart';
import 'package:niraah/features/instructor/instructor_pages.dart';
import 'package:niraah/features/instructor/instructor_repository.dart';
import 'package:niraah/features/provider_work/domain/provider_work.dart';
import 'package:niraah/l10n/app_localizations.dart';

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
    routerConfig: GoRouter(
      routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => child)],
    ),
  ),
);

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final RenderRepaintBoundary rb = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await rb.toImage(pixelRatio: 2);
    final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_out!).createSync(recursive: true);
    File('${_out!}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

String _at(int days, int hour, [int minute = 0]) {
  final DateTime n = DateTime.now();
  return DateTime(n.year, n.month, n.day + days, hour, minute).toUtc().toIso8601String();
}

Json _cls(String id, String title, int days, int hour, String status, int booked, int capacity, {int waiting = 0, int requests = 0, bool startable = false}) => <String, dynamic>{
  'id': id,
  'title': title,
  'startsAt': _at(days, hour),
  'endsAt': _at(days, hour + 1),
  'status': status,
  'booked': booked,
  'capacity': capacity,
  'waiting': waiting,
  'requests': requests,
  'startable': startable,
};

class _FakeInstructor implements InstructorRepository {
  @override
  Future<Json> home() async => <String, dynamic>{
    'today': <Object>[
      _cls('c1', 'Morning Hatha flow', 0, 7, 'completed', 12, 15),
      _cls('c2', 'Gentle luteal-phase yin', 0, 18, 'scheduled', 15, 15, waiting: 3, requests: 2, startable: true),
      _cls('c3', 'Breathwork and yoga nidra', 0, 20, 'scheduled', 4, 12),
    ],
    'next': _cls('c2', 'Gentle luteal-phase yin', 0, 18, 'scheduled', 15, 15),
    'needsMe': <String, dynamic>{'requests': 2, 'attendanceToConfirm': 1, 'contentReturned': 1, 'classesWithoutBookings': 0},
  };

  @override
  Future<List<Json>> classes({DateTime? from, DateTime? to}) async => <Json>[
    _cls('p1', 'Sunrise vinyasa', -3, 7, 'completed', 10, 12),
    _cls('p2', 'Pelvic floor basics', -2, 19, 'cancelled', 6, 10),
    _cls('c2', 'Gentle luteal-phase yin', 1, 18, 'scheduled', 15, 15, waiting: 3, requests: 2),
    _cls('c3', 'Breathwork and yoga nidra', 1, 20, 'scheduled', 4, 12),
    _cls('c4', 'Follicular power flow', 3, 7, 'awaiting_approval', 0, 20),
    _cls('c5', 'Restorative for cramps', 5, 19, 'draft', 0, 10),
  ];

  @override
  Future<Json> classDetail(String id) async => <String, dynamic>{
    ..._cls(id, 'Gentle luteal-phase yin', 1, 18, 'scheduled', 4, 15),
    'description': 'Slow, supported holds with bolsters for the days before a period. Suits every level.',
    'attendanceCorrectable': true,
    'bookings': <Object>[
      <String, dynamic>{
        'id': 'b1',
        'firstName': 'Asha',
        'status': 'booked',
        'attended': true,
        'request': <String, dynamic>{'choice': 'first_class', 'text': 'New to yin; may need a variation.', 'seen': false},
      },
      <String, dynamic>{'id': 'b2', 'firstName': 'Kavya', 'status': 'booked', 'attended': false},
      <String, dynamic>{
        'id': 'b3',
        'firstName': 'Ritu',
        'status': 'booked',
        'request': <String, dynamic>{'choice': 'arriving_late', 'text': '', 'seen': true},
      },
      <String, dynamic>{'id': 'b4', 'firstName': 'Neha', 'status': 'waitlisted'},
    ],
  };

  @override
  Future<List<Json>> students() async => <Json>[
    <String, dynamic>{
      'id': 'm1',
      'firstName': 'Asha',
      'attendance': <String, dynamic>{'booked': 3, 'attended': 2},
      'cyclePhase': 'luteal',
      'practiceProgress': <String, dynamic>{'sessionsCompleted': 9, 'minutesThisMonth': 140},
    },
    <String, dynamic>{
      'id': 'm2',
      'firstName': 'Kavya',
      'attendance': <String, dynamic>{'booked': 8, 'attended': 8},
      'cyclePhase': 'follicular',
      'practiceProgress': <String, dynamic>{'sessionsCompleted': 21, 'minutesThisMonth': 310},
    },
    <String, dynamic>{
      'id': 'm3',
      'firstName': 'Ritu',
      'attendance': <String, dynamic>{'booked': 2, 'attended': 0},
      'practiceProgress': <String, dynamic>{'sessionsCompleted': 1, 'minutesThisMonth': 15},
    },
    <String, dynamic>{
      'id': 'm4',
      'firstName': 'Neha',
      'attendance': <String, dynamic>{'booked': 5, 'attended': 4},
      'cyclePhase': 'menstrual',
      'practiceProgress': <String, dynamic>{'sessionsCompleted': 12, 'minutesThisMonth': 95},
    },
  ];

  @override
  Future<List<Json>> content() async => <Json>[
    <String, dynamic>{
      'id': 'v1',
      'title': 'Ten-minute morning wake-up',
      'status': 'published',
      'minutes': 10,
      'stats': <String, dynamic>{'plays': 412, 'completions': 288},
      'hasVideo': true,
    },
    <String, dynamic>{
      'id': 'v2',
      'title': 'Yin for the luteal phase',
      'status': 'in_review',
      'minutes': 25,
      'stats': <String, dynamic>{'plays': 0, 'completions': 0},
    },
    <String, dynamic>{
      'id': 'v3',
      'title': 'Hip openers for cramps',
      'status': 'returned',
      'minutes': 18,
      'stats': <String, dynamic>{'plays': 0, 'completions': 0},
      'reviewNote': 'Please remove the claim that this relieves endometriosis pain.',
    },
    <String, dynamic>{
      'id': 'v4',
      'title': 'Evening wind-down breath',
      'status': 'draft',
      'minutes': 12,
      'stats': <String, dynamic>{'plays': 0, 'completions': 0},
    },
  ];

  @override
  Future<Json> profile() async => <String, dynamic>{
    'name': 'Lakshmi Rao',
    'approvalStatus': 'approved',
    'bio': 'RYT-500 teacher focused on cycle-aware practice and gentle strength.',
    'languages': <String>['English', 'Kannada'],
    'practiceTypes': <String>['Hatha', 'Yin', 'Pranayama'],
    'rating': <String, dynamic>{'average': 4.9, 'count': 87},
  };

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

  final _FakeInstructor repo = _FakeInstructor();
  final Map<String, (double, Widget Function())> screens = <String, (double, Widget Function())>{
    'i01-home': (1100, () => InstructorHomePage(repository: repo)),
    'i02-sessions': (1300, () => SessionsPage(repository: repo)),
    'i03-class': (1400, () => ClassPage(classId: 'c2', repository: repo)),
    'i04-class-editor': (1500, () => ClassEditorPage(repository: repo)),
    'i05-students': (844, () => StudentsPage(repository: repo)),
    'i06-library': (1200, () => LibraryPage(repository: repo)),
    'i07-content-editor': (
      1700,
      () => ContentEditorPage(
        repository: repo,
        existing: <String, dynamic>{
          'id': 'v3',
          'title': 'Hip openers for cramps',
          'status': 'returned',
          'minutes': 18,
          'intensity': 2,
          'phaseSuitability': <String>['menstrual'],
          'stats': <String, dynamic>{'plays': 0, 'completions': 0},
          'reviewNote': 'Please remove the claim that this relieves endometriosis pain.',
        },
      ),
    ),
    'i08-more': (844, () => const InstructorMorePage()),
    'i09-profile': (1100, () => InstructorProfilePage(repository: repo)),
  };
  for (MapEntry<String, (double, Widget Function())> e in screens.entries) {
    testWidgets(e.key, (WidgetTester tester) async {
      phone(tester, height: e.value.$1);
      await tester.pumpWidget(_frame(e.value.$2()));
      await _shot(tester, e.key);
    }, skip: _out == null);
  }
}
