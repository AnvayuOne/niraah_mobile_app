// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_summary_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberSummaryGet200Response extends MemberSummaryGet200Response {
  @override
  final num? points;
  @override
  final num? streak;
  @override
  final num? adherence7;
  @override
  final Appointment? nextAppointment;

  factory _$MemberSummaryGet200Response([
    void Function(MemberSummaryGet200ResponseBuilder)? updates,
  ]) => (MemberSummaryGet200ResponseBuilder()..update(updates))._build();

  _$MemberSummaryGet200Response._({
    this.points,
    this.streak,
    this.adherence7,
    this.nextAppointment,
  }) : super._();
  @override
  MemberSummaryGet200Response rebuild(
    void Function(MemberSummaryGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberSummaryGet200ResponseBuilder toBuilder() =>
      MemberSummaryGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberSummaryGet200Response &&
        points == other.points &&
        streak == other.streak &&
        adherence7 == other.adherence7 &&
        nextAppointment == other.nextAppointment;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, points.hashCode);
    _$hash = $jc(_$hash, streak.hashCode);
    _$hash = $jc(_$hash, adherence7.hashCode);
    _$hash = $jc(_$hash, nextAppointment.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberSummaryGet200Response')
          ..add('points', points)
          ..add('streak', streak)
          ..add('adherence7', adherence7)
          ..add('nextAppointment', nextAppointment))
        .toString();
  }
}

class MemberSummaryGet200ResponseBuilder
    implements
        Builder<
          MemberSummaryGet200Response,
          MemberSummaryGet200ResponseBuilder
        > {
  _$MemberSummaryGet200Response? _$v;

  num? _points;
  num? get points => _$this._points;
  set points(num? points) => _$this._points = points;

  num? _streak;
  num? get streak => _$this._streak;
  set streak(num? streak) => _$this._streak = streak;

  num? _adherence7;
  num? get adherence7 => _$this._adherence7;
  set adherence7(num? adherence7) => _$this._adherence7 = adherence7;

  AppointmentBuilder? _nextAppointment;
  AppointmentBuilder get nextAppointment =>
      _$this._nextAppointment ??= AppointmentBuilder();
  set nextAppointment(AppointmentBuilder? nextAppointment) =>
      _$this._nextAppointment = nextAppointment;

  MemberSummaryGet200ResponseBuilder() {
    MemberSummaryGet200Response._defaults(this);
  }

  MemberSummaryGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _points = $v.points;
      _streak = $v.streak;
      _adherence7 = $v.adherence7;
      _nextAppointment = $v.nextAppointment?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberSummaryGet200Response other) {
    _$v = other as _$MemberSummaryGet200Response;
  }

  @override
  void update(void Function(MemberSummaryGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberSummaryGet200Response build() => _build();

  _$MemberSummaryGet200Response _build() {
    _$MemberSummaryGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$MemberSummaryGet200Response._(
            points: points,
            streak: streak,
            adherence7: adherence7,
            nextAppointment: _nextAppointment?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'nextAppointment';
        _nextAppointment?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberSummaryGet200Response',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
