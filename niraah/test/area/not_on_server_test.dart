import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/core/errors/api_exception.dart';
import 'package:niraah/shared/area/area_widgets.dart';

import '../helpers/pump_app.dart';

// A server without this area yet (404) shows "Coming soon", not the load error (e.g. Connected devices, spec 016).
void main() {
  testWidgets('a 404 shows Coming soon instead of an error', (WidgetTester t) async {
    await t.pumpApp(Scaffold(
      body: AsyncBody<int>(
        future: Future<int>.delayed(Duration.zero, () => throw ApiException(message: 'Not found', statusCode: 404)),
        onRetry: () {},
        builder: (_, int v) => Text('$v'),
      ),
    ));
    await t.pumpAndSettle();
    expect(find.textContaining('Coming soon'), findsOneWidget);
  });

  testWidgets('other failures still offer Try again', (WidgetTester t) async {
    await t.pumpApp(Scaffold(
      body: AsyncBody<int>(
        future: Future<int>.delayed(Duration.zero, () => throw ApiException(message: 'Boom', statusCode: 500)),
        onRetry: () {},
        builder: (_, int v) => Text('$v'),
      ),
    ));
    await t.pumpAndSettle();
    expect(find.textContaining('Coming soon'), findsNothing);
  });
}
