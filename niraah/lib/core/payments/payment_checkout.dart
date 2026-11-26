import 'dart:async';

import 'package:equatable/equatable.dart';

/// What the server returned for the gateway's checkout (packages/contracts/src/billing.ts `Checkout`; core
/// `Booking.confirm` and `Classes.book` return the same shape without a subscription). The amount and the public key
/// are the server's: the app sends no amount and holds no key (spec 008 AC1).
class Checkout extends Equatable {
  const Checkout({required this.kind, required this.gatewayRef, required this.keyId, required this.amountPaise, this.subscriptionId, this.trialDays});

  /// `order` (pay-once plan, consult, class) or `subscription` (a renewing plan).
  final String kind;

  /// The gateway's order or subscription id.
  final String gatewayRef;

  /// The gateway's public key id. Never a secret.
  final String keyId;
  final int amountPaise;

  /// Niraah's subscription id, to ask whether it is confirmed (`GET /me/subscription/{id}`).
  final String? subscriptionId;
  final int? trialDays;

  bool get isSubscription => kind == 'subscription';

  static Checkout? fromJson(Object? json) {
    if (json is! Map) return null;
    final Object? ref = json['gatewayRef'];
    final Object? key = json['keyId'];
    if (ref is! String || key is! String || ref.isEmpty || key.isEmpty) return null;
    return Checkout(
      kind: '${json['kind'] ?? 'order'}',
      gatewayRef: ref,
      keyId: key,
      amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
      subscriptionId: json['subscriptionId'] as String?,
      trialDays: (json['trialDays'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => <Object?>[kind, gatewayRef, keyId, amountPaise, subscriptionId, trialDays];
}

/// How the gateway's checkout ended on the phone. A [CheckoutPaid] is only what the gateway's sheet said: the payment
/// counts once the server has it from the gateway's signed webhook (spec 008 §5 "Payment truth" 1, AC2).
sealed class CheckoutResult {
  const CheckoutResult();
}

class CheckoutPaid extends CheckoutResult {
  const CheckoutPaid({required this.paymentId, this.orderId, this.subscriptionId, this.signature});
  final String paymentId;
  final String? orderId;
  final String? subscriptionId;
  final String? signature;
}

/// She closed the checkout.
class CheckoutCancelled extends CheckoutResult {
  const CheckoutCancelled();
}

class CheckoutFailed extends CheckoutResult {
  const CheckoutFailed([this.message]);

  /// The gateway's words, when it gave any.
  final String? message;
}

/// The gateway's checkout sheet (decision D3: Razorpay). Behind an interface so flows are tested with a fake;
/// [RazorpayCheckout] is the real one.
abstract class PaymentCheckout {
  /// [description] is a plain label ("Consult", "Live class", the plan's name); never a condition or health detail
  /// (spec 008 §3.9).
  Future<CheckoutResult> open(Checkout checkout, {required String description});
}

/// What the server says about the thing being paid for, while she waits.
enum ServerPaymentState {
  /// Confirmed from the gateway's webhook.
  confirmed,

  /// Not yet.
  waiting,

  /// The hold ran out before the payment arrived; the server refunds it in full (spec 008 §6.3, spec 014 §3.5).
  lapsed,
}

enum PaymentOutcome { confirmed, pending, lapsed, cancelled, failed }

/// The end of a payment, for the screen to say what happened.
class PaymentResult {
  const PaymentResult(this.outcome, [this.message]);
  final PaymentOutcome outcome;
  final String? message;
}

/// Opens the checkout, then asks the server, never the phone, whether the payment counts (spec 008 §5.1, §5.6): she
/// waits on a calm screen for at most [wait], then is told it is being confirmed and that she will be notified.
///
/// The success payload from the gateway's sheet is not sent anywhere: `/api/v1` has no endpoint that takes it, and the
/// server learns of the payment from the gateway's signed webhook.
Future<PaymentResult> payAndConfirm({
  required PaymentCheckout gateway,
  required Checkout checkout,
  required String description,
  required Future<ServerPaymentState> Function() check,
  void Function()? onConfirming,
  Duration wait = const Duration(seconds: 30),
  Duration every = const Duration(seconds: 2),
  Future<void> Function(Duration) sleep = _sleep,
  DateTime Function() clock = DateTime.now,
}) async {
  final CheckoutResult r = await gateway.open(checkout, description: description);
  switch (r) {
    case CheckoutCancelled():
      return const PaymentResult(PaymentOutcome.cancelled);
    case CheckoutFailed(:final String? message):
      return PaymentResult(PaymentOutcome.failed, message);
    case CheckoutPaid():
      break;
  }
  onConfirming?.call();
  final DateTime until = clock().add(wait);
  while (true) {
    try {
      switch (await check()) {
        case ServerPaymentState.confirmed:
          return const PaymentResult(PaymentOutcome.confirmed);
        case ServerPaymentState.lapsed:
          return const PaymentResult(PaymentOutcome.lapsed);
        case ServerPaymentState.waiting:
          break;
      }
    } on Object {
      // A failed read is the same as "not yet": the webhook still decides.
    }
    if (!clock().isBefore(until)) return const PaymentResult(PaymentOutcome.pending);
    await sleep(every);
  }
}

Future<void> _sleep(Duration d) => Future<void>.delayed(d);
