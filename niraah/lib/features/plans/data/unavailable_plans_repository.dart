import '../../../shared/helpers/result.dart';
import '../domain/plan.dart';

/// Used by `main.dart` until the plans endpoints exist (spec 004).
class UnavailablePlansRepository implements PlansRepository {
  const UnavailablePlansRepository();

  @override
  Future<Result<PlansOffer>> offer() async => const FailureResult<PlansOffer>('not_connected');

  @override
  Future<Result<bool>> choose(String priceId) async => const Success<bool>(false);
}
