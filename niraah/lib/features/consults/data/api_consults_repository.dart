import '../../../core/network/niraah_api.dart';
import '../../../core/payments/payment_checkout.dart';
import '../../../shared/area/area_access.dart';
import '../domain/consults.dart';

String _e(String v) => Uri.encodeComponent(v);

/// Consults on `/api/v1` (spec 014; plan 014 "Booking", "Rooms", "Changes"): `GET /specialists`, `GET /specialists/{id}`,
/// `GET /me/consult-slots`, `POST /me/appointments`, `GET /appointments`, `GET /appointments/{id}` and its member actions,
/// `GET /me/entitlements` for included consults, `POST /me/specialist-guide`.
class ApiConsultsRepository implements ConsultsRepository {
  ApiConsultsRepository(this._api);

  final NiraahApi _api;

  @override
  Future<List<Specialist>> specialists(DirectoryFilters f) async {
    final Map<String, String> q = <String, String>{
      if (f.type != null) 'type': f.type!,
      if (f.speciality != null && f.speciality!.isNotEmpty) 'speciality': f.speciality!,
      if (f.language != null && f.language!.isNotEmpty) 'language': f.language!,
      if (f.day != null) 'day': f.day!,
    };
    final String query = q.isEmpty ? '' : '?${Uri(queryParameters: q).query}';
    final Map<String, dynamic> r = (await _api.get('/specialists$query')).orArea();
    return <Specialist>[for (final dynamic c in r['clinicians'] as List<dynamic>) _specialist(c as Map<String, dynamic>)];
  }

  @override
  Future<Specialist> specialist(String id) async => _specialist((await _api.get('/specialists/${_e(id)}')).orArea());

  @override
  Future<SlotList> slots({String? providerId, ProviderType? type, required DateTime from, required DateTime to}) async {
    final String query = Uri(queryParameters: <String, String>{
      'providerId': ?providerId,
      if (providerId == null && type != null) 'type': type,
      'from': from.toUtc().toIso8601String(),
      'to': to.toUtc().toIso8601String(),
    }).query;
    final Map<String, dynamic> r = (await _api.get('/me/consult-slots?$query')).orArea();
    final Map<String, dynamic>? fallback = r['fallback'] as Map<String, dynamic>?;
    return SlotList(
      slots: <Slot>[
        for (final dynamic s in r['slots'] as List<dynamic>)
          Slot(
            startsAt: DateTime.parse((s as Map<String, dynamic>)['startsAt'] as String).toLocal(),
            endsAt: s['endsAt'] == null ? null : DateTime.parse(s['endsAt'] as String).toLocal(),
          ),
      ],
      feePaise: (r['feePaise'] as num?)?.toInt(),
      included: r['included'] == true,
      fallbackReason: fallback?['reason'] as String?,
      fallbackType: fallback?['type'] as String?,
    );
  }

  @override
  Future<Appointment> hold({String? providerId, ProviderType? type, required DateTime startsAt, bool includedOnly = false}) async =>
      _appointment((await _api.post('/me/appointments', <String, dynamic>{
        'providerId': ?providerId,
        if (providerId == null && type != null) 'type': type,
        'startsAt': startsAt.toUtc().toIso8601String(),
        if (includedOnly) 'payWith': 'included',
      }))
          .orArea());

  @override
  Future<ConfirmOutcome> confirm(String id, {required List<String> consents, String? reason, bool? recordConsent}) async {
    final String? why = reason?.trim();
    final Map<String, dynamic> r = (await _api.post('/appointments/${_e(id)}/confirm', <String, dynamic>{
      'consents': consents,
      if (why != null && why.isNotEmpty) 'reason': why,
      'recordConsent': ?recordConsent,
    }))
        .orArea();
    if (r['status'] == 'confirmed') return Confirmed(_appointment(r['appointment'] as Map<String, dynamic>));
    // `{kind: "order", gatewayRef, keyId, amountPaise}` (core `Booking.confirm`): the key and amount are the server's.
    return PaymentNeeded(((r['checkout'] as Map<String, dynamic>?)?['amountPaise'] as num?)?.toInt() ?? 0, Checkout.fromJson(r['checkout']));
  }

