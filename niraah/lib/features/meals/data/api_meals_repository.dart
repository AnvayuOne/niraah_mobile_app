import '../../../core/network/niraah_api.dart';
import '../domain/meals.dart';

/// The meal scanner and log on `/api/v1` (spec 010 §6; spec 009 "Meal scan"): `POST /me/meals/scan`,
/// `GET /me/foods`, `POST /me/meals`, `GET /me/meals`.
class ApiMealsRepository implements MealsRepository {
  ApiMealsRepository(this._api);

  final NiraahApi _api;

  @override
  Future<ScanResult> scan(String photoBase64) async {
    final Map<String, dynamic> r = (await _api.post('/me/meals/scan', <String, dynamic>{'photo': photoBase64})).orThrow();
    switch (r['status']) {
      case 'ok':
        return ScanOk(
          items: <ScanItem>[for (final dynamic i in r['items'] as List<dynamic>) _item(i as Map<String, dynamic>)],
          totals: _nutrients(r['totals'] as Map<String, dynamic>),
          tags: (r['tags'] as List<dynamic>).cast<String>(),
          caloriesHidden: r['caloriesHidden'] as bool,
        );
      case 'no_food':
        return ScanNoFood(r['message'] as String);
      case 'limit':
        final Map<String, dynamic> refusal = r['refusal'] as Map<String, dynamic>;
        return ScanLimit(limit: (refusal['limit'] as num?)?.toInt() ?? 0, refillsAt: refusal['refillsAt'] as String?);
      default:
        return const ScanUnavailable();
    }
  }

  @override
  Future<List<FoodOption>> searchFoods(String query) async {
    final Map<String, dynamic> r = (await _api.get('/me/foods?q=${Uri.encodeQueryComponent(query)}')).orThrow();
    return <FoodOption>[
      for (final dynamic f in r['items'] as List<dynamic>)
        FoodOption(id: (f as Map<String, dynamic>)['id'] as String, name: f['name'] as String, regionalNames: ((f['regionalNames'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>()),
    ];
  }

  @override
  Future<Meal> save({required DateTime eatenAt, required MealSlot slot, required bool fromScan, required List<MealItemInput> items}) async {
    final Map<String, dynamic> r = (await _api.post('/me/meals', <String, dynamic>{
      'eatenAt': _isoWithOffset(eatenAt),
      'slot': slot.name,
      'source': fromScan ? 'scan' : 'manual',
      'items': <Map<String, dynamic>>[
        for (final MealItemInput i in items) <String, dynamic>{'foodId': i.foodId, 'count': i.count, 'unit': i.unit},
      ],
    })).orThrow();
    return _meal(r);
  }

  @override
  Future<MealDay> today() async {
    final Map<String, dynamic> r = (await _api.get('/me/meals')).orThrow();
    return MealDay(
      date: r['date'] as String,
      meals: <Meal>[for (final dynamic m in r['meals'] as List<dynamic>) _meal(m as Map<String, dynamic>)],
      totals: _nutrients(r['totals'] as Map<String, dynamic>),
      caloriesHidden: r['caloriesHidden'] as bool,
      privacyNote: r['privacyNote'] as String?,
    );
  }

  static ScanItem _item(Map<String, dynamic> i) {
    final Map<String, dynamic> p = i['portion'] as Map<String, dynamic>;
    final double count = (p['count'] as num).toDouble();
    final String unit = p['unit'] as String;
    if (i['state'] == 'matched') {
      final Map<String, dynamic> f = i['food'] as Map<String, dynamic>;
      return MatchedItem(
        food: FoodRef(id: f['id'] as String, name: f['name'] as String),
        count: count,
        unit: unit,
        nutrients: _nutrients(i['nutrients'] as Map<String, dynamic>),
        confidence: (i['confidence'] as num).toDouble(),
      );
    }
    return NotSureItem(label: i['label'] as String, count: count, unit: unit);
  }

  static Meal _meal(Map<String, dynamic> m) => Meal(
    id: m['id'] as String,
    eatenAt: DateTime.parse(m['eatenAt'] as String).toLocal(),
    slot: MealSlot.values.firstWhere((MealSlot s) => s.name == m['slot'], orElse: () => MealSlot.snack),
    source: m['source'] as String,
    items: <LoggedItem>[
      for (final dynamic i in m['items'] as List<dynamic>)
        LoggedItem(
          name: (i as Map<String, dynamic>)['name'] as String,
          grams: (i['grams'] as num).toDouble(),
          portion: i['portion'] as String?,
          nutrients: _nutrients(i['nutrients'] as Map<String, dynamic>),
        ),
    ],
    totals: _nutrients(m['totals'] as Map<String, dynamic>),
    tags: (m['tags'] as List<dynamic>).cast<String>(),
    suggestion: m['suggestion'] as String?,
  );

  static Nutrients _nutrients(Map<String, dynamic> n) => Nutrients(
    energyKcal: (n['energyKcal'] as num?)?.toDouble(),
    proteinG: (n['proteinG'] as num).toDouble(),
    carbohydrateG: (n['carbohydrateG'] as num).toDouble(),
    fatG: (n['fatG'] as num).toDouble(),
    fibreG: (n['fibreG'] as num).toDouble(),
    glycaemicIndex: (n['glycaemicIndex'] as num?)?.toInt(),
  );

  /// The server wants an ISO time with an offset (contracts `z.iso.datetime({ offset: true })`).
  static String _isoWithOffset(DateTime t) {
    final Duration o = t.timeZoneOffset;
    final String sign = o.isNegative ? '-' : '+';
    final String hh = o.inHours.abs().toString().padLeft(2, '0');
    final String mm = (o.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final DateTime l = t.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)}T${two(l.hour)}:${two(l.minute)}:${two(l.second)}$sign$hh:$mm';
  }
}
