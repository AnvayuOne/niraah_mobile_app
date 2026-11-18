import '../../../core/network/niraah_api.dart';
import '../domain/provider_work.dart';

/// Provider work on `/api/v1`: `/provider/earnings`, `/provider/payouts`, `/provider/payout-details`,
/// `/provider/schedule`, `/provider/availability`, `/auth/fresh/staff`.
class ApiProviderWorkRepository implements ProviderWorkRepository {
  ApiProviderWorkRepository(this._api);

  final NiraahApi _api;

  @override
  Future<Json> earnings() async => (await _api.get('/provider/earnings')).orThrow();

  @override
  Future<List<Json>> payouts() async => (await _api.get('/provider/payouts')).orThrow().objs('items');

  @override
  Future<Json> payoutDetails() async => (await _api.get('/provider/payout-details')).orThrow();

  @override
  Future<Json> requestPayout() async => (await _api.post('/provider/payouts')).orThrow();

  @override
  Future<Json> schedule(DateTime from, DateTime to) async {
    final String q = Uri(queryParameters: <String, String>{'from': from.toUtc().toIso8601String(), 'to': to.toUtc().toIso8601String()}).query;
    return (await _api.get('/provider/schedule?$q')).orThrow();
  }

  @override
  Future<Json> availability() async => (await _api.get('/provider/availability')).orThrow();

  @override
  Future<void> addException(String kind, DateTime startsAt, DateTime endsAt) async =>
      (await _api.post('/provider/availability/exceptions', <String, dynamic>{'kind': kind, 'startsAt': startsAt.toUtc().toIso8601String(), 'endsAt': endsAt.toUtc().toIso8601String()})).orThrow();

  @override
  Future<void> removeException(String id) async => (await _api.delete('/provider/availability/exceptions/${Uri.encodeComponent(id)}')).orThrow();

  @override
  Future<String> freshStaff(String password, String code) async => (await _api.post('/auth/fresh/staff', <String, dynamic>{'password': password, 'code': code})).orThrow()['proofId'] as String;
}
