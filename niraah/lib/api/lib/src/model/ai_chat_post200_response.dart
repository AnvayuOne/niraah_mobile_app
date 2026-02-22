//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ai_chat_post200_response.g.dart';

/// AiChatPost200Response
///
/// Properties:
/// * [role] 
/// * [content] 
@BuiltValue()
abstract class AiChatPost200Response implements Built<AiChatPost200Response, AiChatPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'role')
  AiChatPost200ResponseRoleEnum? get role;
  // enum roleEnum {  assistant,  };

  @BuiltValueField(wireName: r'content')
  String? get content;

  AiChatPost200Response._();

  factory AiChatPost200Response([void updates(AiChatPost200ResponseBuilder b)]) = _$AiChatPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AiChatPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AiChatPost200Response> get serializer => _$AiChatPost200ResponseSerializer();
}

class _$AiChatPost200ResponseSerializer implements PrimitiveSerializer<AiChatPost200Response> {
  @override
  final Iterable<Type> types = const [AiChatPost200Response, _$AiChatPost200Response];

  @override
  final String wireName = r'AiChatPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AiChatPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(AiChatPost200ResponseRoleEnum),
      );
    }
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AiChatPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AiChatPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AiChatPost200ResponseRoleEnum),
          ) as AiChatPost200ResponseRoleEnum;
          result.role = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AiChatPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AiChatPost200ResponseBuilder();
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

class AiChatPost200ResponseRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'assistant')
  static const AiChatPost200ResponseRoleEnum assistant = _$aiChatPost200ResponseRoleEnum_assistant;

  static Serializer<AiChatPost200ResponseRoleEnum> get serializer => _$aiChatPost200ResponseRoleEnumSerializer;

  const AiChatPost200ResponseRoleEnum._(String name): super(name);

  static BuiltSet<AiChatPost200ResponseRoleEnum> get values => _$aiChatPost200ResponseRoleEnumValues;
  static AiChatPost200ResponseRoleEnum valueOf(String name) => _$aiChatPost200ResponseRoleEnumValueOf(name);
}

