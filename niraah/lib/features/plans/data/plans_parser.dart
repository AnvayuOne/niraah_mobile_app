import '../domain/plan.dart';

/// Parses the public plans list (spec 004). `recommendedId` is the plan the
/// server marked for this member.
abstract final class PlansParser {
  static PlansOffer parse(Map<String, dynamic> json, {String? recommendedId, String? currentPlanId, bool trialUsed = false}) {
    final Map<String, dynamic> trial = json['trial'] as Map<String, dynamic>;
    return PlansOffer(
      currentPlanId: currentPlanId,
      trialDays: trialUsed ? 0 : trial['days'] as int,
      trialNote: trial['note'] as String,
      plans: (json['plans'] as List<dynamic>).map((dynamic p) {
        final Map<String, dynamic> m = p as Map<String, dynamic>;
        return Plan(
          id: m['id'] as String,
          name: m['name'] as String,
          description: m['description'] as String,
          colorToken: m['colorToken'] as String,
          highlighted: (m['highlighted'] as bool?) ?? false,
          badge: m['badge'] as String?,
          recommended: m['id'] == recommendedId,
          isFree: (m['isFree'] as bool?) ?? false,
          extraLines: ((m['extraLines'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>(),
          prices: (m['prices'] as List<dynamic>).map((dynamic pr) {
            final Map<String, dynamic> x = pr as Map<String, dynamic>;
            final Map<String, dynamic> v = x['validity'] as Map<String, dynamic>;
            return PlanPrice(
              id: x['id'] as String,
              amountPaise: x['amountPaise'] as int,
              currency: x['currency'] as String,
              validityCount: v['count'] as int,
              validityUnit: v['unit'] as String,
              renews: x['renews'] as bool,
            );
          }).toList(growable: false),
          features: (m['features'] as List<dynamic>).map((dynamic f) => _feature(f as Map<String, dynamic>)).toList(growable: false),
        );
      }).toList(growable: false),
    );
  }

  static PlanFeature _feature(Map<String, dynamic> f) {
    final Object? v = f['value'];
    final String key = f['key'] as String;
    final String name = f['name'] as String;
    if (v is Map<String, dynamic>) {
      if (v['unlimited'] == true) return PlanFeature(key: key, name: name, kind: FeatureValueKind.unlimited);
      if (v.containsKey('limit')) {
        return PlanFeature(key: key, name: name, kind: FeatureValueKind.limit, amount: v['limit'] as int, period: v['period'] as String?);
      }
      return PlanFeature(key: key, name: name, kind: FeatureValueKind.quantity, amount: v['quantity'] as int?, period: v['period'] as String?);
    }
    return PlanFeature(key: key, name: name, kind: FeatureValueKind.included);
  }
}
