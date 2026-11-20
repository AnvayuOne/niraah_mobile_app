import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/plans/data/api_plans_repository.dart';
import 'package:niraah/features/plans/domain/plan.dart';
import 'package:niraah/shared/helpers/result.dart';

/// Answers requests from a script and records what was sent.
class _Adapter implements HttpClientAdapter {
  final List<(int, Object)> replies = <(int, Object)>[];
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (int status, Object body) = replies.removeAt(0);
    return ResponseBody.fromString(jsonEncode(body), status, headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('reads the API plans list: recommended plan, trial, GST-inclusive prices, included features only (spec 004)', () {
    final PlansOffer offer = ApiPlansRepository.parse(<String, dynamic>{
      'trial': <String, dynamic>{'days': 7, 'covers': 'AI and self-guided features.'},
      'plans': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'p1', 'name': 'Essential', 'description': 'd', 'colorToken': 'tier2', 'badgeText': 'Most popular', 'highlighted': true, 'isFree': false, 'recommended': true,
          'prices': <Map<String, dynamic>>[<String, dynamic>{'id': 'x', 'validityCount': 1, 'validityUnit': 'months', 'renews': true, 'amountPaise': 99900, 'display': '₹999'}],
          'features': <Map<String, dynamic>>[
            <String, dynamic>{'key': 'ai_chat.messages', 'name': 'AI Care chat', 'kind': 'limit', 'value': <String, int>{'limit': 100}, 'allowancePeriod': 'day', 'carryOver': false},
            <String, dynamic>{'key': 'meal_scan.scans', 'name': 'Meal scans', 'kind': 'limit', 'value': <String, String>{'limit': 'unlimited'}, 'allowancePeriod': 'day', 'carryOver': false},
            <String, dynamic>{'key': 'care_team.dedicated_doctor', 'name': 'Your own doctor', 'kind': 'boolean', 'value': false, 'allowancePeriod': null, 'carryOver': false},
            <String, dynamic>{'key': 'consults.doctor_included', 'name': 'Doctor consults', 'kind': 'quantity', 'value': <String, int>{'quantity': 1}, 'allowancePeriod': 'month', 'carryOver': true},
          ],
          'extraLines': <String>['Priority support'],
        },
      ],
    }, currentPlanId: 'p1');
    final Plan p = offer.plans.single;
    expect(offer.trialDays, 7);
    expect(p.recommended, isTrue);
    expect(p.badge, 'Most popular');
    expect(p.prices.single.amountPaise, 99900);
    expect(p.features.map((PlanFeature f) => f.key), <String>['ai_chat.messages', 'meal_scan.scans', 'consults.doctor_included']);
    expect(p.features[1].kind, FeatureValueKind.unlimited);
    expect(offer.currentPlanId, 'p1');
  });

  test('choosing a plan: active at once when the server skipped payment, otherwise payment comes later (plan 008)', () async {
    final _Adapter adapter = _Adapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))..httpClientAdapter = adapter;
    final ApiPlansRepository repo = ApiPlansRepository(NiraahApi(dio: dio, store: MemorySessionStore()));
    final Map<String, dynamic> checkout = <String, dynamic>{'subscriptionId': 's1', 'kind': 'subscription', 'gatewayRef': 'sub_1', 'keyId': 'k', 'amountPaise': 99900, 'trialDays': 7};
    adapter.replies.addAll(<(int, Object)>[
      (200, <String, dynamic>{...checkout, 'skippedPayment': true}),
      (200, checkout),
      (409, <String, dynamic>{'error': <String, dynamic>{'code': 'conflict', 'message': 'You already have a plan. Change plan instead.'}, 'requestId': 'r'}),
      (200, <String, dynamic>{'kind': 'upgrade', 'checkout': <String, dynamic>{...checkout, 'skippedPayment': true}}),
      (409, <String, dynamic>{'error': <String, dynamic>{'code': 'conflict', 'message': 'You already have a plan. Change plan instead.'}, 'requestId': 'r'}),
      (200, <String, dynamic>{'kind': 'downgrade', 'effectiveAt': '2026-12-19T00:00:00Z'}),
    ]);
    expect((await repo.choose('price-1') as Success<bool>).data, isTrue);
    expect((await repo.choose('price-1') as Success<bool>).data, isFalse);
    // With a plan already: an upgrade goes through the change endpoint and is active at once; a downgrade waits.
    expect((await repo.choose('price-2') as Success<bool>).data, isTrue);
    expect(adapter.requests[3].path, '/me/subscription/change');
    expect((await repo.choose('price-0') as FailureResult<bool>).message, contains('19/12/2026'));
    expect(adapter.requests.first.data, <String, dynamic>{'priceId': 'price-1'});
    expect(adapter.requests.first.path, '/me/subscription');
  });
}
