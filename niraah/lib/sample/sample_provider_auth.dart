// SAMPLE ONLY (constitution §2 rule 6). Mirrors
// apps/web/src/sample/provider-auth-repository.ts. A fixed sample password and
// "any 6 digits" for the authenticator are test shortcuts that constitution
// §5.5 forbids in production code; they live only in lib/sample, which
// lib/main.dart never imports (test/sample_isolation_test.dart).

import 'dart:convert';
import 'dart:math';

import '../features/provider_auth/domain/provider_auth.dart';
import 'sample_content.dart';

final Map<String, dynamic> sampleProviders = jsonDecode(sampleProvidersJson) as Map<String, dynamic>;

/// Wrong passwords in 15 minutes before password sign-in locks (spec 003).
const int lockAfter = 10;
const Duration lockWindow = Duration(minutes: 15);

class SampleProviderAuthRepository implements ProviderAuthRepository {
  SampleProviderAuthRepository({DateTime Function()? clock, Random? random})
      : _clock = clock ?? DateTime.now,
        _random = random ?? Random();

  final DateTime Function() _clock;
  final Random _random;

  ProviderSession? _session;
  String? _pendingEmail;
  final Map<String, (int, DateTime)> _fails = <String, (int, DateTime)>{};

  List<Map<String, dynamic>> get _accounts => (sampleProviders['accounts'] as List<dynamic>).cast<Map<String, dynamic>>();

  static bool _sixDigits(String c) => RegExp(r'^\d{6}$').hasMatch(c);

  static ProviderRole _role(String r) => ProviderRole.values.byName(r);

  static ProviderSession _toSession(Map<String, dynamic> a) => ProviderSession(
        role: _role(a['role'] as String),
        status: a['status'] == 'active' ? ProviderStatus.active : ProviderStatus.underReview,
        name: a['name'] as String,
        speciality: a['speciality'] as String,
        missing: ((a['missing'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>(),
      );

  @override
  bool get sampleMode => true;

  @override
  Future<StepResult> checkPassword(String email, String password) async {
    final String key = email.trim().toLowerCase();
    final DateTime now = _clock();
    final (int, DateTime)? f = _fails[key];
    final bool inWindow = f != null && now.difference(f.$2) < lockWindow;
    if (f != null && f.$1 >= lockAfter && inWindow) return const StepResult.failed(StepFailure.locked);
    final Map<String, dynamic>? account = _accounts.where((Map<String, dynamic> a) => a['email'] == key).firstOrNull;
    if (account != null && password == sampleProviders['samplePassword']) {
      _pendingEmail = key;
      _fails.remove(key);
      return const StepResult.ok();
    }
    _fails[key] = inWindow ? (f.$1 + 1, f.$2) : (1, now);
    // Same answer for an unknown email, a wrong password or a member's recovery email (AC4, AC6).
    return const StepResult.failed(StepFailure.generic);
  }

  @override
  Future<ProviderSession?> verifySecondFactor(String code, SecondFactorKind kind) async {
    final Map<String, dynamic>? account = _accounts.where((Map<String, dynamic> a) => a['email'] == _pendingEmail).firstOrNull;
    final bool valid = kind == SecondFactorKind.authenticator
        ? _sixDigits(code)
        : RegExp(r'^[a-z0-9]{4}-[a-z0-9]{4}$', caseSensitive: false).hasMatch(code.trim());
    if (account == null || !valid) return null;
    return _session = _toSession(account);
  }

  static const AuthenticatorSetup _sampleSetup =
      AuthenticatorSetup(factorId: 'sample-factor', secret: 'SAMPLE KEY NOT FOR USE', otpauthUri: 'otpauth://totp/Niraah:sample?secret=SAMPLEKEYNOTFORUSE&issuer=Niraah');

  @override
  Future<AuthenticatorSetup?> startReenrol() async => _sampleSetup;

  @override
  Future<ProviderSession?> confirmReenrol(String factorId, String code) async {
    final Map<String, dynamic>? account = _accounts.where((Map<String, dynamic> a) => a['email'] == _pendingEmail).firstOrNull;
    if (account == null || !_sixDigits(code)) return null;
    return _session = _toSession(account);
  }

  @override
  Future<AuthenticatorSetup?> startAuthenticator(String token) async => _sampleSetup;

  @override
  Future<void> forgotPassword(String email) async {
    // "If that email has an account, we have sent a link." The sample sends nothing.
  }

  @override
  Future<ProviderSession?> currentSession() async => _session;

  @override
  Future<void> signOut() async {
    _session = null;
    _pendingEmail = null;
  }

  Map<String, dynamic>? _invite(String token) =>
      (sampleProviders['invites'] as List<dynamic>).cast<Map<String, dynamic>>().where((Map<String, dynamic> i) => i['token'] == token).firstOrNull;

  @override
  Future<InviteInfo?> getInvite(String token) async {
    final Map<String, dynamic>? i = _invite(token);
    return i == null ? null : InviteInfo(email: i['email'] as String, name: i['name'] as String, role: _role(i['role'] as String));
  }

  @override
  Future<PasswordRejection?> setPassword(String token, String password) async {
    if (password.length < 12) return PasswordRejection.tooShort;
    if ((sampleProviders['breachedPasswords'] as List<dynamic>).contains(password.toLowerCase())) return PasswordRejection.breached;
    return null;
  }

  @override
  Future<List<String>?> confirmAuthenticator(String token, String code) async {
    if (!_sixDigits(code)) return null;
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String part() => List<String>.generate(4, (_) => chars[_random.nextInt(chars.length)]).join();
    return List<String>.generate(10, (_) => '${part()}-${part()}');
  }

  @override
  Future<ProviderSession> finishSetup(String token) async {
    final Map<String, dynamic> i = _invite(token)!;
    // A newly set-up provider still needs an admin's approval before any member data (spec 001).
    return _session = ProviderSession(
      role: _role(i['role'] as String),
      status: ProviderStatus.underReview,
      name: i['name'] as String,
      speciality: '',
      missing: const <String>['Qualification certificates', 'Registration certificate'],
    );
  }
}
