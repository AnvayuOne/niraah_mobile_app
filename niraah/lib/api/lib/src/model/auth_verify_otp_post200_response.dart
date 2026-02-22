//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/user.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_verify_otp_post200_response.g.dart';

/// AuthVerifyOtpPost200Response
///
/// Properties:
/// * [token] - JWT authentication token
/// * [user] 
@BuiltValue()
abstract class AuthVerifyOtpPost200Response implements Built<AuthVerifyOtpPost200Response, AuthVerifyOtpPost200ResponseBuilder> {
  /// JWT authentication token
  @BuiltValueField(wireName: r'token')
  String? get token;

  @BuiltValueField(wireName: r'user')
  User? get user;

  AuthVerifyOtpPost200Response._();

  factory AuthVerifyOtpPost200Response([void updates(AuthVerifyOtpPost200ResponseBuilder b)]) = _$AuthVerifyOtpPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthVerifyOtpPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthVerifyOtpPost200Response> get serializer => _$AuthVerifyOtpPost200ResponseSerializer();
}

class _$AuthVerifyOtpPost200ResponseSerializer implements PrimitiveSerializer<AuthVerifyOtpPost200Response> {
  @override
  final Iterable<Type> types = const [AuthVerifyOtpPost200Response, _$AuthVerifyOtpPost200Response];

  @override
  final String wireName = r'AuthVerifyOtpPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthVerifyOtpPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.token != null) {
      yield r'token';
      yield serializers.serialize(
        object.token,
        specifiedType: const FullType(String),
      );
    }
    if (object.user != null) {
      yield r'user';
      yield serializers.serialize(
        object.user,
        specifiedType: const FullType(User),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthVerifyOtpPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthVerifyOtpPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(User),
          ) as User;
          result.user.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthVerifyOtpPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthVerifyOtpPost200ResponseBuilder();
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

