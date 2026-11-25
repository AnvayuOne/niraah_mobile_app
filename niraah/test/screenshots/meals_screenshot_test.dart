// Renders the meal scan states to PNG for visual review. Runs only when SCREENSHOT_DIR is set.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/design_system/tokens/tokens.dart';
import 'package:niraah/features/meals/domain/meals.dart';
import 'package:niraah/features/meals/presentation/meal_scan_page.dart';
import 'package:niraah/l10n/app_localizations.dart';

final String? _out = Platform.environment['SCREENSHOT_DIR'];
const GlobalObjectKey<State<StatefulWidget>> _boundary = GlobalObjectKey<State<StatefulWidget>>('meals-shot');

class _Picker extends ImagePicker {
  @override
  Future<XFile?> pickImage({required ImageSource source, double? maxWidth, double? maxHeight, int? imageQuality, CameraDevice preferredCameraDevice = CameraDevice.rear, bool requestFullMetadata = true}) async =>
      XFile.fromData(File('assets/images/10_indian_thali_meal_plate.webp').readAsBytesSync());
}

class _Repo implements MealsRepository {
  final Completer<ScanResult> pending = Completer<ScanResult>();

  @override
  Future<ScanResult> scan(String photoBase64) => pending.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const Nutrients _dal = Nutrients(energyKcal: 168, proteinG: 9.4, carbohydrateG: 22, fatG: 4.6, fibreG: 5.1);
const Nutrients _rice = Nutrients(energyKcal: 205, proteinG: 4.2, carbohydrateG: 45, fatG: 0.4, fibreG: 0.6);
const Nutrients _roti = Nutrients(energyKcal: 240, proteinG: 7.8, carbohydrateG: 46, fatG: 3.2, fibreG: 6.4);

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

Future<void> _shot(WidgetTester tester, String name, {bool settle = true}) async {
  await tester.runAsync(() async {
    for (Element e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 1600));
  }
  await tester.runAsync(() async {
    final RenderRepaintBoundary rb = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await rb.toImage(pixelRatio: 2);
    final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
    File('${_out!}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  NColors.dark = Platform.environment['SCREENSHOT_DARK'] == '1';
  testWidgets('meal scan', (WidgetTester tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    final _Repo repo = _Repo();
    await tester.pumpWidget(RepaintBoundary(
      key: _boundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.current,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: MealScanPage(repository: repo, picker: _Picker()),
      ),
    ));
    await _shot(tester, '40-scan-start');
    await tester.tap(find.text('Take a photo').first);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await _shot(tester, '41-scan-reading', settle: false);
    repo.pending.complete(const ScanOk(
      items: <ScanItem>[
        MatchedItem(food: FoodRef(id: '1', name: 'Dal tadka'), count: 1, unit: 'katori', nutrients: _dal, confidence: 0.9),
        MatchedItem(food: FoodRef(id: '2', name: 'Steamed rice'), count: 1, unit: 'katori', nutrients: _rice, confidence: 0.9),
        MatchedItem(food: FoodRef(id: '3', name: 'Roti'), count: 2, unit: 'piece', nutrients: _roti, confidence: 0.8),
        NotSureItem(label: 'Green chutney', count: 1, unit: 'tablespoon'),
      ],
      totals: _dal,
      tags: <String>['High fibre', 'Balanced'],
      caloriesHidden: false,
    ));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(seconds: 3));
    await _shot(tester, '42-scan-result');
  }, skip: _out == null);
}
