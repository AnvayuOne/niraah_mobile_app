import '../domain/consults.dart';

/// SAMPLE data for the booking screens (sample build and widget tests). Never used with a real server.
class SampleConsultsRepository implements ConsultsRepository {
  SampleConsultsRepository();

  final List<Appointment> _booked = <Appointment>[];

  static final DateTime _today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  static final List<Specialist> _all = <Specialist>[
    Specialist(
      id: 'dr-ananya',
      type: ProviderType.doctor,
      name: 'Dr. Ananya Rao',
      title: 'Gynaecologist',
      specialities: const <String>['pcos', 'fertility', 'thyroid'],
      languages: const <String>['English', 'Hindi', 'Telugu'],
      yearsExperience: 11,
      bio: 'Gynaecologist focused on PCOS and metabolic health. Calm, unhurried consults with a clear plan at the end.',
      nextSlot: _today.add(const Duration(days: 1, hours: 10)),
      feePaise: 49900,
      ratingAverage: 4.8,
      ratingCount: 126,
      registration: 'DEMO-12345 · Demo Medical Council',
      label: 'Your doctor',
    ),
    Specialist(
      id: 'dt-sunita',
      type: ProviderType.dietitian,
      name: 'Sunita Iyer',
      title: 'Clinical dietitian',
      specialities: const <String>['pcos', 'weight_management'],
      languages: const <String>['English', 'Tamil'],
      yearsExperience: 8,
      bio: 'Indian-food-first plans that fit your kitchen, your phase and your week.',
      nextSlot: _today.add(const Duration(days: 2, hours: 17)),
      feePaise: 39900,
      ratingAverage: 4.7,
      ratingCount: 58,
    ),
  ];

  @override
  Future<List<Specialist>> specialists({ProviderType? type}) async => _all.where((Specialist s) => type == null || s.type == type).toList();

  @override
  Future<Specialist> specialist(String id) async => _all.firstWhere((Specialist s) => s.id == id);

  @override
  Future<SlotList> slots(String providerId, DateTime from, DateTime to) async {
    final List<DateTime> out = <DateTime>[];
    for (int d = 0; d < 14; d++) {
      final DateTime day = _today.add(Duration(days: d));
      if (d % 4 == 3) continue; // a day off now and then
      for (final int m in <int>[9 * 60, 9 * 60 + 30, 11 * 60, 14 * 60 + 30, 16 * 60, 18 * 60 + 30, 19 * 60]) {
        final DateTime t = day.add(Duration(minutes: m));
        if (t.isAfter(DateTime.now().add(const Duration(hours: 1))) && (d + m) % 3 != 0) out.add(t);
      }
    }
    return SlotList(slots: out, feePaise: _all.firstWhere((Specialist s) => s.id == providerId).feePaise, included: providerId == 'dr-ananya');
  }

  @override
  Future<Appointment> hold(String providerId, DateTime startsAt) async {
    final Specialist s = _all.firstWhere((Specialist x) => x.id == providerId);
    final Appointment a = Appointment(
      id: 'appt-${_booked.length + 1}',
      status: AppointmentStatus.held,
      included: providerId == 'dr-ananya',
      startsAt: startsAt,
      endsAt: startsAt.add(const Duration(minutes: 20)),
      feePaise: s.feePaise ?? 0,
      clinicianId: s.id,
      clinicianName: s.name,
      providerType: s.type,
      holdExpiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );
    _booked.add(a);
    return a;
  }

  @override
  Future<ConfirmOutcome> confirm(String id, {required Set<ShareCategory> share, String? reason, bool? recordConsent}) async {
    final int i = _booked.indexWhere((Appointment a) => a.id == id);
    final Appointment a = _booked[i];
    if (!a.included) return PaymentNeeded(a.feePaise);
    final Appointment done = Appointment(
      id: a.id,
      status: AppointmentStatus.confirmed,
      included: a.included,
      startsAt: a.startsAt,
      endsAt: a.endsAt,
      feePaise: a.feePaise,
      clinicianId: a.clinicianId,
      clinicianName: a.clinicianName,
      providerType: a.providerType,
      canCancel: true,
    );
    _booked[i] = done;
    return Confirmed(done);
  }

  @override
  Future<List<Appointment>> appointments() async => List<Appointment>.of(_booked);

  @override
  Future<Appointment> appointment(String id) async => _booked.firstWhere((Appointment a) => a.id == id);

  @override
  Future<void> cancel(String id) async => _booked.removeWhere((Appointment a) => a.id == id);
}
