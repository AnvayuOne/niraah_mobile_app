import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/core/video/video_engine.dart';
import 'package:niraah/features/consults/presentation/device_check_page.dart';

import '../helpers/fake_video.dart';
import '../helpers/pump_app.dart';

/// The device check (spec 014 §4.4) on a fake engine. Tested with fakes only.
void main() {
  testWidgets('camera preview, microphone level and connection test; nothing is sent to the API', (WidgetTester t) async {
    final FakeVideoEngine engine = FakeVideoEngine();
    await t.pumpApp(DeviceCheckPage(engines: () => engine, permissions: FakePermissions(), appId: 'agora-app'));
    await t.tap(find.text('Start the check'));
    await t.pump();
    await t.pump();
    expect(engine.calls, containsAllInOrder(<String>['initialize:agora-app', 'startPreview', 'micTest', 'probe']));
    expect(find.byKey(const Key('local-video')), findsOneWidget);
    await t.scrollUntilVisible(find.text('Testing…'), 200);
    engine
      ..emit(const VideoMicLevel(128))
      ..emit(const VideoProbe(2));
    await t.pump();
    expect(find.text('Good for video'), findsOneWidget);
    engine.emit(const VideoProbe(5));
    await t.pump();
    expect(find.textContaining('Weak'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await t.pump();
    expect(engine.disposed, isTrue);
  });

  testWidgets('without the app id the check asks for the permissions only and says so', (WidgetTester t) async {
    final FakeVideoEngine engine = FakeVideoEngine();
    await t.pumpApp(DeviceCheckPage(engines: () => engine, permissions: FakePermissions(), appId: ''));
    await t.tap(find.text('Start the check'));
    await t.pump();
    expect(find.textContaining('run in the room before you join'), findsOneWidget);
    expect(engine.calls, isEmpty);
  });
}
