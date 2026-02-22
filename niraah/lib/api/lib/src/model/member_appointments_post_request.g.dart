// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_appointments_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberAppointmentsPostRequest extends MemberAppointmentsPostRequest {
  @override
  final String reason;
  @override
  final Date? preferredDate;
  @override
  final String? preferredTime;

  factory _$MemberAppointmentsPostRequest([
    void Function(MemberAppointmentsPostRequestBuilder)? updates,
  ]) => (MemberAppointmentsPostRequestBuilder()..update(updates))._build();

  _$MemberAppointmentsPostRequest._({
    required this.reason,
    this.preferredDate,
    this.preferredTime,
  }) : super._();
  @override
  MemberAppointmentsPostRequest rebuild(
    void Function(MemberAppointmentsPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberAppointmentsPostRequestBuilder toBuilder() =>
      MemberAppointmentsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberAppointmentsPostRequest &&
        reason == other.reason &&
        preferredDate == other.preferredDate &&
        preferredTime == other.preferredTime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, preferredDate.hashCode);
    _$hash = $jc(_$hash, preferredTime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberAppointmentsPostRequest')
          ..add('reason', reason)
          ..add('preferredDate', preferredDate)
          ..add('preferredTime', preferredTime))
        .toString();
  }
}

class MemberAppointmentsPostRequestBuilder
    implements
        Builder<
          MemberAppointmentsPostRequest,
          MemberAppointmentsPostRequestBuilder
        > {
  _$MemberAppointmentsPostRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  Date? _preferredDate;
  Date? get preferredDate => _$this._preferredDate;
  set preferredDate(Date? preferredDate) =>
      _$this._preferredDate = preferredDate;

  String? _preferredTime;
  String? get preferredTime => _$this._preferredTime;
  set preferredTime(String? preferredTime) =>
      _$this._preferredTime = preferredTime;

  MemberAppointmentsPostRequestBuilder() {
    MemberAppointmentsPostRequest._defaults(this);
  }

  MemberAppointmentsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _preferredDate = $v.preferredDate;
      _preferredTime = $v.preferredTime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberAppointmentsPostRequest other) {
    _$v = other as _$MemberAppointmentsPostRequest;
  }

  @override
  void update(void Function(MemberAppointmentsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberAppointmentsPostRequest build() => _build();

  _$MemberAppointmentsPostRequest _build() {
    final _$result =
        _$v ??
        _$MemberAppointmentsPostRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'MemberAppointmentsPostRequest',
            'reason',
          ),
          preferredDate: preferredDate,
          preferredTime: preferredTime,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
