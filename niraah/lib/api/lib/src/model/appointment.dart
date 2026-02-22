//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'appointment.g.dart';

/// Appointment
///
/// Properties:
/// * [id] 
/// * [memberId] 
/// * [appointmentDate] 
/// * [appointmentTime] 
/// * [status] 
/// * [reason] 
@BuiltValue()
abstract class Appointment implements Built<Appointment, AppointmentBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'member_id')
  String? get memberId;

  @BuiltValueField(wireName: r'appointment_date')
  Date? get appointmentDate;

  @BuiltValueField(wireName: r'appointment_time')
  String? get appointmentTime;

  @BuiltValueField(wireName: r'status')
  AppointmentStatusEnum? get status;
  // enum statusEnum {  requested,  ASSIGNED,  PENDING_DOCTOR,  CONFIRMED,  COMPLETED,  CANCELLED,  };

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  Appointment._();

  factory Appointment([void updates(AppointmentBuilder b)]) = _$Appointment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppointmentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Appointment> get serializer => _$AppointmentSerializer();
}

class _$AppointmentSerializer implements PrimitiveSerializer<Appointment> {
  @override
  final Iterable<Type> types = const [Appointment, _$Appointment];

  @override
  final String wireName = r'Appointment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Appointment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.memberId != null) {
      yield r'member_id';
      yield serializers.serialize(
        object.memberId,
        specifiedType: const FullType(String),
      );
    }
    if (object.appointmentDate != null) {
      yield r'appointment_date';
      yield serializers.serialize(
        object.appointmentDate,
        specifiedType: const FullType(Date),
      );
    }
    if (object.appointmentTime != null) {
      yield r'appointment_time';
      yield serializers.serialize(
        object.appointmentTime,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(AppointmentStatusEnum),
      );
    }
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Appointment object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AppointmentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.memberId = valueDes;
          break;
        case r'appointment_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.appointmentDate = valueDes;
          break;
        case r'appointment_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.appointmentTime = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AppointmentStatusEnum),
          ) as AppointmentStatusEnum;
          result.status = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Appointment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppointmentBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class AppointmentStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'requested')
  static const AppointmentStatusEnum requested = _$appointmentStatusEnum_requested;
  @BuiltValueEnumConst(wireName: r'ASSIGNED')
  static const AppointmentStatusEnum ASSIGNED = _$appointmentStatusEnum_ASSIGNED;
  @BuiltValueEnumConst(wireName: r'PENDING_DOCTOR')
  static const AppointmentStatusEnum PENDING_DOCTOR = _$appointmentStatusEnum_PENDING_DOCTOR;
  @BuiltValueEnumConst(wireName: r'CONFIRMED')
  static const AppointmentStatusEnum CONFIRMED = _$appointmentStatusEnum_CONFIRMED;
  @BuiltValueEnumConst(wireName: r'COMPLETED')
  static const AppointmentStatusEnum COMPLETED = _$appointmentStatusEnum_COMPLETED;
  @BuiltValueEnumConst(wireName: r'CANCELLED')
  static const AppointmentStatusEnum CANCELLED = _$appointmentStatusEnum_CANCELLED;

  static Serializer<AppointmentStatusEnum> get serializer => _$appointmentStatusEnumSerializer;

  const AppointmentStatusEnum._(String name): super(name);

  static BuiltSet<AppointmentStatusEnum> get values => _$appointmentStatusEnumValues;
  static AppointmentStatusEnum valueOf(String name) => _$appointmentStatusEnumValueOf(name);
}

