import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_ui/material_ui.dart';

/// Light, dark or follow the phone. Saved on the device; read once at start-up.
class NThemeController extends ValueNotifier<ThemeMode> {
  NThemeController._() : super(ThemeMode.system);

  static final NThemeController instance = NThemeController._();

  /// Dark mode is switched off for now (2026-11-25): the app is always light and the switches are hidden.
  /// Set to true to bring the dark look and its switches back.
  static const bool darkModeEnabled = false;
  static const String _key = 'niraah.appearance';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> load() async {
    try {
      value = switch (await _storage.read(key: _key)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } on Object {
      value = ThemeMode.system;
    }
  }

  /// True when the app is showing its dark look right now (a saved choice, or the phone's setting until she picks one).
  bool get isDark => darkModeEnabled && switch (value) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
      };

  Future<void> set(ThemeMode mode) async {
    value = mode;
    try {
      await _storage.write(key: _key, value: mode.name);
    } on Object {
      // Not saved: the choice still applies until the app closes.
    }
  }
}
