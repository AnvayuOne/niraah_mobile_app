// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_appointments_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberAppointmentsGet200Response
    extends MemberAppointmentsGet200Response {
  @override
  final BuiltList<Appointment>? appointments;

  factory _$MemberAppointmentsGet200Response([
    void Function(MemberAppointmentsGet200ResponseBuilder)? updates,
  ]) => (MemberAppointmentsGet200ResponseBuilder()..update(updates))._build();

  _$MemberAppointmentsGet200Response._({this.appointments}) : super._();
  @override
  MemberAppointmentsGet200Response rebuild(
    void Function(MemberAppointmentsGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberAppointmentsGet200ResponseBuilder toBuilder() =>
      MemberAppointmentsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberAppointmentsGet200Response &&
        appointments == other.appointments;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appointments.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'MemberAppointmentsGet200Response',
    )..add('appointments', appointments)).toString();
  }
}

class MemberAppointmentsGet200ResponseBuilder
    implements
        Builder<
          MemberAppointmentsGet200Response,
          MemberAppointmentsGet200ResponseBuilder
        > {
  _$MemberAppointmentsGet200Response? _$v;

  ListBuilder<Appointment>? _appointments;
  ListBuilder<Appointment> get appointments =>
      _$this._appointments ??= ListBuilder<Appointment>();
  set appointments(ListBuilder<Appointment>? appointments) =>
      _$this._appointments = appointments;

  MemberAppointmentsGet200ResponseBuilder() {
    MemberAppointmentsGet200Response._defaults(this);
  }

  MemberAppointmentsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appointments = $v.appointments?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberAppointmentsGet200Response other) {
    _$v = other as _$MemberAppointmentsGet200Response;
  }

  @override
  void update(void Function(MemberAppointmentsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberAppointmentsGet200Response build() => _build();

  _$MemberAppointmentsGet200Response _build() {
    _$MemberAppointmentsGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$MemberAppointmentsGet200Response._(
            appointments: _appointments?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'appointments';
        _appointments?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberAppointmentsGet200Response',
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
