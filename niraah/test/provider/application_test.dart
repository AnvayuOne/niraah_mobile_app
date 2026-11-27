import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/provider_auth/application_repository.dart';
import 'package:niraah/features/provider_auth/presentation/application_form.dart';
import 'package:niraah/features/provider_work/domain/provider_work.dart';

import '../helpers/fake_api.dart';
import '../helpers/pump_app.dart';

// Spec 006 "Completing the application" in the app (plan 006 T9): the status page's form on /provider/application.

Json _app({String status = 'draft', bool editable = true, List<String> missing = const <String>['Photo'], String? asked}) => <String, dynamic>{
      'id': 'a1',
      'status': status,
      'statusWords': status == 'draft' ? 'not yet submitted' : 'more information needed',
      'providerType': 'instructor',
      'editable': editable,
      'missing': missing,
      'informationRequested': asked,
      'decisionReason': null,
      'canReapplyAt': null,
      'termsVersion': '2026-11-17',
      'termsAccepted': false,
      'profile': <String, dynamic>{'name': 'Meera', 'email': 'm@example.com', 'contactPhone': '', 'bio': '', 'specialities': <String>[], 'languages': <String>[], 'yearsExperience': null, 'registrationNumber': '', 'registrationCouncil': ''},
      'referees': <Json>[],
      'documents': <Json>[],
    };

class FakeApplication implements ProviderApplicationRepository {
  FakeApplication(this.current);

  Json current;
  final List<String> calls = <String>[];

  @override
  Future<Json> get() async => current;

  @override
  Future<Json> submit({required bool acceptTerms}) async {
    calls.add('submit:$acceptTerms');
    return current = <String, dynamic>{...current, 'status': 'submitted', 'statusWords': 'waiting for review', 'editable': false};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> settle(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  test('the repository uses the contract paths and sends documents as base64 (plan 006)', () async {
    final FakeAdapter adapter = FakeAdapter();
    final ApiProviderApplicationRepository repo = ApiProviderApplicationRepository(fakeApi(adapter));
    adapter
      ..reply(<String, dynamic>{'fileId': 'f1'})
      ..reply(_app());
    await repo.upload(kind: 'photo', fileName: 'me.png', contentType: 'image/png', bytes: <int>[1, 2, 3]);
    expect(adapter.last.path, '/provider/application/documents');
    expect(adapter.lastBody, <String, dynamic>{'kind': 'photo', 'fileName': 'me.png', 'contentType': 'image/png', 'dataBase64': 'AQID'});
    await repo.submit(acceptTerms: true);
    expect(adapter.last.path, '/provider/application/submit');
    expect(adapter.lastBody, <String, dynamic>{'acceptTerms': true});
  });

  testWidgets('Submit stays off while something is missing (AC46)', (WidgetTester tester) async {
    final FakeApplication repo = FakeApplication(_app());
    await tester.pumpApp(Scaffold(body: SingleChildScrollView(child: ApplicationForm(repository: repo))));
    await settle(tester);
    expect(find.text('not yet submitted'), findsOneWidget);
    expect(find.textContaining('Still needed: Photo'), findsOneWidget);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await settle(tester);
    expect(repo.calls, isEmpty);
    expect(find.text('Add what is still needed first'), findsOneWidget);
  });

  testWidgets('what the team asked for is shown, and she sends it again (AC9)', (WidgetTester tester) async {
    final FakeApplication repo = FakeApplication(_app(status: 'more_information_requested', missing: <String>[], asked: 'A clearer identity scan'));
    await tester.pumpApp(Scaffold(body: SingleChildScrollView(child: ApplicationForm(repository: repo))));
    await settle(tester);
    expect(find.textContaining('A clearer identity scan'), findsOneWidget);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await settle(tester);
    await tester.ensureVisible(find.text('Send again'));
    await tester.tap(find.text('Send again'));
    await settle(tester);
    expect(repo.calls, <String>['submit:true']);
    expect(find.text('waiting for review'), findsOneWidget);
  });
}
