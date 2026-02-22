//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/user.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_login_password_post200_response.g.dart';

/// AuthLoginPasswordPost200Response
///
/// Properties:
/// * [token] 
/// * [user] 
@BuiltValue()
abstract class AuthLoginPasswordPost200Response implements Built<AuthLoginPasswordPost200Response, AuthLoginPasswordPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'token')
  String? get token;

  @BuiltValueField(wireName: r'user')
  User? get user;

  AuthLoginPasswordPost200Response._();

  factory AuthLoginPasswordPost200Response([void updates(AuthLoginPasswordPost200ResponseBuilder b)]) = _$AuthLoginPasswordPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLoginPasswordPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLoginPasswordPost200Response> get serializer => _$AuthLoginPasswordPost200ResponseSerializer();
}

class _$AuthLoginPasswordPost200ResponseSerializer implements PrimitiveSerializer<AuthLoginPasswordPost200Response> {
  @override
  final Iterable<Type> types = const [AuthLoginPasswordPost200Response, _$AuthLoginPasswordPost200Response];

  @override
  final String wireName = r'AuthLoginPasswordPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLoginPasswordPost200Response object, {
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
    AuthLoginPasswordPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthLoginPasswordPost200ResponseBuilder result,
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
  AuthLoginPasswordPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLoginPasswordPost200ResponseBuilder();
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

