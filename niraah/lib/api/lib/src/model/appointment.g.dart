// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AppointmentStatusEnum _$appointmentStatusEnum_requested =
    const AppointmentStatusEnum._('requested');
const AppointmentStatusEnum _$appointmentStatusEnum_ASSIGNED =
    const AppointmentStatusEnum._('ASSIGNED');
const AppointmentStatusEnum _$appointmentStatusEnum_PENDING_DOCTOR =
    const AppointmentStatusEnum._('PENDING_DOCTOR');
const AppointmentStatusEnum _$appointmentStatusEnum_CONFIRMED =
    const AppointmentStatusEnum._('CONFIRMED');
const AppointmentStatusEnum _$appointmentStatusEnum_COMPLETED =
    const AppointmentStatusEnum._('COMPLETED');
const AppointmentStatusEnum _$appointmentStatusEnum_CANCELLED =
    const AppointmentStatusEnum._('CANCELLED');

AppointmentStatusEnum _$appointmentStatusEnumValueOf(String name) {
  switch (name) {
    case 'requested':
      return _$appointmentStatusEnum_requested;
    case 'ASSIGNED':
      return _$appointmentStatusEnum_ASSIGNED;
    case 'PENDING_DOCTOR':
      return _$appointmentStatusEnum_PENDING_DOCTOR;
    case 'CONFIRMED':
      return _$appointmentStatusEnum_CONFIRMED;
    case 'COMPLETED':
      return _$appointmentStatusEnum_COMPLETED;
    case 'CANCELLED':
      return _$appointmentStatusEnum_CANCELLED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AppointmentStatusEnum> _$appointmentStatusEnumValues =
    BuiltSet<AppointmentStatusEnum>(const <AppointmentStatusEnum>[
      _$appointmentStatusEnum_requested,
      _$appointmentStatusEnum_ASSIGNED,
      _$appointmentStatusEnum_PENDING_DOCTOR,
      _$appointmentStatusEnum_CONFIRMED,
      _$appointmentStatusEnum_COMPLETED,
      _$appointmentStatusEnum_CANCELLED,
    ]);

Serializer<AppointmentStatusEnum> _$appointmentStatusEnumSerializer =
    _$AppointmentStatusEnumSerializer();

class _$AppointmentStatusEnumSerializer
    implements PrimitiveSerializer<AppointmentStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'requested': 'requested',
    'ASSIGNED': 'ASSIGNED',
    'PENDING_DOCTOR': 'PENDING_DOCTOR',
    'CONFIRMED': 'CONFIRMED',
    'COMPLETED': 'COMPLETED',
    'CANCELLED': 'CANCELLED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'requested': 'requested',
    'ASSIGNED': 'ASSIGNED',
    'PENDING_DOCTOR': 'PENDING_DOCTOR',
    'CONFIRMED': 'CONFIRMED',
    'COMPLETED': 'COMPLETED',
    'CANCELLED': 'CANCELLED',
  };

  @override
  final Iterable<Type> types = const <Type>[AppointmentStatusEnum];
  @override
  final String wireName = 'AppointmentStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    AppointmentStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AppointmentStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AppointmentStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$Appointment extends Appointment {
  @override
  final String? id;
  @override
  final String? memberId;
  @override
  final Date? appointmentDate;
  @override
  final String? appointmentTime;
  @override
  final AppointmentStatusEnum? status;
  @override
  final String? reason;

  factory _$Appointment([void Function(AppointmentBuilder)? updates]) =>
      (AppointmentBuilder()..update(updates))._build();

  _$Appointment._({
    this.id,
    this.memberId,
    this.appointmentDate,
    this.appointmentTime,
    this.status,
    this.reason,
  }) : super._();
  @override
  Appointment rebuild(void Function(AppointmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppointmentBuilder toBuilder() => AppointmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Appointment &&
        id == other.id &&
        memberId == other.memberId &&
        appointmentDate == other.appointmentDate &&
        appointmentTime == other.appointmentTime &&
        status == other.status &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, memberId.hashCode);
    _$hash = $jc(_$hash, appointmentDate.hashCode);
    _$hash = $jc(_$hash, appointmentTime.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Appointment')
          ..add('id', id)
          ..add('memberId', memberId)
          ..add('appointmentDate', appointmentDate)
          ..add('appointmentTime', appointmentTime)
          ..add('status', status)
          ..add('reason', reason))
        .toString();
  }
}

class AppointmentBuilder implements Builder<Appointment, AppointmentBuilder> {
  _$Appointment? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _memberId;
  String? get memberId => _$this._memberId;
  set memberId(String? memberId) => _$this._memberId = memberId;

  Date? _appointmentDate;
  Date? get appointmentDate => _$this._appointmentDate;
  set appointmentDate(Date? appointmentDate) =>
      _$this._appointmentDate = appointmentDate;

  String? _appointmentTime;
  String? get appointmentTime => _$this._appointmentTime;
  set appointmentTime(String? appointmentTime) =>
      _$this._appointmentTime = appointmentTime;

  AppointmentStatusEnum? _status;
  AppointmentStatusEnum? get status => _$this._status;
  set status(AppointmentStatusEnum? status) => _$this._status = status;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  AppointmentBuilder() {
    Appointment._defaults(this);
  }

  AppointmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _memberId = $v.memberId;
      _appointmentDate = $v.appointmentDate;
      _appointmentTime = $v.appointmentTime;
      _status = $v.status;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Appointment other) {
    _$v = other as _$Appointment;
  }

  @override
  void update(void Function(AppointmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Appointment build() => _build();

  _$Appointment _build() {
    final _$result =
        _$v ??
        _$Appointment._(
          id: id,
          memberId: memberId,
          appointmentDate: appointmentDate,
          appointmentTime: appointmentTime,
          status: status,
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
