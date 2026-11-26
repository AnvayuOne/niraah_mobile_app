/// Wellness advice from her doctor (spec 011 §6 "Wellness advice", AC45; spec 010 §9.3): the signed record the
/// doctor's workspace calls a prescription. She never sees that word. Matches core `Prescriptions.memberView`.
library;

import 'package:equatable/equatable.dart';

class AdviceSupplement extends Equatable {
  const AdviceSupplement({required this.name, this.form, this.strength, this.dosePattern, this.timing, this.duration, this.instructions});

  final String name;
  final String? form;
  final String? strength;
  final String? dosePattern;
  final String? timing;
  final String? duration;
  final String? instructions;

  @override
  List<Object?> get props => <Object?>[name, form, strength, dosePattern, timing, duration, instructions];
}

class WellnessAdvice extends Equatable {
  const WellnessAdvice({
    required this.id,
    required this.title,
    required this.current,
    required this.stateLabel,
    required this.replacedBy,
    required this.doctorName,
    required this.doctorQualification,
    required this.registrationNumber,
    required this.council,
    required this.issuedAt,
    required this.assessment,
    required this.supplements,
    required this.advice,
    required this.seeDoctorLine,
    required this.followUpOn,
    required this.testsAdvised,
    required this.wellnessStatement,
    required this.verificationCode,
  });

  final String id;

  /// "Wellness advice from your doctor".
  final String title;

  /// False once a newer advice has replaced it.
  final bool current;
  final String stateLabel;
  final String? replacedBy;
  final String? doctorName;
  final String? doctorQualification;
  final String? registrationNumber;
  final String? council;
  final String? issuedAt;
  final String? assessment;
  final List<AdviceSupplement> supplements;
  final String? advice;
  final String? seeDoctorLine;
  final String? followUpOn;
  final List<String> testsAdvised;
  final String wellnessStatement;
  final String? verificationCode;

  @override
  List<Object?> get props => <Object?>[id, current, issuedAt, supplements, advice];
}

abstract class WellnessAdviceRepository {
  /// Signed and replaced advice, newest first; drafts are never shown to her.
  Future<List<WellnessAdvice>> list();

  Future<WellnessAdvice> get(String id);

  /// A short-lived link to the signed document (plan 011 "Storage").
  Future<String> documentUrl(String id);
}
