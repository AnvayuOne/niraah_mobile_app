import '../../core/errors/api_exception.dart';
import '../../core/network/niraah_api.dart';

/// The server's refusal for an area she cannot use (spec 010 "Limits and plans", AC48): what the area is,
/// which plans include it, or when it starts after the trial. Never carries the area's data.
class AreaLocked implements Exception {
  const AreaLocked({required this.message, required this.status, this.description, this.plans = const <String>[], this.startsOn});

  final String message;

  /// `locked`, `starts_after_trial` or `unavailable` (teen accounts: not offered at all).
  final String status;
  final String? description;
  final List<String> plans;
  final String? startsOn;

  bool get locked => status == 'locked';
  bool get afterTrial => status == 'starts_after_trial';
}

extension AreaResult on ApiResult<Map<String, dynamic>> {
  /// The data; an [AreaLocked] when the server refused the area; otherwise an [ApiException] with the
  /// server's words.
  Map<String, dynamic> orArea() {
    final ApiResult<Map<String, dynamic>> r = this;
    if (r is ApiFail<Map<String, dynamic>> && r.status == 403 && r.error.details?['area'] != null) {
      final Map<String, dynamic> d = r.error.details!;
      throw AreaLocked(
        message: r.error.message,
        status: '${d['status']}',
        description: d['description'] as String?,
        plans: ((d['plans'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>(),
        startsOn: d['startsOn'] as String?,
      );
    }
    return orThrow();
  }
}

/// The server's words for a refused action, for a quiet message on screen.
String failureText(Object e, String fallback) => switch (e) {
      ApiException(:String message) => message,
      AreaLocked(:String message) => message,
      _ => fallback,
    };

/// A device-made id, so an entry sent twice is stored once (spec 010 AC56).
String clientId() => '${DateTime.now().microsecondsSinceEpoch}-${DateTime.now().hashCode & 0xffff}';
