//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_profile_get200_response_user.g.dart';

/// MemberProfileGet200ResponseUser
///
/// Properties:
/// * [id] 
/// * [name] 
@BuiltValue()
abstract class MemberProfileGet200ResponseUser implements Built<MemberProfileGet200ResponseUser, MemberProfileGet200ResponseUserBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  MemberProfileGet200ResponseUser._();

  factory MemberProfileGet200ResponseUser([void updates(MemberProfileGet200ResponseUserBuilder b)]) = _$MemberProfileGet200ResponseUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberProfileGet200ResponseUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberProfileGet200ResponseUser> get serializer => _$MemberProfileGet200ResponseUserSerializer();
}

class _$MemberProfileGet200ResponseUserSerializer implements PrimitiveSerializer<MemberProfileGet200ResponseUser> {
  @override
  final Iterable<Type> types = const [MemberProfileGet200ResponseUser, _$MemberProfileGet200ResponseUser];

  @override
  final String wireName = r'MemberProfileGet200ResponseUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberProfileGet200ResponseUser object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberProfileGet200ResponseUser object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberProfileGet200ResponseUserBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberProfileGet200ResponseUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberProfileGet200ResponseUserBuilder();
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

