import '../../../core/network/niraah_api.dart';
import '../../cycle/data/cycle_parser.dart';
import '../../cycle/domain/cycle.dart';
import '../domain/symptoms.dart';
import 'symptoms_parser.dart';

/// The symptom tracker on `/api/v1` (spec 010 §4), matching apps/web/src/api/member-repositories.ts.
/// Failures other than a named refusal throw an ApiException with the server's message.
class ApiSymptomsRepository implements SymptomsRepository {
  ApiSymptomsRepository(this._api);

  final NiraahApi _api;

  @override
  Future<SymptomsDocument> getSymptoms() async => SymptomsParser.document((await _api.get('/me/symptoms')).orThrow());

  /// A red-flag rule returns its advice at once (AC17); severity outside 1 to 10 and unknown symptoms
  /// are refused (AC18).
  @override
  Future<SymptomLogResult> logSymptom({required IsoDate date, required String symptom, required int severity, String? note}) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/me/symptoms/logs', <String, dynamic>{
      'date': date,
      'symptom': symptom,
      'severity': severity,
      if (note != null && note.isNotEmpty) 'note': note,
    });
    if (r is ApiFail<Map<String, dynamic>>) {
      final SymptomLogError? refused = SymptomsParser.refusal(r.status, r.error.field);
      if (refused != null) return SymptomLogResult.refused(refused);
    }
    final Map<dynamic, dynamic>? advice = r.orThrow()['advice'] as Map?;
    return SymptomLogResult.ok(advice == null ? null : CycleParser.advice(advice));
  }
}
