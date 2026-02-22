//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_request_otp_post200_response.g.dart';

/// AuthRequestOtpPost200Response
///
/// Properties:
/// * [ok] 
/// * [code] - OTP code (only in development mode)
@BuiltValue()
abstract class AuthRequestOtpPost200Response implements Built<AuthRequestOtpPost200Response, AuthRequestOtpPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'ok')
  bool? get ok;

  /// OTP code (only in development mode)
  @BuiltValueField(wireName: r'code')
  String? get code;

  AuthRequestOtpPost200Response._();

  factory AuthRequestOtpPost200Response([void updates(AuthRequestOtpPost200ResponseBuilder b)]) = _$AuthRequestOtpPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRequestOtpPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRequestOtpPost200Response> get serializer => _$AuthRequestOtpPost200ResponseSerializer();
}

class _$AuthRequestOtpPost200ResponseSerializer implements PrimitiveSerializer<AuthRequestOtpPost200Response> {
  @override
  final Iterable<Type> types = const [AuthRequestOtpPost200Response, _$AuthRequestOtpPost200Response];

  @override
  final String wireName = r'AuthRequestOtpPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRequestOtpPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ok != null) {
      yield r'ok';
      yield serializers.serialize(
        object.ok,
        specifiedType: const FullType(bool),
      );
    }
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthRequestOtpPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRequestOtpPost200ResponseBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthRequestOtpPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRequestOtpPost200ResponseBuilder();
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

