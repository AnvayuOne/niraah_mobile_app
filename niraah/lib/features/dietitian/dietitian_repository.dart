import '../../core/network/niraah_api.dart';
import '../provider_work/domain/provider_work.dart';

/// The dietitian workspace (spec 012) on `/api/v1/dietitian/*`. Responses are open records whose content the server
/// decides (consent, computed nutrients, suppression), so the screens read them as [Json].
abstract class DietitianRepository {
  Future<Json> dashboard();

  Future<List<Json>> clients({String? search, String? kind, String? mealPlan, bool? openAlert, bool past = false});
  Future<Json> client(String memberId);
  Future<Json> section(String memberId, String section);
  Future<Json> addNote(String memberId, String text);
  Future<Json> brief(String memberId);

  Future<List<Json>> plans();
  Future<Json> toBuild();
  Future<Json> createPlan(String memberId, {String? title, int weeks = 1, String? templateId});
  Future<Json> plan(String id);
  Future<Json> updatePlan(String id, Json patch);
  Future<void> discardPlan(String id);
  Future<Json> addItem(String planId, Json item);
  Future<Json> updateItem(String planId, String itemId, Json patch);
  Future<Json> removeItem(String planId, String itemId);
  Future<Json> confirmItem(String planId, String itemId);
  Future<Json> copyDay(String planId, int from, List<int> to);
  Future<Json> publish(String planId, String startDate, {bool confirmCarePlanRead = false});
  Future<Json> adjust(String planId);
  Future<Json> endPlan(String planId);
  Future<Json> saveTemplate(String planId, String title);
  Future<List<Json>> templates();

  Future<List<Json>> foodLogQueue();
  Future<Json> foodLogDay(String memberId, String day);
  Future<Json> claimDay(String memberId, String day);
  Future<void> releaseDay(String memberId, String day);
  Future<Json> approveDay(String memberId, String day);
  Future<Json> review(String logId, {required bool approve, String? comment});
  Future<Json> correct(String itemId, {String? foodId, double? count, String? unit});

  Future<List<Json>> searchFoods(String q);
  Future<List<Json>> recipes({String? search, bool mine = false});
  Future<Json> recipe(String id);
  Future<Json> saveRecipe(String? id, Json input);
  Future<Json> publishRecipe(String id);
  Future<void> discardRecipe(String id);
  Future<Json> requestFood(String name, {String? note});

  Future<Json> progress(String memberId);
  Future<Json> respond(String checkInId, String? note);
  Future<void> nudge(String memberId, String week);
  Future<Json> setTargets(String memberId, Json targets);
  Future<List<Json>> checkInQuestionnaires();
  Future<void> assign(String memberId, String questionnaireId, String schedule, String? endsOn);
  Future<List<Json>> unreadCheckIns();

  Future<List<Json>> alerts({String? status});
  Future<void> acknowledge(String id);
  Future<void> resolve(String id, String note);
  Future<Json> refer(String id, String note);

  Future<Json> profile();
  Future<Json> updateProfile({String? bio, List<String>? languages, List<String>? specialities});
}

class ApiDietitianRepository implements DietitianRepository {
  ApiDietitianRepository(this._api);

  final NiraahApi _api;

  static String _e(String id) => Uri.encodeComponent(id);
  static String _q(Map<String, String> q) => q.isEmpty ? '' : '?${Uri(queryParameters: q).query}';

  Future<Json> _get(String p) async => (await _api.get(p)).orThrow();
  Future<Json> _post(String p, [Json? b]) async => (await _api.post(p, b)).orThrow();
  Future<Json> _patch(String p, Json b) async => (await _api.patch(p, b)).orThrow();
  Future<Json> _put(String p, Json b) async => (await _api.put(p, b)).orThrow();
  Future<Json> _delete(String p) async => (await _api.delete(p)).orThrow();
  Future<List<Json>> _items(String p) async => (await _get(p)).objs('items');

