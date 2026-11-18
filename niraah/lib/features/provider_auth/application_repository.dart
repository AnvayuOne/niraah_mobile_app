import 'dart:convert';

import '../../core/network/niraah_api.dart';
import '../../shared/constants/api_constants.dart';
import '../provider_work/domain/provider_work.dart';

/// Her own application (spec 006 "Completing the application"; AC9, AC45, AC46) on `/api/v1/provider/application`.
/// The screens read the response as [Json], exactly as the contract `MyApplication` describes it.
abstract class ProviderApplicationRepository {
  Future<Json> get();
  Future<Json> save(Json edit);
  Future<void> upload({required String kind, required String fileName, required String contentType, required List<int> bytes});
  Future<Json> removeDocument(String fileId);
  Future<Json> submit({required bool acceptTerms});
  Future<Json> reapply();
}

class ApiProviderApplicationRepository implements ProviderApplicationRepository {
  ApiProviderApplicationRepository(this._api);

  final NiraahApi _api;

  @override
  Future<Json> get() async => (await _api.get('/provider/application')).orThrow();

  @override
  Future<Json> save(Json edit) async => (await _api.put('/provider/application', edit)).orThrow();

  @override
  Future<void> upload({required String kind, required String fileName, required String contentType, required List<int> bytes}) async {
    (await _api.post('/provider/application/documents', <String, dynamic>{'kind': kind, 'fileName': fileName, 'contentType': contentType, 'dataBase64': base64Encode(bytes)})).orThrow();
  }

  @override
  Future<Json> removeDocument(String fileId) async => (await _api.delete('/provider/application/documents/${Uri.encodeComponent(fileId)}')).orThrow();

  @override
  Future<Json> submit({required bool acceptTerms}) async => (await _api.post('/provider/application/submit', <String, dynamic>{'acceptTerms': acceptTerms})).orThrow();

  @override
  Future<Json> reapply() async => (await _api.post('/provider/application/reapply')).orThrow();
}

/// The web page where a provider applies (spec 006 "Applying by herself"). The app opens it in the browser: the
/// human check (Cloudflare Turnstile) runs there until the app can show it itself (spec 003 open item).
Uri applyPageUrl() {
  final Uri api = Uri.parse(ApiConstants.baseUrl);
  final String root = api.path.endsWith('/api/v1') ? api.path.substring(0, api.path.length - '/api/v1'.length) : '';
  return api.replace(path: '$root/apply');
}
