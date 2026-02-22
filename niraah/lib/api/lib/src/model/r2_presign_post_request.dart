//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'r2_presign_post_request.g.dart';

/// R2PresignPostRequest
///
/// Properties:
/// * [key] - Storage key/path for the file
/// * [contentType] - MIME type of the file
@BuiltValue()
abstract class R2PresignPostRequest implements Built<R2PresignPostRequest, R2PresignPostRequestBuilder> {
  /// Storage key/path for the file
  @BuiltValueField(wireName: r'key')
  String get key;

  /// MIME type of the file
  @BuiltValueField(wireName: r'contentType')
  String get contentType;

  R2PresignPostRequest._();

  factory R2PresignPostRequest([void updates(R2PresignPostRequestBuilder b)]) = _$R2PresignPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(R2PresignPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<R2PresignPostRequest> get serializer => _$R2PresignPostRequestSerializer();
}

class _$R2PresignPostRequestSerializer implements PrimitiveSerializer<R2PresignPostRequest> {
  @override
  final Iterable<Type> types = const [R2PresignPostRequest, _$R2PresignPostRequest];

  @override
  final String wireName = r'R2PresignPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    R2PresignPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'contentType';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    R2PresignPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required R2PresignPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'contentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  R2PresignPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = R2PresignPostRequestBuilder();
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

