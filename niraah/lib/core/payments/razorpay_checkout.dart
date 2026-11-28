import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'payment_checkout.dart';

/// [PaymentCheckout] on Razorpay's Flutter SDK (decision D3; plan 008 "Gateway"). The only file in the app that imports
/// it. The key id, the order or subscription id and the amount all come from the server's checkout.
class RazorpayCheckout implements PaymentCheckout {
  RazorpayCheckout({Razorpay Function()? create}) : _create = create ?? Razorpay.new;

  final Razorpay Function() _create;

  @override
  Future<CheckoutResult> open(Checkout checkout, {required String description}) {
    final Razorpay rp = _create();
    final Completer<CheckoutResult> done = Completer<CheckoutResult>();
    void finish(CheckoutResult r) {
      if (!done.isCompleted) done.complete(r);
      rp.clear();
    }

    rp
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
        finish(CheckoutPaid(paymentId: r.paymentId ?? '', orderId: r.orderId, signature: r.signature, subscriptionId: checkout.isSubscription ? checkout.gatewayRef : null));
      })
      ..on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
        finish(r.code == Razorpay.PAYMENT_CANCELLED ? const CheckoutCancelled() : CheckoutFailed(r.message));
      })
      // She finishes in a wallet app; whether it was paid is learnt from the server, as for any payment.
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse _) => finish(const CheckoutPaid(paymentId: '')));

    final Map<String, dynamic> options = <String, dynamic>{
      'key': checkout.keyId,
      'name': 'Niraah',
      'description': description,
      if (checkout.isSubscription) 'subscription_id': checkout.gatewayRef else ...<String, dynamic>{
        'order_id': checkout.gatewayRef,
        'amount': checkout.amountPaise,
        'currency': 'INR',
      },
    };
    try {
      rp.open(options);
    } on Object catch (e) {
      finish(CheckoutFailed('$e'));
    }
    return done.future;
  }
}
