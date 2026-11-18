import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/meals/data/api_meals_repository.dart';
import 'package:niraah/features/meals/domain/meals.dart';

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

Map<String, dynamic> n(double? kcal, double p) =>
    <String, dynamic>{'energyKcal': kcal, 'proteinG': p, 'carbohydrateG': 20, 'fatG': 3, 'fibreG': 2, 'glycaemicIndex': 55};

void main() {
  late _Adapter adapter;
  late ApiMealsRepository repo;

  setUp(() {
    adapter = _Adapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))..httpClientAdapter = adapter;
    repo = ApiMealsRepository(NiraahApi(dio: dio, store: MemorySessionStore()));
  });

  test('a scan lists matched dishes with food-table nutrients and leaves unsure ones for her (spec 009 AC36)', () async {
    adapter.replies.add((200, <String, dynamic>{
      'status': 'ok',
      'items': <Map<String, dynamic>>[
        <String, dynamic>{'state': 'matched', 'food': <String, dynamic>{'id': 'f1', 'name': 'Bhatura'}, 'portion': <String, dynamic>{'count': 1, 'unit': 'piece', 'grams': 80}, 'nutrients': n(272, 6), 'confidence': 0.9},
        <String, dynamic>{'state': 'not_sure', 'label': 'Not sure — what is this?', 'portion': <String, dynamic>{'count': 1, 'unit': 'slice'}},
      ],
      'totals': n(272, 6),
      'tags': <String>['high_protein'],
      'caloriesHidden': false,
      'madeByModel': true,
    }));
    final ScanResult r = await repo.scan('aGVsbG8gd29ybGQgcGhvdG8=');
    expect(adapter.requests.single.path, '/me/meals/scan');
    expect((adapter.requests.single.data as Map<String, dynamic>)['photo'], 'aGVsbG8gd29ybGQgcGhvdG8=');
    final ScanOk ok = r as ScanOk;
    expect((ok.items[0] as MatchedItem).food.name, 'Bhatura');
    expect((ok.items[0] as MatchedItem).nutrients.energyKcal, 272);
    expect(ok.items[1], isA<NotSureItem>());
    expect(ok.tags, <String>['high_protein']);
  });

  test('no food, the limit and an unavailable scanner each have their own result', () async {
    adapter.replies
      ..add((200, <String, dynamic>{'status': 'no_food', 'message': 'I could not see a meal in this photo.'}))
      ..add((200, <String, dynamic>{'status': 'limit', 'refusal': <String, dynamic>{'feature': 'meal_scan.scans', 'name': 'Meal scans', 'limit': 1, 'refillsAt': null, 'paidOption': true, 'reason': 'used_up'}}))
      ..add((200, <String, dynamic>{'status': 'unavailable'}));
    expect((await repo.scan('cGhvdG8gb25lIHR3byB0aHJlZQ==') as ScanNoFood).message, 'I could not see a meal in this photo.');
    expect((await repo.scan('cGhvdG8gb25lIHR3byB0aHJlZQ==') as ScanLimit).limit, 1);
    expect(await repo.scan('cGhvdG8gb25lIHR3byB0aHJlZQ=='), isA<ScanUnavailable>());
  });

  test('saving sends a scan-sourced meal with an offset time; calories may be hidden for her', () async {
    adapter.replies.add((200, <String, dynamic>{
      'id': 'm1', 'eatenAt': '2026-11-17T13:05:00.000Z', 'slot': 'lunch', 'source': 'scan', 'hasPhoto': false,
      'items': <Map<String, dynamic>>[<String, dynamic>{'id': 'i1', 'foodId': 'f1', 'name': 'Chole', 'grams': 150, 'portion': '1 katori', 'nutrients': n(null, 10.5)}],
      'totals': n(null, 10.5), 'tags': <String>[], 'suggestion': 'Add a salad next time for crunch.', 'review': <String, dynamic>{'state': 'private'},
    }));
    final Meal m = await repo.save(eatenAt: DateTime(2026, 11, 17, 18, 35), slot: MealSlot.lunch, fromScan: true, items: const <MealItemInput>[MealItemInput(foodId: 'f1', count: 1, unit: 'katori')]);
    final Map<String, dynamic> body = adapter.requests.single.data as Map<String, dynamic>;
    expect(body['source'], 'scan');
    expect(body['slot'], 'lunch');
    expect(body['eatenAt'] as String, matches(RegExp(r'^2026-11-17T18:35:00[+-]\d\d:\d\d$')));
    expect((body['items'] as List<dynamic>).single, <String, dynamic>{'foodId': 'f1', 'count': 1.0, 'unit': 'katori'});
    expect(m.totals.energyKcal, isNull);
    expect(m.suggestion, 'Add a salad next time for crunch.');
  });
}
