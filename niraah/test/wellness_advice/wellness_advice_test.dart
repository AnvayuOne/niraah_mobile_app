import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/errors/api_exception.dart';
import 'package:niraah/features/wellness_advice/data/api_wellness_advice_repository.dart';
import 'package:niraah/features/wellness_advice/domain/wellness_advice.dart';
import 'package:niraah/features/wellness_advice/presentation/wellness_advice_pages.dart';

import '../helpers/fake_api.dart';
import '../helpers/pump_app.dart';

Map<String, dynamic> advice({String state = 'current'}) => <String, dynamic>{
      'id': 'w1',
      'title': 'Wellness advice from your doctor',
      'state': state,
      'stateLabel': state == 'replaced' ? 'Replaced' : 'Current',
      'replacedBy': state == 'replaced' ? 'w2' : null,
      'correctsEarlier': null,
      'doctor': <String, dynamic>{'name': 'Dr Asha Rao', 'qualification': 'MBBS, MD', 'registrationNumber': 'KMC-123', 'council': 'KMC'},
      'issuedAt': '2026-11-15T10:00:00.000Z',
      'assessment': 'Irregular cycles.',
      'supplements': <Object>[
        <String, dynamic>{'name': 'Vitamin D3', 'form': 'Tablet', 'strength': '1000 IU', 'dosePattern': '1-0-0', 'timing': 'After breakfast', 'duration': '8 weeks', 'instructions': null},
      ],
      'advice': 'Walk daily.',
      'seeDoctorLine': 'See a doctor if bleeding is heavy.',
      'followUpOn': '2026-12-15',
      'testsAdvised': <String>['TSH'],
      'wellnessStatement': 'This supports your wellbeing and does not replace your own doctor.',
      'verificationCode': 'ABCD-EFGH',
    };

class FakeAdvice implements WellnessAdviceRepository {
  Future<List<WellnessAdvice>> Function() onList = () async => <WellnessAdvice>[ApiWellnessAdviceRepository.parse(advice())];

  @override
  Future<List<WellnessAdvice>> list() => onList();

  @override
  Future<WellnessAdvice> get(String id) async => ApiWellnessAdviceRepository.parse(advice());

  @override
  Future<String> documentUrl(String id) async => 'https://files.test/w1.pdf';
}

void main() {
  late FakeAdapter adapter;
  late ApiWellnessAdviceRepository repo;

  setUp(() {
    adapter = FakeAdapter();
    repo = ApiWellnessAdviceRepository(fakeApi(adapter));
  });

  test('reads her signed advice with supplements, and a replaced one as replaced (spec 011 AC45)', () async {
    adapter.reply(<String, dynamic>{'items': <Object>[advice(), advice(state: 'replaced')]});
    final List<WellnessAdvice> list = await repo.list();
    expect(adapter.last.path, '/me/wellness-advice');
    expect(list.first.current, isTrue);
    expect(list.last.current, isFalse);
    expect(list.first.supplements.single.dosePattern, '1-0-0');
    expect(list.first.testsAdvised, <String>['TSH']);
  });

  test('one advice and its short document link', () async {
    adapter
      ..reply(advice())
      ..reply(<String, dynamic>{'url': 'https://files.test/w1.pdf', 'expiresInSeconds': 300});
    expect((await repo.get('w1')).doctorName, 'Dr Asha Rao');
    expect(adapter.last.path, '/me/wellness-advice/w1');
    expect(await repo.documentUrl('w1'), 'https://files.test/w1.pdf');
    expect(adapter.last.path, '/me/wellness-advice/w1/document');
  });

  test('the cubit loads, and keeps a failure for "Try again"', () async {
    final FakeAdvice f = FakeAdvice();
    final WellnessAdviceCubit c = WellnessAdviceCubit(f);
    await c.load();
    expect(c.state.items.single.id, 'w1');
    f.onList = () async => throw ApiException(message: 'x');
    await c.load();
    expect(c.state.status, AdviceStatus.failure);
  });

  testWidgets('the screen never says "prescription" or "diagnosis" (spec 011 AC45)', (WidgetTester t) async {
    await t.pumpApp(WellnessAdvicePage(adviceId: 'w1', repository: FakeAdvice()));
    await t.pumpAndSettle();
    expect(find.text('Wellness advice from your doctor'), findsWidgets);
    expect(find.textContaining('Vitamin D3'), findsOneWidget);
    expect(find.textContaining(RegExp('prescription|diagnosis', caseSensitive: false)), findsNothing);
  });

  testWidgets('an empty list says what will appear (spec 010 AC3)', (WidgetTester t) async {
    final FakeAdvice f = FakeAdvice()..onList = () async => const <WellnessAdvice>[];
    await t.pumpApp(WellnessAdviceListPage(repository: f));
    await t.pumpAndSettle();
    expect(find.textContaining('appears here'), findsOneWidget);
  });
}
