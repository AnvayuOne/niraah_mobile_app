import '../../provider_work/domain/provider_work.dart';

/// The rest of the doctor workspace (spec 011 §2, §3, §5, §7, §9, §12, §13, §15). Responses are open records
/// (packages/contracts/src/doctor.ts `Open`) whose content core decides and tests: consent, no health values in
/// lists, drafts never shown to members. Screens read them as [Json].

/// The profile sections in spec 011 §3's order.
const List<String> patientSections = <String>['assessment', 'cycle_symptoms', 'care_plan', 'prescriptions', 'labs', 'meals', 'shared_ai', 'notes', 'timeline'];

const List<String> carePlanKinds = <String>['nutrition', 'movement', 'sleep', 'supplements'];

class PatientFilters {
  const PatientFilters({this.search, this.kind, this.openAlert, this.planAwaiting, this.past = false});

  final String? search;

  /// `dedicated`, `consult` or `review`.
  final String? kind;
  final bool? openAlert;
  final bool? planAwaiting;
  final bool past;

  Map<String, String> get query => <String, String>{
    if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
    'kind': ?kind,
    if (openAlert != null) 'openAlert': '$openAlert',
    if (planAwaiting != null) 'planAwaiting': '$planAwaiting',
    if (past) 'past': 'true',
  };
}

abstract class DoctorWorkRepository {
  // Patients and the profile (§2, §3).
  Future<List<Json>> patients(PatientFilters filters);
  Future<Json> patient(String memberId);

  /// `{ shared: false }` and nothing else when she has not consented to the section's category (AC3).
  Future<Json> section(String memberId, String section);
  Future<Json> addNote(String memberId, String text);
  Future<Json> brief(String memberId);
  Future<Json> medicines(String memberId);

  // Care plans (§5).
  Future<List<Json>> carePlanQueue();
  Future<void> claimCarePlan(String id);
  Future<Json> carePlan(String id);

  /// `accepted`, `edited` or `cleared`; the AI suggestion is never changed (AC12).
  Future<Json> decide(String id, String kind, String decision, {String? text, String? reason});
  Future<Json> confirmDose(String id, String kind);
  Future<Json> setTasks(String id, List<Json> tasks);
  Future<Json> returnPlan(String id, String note);
  Future<Json> signPlan(String id);
  Future<Json> revisePlan(String id);

  // Alerts (§12).
  Future<List<Json>> alerts({String? status});
  Future<Json> openAlert(String id);
  Future<void> acknowledgeAlert(String id);
  Future<void> askToBook(String id);
  Future<void> resolveAlert(String id, String note);

  // Labs (§9).
  Future<List<Json>> labTests();
  Future<void> recommendTests(String memberId, List<String> testIds, {String? note});
  Future<List<Json>> labReportsToReview();
  Future<Json> labReport(String id);
  Future<Json> reviewLab(String id, {String? comment, bool confirmMedicines = false});

  // Wellness advice (§7). `prescriptions` stays the API's name; the screens say "Wellness advice".
  Future<List<Json>> prescriptionDrafts();
  Future<String> createPrescription(String appointmentId);
  Future<Json> prescription(String id);
  Future<Json> updatePrescription(String id, Json patch);
  Future<Json> confirmWording(String id, String field);
  Future<void> discardPrescription(String id);
  Future<Json> signPrescription(String id, String proofId);
  Future<List<Json>> supplements();

  // Profile and reviewer tasks (§13, §15).
  Future<Json> profile();
  Future<Json> updateProfile({String? bio, List<String>? languages, List<String>? specialities, bool? onCall});
  Future<Json> reviewerTasks();
}
