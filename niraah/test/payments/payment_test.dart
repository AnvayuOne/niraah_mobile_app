import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/core/payments/payment_checkout.dart';
import 'package:niraah/features/consults/data/api_consults_repository.dart';
import 'package:niraah/features/consults/domain/consults.dart';
import 'package:niraah/features/consults/presentation/booking_pages.dart';
import 'package:niraah/features/consults/presentation/consult_cubits.dart';
import 'package:niraah/features/plans/data/api_plans_repository.dart';
import 'package:niraah/features/plans/domain/plan.dart';

import '../consults/consult_cubits_test.dart' show FakeConsults, appt;
import '../helpers/fake_api.dart';
import '../helpers/fake_video.dart';
import '../helpers/pump_app.dart';

const Checkout order = Checkout(kind: 'order', gatewayRef: 'order_9', keyId: 'rzp_live_pub', amountPaise: 80000);

/// Paid consults, classes and plans on a fake checkout (spec 008 §5, §6; spec 014 §3 "Steps" 4). Tested with fakes
/// only; the Razorpay sheet itself needs a device.
void main() {
  group('payAndConfirm (spec 008 §5 "Payment truth")', () {
    late DateTime now;
    late List<Duration> slept;

    Future<PaymentResult> run(FakeCheckout gateway, List<ServerPaymentState> answers, {bool throwFirst = false}) {
      int i = 0;
      return payAndConfirm(
        gateway: gateway,
        checkout: order,
        description: 'Consult',
        clock: () => now,
        sleep: (Duration d) async {
          slept.add(d);
          now = now.add(d);
        },
        check: () async {
          if (throwFirst && i == 0) {
            i++;
            throw Exception('network');
          }
          return answers[(i++).clamp(0, answers.length - 1)];
        },
      );
    }

    setUp(() {
      now = DateTime(2026, 11, 20, 9);
      slept = <Duration>[];
    });

    test('AC2: the sheet saying "paid" is not enough; it is confirmed only when the server says so', () async {
      final PaymentResult r = await run(FakeCheckout(), <ServerPaymentState>[ServerPaymentState.waiting, ServerPaymentState.waiting, ServerPaymentState.confirmed]);
      expect(r.outcome, PaymentOutcome.confirmed);
      expect(slept, hasLength(2));
    });

    test('§5.6: after 30 seconds without confirmation she is told it is being confirmed', () async {
      final PaymentResult r = await run(FakeCheckout(), <ServerPaymentState>[ServerPaymentState.waiting]);
      expect(r.outcome, PaymentOutcome.pending);
      expect(slept.fold<Duration>(Duration.zero, (Duration a, Duration b) => a + b), const Duration(seconds: 30));
    });

    test('a failed read is "not yet", never success', () async {
      final PaymentResult r = await run(FakeCheckout(), <ServerPaymentState>[ServerPaymentState.confirmed], throwFirst: true);
      expect(r.outcome, PaymentOutcome.confirmed);
      expect(slept, hasLength(1));
    });

    test('a payment after the hold ran out is "lapsed": the server refunds it (spec 008 §6.3)', () async {
      expect((await run(FakeCheckout(), <ServerPaymentState>[ServerPaymentState.lapsed])).outcome, PaymentOutcome.lapsed);
    });

    test('closing the sheet or a failure asks the server nothing', () async {
      int checks = 0;
      Future<PaymentResult> once(CheckoutResult r) => payAndConfirm(
            gateway: FakeCheckout(r),
            checkout: order,
            description: 'x',
            check: () async {
              checks++;
              return ServerPaymentState.confirmed;
            },
          );
      expect((await once(const CheckoutCancelled())).outcome, PaymentOutcome.cancelled);
      final PaymentResult failed = await once(const CheckoutFailed('Card declined'));
      expect(failed.outcome, PaymentOutcome.failed);
      expect(failed.message, 'Card declined');
      expect(checks, 0);
    });

    test('the checkout opened is the server\'s: its key, its order and its amount (spec 008 AC1)', () async {
      final FakeCheckout g = FakeCheckout();
      await run(g, <ServerPaymentState>[ServerPaymentState.confirmed]);
      expect(g.opened.single, order);
      expect(g.descriptions.single, 'Consult');
    });
  });

  test('Checkout.fromJson reads the contract shape and refuses one without a key or reference', () {
    expect(Checkout.fromJson(<String, dynamic>{'kind': 'order', 'gatewayRef': 'order_9', 'keyId': 'rzp_live_pub', 'amountPaise': 80000}), order);
    expect(Checkout.fromJson(<String, dynamic>{'kind': 'order', 'gatewayRef': '', 'keyId': 'k', 'amountPaise': 1}), isNull);
    expect(Checkout.fromJson(null), isNull);
  });

  test('a paid consult\'s confirm answer carries the checkout to open (core Booking.confirm)', () async {
    final FakeAdapter adapter = FakeAdapter()
      ..reply(<String, dynamic>{
        'status': 'payment_needed',
        'checkout': <String, dynamic>{'kind': 'order', 'gatewayRef': 'order_9', 'keyId': 'rzp_live_pub', 'amountPaise': 80000},
      });
    final ConfirmOutcome o = await ApiConsultsRepository(fakeApi(adapter)).confirm('a1', consents: <String>['health_data']);
    expect((o as PaymentNeeded).checkout, order);
    expect(o.amountPaise, 80000);
  });

  test('the plan status read for the confirming screen (GET /me/subscription/{id})', () async {
    final FakeAdapter adapter = FakeAdapter()..reply(<String, dynamic>{'subscriptionId': 's1', 'status': 'trialing', 'confirmed': true});
    final SubscriptionCheck c = await ApiPlansRepository(fakeApi(adapter)).subscriptionStatus('s1');
    expect(c, const SubscriptionCheck(status: 'trialing', confirmed: true));
    expect(adapter.last.path, '/me/subscription/s1');
  });

  group('paying for a held consult (spec 014 §3 "Steps" 4-5, AC10, AC11)', () {
    Appointment held() => appt(status: 'held', kind: 'paid', holdUntil: DateTime.now().add(const Duration(minutes: 9)));

    test('AC11: confirmed only once the server has the verified payment', () async {
      final FakeConsults repo = FakeConsults()..current = held();
      final List<Appointment> reads = <Appointment>[held(), appt(kind: 'paid')];
      final _SeqRepo r2 = _SeqRepo(reads);
      final ConfirmCubit c = ConfirmCubit(r2, repo.current, sleep: (_) async {});
      final PaymentResult r = await c.pay(FakeCheckout(), order, description: 'Consult');
      expect(r.outcome, PaymentOutcome.confirmed);
      expect(c.state.appointment.status, 'confirmed');
      expect(r2.reads, 2);
      await c.close();
    });

    test('a hold that ran out before the payment arrived is "lapsed" (refunded by the server)', () async {
      final ConfirmCubit c = ConfirmCubit(_SeqRepo(<Appointment>[appt(status: 'expired', kind: 'paid')]), held(), sleep: (_) async {});
      expect((await c.pay(FakeCheckout(), order, description: 'Consult')).outcome, PaymentOutcome.lapsed);
      await c.close();
    });

    testWidgets('the fee on the button; closing the checkout keeps the time held and gives nothing back', (WidgetTester t) async {
      final FakeConsults repo = FakeConsults()..onConfirm = (_) async => const PaymentNeeded(80000, order);
      final FakeCheckout gateway = FakeCheckout(const CheckoutCancelled());
      await t.pumpApp(ConfirmBookingPage(repository: repo, held: held(), gateway: gateway));
      await t.pump();
      await t.scrollUntilVisible(find.text('Confirm and pay ₹800'), 300);
      expect(find.textContaining('Your time stays held while you pay'), findsOneWidget);
      t.widget<FilledButton>(find.ancestor(of: find.text('Confirm and pay ₹800'), matching: find.byType(FilledButton))).onPressed!();
      await t.pump();
      await t.pump();
      expect(gateway.opened.single, order);
      expect(find.text('Payment not completed.'), findsOneWidget);
      expect(repo.calls, isNot(contains('cancel')), reason: 'the hold is kept; she can pay again or give it back');
      expect(find.text('Confirm and pay ₹800'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('paid and confirmed by the server: the page closes with the confirmed appointment', (WidgetTester t) async {
      final FakeConsults repo = FakeConsults()
        ..onConfirm = ((_) async => const PaymentNeeded(80000, order))
        ..current = appt(kind: 'paid');
      Appointment? popped;
      await t.pumpApp(Scaffold(body: Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () async => popped = await Navigator.of(context).push<Appointment>(
            MaterialPageRoute<Appointment>(builder: (_) => ConfirmBookingPage(repository: repo, held: held(), gateway: FakeCheckout(), sleep: (_) async {})),
          ),
          child: const Text('open'),
        ),
      )));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.text('Confirm and pay ₹800'), 300);
      t.widget<FilledButton>(find.ancestor(of: find.text('Confirm and pay ₹800'), matching: find.byType(FilledButton))).onPressed!();
      await t.pumpAndSettle();
      expect(popped?.status, 'confirmed');
      expect(find.text('Paid. Your consult is booked.'), findsOneWidget);
    });
  });
}

/// Returns [reads] in turn for `GET /appointments/{id}`.
class _SeqRepo extends FakeConsults {
  _SeqRepo(this.answers);

  final List<Appointment> answers;
  int reads = 0;

  @override
  Future<Appointment> appointment(String id) async => answers[(reads++).clamp(0, answers.length - 1)];
}
