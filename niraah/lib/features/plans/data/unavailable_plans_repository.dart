import '../../../shared/helpers/result.dart';
import '../domain/plan.dart';

/// Used by `main.dart` until the plans endpoints exist (spec 004).
class UnavailablePlansRepository implements PlansRepository {
  const UnavailablePlansRepository();

  @override
  Future<Result<PlansOffer>> offer() async => const FailureResult<PlansOffer>('not_connected');

  @override
  Future<Result<PlanChoice>> choose(String priceId) async => const Success<PlanChoice>(PlanPaymentUnavailable());

  @override
  Future<SubscriptionCheck> subscriptionStatus(String subscriptionId) async => const SubscriptionCheck(status: 'pending', confirmed: false);
}
