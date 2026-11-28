/// "Manage plan" and invoices (spec 008 §4, §8; spec 010 §5.6), matching packages/contracts/src/billing.ts `CurrentPlan`,
/// `CancelResult`, `ChangePlanResult`, `Invoice`. Every amount includes GST; the server decides every date and outcome.
library;

import 'package:equatable/equatable.dart';

import '../../../core/payments/payment_checkout.dart';

class Subscription extends Equatable {
  const Subscription({
    required this.subscriptionId,
    required this.planId,
    required this.name,
    required this.status,
    required this.priceDisplay,
    required this.renews,
    required this.renewsAt,
    required this.endsAt,
    required this.cancelled,
    required this.retired,
  });

  /// Null on the free plan.
  final String? subscriptionId;
  final String planId;
  final String name;

  /// `trialing`, `active`, `past_due`, `pending`, `ended`, or `free`.
  final String status;
  final String? priceDisplay;
  final bool? renews;
  final String? renewsAt;
  final String? endsAt;

  /// "Ends at validity end": she keeps it until [endsAt] and can undo (§4 "Cancelling" 2, 3).
  final bool cancelled;
  final bool retired;

  bool get paid => subscriptionId != null;

  @override
  List<Object?> get props => <Object?>[subscriptionId, planId, name, status, priceDisplay, renews, renewsAt, endsAt, cancelled, retired];
}

/// What changing plan did (§4 "Upgrading and downgrading").
sealed class PlanChange {
  const PlanChange();
}

/// A downgrade waits for the end of the current validity.
class DowngradeScheduled extends PlanChange {
  const DowngradeScheduled(this.effectiveAt);
  final String effectiveAt;
}

/// An upgrade takes effect when its payment succeeds; the app can't take that payment yet.
class UpgradeNeedsPayment extends PlanChange {
  const UpgradeNeedsPayment(this.amountPaise, [this.checkout]);
  final int amountPaise;

  /// The gateway's checkout for the new subscription, the unused days already credited (plan 008 "Upgrade").
  final Checkout? checkout;
}

/// Locally, with payment skipped for testing (plan 008), the new plan is in force at once.
class UpgradeActive extends PlanChange {
  const UpgradeActive();
}

class InvoiceLine extends Equatable {
  const InvoiceLine({required this.description, required this.beforeTaxPaise, required this.taxPaise, required this.totalPaise, required this.display});

  final String description;
  final int beforeTaxPaise;
  final int taxPaise;
  final int totalPaise;
  final String display;

  @override
  List<Object?> get props => <Object?>[description, beforeTaxPaise, taxPaise, totalPaise, display];
}

/// A tax invoice or a credit note (§8.1, §8.3).
class Invoice extends Equatable {
  const Invoice({
    required this.id,
    required this.kind,
    required this.number,
    required this.issuedAt,
    required this.sellerName,
    required this.sellerAddress,
    required this.sellerGstin,
    required this.buyerName,
    required this.lines,
    required this.taxRatePercent,
    required this.taxPaise,
    required this.totalPaise,
    required this.totalDisplay,
  });

  final String id;

  /// `invoice` or `credit_note`.
  final String kind;
  final String number;
  final String issuedAt;
  final String? sellerName;
  final String? sellerAddress;
  final String? sellerGstin;
  final String? buyerName;
  final List<InvoiceLine> lines;
  final double taxRatePercent;
  final int taxPaise;
  final int totalPaise;
  final String totalDisplay;

  bool get creditNote => kind == 'credit_note';

  @override
  List<Object?> get props => <Object?>[id, kind, number, issuedAt, lines, taxPaise, totalPaise];
}

abstract class BillingRepository {
  /// Her current plan (`GET /me/plan`), or null when she has none yet.
  Future<Subscription?> current();

  /// Cancels; she keeps the plan until the returned date (AC13).
  Future<String> cancel();

  Future<void> undoCancel();

  Future<PlanChange> change(String priceId);

  /// Her invoices and credit notes, also after her subscription ends (AC30).
  Future<List<Invoice>> invoices();

  Future<Invoice> invoice(String id);
}
