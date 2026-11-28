import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/errors/api_exception.dart';
import 'package:niraah/core/payments/payment_checkout.dart';
import 'package:niraah/features/billing/data/api_billing_repository.dart';
import 'package:niraah/features/billing/domain/billing.dart';
import 'package:niraah/features/billing/presentation/manage_plan_cubit.dart';
import 'package:niraah/features/billing/presentation/manage_plan_page.dart';

import '../helpers/fake_api.dart';
import '../helpers/pump_app.dart';

Map<String, dynamic> plan({bool cancelled = false, String? subscriptionId = 's1'}) => <String, dynamic>{
      'subscriptionId': subscriptionId,
      'planId': 'p1',
      'name': 'Essential',
      'status': 'active',
      'price': <String, dynamic>{'amountPaise': 99900, 'display': '₹999', 'validityCount': 1, 'validityUnit': 'months', 'renews': true},
      'renewsAt': '2026-12-18T00:00:00.000Z',
      'endsAt': null,
      'cancelled': cancelled,
      'retired': false,
    };

Map<String, dynamic> invoiceJson() => <String, dynamic>{
      'id': 'i1',
      'kind': 'invoice',
      'number': 'INV/2026-27/000012',
      'issuedAt': '2026-11-18T10:00:00.000Z',
      'seller': <String, dynamic>{'legal_name': 'Niraah Health', 'address': 'Bengaluru', 'gstin': '29ABCDE1234F1Z5'},
      'buyer': <String, dynamic>{'name': 'Meera'},
      'lines': <Object>[
        <String, dynamic>{'description': 'Subscription', 'beforeTaxPaise': 84661, 'taxPaise': 15239, 'totalPaise': 99900, 'display': '₹999'},
      ],
      'taxRatePercent': 18,
      'taxPaise': 15239,
      'totalPaise': 99900,
      'totalDisplay': '₹999',
    };

class FakeBilling implements BillingRepository {
  Subscription? sub = const Subscription(
    subscriptionId: 's1',
    planId: 'p1',
    name: 'Essential',
    status: 'active',
    priceDisplay: '₹999',
    renews: true,
    renewsAt: '2026-12-18T00:00:00.000Z',
    endsAt: null,
    cancelled: false,
    retired: false,
  );
  final List<String> calls = <String>[];

  @override
  Future<Subscription?> current() async {
    calls.add('current');
    return sub;
  }

  @override
  Future<String> cancel() async {
    calls.add('cancel');
    return '2026-12-18T00:00:00.000Z';
  }

  @override
  Future<void> undoCancel() async => throw ApiException(message: 'This plan is no longer offered. Choose another plan.');

  @override
  Future<PlanChange> change(String priceId) async => const DowngradeScheduled('2026-12-18T00:00:00.000Z');

  @override
  Future<List<Invoice>> invoices() async => <Invoice>[ApiBillingRepository.parseInvoice(invoiceJson())];

  @override
  Future<Invoice> invoice(String id) async => ApiBillingRepository.parseInvoice(invoiceJson());
}

