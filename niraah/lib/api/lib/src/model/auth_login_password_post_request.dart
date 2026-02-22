//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_login_password_post_request.g.dart';

/// AuthLoginPasswordPostRequest
///
/// Properties:
/// * [email] 
/// * [password] 
/// * [role] - Required role for login
@BuiltValue()
abstract class AuthLoginPasswordPostRequest implements Built<AuthLoginPasswordPostRequest, AuthLoginPasswordPostRequestBuilder> {
  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'password')
  String get password;

  /// Required role for login
  @BuiltValueField(wireName: r'role')
  AuthLoginPasswordPostRequestRoleEnum? get role;
  // enum roleEnum {  DOCTOR,  ADMIN,  OTHER,  };

  AuthLoginPasswordPostRequest._();

  factory AuthLoginPasswordPostRequest([void updates(AuthLoginPasswordPostRequestBuilder b)]) = _$AuthLoginPasswordPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLoginPasswordPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLoginPasswordPostRequest> get serializer => _$AuthLoginPasswordPostRequestSerializer();
}

class _$AuthLoginPasswordPostRequestSerializer implements PrimitiveSerializer<AuthLoginPasswordPostRequest> {
  @override
  final Iterable<Type> types = const [AuthLoginPasswordPostRequest, _$AuthLoginPasswordPostRequest];

  @override
  final String wireName = r'AuthLoginPasswordPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLoginPasswordPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(AuthLoginPasswordPostRequestRoleEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthLoginPasswordPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthLoginPasswordPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthLoginPasswordPostRequestRoleEnum),
          ) as AuthLoginPasswordPostRequestRoleEnum;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthLoginPasswordPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLoginPasswordPostRequestBuilder();
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

class AuthLoginPasswordPostRequestRoleEnum extends EnumClass {

  /// Required role for login
  @BuiltValueEnumConst(wireName: r'DOCTOR')
  static const AuthLoginPasswordPostRequestRoleEnum DOCTOR = _$authLoginPasswordPostRequestRoleEnum_DOCTOR;
  /// Required role for login
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const AuthLoginPasswordPostRequestRoleEnum ADMIN = _$authLoginPasswordPostRequestRoleEnum_ADMIN;
  /// Required role for login
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const AuthLoginPasswordPostRequestRoleEnum OTHER = _$authLoginPasswordPostRequestRoleEnum_OTHER;

  static Serializer<AuthLoginPasswordPostRequestRoleEnum> get serializer => _$authLoginPasswordPostRequestRoleEnumSerializer;

  const AuthLoginPasswordPostRequestRoleEnum._(String name): super(name);

  static BuiltSet<AuthLoginPasswordPostRequestRoleEnum> get values => _$authLoginPasswordPostRequestRoleEnumValues;
  static AuthLoginPasswordPostRequestRoleEnum valueOf(String name) => _$authLoginPasswordPostRequestRoleEnumValueOf(name);
}

