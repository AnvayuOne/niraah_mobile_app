//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_appointments_post_request.g.dart';

/// MemberAppointmentsPostRequest
///
/// Properties:
/// * [reason] - Reason for appointment
/// * [preferredDate] - Preferred appointment date
/// * [preferredTime] - Preferred time in HH:MM format
@BuiltValue()
abstract class MemberAppointmentsPostRequest implements Built<MemberAppointmentsPostRequest, MemberAppointmentsPostRequestBuilder> {
  /// Reason for appointment
  @BuiltValueField(wireName: r'reason')
  String get reason;

  /// Preferred appointment date
  @BuiltValueField(wireName: r'preferredDate')
  Date? get preferredDate;

  /// Preferred time in HH:MM format
  @BuiltValueField(wireName: r'preferredTime')
  String? get preferredTime;

  MemberAppointmentsPostRequest._();

  factory MemberAppointmentsPostRequest([void updates(MemberAppointmentsPostRequestBuilder b)]) = _$MemberAppointmentsPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberAppointmentsPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberAppointmentsPostRequest> get serializer => _$MemberAppointmentsPostRequestSerializer();
}

class _$MemberAppointmentsPostRequestSerializer implements PrimitiveSerializer<MemberAppointmentsPostRequest> {
  @override
  final Iterable<Type> types = const [MemberAppointmentsPostRequest, _$MemberAppointmentsPostRequest];

  @override
  final String wireName = r'MemberAppointmentsPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberAppointmentsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    if (object.preferredDate != null) {
      yield r'preferredDate';
      yield serializers.serialize(
        object.preferredDate,
        specifiedType: const FullType(Date),
      );
    }
    if (object.preferredTime != null) {
      yield r'preferredTime';
      yield serializers.serialize(
        object.preferredTime,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberAppointmentsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberAppointmentsPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'preferredDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.preferredDate = valueDes;
          break;
        case r'preferredTime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.preferredTime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberAppointmentsPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberAppointmentsPostRequestBuilder();
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

