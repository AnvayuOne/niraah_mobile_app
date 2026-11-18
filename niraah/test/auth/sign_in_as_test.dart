import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/auth/presentation/pages/sign_in_page.dart';

import '../helpers/pump_app.dart';

// Spec 003 "The sign-in screen" 1–2a, AC1–AC3 (amended 2026-11-18): "Sign in as" picks the field only; a value that
// does not fit the choice is refused on the screen without a server call. Admin is web only.

void main() {
  testWidgets('offers member, doctor, dietitian and trainer; admin is not offered in the app (AC2)', (WidgetTester tester) async {
    await tester.pumpApp(const SignInPage());
    for (final String label in <String>['Member', 'Doctor', 'Dietitian', 'Trainer']) {
      expect(find.widgetWithText(ChoiceChip, label), findsOneWidget);
    }
    expect(find.widgetWithText(ChoiceChip, 'Admin'), findsNothing);
    expect(find.text('Mobile number'), findsOneWidget);
  });

  testWidgets('a member typing an email is told to use her number (AC1)', (WidgetTester tester) async {
    await tester.pumpApp(const SignInPage());
    await tester.enterText(find.byType(TextField), 'asha@example.com');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Members sign in with a mobile number.'), findsOneWidget);
  });

  testWidgets('choosing Trainer asks for an email and refuses a number (AC1)', (WidgetTester tester) async {
    await tester.pumpApp(const SignInPage());
    await tester.tap(find.widgetWithText(ChoiceChip, 'Trainer'));
    await tester.pump();
    expect(find.text('Email'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter your email address.'), findsOneWidget);
  });
}
