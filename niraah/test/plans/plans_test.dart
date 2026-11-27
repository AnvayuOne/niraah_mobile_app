import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/assessment/domain/prescore.dart';
import 'package:niraah/features/assessment/domain/questionnaire.dart';
import 'package:niraah/features/plans/domain/plan.dart';
import 'package:niraah/sample/sample_backend.dart';
import 'package:niraah/shared/helpers/result.dart';

Answer v(String value) => Answer.values(<String>[value]);

void main() {
  test('plans are refused until the assessment is complete', () async {
    final Result<PlansOffer> r = await SamplePlansRepository(SampleBackend()).offer();
    expect(r, isA<FailureResult<PlansOffer>>());
  });

  test('free plan is listed and current; exactly one plan is recommended', () async {
    final SampleBackend b = SampleBackend();
    final PreScore p = b.submit(<String, Answer>{
      'cycle_regularity': v('irregular'),
      'mood': v('tired'),
      'symptoms': v('acne'),
      'diet': v('rushed'),
      'activity': v('2'),
      'stress': v('4'),
      'sleep': v('tired'),
      'goal': v('pcos'),
    });
    expect(nextActionFor(p), NextAction.seePlans);
    final PlansOffer offer = (await SamplePlansRepository(b).offer() as Success<PlansOffer>).data;
    final Plan free = offer.plans.firstWhere((Plan x) => x.isFree);
    expect(offer.currentPlanId, free.id);
    expect(free.prices, isEmpty);
    expect(free.features, isNotEmpty);
    expect(offer.plans.where((Plan x) => x.recommended).length, 1);
  });

  test('an urgent flag makes booking a doctor the next step', () {
    final PreScore p = SampleBackend().submit(<String, Answer>{
      'cycle_regularity': v('regular'),
      'symptoms': v('heavy_bleeding'),
    });
    expect(p.hasUrgentFlag, isTrue);
    expect(nextActionFor(p), NextAction.bookDoctor);
    expect(p.reviewState, ReviewState.notRequired);
  });
}
