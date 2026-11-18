class ApiConstants {
  const ApiConstants._();

  /// The Niraah API (constitution §3.3). Set per build with
  /// `--dart-define=API_BASE_URL=https://…/api/v1`. The default reaches the web app's dev server
  /// from the Android emulator, where the host machine is 10.0.2.2.
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/api/v1');
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
