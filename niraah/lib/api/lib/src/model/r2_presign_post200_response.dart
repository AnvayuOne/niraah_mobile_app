//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'r2_presign_post200_response.g.dart';

/// R2PresignPost200Response
///
/// Properties:
/// * [url] - Presigned upload URL
/// * [key] 
@BuiltValue()
abstract class R2PresignPost200Response implements Built<R2PresignPost200Response, R2PresignPost200ResponseBuilder> {
  /// Presigned upload URL
  @BuiltValueField(wireName: r'url')
  String? get url;

  @BuiltValueField(wireName: r'key')
  String? get key;

  R2PresignPost200Response._();

  factory R2PresignPost200Response([void updates(R2PresignPost200ResponseBuilder b)]) = _$R2PresignPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(R2PresignPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<R2PresignPost200Response> get serializer => _$R2PresignPost200ResponseSerializer();
}

class _$R2PresignPost200ResponseSerializer implements PrimitiveSerializer<R2PresignPost200Response> {
  @override
  final Iterable<Type> types = const [R2PresignPost200Response, _$R2PresignPost200Response];

  @override
  final String wireName = r'R2PresignPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    R2PresignPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.url != null) {
      yield r'url';
      yield serializers.serialize(
        object.url,
        specifiedType: const FullType(String),
      );
    }
    if (object.key != null) {
      yield r'key';
      yield serializers.serialize(
        object.key,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    R2PresignPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required R2PresignPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  R2PresignPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = R2PresignPost200ResponseBuilder();
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

