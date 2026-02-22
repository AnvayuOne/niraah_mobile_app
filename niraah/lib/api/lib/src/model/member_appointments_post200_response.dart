//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/appointment.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_appointments_post200_response.g.dart';

/// MemberAppointmentsPost200Response
///
/// Properties:
/// * [ok] 
/// * [appointment] 
/// * [assigned] - Whether a doctor was automatically assigned
@BuiltValue()
abstract class MemberAppointmentsPost200Response implements Built<MemberAppointmentsPost200Response, MemberAppointmentsPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'ok')
  bool? get ok;

  @BuiltValueField(wireName: r'appointment')
  Appointment? get appointment;

  /// Whether a doctor was automatically assigned
  @BuiltValueField(wireName: r'assigned')
  bool? get assigned;

  MemberAppointmentsPost200Response._();

  factory MemberAppointmentsPost200Response([void updates(MemberAppointmentsPost200ResponseBuilder b)]) = _$MemberAppointmentsPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberAppointmentsPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberAppointmentsPost200Response> get serializer => _$MemberAppointmentsPost200ResponseSerializer();
}

class _$MemberAppointmentsPost200ResponseSerializer implements PrimitiveSerializer<MemberAppointmentsPost200Response> {
  @override
  final Iterable<Type> types = const [MemberAppointmentsPost200Response, _$MemberAppointmentsPost200Response];

  @override
  final String wireName = r'MemberAppointmentsPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberAppointmentsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ok != null) {
      yield r'ok';
      yield serializers.serialize(
        object.ok,
        specifiedType: const FullType(bool),
      );
    }
    if (object.appointment != null) {
      yield r'appointment';
      yield serializers.serialize(
        object.appointment,
        specifiedType: const FullType(Appointment),
      );
    }
    if (object.assigned != null) {
      yield r'assigned';
      yield serializers.serialize(
        object.assigned,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberAppointmentsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberAppointmentsPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ok':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ok = valueDes;
          break;
        case r'appointment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Appointment),
          ) as Appointment;
          result.appointment.replace(valueDes);
          break;
        case r'assigned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.assigned = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberAppointmentsPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberAppointmentsPost200ResponseBuilder();
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

