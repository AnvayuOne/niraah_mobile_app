// Find a specialist and book a consult (spec 014 §2, §3, §6). The same shapes the website reads from /api/v1.

enum ProviderType { doctor, dietitian }

ProviderType? providerTypeOf(Object? v) => switch (v) {
  'doctor' => ProviderType.doctor,
  'dietitian' => ProviderType.dietitian,
  _ => null,
};

class Specialist {
  const Specialist({
    required this.id,
    required this.type,
    required this.name,
    required this.title,
    required this.specialities,
    required this.languages,
    this.yearsExperience,
    this.bio,
    this.nextSlot,
    this.feePaise,
    this.ratingAverage,
    this.ratingCount = 0,
    this.registration,
    this.label,
    this.available = true,
    this.horizonDays = 14,
  });

  final String id;
  final ProviderType type;
  final String? name;
  final String title;
  final List<String> specialities;
  final List<String> languages;
  final int? yearsExperience;
  final String? bio;

  /// Her next free time; null when none is in the booking horizon.
  final DateTime? nextSlot;

  /// GST-inclusive fee; null when she cannot be booked.
  final int? feePaise;
  final double? ratingAverage;
  final int ratingCount;

  /// "Reg. no. · Council" for a doctor; null for a dietitian.
  final String? registration;

  /// "Your doctor" / "Your dietitian" for her dedicated clinician.
  final String? label;
  final bool available;
  final int horizonDays;
}

class SlotList {
  const SlotList({required this.slots, this.feePaise, this.included = false, this.fallbackReason});

  final List<DateTime> slots;
  final int? feePaise;

  /// This time uses a consult included in her plan instead of the fee.
  final bool included;

  /// Her dedicated clinician has no time soon: why, in the server's words.
  final String? fallbackReason;
}

enum AppointmentStatus { held, confirmed, inProgress, completed, cancelled, noShow, expired }

AppointmentStatus appointmentStatusOf(Object? v) => switch (v) {
  'held' => AppointmentStatus.held,
  'confirmed' => AppointmentStatus.confirmed,
  'in_progress' => AppointmentStatus.inProgress,
  'completed' => AppointmentStatus.completed,
  'cancelled' => AppointmentStatus.cancelled,
  'no_show' => AppointmentStatus.noShow,
  _ => AppointmentStatus.expired,
};

class Appointment {
  const Appointment({
    required this.id,
    required this.status,
    required this.included,
    required this.startsAt,
    required this.endsAt,
    required this.feePaise,
    required this.clinicianId,
    required this.clinicianName,
    this.providerType,
    this.holdExpiresAt,
    this.recording = false,
    this.canCancel = false,
    this.roomOpensAt,
  });

  final String id;
  final AppointmentStatus status;
  final bool included;
  final DateTime startsAt;
  final DateTime endsAt;
  final int feePaise;
  final String clinicianId;
  final String? clinicianName;
  final ProviderType? providerType;
  final DateTime? holdExpiresAt;

  /// The consult is recorded (she is asked to agree when she confirms).
  final bool recording;
  final bool canCancel;

  /// When the video room opens (spec 014 §5 "Entering" 1), a few minutes before the start.
  final DateTime? roomOpensAt;

  /// Join shows while the room is open: confirmed or in progress, from [roomOpensAt] until the end. Mirrors the
  /// website's `canJoin` (apps/web/src/features/consults/format.ts).
  bool canJoin(DateTime now) =>
      (status == AppointmentStatus.confirmed || status == AppointmentStatus.inProgress) &&
      !now.isBefore(roomOpensAt ?? startsAt.subtract(const Duration(minutes: 10))) &&
      now.isBefore(endsAt);

  bool get upcoming => status == AppointmentStatus.held || status == AppointmentStatus.confirmed || status == AppointmentStatus.inProgress;
}

/// What she may share with the clinician for this consult, chosen per booking (spec 014 §3 "Steps" 2).
enum ShareCategory { healthData, assessment, cycleSymptoms, meals, labReports, messages }

const Map<ShareCategory, String> shareKeys = <ShareCategory, String>{
  ShareCategory.healthData: 'health_data',
  ShareCategory.assessment: 'assessment',
  ShareCategory.cycleSymptoms: 'cycle_symptoms',
  ShareCategory.meals: 'meals',
  ShareCategory.labReports: 'lab_reports',
  ShareCategory.messages: 'messages',
};

sealed class ConfirmOutcome {
  const ConfirmOutcome();
}

class Confirmed extends ConfirmOutcome {
  const Confirmed(this.appointment);
  final Appointment appointment;
}

/// The fee is due; the app hands payment to the website until in-app checkout ships.
class PaymentNeeded extends ConfirmOutcome {
  const PaymentNeeded(this.amountPaise);
  final int amountPaise;
}

abstract class ConsultsRepository {
  Future<List<Specialist>> specialists({ProviderType? type});
  Future<Specialist> specialist(String id);
  Future<SlotList> slots(String providerId, DateTime from, DateTime to);

  /// Holds a time; it is gone for everyone else at once.
  Future<Appointment> hold(String providerId, DateTime startsAt);
  Future<ConfirmOutcome> confirm(String id, {required Set<ShareCategory> share, String? reason, bool? recordConsent});
  Future<List<Appointment>> appointments();
  Future<Appointment> appointment(String id);
  Future<void> cancel(String id);
}

/// "₹499" from paise.
String rupees(int paise) {
  final int r = paise ~/ 100;
  final int p = paise % 100;
  final String whole = r.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+\d$)'), (Match m) => '${m[1]},');
  return p == 0 ? '₹$whole' : '₹$whole.${p.toString().padLeft(2, '0')}';
}

/// "PCOS", "Thyroid", "Weight management" from server keys such as "pcos" or "weight_management".
String niceWord(String key) {
  const Set<String> acronyms = <String>{'pcos', 'pcod', 'ivf', 'iui', 'tsh', 'bmi', 'amh', 'ai'};
  final String spaced = key.replaceAll('_', ' ').trim();
  if (spaced.isEmpty) return key;
  return spaced
      .split(' ')
      .asMap()
      .entries
      .map(
        (MapEntry<int, String> e) => acronyms.contains(e.value.toLowerCase())
            ? e.value.toUpperCase()
            : e.key == 0
            ? '${e.value[0].toUpperCase()}${e.value.substring(1)}'
            : e.value,
      )
      .join(' ');
}
