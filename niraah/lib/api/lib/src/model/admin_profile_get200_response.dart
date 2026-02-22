//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/admin_profile_get200_response_user.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_profile_get200_response.g.dart';

/// AdminProfileGet200Response
///
/// Properties:
/// * [user] 
@BuiltValue()
abstract class AdminProfileGet200Response implements Built<AdminProfileGet200Response, AdminProfileGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'user')
  AdminProfileGet200ResponseUser? get user;

  AdminProfileGet200Response._();

  factory AdminProfileGet200Response([void updates(AdminProfileGet200ResponseBuilder b)]) = _$AdminProfileGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminProfileGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminProfileGet200Response> get serializer => _$AdminProfileGet200ResponseSerializer();
}

class _$AdminProfileGet200ResponseSerializer implements PrimitiveSerializer<AdminProfileGet200Response> {
  @override
  final Iterable<Type> types = const [AdminProfileGet200Response, _$AdminProfileGet200Response];

  @override
  final String wireName = r'AdminProfileGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminProfileGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.user != null) {
      yield r'user';
      yield serializers.serialize(
        object.user,
        specifiedType: const FullType(AdminProfileGet200ResponseUser),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminProfileGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminProfileGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminProfileGet200ResponseUser),
          ) as AdminProfileGet200ResponseUser;
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
  AdminProfileGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminProfileGet200ResponseBuilder();
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

