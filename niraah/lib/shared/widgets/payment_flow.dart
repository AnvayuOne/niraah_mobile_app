import 'package:material_ui/material_ui.dart';

import '../../core/payments/payment_checkout.dart';
import '../../design_system/tokens/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Runs a payment and, once the gateway's sheet has closed with a payment, shows the calm "confirming" screen while
/// the server is asked (spec 008 §5.6; plan 008 "Returning from checkout"). [pay] receives the callback that opens it.
Future<PaymentResult> runPayment(BuildContext context, Future<PaymentResult> Function(void Function() onConfirming) pay) async {
  final NavigatorState nav = Navigator.of(context);
  bool shown = false;
  void confirming() {
    if (shown || !nav.mounted) return;
    shown = true;
    showDialog<void>(context: nav.context, barrierDismissible: false, builder: (_) => const PopScope(canPop: false, child: _Confirming()));
  }

  final PaymentResult r = await pay(confirming);
  if (shown && nav.mounted) nav.pop();
  return r;
}

/// What to tell her after a payment that did not end confirmed; null when it was confirmed.
String? paymentNote(S s, PaymentResult r) => switch (r.outcome) {
      PaymentOutcome.confirmed => null,
      PaymentOutcome.pending => s.payPending,
      PaymentOutcome.lapsed => s.payLapsed,
      PaymentOutcome.cancelled => s.payCancelled,
      PaymentOutcome.failed => s.payFailed,
    };

class _Confirming extends StatelessWidget {
  const _Confirming();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AlertDialog(
      content: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: NSpace.md),
            Text(s.payConfirming, textAlign: TextAlign.center, style: NType.h4.copyWith(color: NColors.inkPrimary)),
            const SizedBox(height: NSpace.xxs),
            Text(s.payConfirmingNote, textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          ],
        ),
      ),
    );
  }
}
