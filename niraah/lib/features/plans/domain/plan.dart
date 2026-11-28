import 'package:equatable/equatable.dart';

import '../../../core/payments/payment_checkout.dart';
import '../../../shared/helpers/result.dart';

/// A published plan as members see it (spec 004, "Public API behaviour").
/// Feature values arrive with their keys and display names, so the checklist
/// is never hard-coded.

class PlanPrice extends Equatable {
  const PlanPrice({
    required this.id,
    required this.amountPaise,
    required this.currency,
    required this.validityCount,
    required this.validityUnit,
    required this.renews,
  });

  final String id;

  /// Includes GST (spec 004).
  final int amountPaise;
  final String currency;
  final int validityCount;
  final String validityUnit;
  final bool renews;

  @override
  List<Object?> get props => <Object?>[id, amountPaise, currency, validityCount, validityUnit, renews];
}

enum FeatureValueKind { included, limit, quantity, unlimited }

class PlanFeature extends Equatable {
  const PlanFeature({required this.key, required this.name, required this.kind, this.amount, this.period});

  final String key;
  final String name;
  final FeatureValueKind kind;
  final int? amount;
  final String? period;

  @override
  List<Object?> get props => <Object?>[key, name, kind, amount, period];
}

class Plan extends Equatable {
  const Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.colorToken,
    required this.highlighted,
    required this.prices,
    required this.features,
    this.badge,
    this.extraLines = const <String>[],
    this.recommended = false,
    this.isFree = false,
  });

  /// The one free plan: shown as a plan with what it includes (spec 010 §5.7).
  final bool isFree;

  final String id;
  final String name;
  final String description;
  final String colorToken;
  final bool highlighted;
  final String? badge;
  final List<PlanPrice> prices;
  final List<PlanFeature> features;
  final List<String> extraLines;

  /// Marked by the server for this member (spec 004, "Recommending a plan").
  final bool recommended;

  @override
  List<Object?> get props => <Object?>[id, name, description, colorToken, highlighted, badge, prices, features, extraLines, recommended, isFree];
}

class PlansOffer extends Equatable {
  const PlansOffer({required this.plans, required this.trialDays, required this.trialNote, this.currentPlanId});

  final List<Plan> plans;

  /// The plan she holds now, marked on the screen (spec 010 §5.3).
  final String? currentPlanId;

  /// Zero when she has used her trial or trials are off.
  final int trialDays;
  final String trialNote;

  @override
  List<Object?> get props => <Object?>[plans, trialDays, trialNote, currentPlanId];
}

abstract interface class PlansRepository {
  /// Published plans with the one recommended for her marked. Refused until
  /// her onboarding assessment is complete.
  Future<Result<PlansOffer>> offer();

  /// Choose a plan (spec 008 §1): the server makes a `pending` subscription and the gateway's checkout for it.
  Future<Result<PlanChoice>> choose(String priceId);

  /// `GET /me/subscription/{id}`: whether the gateway's verified webhook has confirmed it (spec 008 AC2).
  Future<SubscriptionCheck> subscriptionStatus(String subscriptionId);
}

/// What choosing a plan led to.
sealed class PlanChoice {
  const PlanChoice();
}

/// In force now: locally, with payment skipped for testing (plan 008).
class PlanActive extends PlanChoice {
  const PlanActive();
}

/// Pay on the gateway's checkout; the plan starts when the server confirms it.
class PlanCheckout extends PlanChoice {
  const PlanCheckout(this.checkout);
  final Checkout checkout;
}

/// No payment can be taken here (the sample build).
class PlanPaymentUnavailable extends PlanChoice {
  const PlanPaymentUnavailable();
}

class SubscriptionCheck extends Equatable {
  const SubscriptionCheck({required this.status, required this.confirmed});

  /// `pending`, `trialing`, `active`, `past_due` or `ended`.
  final String status;
  final bool confirmed;

  @override
  List<Object?> get props => <Object?>[status, confirmed];
}
