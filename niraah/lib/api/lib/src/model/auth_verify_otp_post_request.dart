//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_verify_otp_post_request.g.dart';

/// AuthVerifyOtpPostRequest
///
/// Properties:
/// * [phone] 
/// * [code] - 6-digit OTP code
@BuiltValue()
abstract class AuthVerifyOtpPostRequest implements Built<AuthVerifyOtpPostRequest, AuthVerifyOtpPostRequestBuilder> {
  @BuiltValueField(wireName: r'phone')
  String get phone;

  /// 6-digit OTP code
  @BuiltValueField(wireName: r'code')
  String get code;

  AuthVerifyOtpPostRequest._();

  factory AuthVerifyOtpPostRequest([void updates(AuthVerifyOtpPostRequestBuilder b)]) = _$AuthVerifyOtpPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthVerifyOtpPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthVerifyOtpPostRequest> get serializer => _$AuthVerifyOtpPostRequestSerializer();
}

class _$AuthVerifyOtpPostRequestSerializer implements PrimitiveSerializer<AuthVerifyOtpPostRequest> {
  @override
  final Iterable<Type> types = const [AuthVerifyOtpPostRequest, _$AuthVerifyOtpPostRequest];

  @override
  final String wireName = r'AuthVerifyOtpPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthVerifyOtpPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthVerifyOtpPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthVerifyOtpPostRequestBuilder result,
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
  AuthVerifyOtpPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthVerifyOtpPostRequestBuilder();
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

