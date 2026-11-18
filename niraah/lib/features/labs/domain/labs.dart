/// Lab reports, results and home collection (spec 010 §9 "Lab tests"), matching packages/contracts/src/member.ts
/// `LabReport`, `LabCollection`, `LabOrder`. Results are never interpreted (AC34).
library;

class LabResult {
  const LabResult({required this.name, required this.value, required this.unit, required this.low, required this.high, required this.outsideRange, required this.label});

  final String name;
  final double value;
  final String unit;
  final double? low;
  final double? high;
  final bool outsideRange;

  /// The server's neutral words ("outside the lab's range"), or null.
  final String? label;
}

class LabReport {
  const LabReport({required this.id, required this.testDate, required this.hasFile, required this.clinicianComment, required this.results, required this.note});

  final String id;
  final String? testDate;
  final bool hasFile;
  final String? clinicianComment;
  final List<LabResult> results;

  /// "Your doctor can explain these results." and the like, from the server.
  final String note;
}

class ResultInput {
  const ResultInput({required this.name, required this.value, required this.unit, this.low, this.high});

  final String name;
  final double value;
  final String unit;
  final double? low;
  final double? high;
}

class LabTest {
  const LabTest({required this.id, required this.name, required this.fasting});

  final String id;
  final String name;
  final bool fasting;
}

class LabCollection {
  const LabCollection({required this.access, required this.tests, required this.partners});

  /// `included`, `after_trial`, `not_included` or `unavailable`.
  final String access;
  final List<LabTest> tests;
  final List<({String id, String name})> partners;
}

class LabOrder {
  const LabOrder({required this.id, required this.statusText, required this.partner, required this.slotStart});

  final String id;

  /// "Requested", "Confirmed", "Sample collected", "Report ready" (spec 010 §9 rule 4).
  final String statusText;
  final String? partner;
  final String? slotStart;
}

abstract class LabsRepository {
  Future<List<LabReport>> reports();

  /// Any plan can add a report (AC33).
  Future<LabReport> addReport({required String testDate, required List<ResultInput> results});

  Future<LabCollection> collection();

  Future<List<LabOrder>> orders();

  Future<LabOrder> order({required String partnerId, required List<String> testIds, required Map<String, String> address, required DateTime start, required DateTime end});
}
