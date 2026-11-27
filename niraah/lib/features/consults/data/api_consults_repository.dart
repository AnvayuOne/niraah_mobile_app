import '../../../core/network/niraah_api.dart';
import '../../../shared/area/area_access.dart';
import '../domain/consults.dart';

/// Find a specialist and booking on `/api/v1` (spec 014): the same endpoints the website calls.
/// `GET /specialists`, `GET /specialists/{id}`, `GET /me/consult-slots`, `POST /me/appointments`,
/// `POST /appointments/{id}/confirm`, `GET /appointments`, `GET /appointments/{id}`, `POST /appointments/{id}/cancel`.
class ApiConsultsRepository implements ConsultsRepository {
  ApiConsultsRepository(this._api);

  final NiraahApi _api;

  static String _q(Map<String, String?> m) {
    final Map<String, String> q = <String, String>{
      for (final MapEntry<String, String?> e in m.entries)
        if (e.value != null) e.key: e.value!,
    };
    return q.isEmpty ? '' : '?${Uri(queryParameters: q).query}';
  }

  @override
  Future<List<Specialist>> specialists({ProviderType? type}) async {
    final Map<String, dynamic> r = (await _api.get('/specialists${_q(<String, String?>{'type': type?.name})}')).orArea();
    return <Specialist>[for (final dynamic c in (r['clinicians'] as List<dynamic>? ?? const <dynamic>[])) _specialist(c as Map<String, dynamic>)];
  }

  @override
  Future<Specialist> specialist(String id) async => _specialist((await _api.get('/specialists/${Uri.encodeComponent(id)}')).orArea());

  @override
  Future<SlotList> slots(String providerId, DateTime from, DateTime to) async {
    final Map<String, dynamic> r = (await _api.get(
      '/me/consult-slots${_q(<String, String?>{'providerId': providerId, 'from': from.toUtc().toIso8601String(), 'to': to.toUtc().toIso8601String()})}',
    )).orArea();
    return SlotList(
      slots: <DateTime>[
        for (final dynamic s in (r['slots'] as List<dynamic>? ?? const <dynamic>[]))
          DateTime.parse((s as Map<String, dynamic>)['startsAt'] as String).toLocal(),
      ],
      feePaise: (r['feePaise'] as num?)?.toInt(),
      included: r['included'] == true,
      fallbackReason: (r['fallback'] as Map<String, dynamic>?)?['reason'] as String?,
    );
  }

  @override
  Future<Appointment> hold(String providerId, DateTime startsAt) async =>
      _appointment((await _api.post('/me/appointments', <String, dynamic>{'providerId': providerId, 'startsAt': startsAt.toUtc().toIso8601String()})).orArea());

  @override
  Future<ConfirmOutcome> confirm(String id, {required Set<ShareCategory> share, String? reason, bool? recordConsent}) async {
    final Map<String, dynamic> r = (await _api.post('/appointments/${Uri.encodeComponent(id)}/confirm', <String, dynamic>{
      'consents': <String>[
        for (final ShareCategory c in ShareCategory.values)
          if (share.contains(c)) shareKeys[c]!,
      ],
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      'recordConsent': ?recordConsent,
    })).orArea();
    if (r['status'] == 'confirmed') return Confirmed(_appointment(r['appointment'] as Map<String, dynamic>));
    return PaymentNeeded(((r['checkout'] as Map<String, dynamic>?)?['amountPaise'] as num?)?.toInt() ?? 0);
  }

  @override
  Future<List<Appointment>> appointments() async {
    final Map<String, dynamic> r = (await _api.get('/appointments')).orArea();
    return <Appointment>[for (final dynamic a in (r['appointments'] as List<dynamic>? ?? const <dynamic>[])) _appointment(a as Map<String, dynamic>)];
  }

  @override
  Future<Appointment> appointment(String id) async => _appointment((await _api.get('/appointments/${Uri.encodeComponent(id)}')).orArea());

  @override
  Future<void> cancel(String id) async {
    (await _api.post('/appointments/${Uri.encodeComponent(id)}/cancel', <String, dynamic>{})).orArea();
  }

  static Specialist _specialist(Map<String, dynamic> c) {
    final Map<String, dynamic>? reg = c['registration'] as Map<String, dynamic>?;
    final Map<String, dynamic>? rating = c['rating'] as Map<String, dynamic>?;
    final String? regText = reg == null
        ? null
        : <String?>[reg['number'] as String?, reg['council'] as String?].whereType<String>().where((String x) => x.isNotEmpty).join(' · ');
    return Specialist(
      id: c['id'] as String,
      type: providerTypeOf(c['type']) ?? ProviderType.doctor,
      name: c['name'] as String?,
      title: (c['title'] as String?) ?? '',
      specialities: ((c['specialities'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>(),
      languages: ((c['languages'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>(),
      yearsExperience: (c['yearsExperience'] as num?)?.toInt(),
      bio: c['bio'] as String?,
      nextSlot: c['nextSlot'] == null ? null : DateTime.tryParse(c['nextSlot'] as String)?.toLocal(),
      feePaise: (c['feePaise'] as num?)?.toInt(),
      ratingAverage: (rating?['average'] as num?)?.toDouble(),
      ratingCount: (rating?['count'] as num?)?.toInt() ?? 0,
      registration: (regText == null || regText.isEmpty) ? null : regText,
      label: c['label'] as String?,
      available: c['available'] != false,
      horizonDays: (c['horizonDays'] as num?)?.toInt() ?? 14,
    );
  }

  static Appointment _appointment(Map<String, dynamic> a) {
    final Map<String, dynamic>? clinician = a['clinician'] as Map<String, dynamic>?;
    final Map<String, dynamic>? cancellation = a['cancellation'] as Map<String, dynamic>?;
    return Appointment(
      id: a['id'] as String,
      status: appointmentStatusOf(a['status']),
      included: a['kind'] == 'included',
      startsAt: DateTime.parse(a['startsAt'] as String).toLocal(),
      endsAt: DateTime.parse(a['endsAt'] as String).toLocal(),
      feePaise: (a['feePaise'] as num?)?.toInt() ?? 0,
      clinicianId: (clinician?['id'] as String?) ?? '',
      clinicianName: clinician?['name'] as String?,
      providerType: providerTypeOf(a['providerType']),
      holdExpiresAt: a['holdExpiresAt'] == null ? null : DateTime.tryParse(a['holdExpiresAt'] as String)?.toLocal(),
      recording: a['recordMode'] == 'recording',
      canCancel: cancellation?['canCancel'] == true,
      roomOpensAt: a['roomOpensAt'] == null ? null : DateTime.tryParse(a['roomOpensAt'] as String)?.toLocal(),
    );
  }
}
