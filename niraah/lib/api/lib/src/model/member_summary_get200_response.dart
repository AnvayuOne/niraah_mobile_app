//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/appointment.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_summary_get200_response.g.dart';

/// MemberSummaryGet200Response
///
/// Properties:
/// * [points] - Health points based on tracking activity
/// * [streak] - Current tracking streak in days
/// * [adherence7] - 7-day adherence percentage
/// * [nextAppointment] 
@BuiltValue()
abstract class MemberSummaryGet200Response implements Built<MemberSummaryGet200Response, MemberSummaryGet200ResponseBuilder> {
  /// Health points based on tracking activity
  @BuiltValueField(wireName: r'points')
  num? get points;

  /// Current tracking streak in days
  @BuiltValueField(wireName: r'streak')
  num? get streak;

  /// 7-day adherence percentage
  @BuiltValueField(wireName: r'adherence7')
  num? get adherence7;

  @BuiltValueField(wireName: r'nextAppointment')
  Appointment? get nextAppointment;

  MemberSummaryGet200Response._();

  factory MemberSummaryGet200Response([void updates(MemberSummaryGet200ResponseBuilder b)]) = _$MemberSummaryGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberSummaryGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberSummaryGet200Response> get serializer => _$MemberSummaryGet200ResponseSerializer();
}

class _$MemberSummaryGet200ResponseSerializer implements PrimitiveSerializer<MemberSummaryGet200Response> {
  @override
  final Iterable<Type> types = const [MemberSummaryGet200Response, _$MemberSummaryGet200Response];

  @override
  final String wireName = r'MemberSummaryGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberSummaryGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.points != null) {
      yield r'points';
      yield serializers.serialize(
        object.points,
        specifiedType: const FullType(num),
      );
    }
    if (object.streak != null) {
      yield r'streak';
      yield serializers.serialize(
        object.streak,
        specifiedType: const FullType(num),
      );
    }
    if (object.adherence7 != null) {
      yield r'adherence7';
      yield serializers.serialize(
        object.adherence7,
        specifiedType: const FullType(num),
      );
    }
    if (object.nextAppointment != null) {
      yield r'nextAppointment';
      yield serializers.serialize(
        object.nextAppointment,
        specifiedType: const FullType.nullable(Appointment),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberSummaryGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberSummaryGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'points':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.points = valueDes;
          break;
        case r'streak':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.streak = valueDes;
          break;
        case r'adherence7':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.adherence7 = valueDes;
          break;
        case r'nextAppointment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Appointment),
          ) as Appointment?;
          if (valueDes == null) continue;
          result.nextAppointment.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberSummaryGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberSummaryGet200ResponseBuilder();
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

