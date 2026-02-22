//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/ai_chat_post_request_messages_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ai_chat_post_request.g.dart';

/// AiChatPostRequest
///
/// Properties:
/// * [messages] - Chat message history
/// * [isGuest] - Whether the user is a guest (not logged in)
@BuiltValue()
abstract class AiChatPostRequest implements Built<AiChatPostRequest, AiChatPostRequestBuilder> {
  /// Chat message history
  @BuiltValueField(wireName: r'messages')
  BuiltList<AiChatPostRequestMessagesInner> get messages;

  /// Whether the user is a guest (not logged in)
  @BuiltValueField(wireName: r'isGuest')
  bool? get isGuest;

  AiChatPostRequest._();

  factory AiChatPostRequest([void updates(AiChatPostRequestBuilder b)]) = _$AiChatPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AiChatPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AiChatPostRequest> get serializer => _$AiChatPostRequestSerializer();
}

class _$AiChatPostRequestSerializer implements PrimitiveSerializer<AiChatPostRequest> {
  @override
  final Iterable<Type> types = const [AiChatPostRequest, _$AiChatPostRequest];

  @override
  final String wireName = r'AiChatPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AiChatPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'messages';
    yield serializers.serialize(
      object.messages,
      specifiedType: const FullType(BuiltList, [FullType(AiChatPostRequestMessagesInner)]),
    );
    if (object.isGuest != null) {
      yield r'isGuest';
      yield serializers.serialize(
        object.isGuest,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AiChatPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AiChatPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'messages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AiChatPostRequestMessagesInner)]),
          ) as BuiltList<AiChatPostRequestMessagesInner>;
          result.messages.replace(valueDes);
          break;
        case r'isGuest':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isGuest = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AiChatPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AiChatPostRequestBuilder();
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

