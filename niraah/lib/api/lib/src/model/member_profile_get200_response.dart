//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/member_profile_get200_response_profile.dart';
import 'package:openapi/src/model/member_profile_get200_response_user.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_profile_get200_response.g.dart';

/// MemberProfileGet200Response
///
/// Properties:
/// * [user] 
/// * [profile] 
@BuiltValue()
abstract class MemberProfileGet200Response implements Built<MemberProfileGet200Response, MemberProfileGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'user')
  MemberProfileGet200ResponseUser? get user;

  @BuiltValueField(wireName: r'profile')
  MemberProfileGet200ResponseProfile? get profile;

  MemberProfileGet200Response._();

  factory MemberProfileGet200Response([void updates(MemberProfileGet200ResponseBuilder b)]) = _$MemberProfileGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberProfileGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberProfileGet200Response> get serializer => _$MemberProfileGet200ResponseSerializer();
}

class _$MemberProfileGet200ResponseSerializer implements PrimitiveSerializer<MemberProfileGet200Response> {
  @override
  final Iterable<Type> types = const [MemberProfileGet200Response, _$MemberProfileGet200Response];

  @override
  final String wireName = r'MemberProfileGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberProfileGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.user != null) {
      yield r'user';
      yield serializers.serialize(
        object.user,
        specifiedType: const FullType(MemberProfileGet200ResponseUser),
      );
    }
    if (object.profile != null) {
      yield r'profile';
      yield serializers.serialize(
        object.profile,
        specifiedType: const FullType(MemberProfileGet200ResponseProfile),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberProfileGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberProfileGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemberProfileGet200ResponseUser),
          ) as MemberProfileGet200ResponseUser;
          result.user.replace(valueDes);
          break;
        case r'profile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemberProfileGet200ResponseProfile),
          ) as MemberProfileGet200ResponseProfile;
          result.profile.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberProfileGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberProfileGet200ResponseBuilder();
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

