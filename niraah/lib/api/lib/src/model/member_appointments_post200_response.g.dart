// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_appointments_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberAppointmentsPost200Response
    extends MemberAppointmentsPost200Response {
  @override
  final bool? ok;
  @override
  final Appointment? appointment;
  @override
  final bool? assigned;

  factory _$MemberAppointmentsPost200Response([
    void Function(MemberAppointmentsPost200ResponseBuilder)? updates,
  ]) => (MemberAppointmentsPost200ResponseBuilder()..update(updates))._build();

  _$MemberAppointmentsPost200Response._({
    this.ok,
    this.appointment,
    this.assigned,
  }) : super._();
  @override
  MemberAppointmentsPost200Response rebuild(
    void Function(MemberAppointmentsPost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberAppointmentsPost200ResponseBuilder toBuilder() =>
      MemberAppointmentsPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberAppointmentsPost200Response &&
        ok == other.ok &&
        appointment == other.appointment &&
        assigned == other.assigned;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, appointment.hashCode);
    _$hash = $jc(_$hash, assigned.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberAppointmentsPost200Response')
          ..add('ok', ok)
          ..add('appointment', appointment)
          ..add('assigned', assigned))
        .toString();
  }
}

class MemberAppointmentsPost200ResponseBuilder
    implements
        Builder<
          MemberAppointmentsPost200Response,
          MemberAppointmentsPost200ResponseBuilder
        > {
  _$MemberAppointmentsPost200Response? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  AppointmentBuilder? _appointment;
  AppointmentBuilder get appointment =>
      _$this._appointment ??= AppointmentBuilder();
  set appointment(AppointmentBuilder? appointment) =>
      _$this._appointment = appointment;

  bool? _assigned;
  bool? get assigned => _$this._assigned;
  set assigned(bool? assigned) => _$this._assigned = assigned;

  MemberAppointmentsPost200ResponseBuilder() {
    MemberAppointmentsPost200Response._defaults(this);
  }

  MemberAppointmentsPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ok = $v.ok;
      _appointment = $v.appointment?.toBuilder();
      _assigned = $v.assigned;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberAppointmentsPost200Response other) {
    _$v = other as _$MemberAppointmentsPost200Response;
  }

  @override
  void update(
    void Function(MemberAppointmentsPost200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MemberAppointmentsPost200Response build() => _build();

  _$MemberAppointmentsPost200Response _build() {
    _$MemberAppointmentsPost200Response _$result;
    try {
      _$result =
          _$v ??
          _$MemberAppointmentsPost200Response._(
            ok: ok,
            appointment: _appointment?.build(),
            assigned: assigned,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'appointment';
        _appointment?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberAppointmentsPost200Response',
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