  @override
  Future<Json> dashboard() => _get('/dietitian/dashboard');

  @override
  Future<List<Json>> clients({String? search, String? kind, String? mealPlan, bool? openAlert, bool past = false}) => _items(
    '/dietitian/clients${_q(<String, String>{if (search != null && search.trim().isNotEmpty) 'search': search.trim(), 'kind': ?kind, 'mealPlan': ?mealPlan, if (openAlert != null) 'openAlert': '$openAlert', if (past) 'past': 'true'})}',
  );

  @override
  Future<Json> client(String memberId) => _get('/dietitian/clients/${_e(memberId)}');

  @override
  Future<Json> section(String memberId, String section) => _get('/dietitian/clients/${_e(memberId)}/sections/${_e(section)}');

  @override
  Future<Json> addNote(String memberId, String text) => _post('/dietitian/clients/${_e(memberId)}/notes', <String, dynamic>{'text': text});

  @override
  Future<Json> brief(String memberId) => _get('/dietitian/clients/${_e(memberId)}/brief');

  @override
  Future<List<Json>> plans() => _items('/dietitian/meal-plans');

  @override
  Future<Json> toBuild() => _get('/dietitian/meal-plans/to-build');

  @override
  Future<Json> createPlan(String memberId, {String? title, int weeks = 1, String? templateId}) =>
      _post('/dietitian/meal-plans', <String, dynamic>{'memberId': memberId, 'title': ?title, 'weeks': weeks, 'templateId': ?templateId});

  @override
  Future<Json> plan(String id) => _get('/dietitian/meal-plans/${_e(id)}');

  @override
  Future<Json> updatePlan(String id, Json patch) => _patch('/dietitian/meal-plans/${_e(id)}', patch);

  @override
  Future<void> discardPlan(String id) => _delete('/dietitian/meal-plans/${_e(id)}');

  @override
  Future<Json> addItem(String planId, Json item) => _post('/dietitian/meal-plans/${_e(planId)}/items', item);

  @override
  Future<Json> updateItem(String planId, String itemId, Json patch) => _patch('/dietitian/meal-plans/${_e(planId)}/items/${_e(itemId)}', patch);

  @override
  Future<Json> removeItem(String planId, String itemId) => _delete('/dietitian/meal-plans/${_e(planId)}/items/${_e(itemId)}');

  @override
  Future<Json> confirmItem(String planId, String itemId) => _post('/dietitian/meal-plans/${_e(planId)}/items/${_e(itemId)}/confirm');

  @override
  Future<Json> copyDay(String planId, int from, List<int> to) => _post('/dietitian/meal-plans/${_e(planId)}/copy-day', <String, dynamic>{'from': from, 'to': to});

  @override
  Future<Json> publish(String planId, String startDate, {bool confirmCarePlanRead = false}) =>
      _post('/dietitian/meal-plans/${_e(planId)}/publish', <String, dynamic>{'startDate': startDate, if (confirmCarePlanRead) 'confirmCarePlanRead': true});

  @override
  Future<Json> adjust(String planId) => _post('/dietitian/meal-plans/${_e(planId)}/adjust');

  @override
  Future<Json> endPlan(String planId) => _post('/dietitian/meal-plans/${_e(planId)}/end');

  @override
  Future<Json> saveTemplate(String planId, String title) => _post('/dietitian/meal-plans/${_e(planId)}/template', <String, dynamic>{'title': title});

  @override
  Future<List<Json>> templates() => _items('/dietitian/templates');

  @override
  Future<List<Json>> foodLogQueue() => _items('/dietitian/food-logs');

  @override
  Future<Json> foodLogDay(String memberId, String day) => _get('/dietitian/food-logs/day${_q(<String, String>{'memberId': memberId, 'day': day})}');

  @override
  Future<Json> claimDay(String memberId, String day) => _post('/dietitian/food-logs/claim', <String, dynamic>{'memberId': memberId, 'day': day});