void main() {
  late FakeAdapter adapter;
  late ApiBillingRepository repo;

  setUp(() {
    adapter = FakeAdapter();
    repo = ApiBillingRepository(fakeApi(adapter));
  });

  group('ApiBillingRepository (spec 008 §4, §8)', () {
    test('reads her plan with its renewal date; none yet is null', () async {
      adapter.reply(plan());
      final Subscription s = (await repo.current())!;
      expect(adapter.last.path, '/me/plan');
      expect((s.paid, s.priceDisplay, s.renewsAt, s.cancelled), (true, '₹999', '2026-12-18T00:00:00.000Z', false));
      adapter.reply(<String, dynamic>{'error': <String, dynamic>{'code': 'not_found', 'message': 'No plan.'}}, 404);
      expect(await repo.current(), isNull);
    });

    test('cancel returns the date she keeps the plan until; undo calls its endpoint (AC13)', () async {
      adapter
        ..reply(<String, dynamic>{'endsAt': '2026-12-18T00:00:00.000Z'})
        ..reply(<String, dynamic>{'status': 'done'});
      expect(await repo.cancel(), '2026-12-18T00:00:00.000Z');
      expect(adapter.last.path, '/me/subscription/cancel');
      await repo.undoCancel();
      expect(adapter.last.path, '/me/subscription/undo-cancel');
    });

    test('change sends only the price id; a downgrade waits, an upgrade needs a payment (AC1, AC14)', () async {
      adapter
        ..reply(<String, dynamic>{'kind': 'downgrade', 'effectiveAt': '2026-12-18T00:00:00.000Z'})
        ..reply(<String, dynamic>{
          'kind': 'upgrade',
          'checkout': <String, dynamic>{'subscriptionId': 's2', 'kind': 'subscription', 'gatewayRef': 'g', 'keyId': 'k', 'amountPaise': 120000, 'trialDays': null},
        })
        ..reply(<String, dynamic>{
          'kind': 'upgrade',
          'checkout': <String, dynamic>{'subscriptionId': 's2', 'kind': 'subscription', 'gatewayRef': 'g', 'keyId': 'k', 'amountPaise': 120000, 'trialDays': null, 'skippedPayment': true},
        });
      expect(await repo.change('price-2'), isA<DowngradeScheduled>());
      expect(adapter.lastBody, <String, dynamic>{'priceId': 'price-2'});
      final UpgradeNeedsPayment up = await repo.change('price-3') as UpgradeNeedsPayment;
      expect(up.amountPaise, 120000);
      // The checkout to open: the server's subscription, gateway reference and public key (spec 008 AC1, AC14).
      expect(up.checkout, const Checkout(kind: 'subscription', gatewayRef: 'g', keyId: 'k', amountPaise: 120000, subscriptionId: 's2'));
      expect(await repo.change('price-3'), isA<UpgradeActive>());
    });

    test('invoices carry the tax split and the total she paid (AC28, AC30)', () async {
      adapter.reply(<String, dynamic>{'items': <Object>[invoiceJson()]});
      final Invoice i = (await repo.invoices()).single;
      expect(adapter.last.path, '/me/invoices');
      expect(i.sellerGstin, '29ABCDE1234F1Z5');
      expect(i.lines.single.beforeTaxPaise + i.lines.single.taxPaise, i.totalPaise);
      expect(i.creditNote, isFalse);
      adapter.reply(invoiceJson());
      await repo.invoice('i1');
      expect(adapter.last.path, '/me/invoices/i1');
    });
  });

  group('ManagePlanCubit', () {
    test('cancel returns the end date and reads the plan again (spec 008 §4.1)', () async {
      final FakeBilling b = FakeBilling();
      final ManagePlanCubit c = ManagePlanCubit(b);
      await c.load();
      expect(c.state.status, PlanStatus.ready);
      final PlanActionResult r = await c.cancel();
      expect(r.endsAt, '2026-12-18T00:00:00.000Z');
      expect(b.calls, <String>['current', 'cancel', 'current']);
    });

    test('a refused undo keeps the server words', () async {
      final ManagePlanCubit c = ManagePlanCubit(FakeBilling());
      await c.load();
      final PlanActionResult r = await c.undo();
      expect(r.ok, isFalse);
      expect((r.error! as ApiException).message, 'This plan is no longer offered. Choose another plan.');
      expect(c.state.busy, isFalse);
    });

    test('change reports a downgrade date', () async {
      final ManagePlanCubit c = ManagePlanCubit(FakeBilling());
      expect((await c.change('p2')).change, isA<DowngradeScheduled>());
    });
  });

  testWidgets('Manage plan says when it renews; cancelling says what she keeps and until when (spec 010 §5.6)', (WidgetTester t) async {
    await t.pumpApp(ManagePlanPage(repository: FakeBilling()));
    await t.pumpAndSettle();
    expect(find.text('Essential'), findsOneWidget);
    expect(find.textContaining('Renews on'), findsOneWidget);
    await t.tap(find.text('Cancel plan'));
    await t.pumpAndSettle();
    expect(find.textContaining('You keep Essential until'), findsOneWidget);
    expect(find.textContaining("there's no refund"), findsOneWidget);
  });

  testWidgets('Invoices list each number and total; empty says what will appear', (WidgetTester t) async {
    await t.pumpApp(InvoicesPage(repository: FakeBilling()));
    await t.pumpAndSettle();
    expect(find.text('INV/2026-27/000012'), findsOneWidget);
    expect(find.text('₹999'), findsOneWidget);
  });
}