  @override
  Future<List<Appointment>> appointments() async =>
      <Appointment>[for (final dynamic a in (await _api.get('/appointments')).orArea()['appointments'] as List<dynamic>) _appointment(a as Map<String, dynamic>)];

  @override
  Future<Appointment> appointment(String id) async => _appointment((await _api.get('/appointments/${_e(id)}')).orArea());

  @override
  Future<String> cancel(String id) async => '${(await _api.post('/appointments/${_e(id)}/cancel')).orArea()['outcome']}';

  @override
  Future<Appointment> reschedule(String id, DateTime startsAt) async =>
      _appointment((await _api.post('/appointments/${_e(id)}/reschedule', <String, dynamic>{'startsAt': startsAt.toUtc().toIso8601String()})).orArea());

  @override
  Future<Appointment> acceptProposal(String id) async => _appointment((await _api.post('/appointments/${_e(id)}/accept-proposal')).orArea());

  @override
  Future<String?> declineOffer(String id) async => (await _api.post('/appointments/${_e(id)}/decline-offer')).orArea()['outcome'] as String?;

  @override
  Future<Appointment> rebook(String id, DateTime startsAt, {String? providerId}) async => _appointment((await _api.post('/appointments/${_e(id)}/rebook', <String, dynamic>{
        'startsAt': startsAt.toUtc().toIso8601String(),
        'providerId': ?providerId,
      }))
          .orArea());

