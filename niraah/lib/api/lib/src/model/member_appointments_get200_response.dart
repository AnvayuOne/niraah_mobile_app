//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/appointment.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_appointments_get200_response.g.dart';

/// MemberAppointmentsGet200Response
///
/// Properties:
/// * [appointments] 
@BuiltValue()
abstract class MemberAppointmentsGet200Response implements Built<MemberAppointmentsGet200Response, MemberAppointmentsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'appointments')
  BuiltList<Appointment>? get appointments;

  MemberAppointmentsGet200Response._();

  factory MemberAppointmentsGet200Response([void updates(MemberAppointmentsGet200ResponseBuilder b)]) = _$MemberAppointmentsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberAppointmentsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberAppointmentsGet200Response> get serializer => _$MemberAppointmentsGet200ResponseSerializer();
}

class _$MemberAppointmentsGet200ResponseSerializer implements PrimitiveSerializer<MemberAppointmentsGet200Response> {
  @override
  final Iterable<Type> types = const [MemberAppointmentsGet200Response, _$MemberAppointmentsGet200Response];

  @override
  final String wireName = r'MemberAppointmentsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberAppointmentsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appointments != null) {
      yield r'appointments';
      yield serializers.serialize(
        object.appointments,
        specifiedType: const FullType(BuiltList, [FullType(Appointment)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberAppointmentsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberAppointmentsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'appointments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Appointment)]),
          ) as BuiltList<Appointment>;
          result.appointments.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberAppointmentsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberAppointmentsGet200ResponseBuilder();
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

