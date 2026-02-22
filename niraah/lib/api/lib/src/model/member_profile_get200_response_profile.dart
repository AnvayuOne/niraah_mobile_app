//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/date.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_profile_get200_response_profile.g.dart';

/// MemberProfileGet200ResponseProfile
///
/// Properties:
/// * [dateOfBirth] 
/// * [notes] 
/// * [questionnaire] 
@BuiltValue()
abstract class MemberProfileGet200ResponseProfile implements Built<MemberProfileGet200ResponseProfile, MemberProfileGet200ResponseProfileBuilder> {
  @BuiltValueField(wireName: r'dateOfBirth')
  Date? get dateOfBirth;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'questionnaire')
  JsonObject? get questionnaire;

  MemberProfileGet200ResponseProfile._();

  factory MemberProfileGet200ResponseProfile([void updates(MemberProfileGet200ResponseProfileBuilder b)]) = _$MemberProfileGet200ResponseProfile;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberProfileGet200ResponseProfileBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberProfileGet200ResponseProfile> get serializer => _$MemberProfileGet200ResponseProfileSerializer();
}

class _$MemberProfileGet200ResponseProfileSerializer implements PrimitiveSerializer<MemberProfileGet200ResponseProfile> {
  @override
  final Iterable<Type> types = const [MemberProfileGet200ResponseProfile, _$MemberProfileGet200ResponseProfile];

  @override
  final String wireName = r'MemberProfileGet200ResponseProfile';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberProfileGet200ResponseProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.dateOfBirth != null) {
      yield r'dateOfBirth';
      yield serializers.serialize(
        object.dateOfBirth,
        specifiedType: const FullType(Date),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.questionnaire != null) {
      yield r'questionnaire';
      yield serializers.serialize(
        object.questionnaire,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberProfileGet200ResponseProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberProfileGet200ResponseProfileBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dateOfBirth':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.dateOfBirth = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notes = valueDes;
          break;
        case r'questionnaire':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.questionnaire = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberProfileGet200ResponseProfile deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberProfileGet200ResponseProfileBuilder();
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

