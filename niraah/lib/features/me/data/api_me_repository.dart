import '../../../core/network/niraah_api.dart';
import '../../../shared/area/area_access.dart';
import '../domain/me.dart';

/// The Me tab on `/api/v1` (spec 010 §13): workspace, profile, plan, privacy, exports, deletion, notification
/// settings, and the fresh sign-in check for sensitive actions (spec 003).
class ApiMeRepository implements MeRepository {
  ApiMeRepository(this._api);

  final NiraahApi _api;

  @override
  Future<Workspace> workspace() async {
    final Map<String, dynamic> r = (await _api.get('/me/workspace')).orThrow();
    return Workspace(
      displayName: r['displayName'] as String?,
      accountKind: '${r['accountKind']}',
      areas: <AreaState>[
        for (final dynamic a in r['areas'] as List<dynamic>)
          AreaState(
            key: (a as Map<String, dynamic>)['key'] as String,
            name: a['name'] as String,
            status: a['status'] as String,
            description: a['description'] as String?,
            plans: ((a['plans'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>(),
            startsOn: a['startsOn'] as String?,
            text: a['text'] as String?,
          ),
      ],
    );
  }

  @override
  Future<Profile> profile() async => _profile((await _api.get('/me/profile')).orThrow());

  @override
  Future<Profile> updateProfile({String? displayName, double? heightCm, List<String>? goals}) async => _profile((await _api.patch('/me/profile', <String, dynamic>{
        'displayName': ?displayName,
        'heightCm': ?heightCm,
        'goals': ?goals,
      }))
          .orThrow());

  @override
  Future<CurrentPlan?> currentPlan() async {
    final ApiResult<Map<String, dynamic>> res = await _api.get('/me/plan');
    if (res is ApiFail<Map<String, dynamic>> && res.status == 404) return null;
    final Map<String, dynamic> r = res.orThrow();
    final Map<String, dynamic>? price = r['price'] as Map<String, dynamic>?;
    return CurrentPlan(
      name: r['name'] as String,
      status: r['status'] as String,
      priceDisplay: price?['display'] as String?,
      renewsAt: r['renewsAt'] as String?,
      endsAt: r['endsAt'] as String?,
      cancelled: r['cancelled'] as bool,
      retired: r['retired'] as bool,
    );
  }

  @override
  Future<PrivacyDocument> privacy() async => _privacy((await _api.get('/me/privacy')).orThrow());

  @override
  Future<PrivacyDocument> withdrawConsent(String id) async => _privacy((await _api.delete('/me/consents/${Uri.encodeComponent(id)}')).orThrow());

  @override
  Future<void> setPersonalisedAi(bool on) async => (await _api.put('/me/profile/personalised-ai', <String, dynamic>{'on': on})).orThrow();

  @override
  Future<void> deleteChatHistory() async => (await _api.delete('/me/chat/history')).orThrow();

  @override
  Future<List<DataExport>> exports() async => _exports((await _api.get('/me/exports')).orArea());

  @override
  Future<List<DataExport>> requestExport() async => _exports((await _api.post('/me/exports')).orArea());

  @override
  Future<Map<String, dynamic>> downloadExport(String id, String proofId) async =>
      (await _api.post('/me/exports/${Uri.encodeComponent(id)}/download', <String, dynamic>{'proofId': proofId})).orThrow();

  @override
  Future<void> requestFreshCode() async => (await _api.post('/auth/fresh/code/request')).orThrow();

  @override
  Future<String> verifyFreshCode(String code) async => (await _api.post('/auth/fresh/code/verify', <String, dynamic>{'code': code})).orThrow()['proofId'] as String;

  @override
  Future<String> requestDeletion(String proofId) async => (await _api.post('/me/deletion', <String, dynamic>{'proofId': proofId})).orThrow()['deletesOn'] as String;

  @override
  Future<void> cancelDeletion() async => (await _api.delete('/me/deletion')).orThrow();

  @override
  Future<NotificationSettings> notificationSettings() async => _settings((await _api.get('/me/notification-settings')).orThrow());

  @override
  Future<NotificationSettings> setNotification(String category, String channel, bool enabled) async => _settings(
        (await _api.put('/me/notification-settings/categories/${Uri.encodeComponent(category)}', <String, dynamic>{'channel': channel, 'enabled': enabled})).orThrow(),
      );

  @override
  Future<void> signOut() async {
    await _api.post('/auth/sign-out');
    await _api.store.clear();
  }

  static Profile _profile(Map<String, dynamic> r) => Profile(
        displayName: r['displayName'] as String?,
        phone: r['phone'] as String?,
        language: r['language'] as String,
        timeZone: r['timeZone'] as String,
        dateOfBirth: r['dateOfBirth'] as String?,
        heightCm: (r['heightCm'] as num?)?.toDouble(),
        goals: (r['goals'] as List<dynamic>).cast<String>(),
        recoveryEmail: r['recoveryEmail'] as String?,
        personalisedAi: r['personalisedAi'] as bool,
        accountKind: '${r['accountKind']}',
      );

  static PrivacyDocument _privacy(Map<String, dynamic> r) => PrivacyDocument(
        consents: <Consent>[
          for (final dynamic c in r['consents'] as List<dynamic>)
            Consent(
              id: (c as Map<String, dynamic>)['id'] as String,
              who: c['who'] as String,
              role: c['role'] as String?,
              kind: c['kind'] as String,
              category: c['category'] as String,
              purpose: c['purpose'] as String,
              givenOn: c['givenOn'] as String,
            ),
        ],
        staffAccess: <StaffAccess>[
          for (final dynamic a in r['staffAccess'] as List<dynamic>) StaffAccess(on: (a as Map<String, dynamic>)['on'] as String, reason: a['reason'] as String),
        ],
        personalisedAi: r['personalisedAi'] as bool,
        accountKind: '${r['accountKind']}',
      );

  static List<DataExport> _exports(Map<String, dynamic> r) => <DataExport>[
        for (final dynamic e in r['items'] as List<dynamic>)
          DataExport(
            id: (e as Map<String, dynamic>)['id'] as String,
            status: e['status'] as String,
            requestedAt: e['requestedAt'] as String,
            expiresAt: e['expiresAt'] as String?,
          ),
      ];

  static NotificationSettings _settings(Map<String, dynamic> r) => NotificationSettings(
        discreetNote: (r['discreetNote'] as String?) ?? '',
        categories: <NotificationCategory>[
          for (final dynamic c in r['categories'] as List<dynamic>)
            NotificationCategory(
              key: (c as Map<String, dynamic>)['key'] as String,
              name: c['name'] as String,
              locked: c['locked'] as bool,
              lockedReason: c['lockedReason'] as String?,
              channels: <ChannelSwitch>[
                for (final dynamic ch in c['channels'] as List<dynamic>) ChannelSwitch(channel: (ch as Map<String, dynamic>)['channel'] as String, enabled: ch['enabled'] as bool),
              ],
            ),
        ],
      );
}
