import '../../../core/network/niraah_api.dart';
import '../../../core/payments/payment_checkout.dart';
import '../../../shared/helpers/result.dart';
import '../domain/plan.dart';

/// The plans screen on `/api/v1` (spec 004 T8). Every amount includes GST. Features a plan does not
/// include are left out of its checklist.
class ApiPlansRepository implements PlansRepository {
  ApiPlansRepository(this._api);

  final NiraahApi _api;

  @override
  Future<Result<PlansOffer>> offer() async {
    // Both reads go out together.
    final Future<ApiResult<Map<String, dynamic>>> currentCall = _api.get('/me/plan');
    final ApiResult<Map<String, dynamic>> r = await _api.get('/me/plans');
    final ApiResult<Map<String, dynamic>> current = await currentCall;
    if (r is ApiFail<Map<String, dynamic>>) return FailureResult<PlansOffer>(r.error.message);
    final String? currentPlanId = current is ApiOk<Map<String, dynamic>> && current.data['subscriptionId'] != null ? '${current.data['planId']}' : null;
    return Success<PlansOffer>(parse((r as ApiOk<Map<String, dynamic>>).data, currentPlanId: currentPlanId));
  }

  /// `POST /me/subscription`, matching apps/web/src/api/plans-repository.ts `choose`. Locally with payment
  /// skipped the plan is active at once (plan 008); otherwise the answer is the gateway's checkout (contracts
  /// `Checkout`), with the amount and the public key from the server (spec 008 AC1).
  @override
  Future<Result<PlanChoice>> choose(String priceId) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/me/subscription', <String, dynamic>{'priceId': priceId});
    switch (r) {
      case ApiOk<Map<String, dynamic>>(:final Map<String, dynamic> data):
        if (data['skippedPayment'] == true) return const Success<PlanChoice>(PlanActive());
        final Checkout? c = Checkout.fromJson(data);
        return c == null ? const Success<PlanChoice>(PlanPaymentUnavailable()) : Success<PlanChoice>(PlanCheckout(c));
      case ApiFail<Map<String, dynamic>>(:final ApiError error):
        return FailureResult<PlanChoice>(error.message);
    }
  }

  @override
  Future<SubscriptionCheck> subscriptionStatus(String subscriptionId) async {
    final Map<String, dynamic> r = (await _api.get('/me/subscription/${Uri.encodeComponent(subscriptionId)}')).orThrow();
    return SubscriptionCheck(status: '${r['status']}', confirmed: r['confirmed'] == true);
  }

  static PlansOffer parse(Map<String, dynamic> json, {String? currentPlanId}) {
    final Map<dynamic, dynamic>? trial = json['trial'] as Map?;
    return PlansOffer(
      currentPlanId: currentPlanId,
      trialDays: (trial?['days'] as int?) ?? 0,
      trialNote: '${trial?['covers'] ?? ''}',
      plans: (json['plans'] as List<dynamic>).map((dynamic raw) {
        final Map<dynamic, dynamic> m = raw as Map;
        return Plan(
          id: '${m['id']}',
          name: '${m['name']}',
          description: '${m['description']}',
          colorToken: '${m['colorToken']}',
          highlighted: m['highlighted'] == true,
          badge: m['badgeText'] as String?,
          recommended: m['recommended'] == true,
          isFree: m['isFree'] == true,
          extraLines: ((m['extraLines'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic e) => '$e').toList(growable: false),
          prices: (m['prices'] as List<dynamic>).map((dynamic p) {
            final Map<dynamic, dynamic> x = p as Map;
            return PlanPrice(
              id: '${x['id']}',
              amountPaise: x['amountPaise'] as int,
              currency: 'INR',
              validityCount: x['validityCount'] as int,
              validityUnit: '${x['validityUnit']}',
              renews: x['renews'] == true,
            );
          }).toList(growable: false),
          features: (m['features'] as List<dynamic>).map((dynamic f) => feature(f as Map)).whereType<PlanFeature>().toList(growable: false),
        );
      }).toList(growable: false),
    );
  }

  /// Null when the plan does not include it: off, or a limit or quantity of zero.
  static PlanFeature? feature(Map<dynamic, dynamic> f) {
    final String key = '${f['key']}';
    final String name = '${f['name']}';
    final Object? v = f['value'];
    final String? period = f['allowancePeriod'] as String?;
    if (v == true) return PlanFeature(key: key, name: name, kind: FeatureValueKind.included);
    if (v is Map) {
      if (v['limit'] == 'unlimited') return PlanFeature(key: key, name: name, kind: FeatureValueKind.unlimited);
      if (v['limit'] is int && (v['limit'] as int) > 0) return PlanFeature(key: key, name: name, kind: FeatureValueKind.limit, amount: v['limit'] as int, period: period);
      if (v['quantity'] is int && (v['quantity'] as int) > 0) return PlanFeature(key: key, name: name, kind: FeatureValueKind.quantity, amount: v['quantity'] as int, period: period);
    }
    return null;
  }
}
