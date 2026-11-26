// Renders every loading view to PNG. Runs only when SCREENSHOT_DIR is set.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/design_system/tokens/tokens.dart';
import 'package:niraah/design_system/widgets/loading_view.dart';
import 'package:niraah/design_system/widgets/n_shimmer.dart';

final String? _out = Platform.environment['SCREENSHOT_DIR'];
const GlobalObjectKey<State<StatefulWidget>> _b = GlobalObjectKey<State<StatefulWidget>>('loaders');

Future<void> _fonts() async {
  Future<ByteData> font(String f) async => ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync());
  final FontLoader sans = FontLoader('PlusJakartaSans');
  for (final String w in <String>['400', '500', '600', '700']) {
    sans.addFont(font('PlusJakartaSans-$w.ttf'));
  }
  await sans.load();
}

void main() {
  setUpAll(_fonts);
  testWidgets('loaders', (WidgetTester t) async {
    t.view.physicalSize = const Size(1170, 2400);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(RepaintBoundary(
      key: _b,
      child: MaterialApp(
        theme: AppTheme.current,
        home: Scaffold(
          backgroundColor: NColors.surfacePage,
          body: GridView.count(
            crossAxisCount: 2,
            children: <Widget>[for (final NLoaderKind k in NLoaderKind.values) LoadingView(label: k.name, kind: k)],
          ),
        ),
      ),
    ));
    await t.pump(const Duration(milliseconds: 700));
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await t.pump(const Duration(milliseconds: 500));
    await t.runAsync(() async {
      final ui.Image img = await (_b.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage(pixelRatio: 1.5);
      final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
      Directory(_out!).createSync(recursive: true);
      File('${_out!}/loaders.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }, skip: _out == null);

  testWidgets('cooking', (WidgetTester t) async {
    t.view.physicalSize = const Size(1170, 1200);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(RepaintBoundary(key: _b, child: MaterialApp(theme: AppTheme.current, home: Scaffold(backgroundColor: NColors.surfacePage, body: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[const NMealLoader(size: 200), const SizedBox(height: 24), const Expanded(child: NPagePlaceholder(label: 'Loading'))])))));
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    for (final int ms in <int>[300, 900, 1500]) {
      await t.pump(Duration(milliseconds: ms));
      await t.runAsync(() async {
        final ui.Image img = await (_b.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage(pixelRatio: 1);
        final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
        File('${_out!}/cooking_$ms.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
  }, skip: _out == null);
}
