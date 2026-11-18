import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Session tokens from `/api/v1` (spec 003 "Sessions" 2, AC28): on mobile they live only in the
/// platform's secure storage (Keychain, Keystore), never in plain preferences or logs.
class SessionTokens {
  const SessionTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

abstract interface class SessionStore {
  Future<SessionTokens?> read();
  Future<void> write(SessionTokens tokens);
  Future<void> clear();

  /// A random id for this install, so the server can tell a known device from a new one (spec 003
  /// "Second check"). It identifies nothing about her.
  Future<String> deviceId();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const String _access = 'niraah.session.access';
  static const String _refresh = 'niraah.session.refresh';
  static const String _device = 'niraah.device.id';

  @override
  Future<SessionTokens?> read() async {
    final String? a = await _storage.read(key: _access);
    final String? r = await _storage.read(key: _refresh);
    return a == null || r == null ? null : SessionTokens(accessToken: a, refreshToken: r);
  }

  @override
  Future<void> write(SessionTokens tokens) async {
    await _storage.write(key: _access, value: tokens.accessToken);
    await _storage.write(key: _refresh, value: tokens.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }

  @override
  Future<String> deviceId() async {
    final String? existing = await _storage.read(key: _device);
    if (existing != null) return existing;
    final String id = randomDeviceId();
    await _storage.write(key: _device, value: id);
    return id;
  }
}

/// For tests.
class MemorySessionStore implements SessionStore {
  SessionTokens? tokens;
  final String _device = randomDeviceId();

  @override
  Future<SessionTokens?> read() async => tokens;

  @override
  Future<void> write(SessionTokens t) async => tokens = t;

  @override
  Future<void> clear() async => tokens = null;

  @override
  Future<String> deviceId() async => _device;
}

String randomDeviceId() {
  final Random r = Random.secure();
  return List<String>.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}
