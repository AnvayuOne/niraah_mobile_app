import '../../cycle/domain/cycle.dart';
import '../../home/data/unavailable_home_repository.dart';
import '../domain/symptoms.dart';

/// Used by `main.dart` until spec 010's symptom endpoints exist. Fails plainly.
class UnavailableSymptomsRepository implements SymptomsRepository {
  const UnavailableSymptomsRepository();

  @override
  Future<SymptomsDocument> getSymptoms() async => throw const HomeNotConnected();

  @override
  Future<SymptomLogResult> logSymptom({required IsoDate date, required String symptom, required int severity, String? note}) async =>
      throw const HomeNotConnected();
}
