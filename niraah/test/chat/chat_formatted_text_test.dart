import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/chat/presentation/conversation_page.dart';

import '../helpers/pump_app.dart';

// A real AI Care answer from the live server (2026-11-23): markdown bold and bullets must not show as marks.
const List<String> answer = <String>[
  'For PCOS, food can support your overall wellbeing alongside care from your doctor.',
  '- **Choose slow-digesting carbohydrates:** whole grains like jowar, bajra, ragi, brown rice or whole wheat.',
  '- **Add protein and fibre to each meal:** dals, chana, rajma, curd, paneer, eggs.',
  'Movement, sleep and managing stress also matter.',
  'Since PCOS looks different for every woman, a doctor can tailor food advice to you.',
];

String shown(WidgetTester t) => t
    .widgetList<RichText>(find.byType(RichText))
    .map((RichText r) => r.text.toPlainText())
    .join('\n');

void main() {
  testWidgets('no stars or dashes are shown; bullets and bold are rendered', (WidgetTester t) async {
    await t.pumpWidget(wrapApp(const Scaffold(body: ChatFormattedText(lines: answer, style: TextStyle()))));
    final String text = shown(t);
    expect(text.contains('*'), isFalse);
    expect(text.contains('- '), isFalse);
    expect(find.text('•'), findsNWidgets(2));
    expect(text, contains('Choose slow-digesting carbohydrates:'));
    // Plain sentences after the list run on in one paragraph.
    expect(text, contains('Movement, sleep and managing stress also matter. Since PCOS'));
    final Iterable<TextSpan> boldSpans = t
        .widgetList<RichText>(find.byType(RichText))
        .expand((RichText r) => (r.text as TextSpan).children ?? <InlineSpan>[])
        .expand((InlineSpan s) => s is TextSpan ? <TextSpan>[s, ...?s.children?.whereType<TextSpan>()] : <TextSpan>[])
        .where((TextSpan s) => s.style?.fontWeight == FontWeight.w700);
    expect(boldSpans.map((TextSpan s) => s.text), contains('Choose slow-digesting carbohydrates:'));
  });

  test('screen-reader text drops the marks', () {
    expect(plainChatText('- **Eat at regular times** and rest'), 'Eat at regular times and rest');
  });
}
