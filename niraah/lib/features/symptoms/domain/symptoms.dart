import 'package:equatable/equatable.dart';

import '../../cycle/domain/cycle.dart';

/// The symptom tracker as the server returns it (spec 010 §4), matching
/// apps/web/src/features/symptoms/types.ts.

class SymptomRef extends Equatable {
  const SymptomRef({required this.key, required this.name});

  final String key;
  final String name;

  @override
  List<Object?> get props => <Object?>[key, name];
}

class SymptomCategory extends Equatable {
  const SymptomCategory({required this.key, required this.name, required this.symptoms});

  final String key;
  final String name;
  final List<SymptomRef> symptoms;

  @override
  List<Object?> get props => <Object?>[key, name, symptoms];
}

class SymptomHistoryEntry extends Equatable {
  const SymptomHistoryEntry({
    required this.id,
    required this.date,
    required this.symptom,
    required this.severity,
    this.note,
    this.phase,
  });

  final String id;
  final IsoDate date;
  final SymptomRef symptom;
  final int severity;
  final String? note;

  /// The estimated phase on that day, when one can be stated.
  final Phase? phase;

  @override
  List<Object?> get props => <Object?>[id, date, symptom, severity, note, phase];
}

class SymptomsDocument extends Equatable {
  const SymptomsDocument({
    required this.today,
    required this.categories,
    required this.frequent,
    required this.severityLow,
    required this.severityHigh,
    required this.history,
  });

  final IsoDate today;
  final List<SymptomCategory> categories;

  /// Symptoms she logs often, offered first (spec 010 §4.2).
  final List<SymptomRef> frequent;

  /// The words at the two ends of the scale; nothing in between is named.
  final String severityLow;
  final String severityHigh;

  /// Recent entries, newest first.
  final List<SymptomHistoryEntry> history;

  @override
  List<Object?> get props => <Object?>[today, categories, frequent, severityLow, severityHigh, history];
}

enum SymptomLogError { severity, unknownSymptom }

class SymptomLogResult {
  const SymptomLogResult.ok(this.advice) : error = null;
  const SymptomLogResult.refused(SymptomLogError this.error) : advice = null;

  final SymptomLogError? error;

  /// Shown at once when a red-flag rule applies (spec 010 §4.4, AC17).
  final AdviceCard? advice;

  bool get ok => error == null;
}

abstract interface class SymptomsRepository {
  Future<SymptomsDocument> getSymptoms();

  /// Severity outside 1 to 10 is refused (AC18).
  Future<SymptomLogResult> logSymptom({required IsoDate date, required String symptom, required int severity, String? note});
}
