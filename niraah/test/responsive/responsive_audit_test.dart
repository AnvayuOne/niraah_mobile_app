// Responsive audit: renders every screen at every device class and fails on
// any layout overflow or exception. Slow, so it runs only on request:
//   RESPONSIVE_AUDIT=1 flutter test test/responsive
// Add AUDIT_DIR=<dir> to also save a PNG of each screen and size.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/app/app.dart';
import 'package:niraah/features/provider_auth/domain/provider_auth.dart';
import 'package:niraah/sample/sample_provider_auth.dart';
import 'package:niraah/sample/sample_registration.dart';

final bool _on = Platform.environment['RESPONSIVE_AUDIT'] == '1';
final String? _out = Platform.environment['AUDIT_DIR'];
final String? _only = Platform.environment['AUDIT_ONLY'];

/// Device classes: name, logical size, pixel ratio.
const List<(String, Size, double)> devices = <(String, Size, double)>[
  ('se', Size(320, 568), 2), // smallest supported phone
  ('phone', Size(390, 844), 3),
  ('max', Size(430, 932), 3),
  ('land', Size(844, 390), 3), // phone in landscape
  ('fold', Size(673, 841), 2.6), // foldable, open
  ('tablet', Size(820, 1180), 2),
  ('desk', Size(1440, 900), 1),
  ('a11y', Size(360, 760), 3), // small phone with large system text (1.3x)
];

const List<String> memberRoutes = <String>[
  '/landing', '/intro', '/welcome', '/sign-in', '/account/details', '/assessment/start', '/assessment',
  '/assessment/result', '/account/paused', '/plans', '/home', '/symptoms', '/cycle', '/meals', '/meals/scan', '/chat',
  '/practice', '/practice/library', '/practice/history', '/me', '/me/profile', '/me/privacy', '/me/notifications',
  '/programs', '/care-plan', '/check-ins', '/labs', '/community', '/messages', '/provider/status',
];

const Map<String, List<String>> providerRoutes = <String, List<String>>{
  'doctor': <String>['/doctor', '/doctor/queue', '/doctor/patients', '/doctor/schedule', '/doctor/more', '/doctor/alerts',
    '/doctor/care-plans', '/doctor/labs', '/doctor/advice', '/doctor/earnings', '/doctor/profile', '/doctor/messages'],
  'dietitian': <String>['/dietitian', '/dietitian/clients', '/dietitian/review', '/dietitian/schedule', '/dietitian/more',
    '/dietitian/meal-plans', '/dietitian/recipes', '/dietitian/check-ins', '/dietitian/alerts', '/dietitian/messages',
    '/dietitian/earnings', '/dietitian/profile'],
  'instructor': <String>['/instructor', '/instructor/sessions', '/instructor/students', '/instructor/library',
    '/instructor/more', '/instructor/earnings', '/instructor/profile'],
};

const GlobalObjectKey<State<StatefulWidget>> _shotKey = GlobalObjectKey<State<StatefulWidget>>('audit');

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

Future<void> _signInAs(String role) async {
  final ProviderAuthRepository repo = GetIt.instance<ProviderAuthRepository>();
  await repo.signOut();
  await repo.checkPassword('$role@sample.niraah.in', sampleProviders['samplePassword'] as String);
  await repo.verifySecondFactor('123456', SecondFactorKind.authenticator);
}

void main() {
  final List<String> problems = <String>[];

  setUpAll(() async {
    if (!_on) return;
    await _loadFonts();
    registerSampleRepositories(GetIt.instance);
  });

  tearDownAll(() {
    if (!_on) return;
    stdout.writeln('\nRESPONSIVE AUDIT: ${problems.length} problem(s)');
    for (String p in problems) {
      stdout.writeln('  $p');
    }
  });

  Future<void> audit(WidgetTester tester, String route, String? role) async {
    for (final (String name, Size size, double dpr) in devices) {
      tester.view.physicalSize = size * dpr;
      tester.view.devicePixelRatio = dpr;
      tester.platformDispatcher.textScaleFactorTestValue = name == 'a11y' ? 1.3 : 1.0;
      final List<String> errs = <String>[];
      final FlutterExceptionHandler? old = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) => errs.add(d.exceptionAsString().split('\n').first);
      try {
        if (role != null) await tester.runAsync(() => _signInAs(role));
        await tester.pumpWidget(RepaintBoundary(key: _shotKey, child: NiraahApp(key: UniqueKey(), initialLocation: route)));
        for (int i = 0; i < 12; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
          await tester.pump(const Duration(milliseconds: 120));
        }
        final Object? ex = tester.takeException();
        if (ex != null) errs.add(ex.toString().split('\n').first);
        if (_out != null) {
          await tester.runAsync(() async {
            for (Element e in find.byType(Image).evaluate()) {
              await precacheImage((e.widget as Image).image, e);
            }
          });
          await tester.pump(const Duration(milliseconds: 50));
          await tester.runAsync(() async {
            final RenderRepaintBoundary rb = _shotKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            final ui.Image img = await rb.toImage(pixelRatio: size.width > 700 ? 1 : 1.5);
            final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
            final String file = '${route.substring(1).replaceAll('/', '_')}__$name.png';
            Directory(_out!).createSync(recursive: true);
            File('${_out!}/$file').writeAsBytesSync(png!.buffer.asUint8List());
          });
        }
        await tester.pumpWidget(const SizedBox());
      } finally {
        FlutterError.onError = old;
      }
      for (String e in errs.toSet()) {
        problems.add('$route @ $name ${size.width.toInt()}x${size.height.toInt()}: $e');
      }
    }
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  }

  for (String r in memberRoutes) {
    testWidgets('member $r', (WidgetTester t) => audit(t, r, null), skip: !_on || (_only != null && !r.contains(_only!)));
  }
  providerRoutes.forEach((String role, List<String> routes) {
    for (String r in routes) {
      testWidgets('$role $r', (WidgetTester t) => audit(t, r, role), skip: !_on || (_only != null && !r.contains(_only!)));
    }
  });
}
