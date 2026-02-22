//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/date.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_profile_post_request.g.dart';

/// MemberProfilePostRequest
///
/// Properties:
/// * [name] 
/// * [dateOfBirth] 
/// * [notes] 
/// * [questionnaire] - Health questionnaire answers
@BuiltValue()
abstract class MemberProfilePostRequest implements Built<MemberProfilePostRequest, MemberProfilePostRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'dateOfBirth')
  Date? get dateOfBirth;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// Health questionnaire answers
  @BuiltValueField(wireName: r'questionnaire')
  JsonObject? get questionnaire;

  MemberProfilePostRequest._();

  factory MemberProfilePostRequest([void updates(MemberProfilePostRequestBuilder b)]) = _$MemberProfilePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberProfilePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberProfilePostRequest> get serializer => _$MemberProfilePostRequestSerializer();
}

class _$MemberProfilePostRequestSerializer implements PrimitiveSerializer<MemberProfilePostRequest> {
  @override
  final Iterable<Type> types = const [MemberProfilePostRequest, _$MemberProfilePostRequest];

  @override
  final String wireName = r'MemberProfilePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberProfilePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
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
    MemberProfilePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberProfilePostRequestBuilder result,
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
  MemberProfilePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberProfilePostRequestBuilder();
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

