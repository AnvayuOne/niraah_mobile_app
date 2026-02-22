//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_profile_get200_response_user.g.dart';

/// AdminProfileGet200ResponseUser
///
/// Properties:
/// * [name] 
/// * [email] 
/// * [phone] 
@BuiltValue()
abstract class AdminProfileGet200ResponseUser implements Built<AdminProfileGet200ResponseUser, AdminProfileGet200ResponseUserBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  AdminProfileGet200ResponseUser._();

  factory AdminProfileGet200ResponseUser([void updates(AdminProfileGet200ResponseUserBuilder b)]) = _$AdminProfileGet200ResponseUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminProfileGet200ResponseUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminProfileGet200ResponseUser> get serializer => _$AdminProfileGet200ResponseUserSerializer();
}

class _$AdminProfileGet200ResponseUserSerializer implements PrimitiveSerializer<AdminProfileGet200ResponseUser> {
  @override
  final Iterable<Type> types = const [AdminProfileGet200ResponseUser, _$AdminProfileGet200ResponseUser];

  @override
  final String wireName = r'AdminProfileGet200ResponseUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminProfileGet200ResponseUser object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminProfileGet200ResponseUser object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminProfileGet200ResponseUserBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminProfileGet200ResponseUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminProfileGet200ResponseUserBuilder();
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