  @override
  Future<void> releaseDay(String memberId, String day) => _post('/dietitian/food-logs/release', <String, dynamic>{'memberId': memberId, 'day': day});

  @override
  Future<Json> approveDay(String memberId, String day) => _post('/dietitian/food-logs/approve-day', <String, dynamic>{'memberId': memberId, 'day': day});

  @override
  Future<Json> review(String logId, {required bool approve, String? comment}) =>
      _post('/dietitian/food-logs/${_e(logId)}/review', <String, dynamic>{'decision': approve ? 'approved' : 'comment', 'comment': ?comment});

  @override
  Future<Json> correct(String itemId, {String? foodId, double? count, String? unit}) =>
      _post('/dietitian/food-log-items/${_e(itemId)}/correct', <String, dynamic>{'foodId': ?foodId, 'count': ?count, 'unit': ?unit});

  @override
  Future<List<Json>> searchFoods(String q) => _items('/dietitian/foods${_q(<String, String>{'q': q})}');

  @override
  Future<List<Json>> recipes({String? search, bool mine = false}) =>
      _items('/dietitian/recipes${_q(<String, String>{if (search != null && search.trim().isNotEmpty) 'search': search.trim(), if (mine) 'mine': 'true'})}');

  @override
  Future<Json> recipe(String id) => _get('/dietitian/recipes/${_e(id)}');

  @override
  Future<Json> saveRecipe(String? id, Json input) => id == null ? _post('/dietitian/recipes', input) : _put('/dietitian/recipes/${_e(id)}', input);

  @override
  Future<Json> publishRecipe(String id) => _post('/dietitian/recipes/${_e(id)}/publish');

  @override
  Future<void> discardRecipe(String id) => _delete('/dietitian/recipes/${_e(id)}');

  @override
  Future<Json> requestFood(String name, {String? note}) => _post('/dietitian/food-requests', <String, dynamic>{'name': name, 'note': ?note});

  @override
  Future<Json> progress(String memberId) => _get('/dietitian/clients/${_e(memberId)}/progress');

  @override
  Future<Json> respond(String checkInId, String? note) => _post('/dietitian/check-ins/${_e(checkInId)}/respond', <String, dynamic>{'note': note});

  @override
  Future<void> nudge(String memberId, String week) => _post('/dietitian/clients/${_e(memberId)}/nudge', <String, dynamic>{'week': week});

  @override
  Future<Json> setTargets(String memberId, Json targets) => _put('/dietitian/clients/${_e(memberId)}/targets', <String, dynamic>{'targets': targets});

  @override
  Future<List<Json>> checkInQuestionnaires() => _items('/dietitian/check-in-questionnaires');

  @override
  Future<void> assign(String memberId, String questionnaireId, String schedule, String? endsOn) =>
      _post('/dietitian/clients/${_e(memberId)}/questionnaires', <String, dynamic>{'questionnaireId': questionnaireId, 'schedule': schedule, 'endsOn': endsOn});

  @override
  Future<List<Json>> unreadCheckIns() => _items('/dietitian/check-ins/unread');

  @override
  Future<List<Json>> alerts({String? status}) => _items('/dietitian/alerts${status == null ? '' : _q(<String, String>{'status': status})}');

  @override
  Future<void> acknowledge(String id) => _post('/dietitian/alerts/${_e(id)}/acknowledge');

  @override
  Future<void> resolve(String id, String note) => _post('/dietitian/alerts/${_e(id)}/resolve', <String, dynamic>{'note': note});

  @override
  Future<Json> refer(String id, String note) => _post('/dietitian/alerts/${_e(id)}/refer', <String, dynamic>{'note': note});

  @override
  Future<Json> profile() => _get('/dietitian/profile');

  @override
  Future<Json> updateProfile({String? bio, List<String>? languages, List<String>? specialities}) =>
      _patch('/dietitian/profile', <String, dynamic>{'bio': ?bio, 'languages': ?languages, 'specialities': ?specialities});
}
