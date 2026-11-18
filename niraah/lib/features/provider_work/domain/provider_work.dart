/// Work shared by every provider workspace (doctor, dietitian, instructor): earnings and payouts (spec 008),
/// schedule and availability (spec 014), and the fresh staff check before signing (spec 003).
///
/// These endpoints answer with open records (packages/contracts/src/consults.ts `Open`); the server decides their
/// content, so screens read them through [Json] with safe accessors rather than fixed classes.
library;

typedef Json = Map<String, dynamic>;

extension JsonRead on Json {
  String? str(String key) => this[key] is String ? this[key] as String : (this[key] == null ? null : '${this[key]}');
  int integer(String key) => (this[key] as num?)?.toInt() ?? 0;
  double? number(String key) => (this[key] as num?)?.toDouble();
  bool flag(String key) => this[key] == true;
  Json obj(String key) => this[key] is Map ? Map<String, dynamic>.from(this[key] as Map<dynamic, dynamic>) : <String, dynamic>{};
  List<Json> objs(String key) => <Json>[
    for (final dynamic x in (this[key] as List<dynamic>?) ?? const <dynamic>[])
      if (x is Map) Map<String, dynamic>.from(x),
  ];
  List<String> strs(String key) => <String>[for (final dynamic x in (this[key] as List<dynamic>?) ?? const <dynamic>[]) '$x'];
}

abstract class ProviderWorkRepository {
  /// Balances, earning lines with their state, and the rules that apply (spec 008; spec 011 §14).
  Future<Json> earnings();

  Future<List<Json>> payouts();

  /// Payout details as the server holds them, masked.
  Future<Json> payoutDetails();

  /// Cash-out of the available balance, under spec 008's rules.
  Future<Json> requestPayout();

  /// Appointments, holds as "being booked", and review and on-call hours between [from] and [to].
  Future<Json> schedule(DateTime from, DateTime to);

  /// Weekly hours, exceptions and the slot lengths allowed.
  Future<Json> availability();

  /// `blocked` or `extra_consults`. Blocking time that holds a confirmed appointment is refused (spec 011 §11 rule 4).
  Future<void> addException(String kind, DateTime startsAt, DateTime endsAt);

  Future<void> removeException(String id);

  /// Password and authenticator code again; returns a 10-minute proof (spec 011 §7 "Signing" 1).
  Future<String> freshStaff(String password, String code);
}