  @override
  Future<FailureReport> reportFailure(String id) async {
    final Map<String, dynamic> r = (await _api.post('/appointments/${_e(id)}/report-failure')).orArea();
    return FailureReport(memberChoice: r['outcome'] == 'member_choice', options: ((r['options'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>());
  }

  @override
  Future<void> rate(String id, int rating, String? comment) async {
    final String? c = comment?.trim();
    (await _api.post('/appointments/${_e(id)}/rating', <String, dynamic>{'rating': rating, if (c != null && c.isNotEmpty) 'comment': c})).orArea();
  }

  @override
  Future<RoomAccess> roomToken(String id) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/appointments/${_e(id)}/room-token');
    switch (r) {
      case ApiOk<Map<String, dynamic>>(:final Map<String, dynamic> data):
        return RoomReady(
          appId: '${data['appId']}',
          channel: '${data['channel']}',
          uid: (data['uid'] as num).toInt(),
          token: '${data['token']}',
          expiresAt: DateTime.parse(data['expiresAt'] as String).toLocal(),
          closesAt: data['closesAt'] == null ? null : DateTime.parse(data['closesAt'] as String).toLocal(),
          recording: data['recording'] == true,
        );
      case ApiFail<Map<String, dynamic>>(:final ApiError error, :final int status):
        // Too early: the server says when it opens (core `Rooms.token`). Anyone but the two participants gets 404 (AC21).
        final Object? opensAt = error.details?['opensAt'];
        if (status == 409 && opensAt is String) return RoomNotOpen(opensAt: DateTime.tryParse(opensAt)?.toLocal(), message: error.message);
        if (status == 409) return RoomClosed(error.message);
        return RoomUnavailable(error.message);
    }
  }

  @override
  Future<void> stopRecording(String id) async => (await _api.post('/appointments/${_e(id)}/record/stop')).orArea();

  @override
  Future<ConsultTranscript> transcript(String id) async {
    final Map<String, dynamic> r = (await _api.get('/appointments/${_e(id)}/transcript')).orArea();
    return ConsultTranscript(
      status: '${r['status']}',
      partial: r['partial'] == true,
      missing: ((r['missing'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>(),
      lines: <TranscriptLine>[
        for (final dynamic x in (r['segments'] as List<dynamic>?) ?? const <dynamic>[])
          TranscriptLine(speaker: '${(x as Map<String, dynamic>)['speaker']}', startSeconds: (x['startSeconds'] as num?)?.toDouble(), text: '${x['text']}'),
      ],
    );
  }

  @override
  Future<List<IncludedConsults>> included() async {
    final Map<String, dynamic> r = (await _api.get('/me/entitlements')).orThrow();
    const Map<String, String> keys = <String, String>{'consults.doctor_included': 'doctor', 'consults.dietitian_included': 'dietitian'};
    return <IncludedConsults>[
      for (final dynamic f in r['features'] as List<dynamic>)
        if (keys.containsKey((f as Map<String, dynamic>)['key']) && f['included'] == true)
          IncludedConsults(
            type: keys[f['key']]!,
            remaining: (f['remaining'] as num?)?.toInt(),
            allowance: (f['allowance'] as num?)?.toInt(),
            refillsAt: f['refillsAt'] as String?,
          ),
    ];
  }

  @override
  Future<SpecialistGuide> guide(String concern) async {
    final Map<String, dynamic> r = (await _api.post('/me/specialist-guide', <String, dynamic>{'concern': concern.trim()})).orArea();
    return SpecialistGuide(
      suggestions: <({String kind, String reason})>[
        for (final dynamic x in r['specialists'] as List<dynamic>) (kind: '${(x as Map<String, dynamic>)['kind']}', reason: '${x['reason']}'),
      ],
      note: '${r['note'] ?? ''}',
      madeByModel: r['madeByModel'] == true,
    );
  }

  static Specialist _specialist(Map<String, dynamic> c) {
    final Map<String, dynamic>? rating = c['rating'] as Map<String, dynamic>?;
    final Map<String, dynamic>? reg = c['registration'] as Map<String, dynamic>?;
    return Specialist(
      id: c['id'] as String,
      type: '${c['type']}',
      name: c['name'] as String?,
      title: '${c['title'] ?? ''}',
      hasPhoto: c['hasPhoto'] == true,
      specialities: ((c['specialities'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>(),
      languages: ((c['languages'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>(),
      yearsExperience: (c['yearsExperience'] as num?)?.toInt(),
      bio: c['bio'] as String?,
      nextSlot: c['nextSlot'] == null ? null : DateTime.parse(c['nextSlot'] as String).toLocal(),
      feePaise: (c['feePaise'] as num?)?.toInt(),
      ratingAverage: (rating?['average'] as num?)?.toDouble(),
      ratingCount: (rating?['count'] as num?)?.toInt() ?? 0,
      registrationNumber: reg?['number'] as String?,
      registrationCouncil: reg?['council'] as String?,
      dedicated: c['dedicated'] == true,
      label: c['label'] as String?,
      available: c['available'] as bool? ?? true,
      horizonDays: (c['horizonDays'] as num?)?.toInt(),
    );
  }

  static Appointment _appointment(Map<String, dynamic> a) {
    DateTime t(String k) => DateTime.parse(a[k] as String).toLocal();
    final Map<String, dynamic> clinician = (a['clinician'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return Appointment(
      id: a['id'] as String,
      status: '${a['status']}',
      kind: '${a['kind']}',
      providerType: a['providerType'] as String?,
      startsAt: t('startsAt'),
      endsAt: t('endsAt'),
      feePaise: (a['feePaise'] as num?)?.toInt() ?? 0,
      holdExpiresAt: a['holdExpiresAt'] == null ? null : t('holdExpiresAt'),
      clinicianId: '${clinician['id'] ?? ''}',
      clinicianName: clinician['name'] as String?,
      pooled: a['pooled'] == true,
      reschedulesLeft: (a['reschedulesLeft'] as num?)?.toInt() ?? 0,
      roomOpensAt: a['roomOpensAt'] == null ? t('startsAt') : t('roomOpensAt'),
      recording: a['recording'] == true,
      recordMode: '${a['recordMode'] ?? 'off'}',
      askTranscriptConsent: a['recordConsentDraft'] == true,
      transcript: a['transcript'] as String?,
    );
  }
}
