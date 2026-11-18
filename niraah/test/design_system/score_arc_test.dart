import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/widgets/score_arc.dart';

import '../helpers/pump_app.dart';

void main() {
  const ScoreArc arc = ScoreArc(total: 72, maximum: 100, caption: 'out of 100', semanticLabel: 'Your pre-score is 72 out of 100.');
  final Finder value = find.byKey(const ValueKey<String>('score-arc-value'));

  testWidgets('with reduced motion the final score is drawn at once and nothing animates', (WidgetTester tester) async {
    await tester.pumpWidget(wrapApp(const Scaffold(body: arc), reducedMotion: true));
    expect(tester.widget<Text>(value).data, '72');
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('without reduced motion it counts up from zero to the score', (WidgetTester tester) async {
    await tester.pumpWidget(wrapApp(const Scaffold(body: arc)));
    expect(tester.widget<Text>(value).data, '0');
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(value).data, '72');
  });
}
