//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ai_chat_post_request_messages_inner.g.dart';

/// AiChatPostRequestMessagesInner
///
/// Properties:
/// * [role] 
/// * [content] 
@BuiltValue()
abstract class AiChatPostRequestMessagesInner implements Built<AiChatPostRequestMessagesInner, AiChatPostRequestMessagesInnerBuilder> {
  @BuiltValueField(wireName: r'role')
  AiChatPostRequestMessagesInnerRoleEnum? get role;
  // enum roleEnum {  user,  assistant,  };

  @BuiltValueField(wireName: r'content')
  String? get content;

  AiChatPostRequestMessagesInner._();

  factory AiChatPostRequestMessagesInner([void updates(AiChatPostRequestMessagesInnerBuilder b)]) = _$AiChatPostRequestMessagesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AiChatPostRequestMessagesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AiChatPostRequestMessagesInner> get serializer => _$AiChatPostRequestMessagesInnerSerializer();
}

class _$AiChatPostRequestMessagesInnerSerializer implements PrimitiveSerializer<AiChatPostRequestMessagesInner> {
  @override
  final Iterable<Type> types = const [AiChatPostRequestMessagesInner, _$AiChatPostRequestMessagesInner];

  @override
  final String wireName = r'AiChatPostRequestMessagesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AiChatPostRequestMessagesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(AiChatPostRequestMessagesInnerRoleEnum),
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
    AiChatPostRequestMessagesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AiChatPostRequestMessagesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AiChatPostRequestMessagesInnerRoleEnum),
          ) as AiChatPostRequestMessagesInnerRoleEnum;
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
  AiChatPostRequestMessagesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AiChatPostRequestMessagesInnerBuilder();
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

class AiChatPostRequestMessagesInnerRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'user')
  static const AiChatPostRequestMessagesInnerRoleEnum user = _$aiChatPostRequestMessagesInnerRoleEnum_user;
  @BuiltValueEnumConst(wireName: r'assistant')
  static const AiChatPostRequestMessagesInnerRoleEnum assistant = _$aiChatPostRequestMessagesInnerRoleEnum_assistant;

  static Serializer<AiChatPostRequestMessagesInnerRoleEnum> get serializer => _$aiChatPostRequestMessagesInnerRoleEnumSerializer;

  const AiChatPostRequestMessagesInnerRoleEnum._(String name): super(name);

  static BuiltSet<AiChatPostRequestMessagesInnerRoleEnum> get values => _$aiChatPostRequestMessagesInnerRoleEnumValues;
  static AiChatPostRequestMessagesInnerRoleEnum valueOf(String name) => _$aiChatPostRequestMessagesInnerRoleEnumValueOf(name);
}

