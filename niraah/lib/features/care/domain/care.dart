/// Programs, the signed care plan, daily tasks and weekly check-ins (spec 010 §10, §11), matching
/// packages/contracts/src/member.ts `Programs`, `CarePlan`, `CareTasks`, `CheckIns`.
library;

class Program {
  const Program({required this.id, required this.name, required this.description, required this.weeks, required this.suggested});

  final String id;
  final String name;
  final String description;
  final int? weeks;

  /// Suggested by her pre-score (spec 007).
  final bool suggested;
}

class Enrolment {
  const Enrolment({required this.programId, required this.name, required this.status, required this.startedOn, required this.week, required this.weeks});

  final String programId;
  final String name;

  /// `active` or `paused`. Missed days never reset progress (spec 010 §10 rule 4).
  final String status;
  final String startedOn;
  final int week;
  final int? weeks;

  bool get paused => status == 'paused';
}

class ProgramsDocument {
  const ProgramsDocument({required this.programs, required this.enrolment});

  final List<Program> programs;
  final Enrolment? enrolment;
}

class CarePlanSection {
  const CarePlanSection({required this.kind, required this.text});

  final String kind;
  final String text;
}

class SignedPlan {
  const SignedPlan({required this.doctor, required this.signedOn, required this.sections});

  final String? doctor;
  final String signedOn;
  final List<CarePlanSection> sections;
}

class CarePlanDocument {
  const CarePlanDocument({required this.plan, required this.waiting, required this.history});

  /// Only ever a plan a doctor signed (AC35).
  final SignedPlan? plan;
  final String? waiting;
  final List<({String doctor, String signedOn})> history;
}

class CareTask {
  const CareTask({required this.id, required this.title, required this.done});

  final String id;
  final String title;
  final bool done;
}

class CareTasks {
  const CareTasks({required this.today, required this.week});

  final List<CareTask>? today;

  /// Her week as what she did: a count of ticked tasks per day, never what she missed (AC36).
  final List<({String date, int done})> week;
}

class CheckInDue {
  const CheckInDue({required this.weekStart, required this.fields});

  final String weekStart;

  /// The fields this check-in asks; weight and waist are absent when that content is suppressed for her.
  final List<String> fields;
}

class TrendPoint {
  const TrendPoint({required this.week, this.energy, this.cravings, this.weightKg, this.waistCm});

  final String week;
  final int? energy;
  final int? cravings;
  final double? weightKg;
  final double? waistCm;
}

class CheckInsDocument {
  const CheckInsDocument({required this.due, required this.trend});

  final CheckInDue? due;
  final List<TrendPoint> trend;
}

class CheckInAnswers {
  const CheckInAnswers({this.weightKg, this.waistCm, this.energy, this.cravings, this.note});

  final double? weightKg;
  final double? waistCm;
  final int? energy;
  final int? cravings;
  final String? note;
}

abstract class CareRepository {
  Future<ProgramsDocument> programs();

  Future<Enrolment?> enrol(String programId, {String? startOn});

  /// `active`, `paused` or `left`.
  Future<Enrolment?> setProgramStatus(String status);

  Future<CarePlanDocument> carePlan();

  Future<CareTasks> tasks();

  Future<void> tick(String taskId, bool done);

  Future<CheckInsDocument> checkIns();

  Future<List<TrendPoint>> submitCheckIn(CheckInAnswers answers);
}
