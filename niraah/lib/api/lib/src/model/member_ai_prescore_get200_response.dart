//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_ai_prescore_get200_response.g.dart';

/// MemberAiPrescoreGet200Response
///
/// Properties:
/// * [total] 
/// * [risk] 
/// * [flags] 
/// * [aiInsights] 
@BuiltValue()
abstract class MemberAiPrescoreGet200Response implements Built<MemberAiPrescoreGet200Response, MemberAiPrescoreGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'total')
  num? get total;

  @BuiltValueField(wireName: r'risk')
  String? get risk;

  @BuiltValueField(wireName: r'flags')
  BuiltList<String>? get flags;

  @BuiltValueField(wireName: r'aiInsights')
  String? get aiInsights;

  MemberAiPrescoreGet200Response._();

  factory MemberAiPrescoreGet200Response([void updates(MemberAiPrescoreGet200ResponseBuilder b)]) = _$MemberAiPrescoreGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberAiPrescoreGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberAiPrescoreGet200Response> get serializer => _$MemberAiPrescoreGet200ResponseSerializer();
}

class _$MemberAiPrescoreGet200ResponseSerializer implements PrimitiveSerializer<MemberAiPrescoreGet200Response> {
  @override
  final Iterable<Type> types = const [MemberAiPrescoreGet200Response, _$MemberAiPrescoreGet200Response];

  @override
  final String wireName = r'MemberAiPrescoreGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberAiPrescoreGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.total != null) {
      yield r'total';
      yield serializers.serialize(
        object.total,
        specifiedType: const FullType(num),
      );
    }
    if (object.risk != null) {
      yield r'risk';
      yield serializers.serialize(
        object.risk,
        specifiedType: const FullType(String),
      );
    }
    if (object.flags != null) {
      yield r'flags';
      yield serializers.serialize(
        object.flags,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.aiInsights != null) {
      yield r'aiInsights';
      yield serializers.serialize(
        object.aiInsights,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberAiPrescoreGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberAiPrescoreGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.total = valueDes;
          break;
        case r'risk':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.risk = valueDes;
          break;
        case r'flags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.flags.replace(valueDes);
          break;
        case r'aiInsights':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.aiInsights = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberAiPrescoreGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberAiPrescoreGet200ResponseBuilder();
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

