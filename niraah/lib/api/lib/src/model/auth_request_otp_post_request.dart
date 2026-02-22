//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_request_otp_post_request.g.dart';

/// AuthRequestOtpPostRequest
///
/// Properties:
/// * [phone] - Phone number with country code
/// * [signup] - Whether this is a signup request
/// * [role] - User role for signup
@BuiltValue()
abstract class AuthRequestOtpPostRequest implements Built<AuthRequestOtpPostRequest, AuthRequestOtpPostRequestBuilder> {
  /// Phone number with country code
  @BuiltValueField(wireName: r'phone')
  String get phone;

  /// Whether this is a signup request
  @BuiltValueField(wireName: r'signup')
  bool? get signup;

  /// User role for signup
  @BuiltValueField(wireName: r'role')
  AuthRequestOtpPostRequestRoleEnum? get role;
  // enum roleEnum {  MEMBER,  DOCTOR,  DIETICIAN,  ADMIN,  };

  AuthRequestOtpPostRequest._();

  factory AuthRequestOtpPostRequest([void updates(AuthRequestOtpPostRequestBuilder b)]) = _$AuthRequestOtpPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRequestOtpPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRequestOtpPostRequest> get serializer => _$AuthRequestOtpPostRequestSerializer();
}

class _$AuthRequestOtpPostRequestSerializer implements PrimitiveSerializer<AuthRequestOtpPostRequest> {
  @override
  final Iterable<Type> types = const [AuthRequestOtpPostRequest, _$AuthRequestOtpPostRequest];

  @override
  final String wireName = r'AuthRequestOtpPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRequestOtpPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    if (object.signup != null) {
      yield r'signup';
      yield serializers.serialize(
        object.signup,
        specifiedType: const FullType(bool),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(AuthRequestOtpPostRequestRoleEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthRequestOtpPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRequestOtpPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'signup':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.signup = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthRequestOtpPostRequestRoleEnum),
          ) as AuthRequestOtpPostRequestRoleEnum;
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
  AuthRequestOtpPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRequestOtpPostRequestBuilder();
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

class AuthRequestOtpPostRequestRoleEnum extends EnumClass {

  /// User role for signup
  @BuiltValueEnumConst(wireName: r'MEMBER')
  static const AuthRequestOtpPostRequestRoleEnum MEMBER = _$authRequestOtpPostRequestRoleEnum_MEMBER;
  /// User role for signup
  @BuiltValueEnumConst(wireName: r'DOCTOR')
  static const AuthRequestOtpPostRequestRoleEnum DOCTOR = _$authRequestOtpPostRequestRoleEnum_DOCTOR;
  /// User role for signup
  @BuiltValueEnumConst(wireName: r'DIETICIAN')
  static const AuthRequestOtpPostRequestRoleEnum DIETICIAN = _$authRequestOtpPostRequestRoleEnum_DIETICIAN;
  /// User role for signup
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const AuthRequestOtpPostRequestRoleEnum ADMIN = _$authRequestOtpPostRequestRoleEnum_ADMIN;

  static Serializer<AuthRequestOtpPostRequestRoleEnum> get serializer => _$authRequestOtpPostRequestRoleEnumSerializer;

  const AuthRequestOtpPostRequestRoleEnum._(String name): super(name);

  static BuiltSet<AuthRequestOtpPostRequestRoleEnum> get values => _$authRequestOtpPostRequestRoleEnumValues;
  static AuthRequestOtpPostRequestRoleEnum valueOf(String name) => _$authRequestOtpPostRequestRoleEnumValueOf(name);
}

