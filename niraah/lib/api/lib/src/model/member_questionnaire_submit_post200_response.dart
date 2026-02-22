//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/member_questionnaire_submit_post200_response_scoring.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_questionnaire_submit_post200_response.g.dart';

/// MemberQuestionnaireSubmitPost200Response
///
/// Properties:
/// * [ok] 
/// * [scoring] 
@BuiltValue()
abstract class MemberQuestionnaireSubmitPost200Response implements Built<MemberQuestionnaireSubmitPost200Response, MemberQuestionnaireSubmitPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'ok')
  bool? get ok;

  @BuiltValueField(wireName: r'scoring')
  MemberQuestionnaireSubmitPost200ResponseScoring? get scoring;

  MemberQuestionnaireSubmitPost200Response._();

  factory MemberQuestionnaireSubmitPost200Response([void updates(MemberQuestionnaireSubmitPost200ResponseBuilder b)]) = _$MemberQuestionnaireSubmitPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberQuestionnaireSubmitPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberQuestionnaireSubmitPost200Response> get serializer => _$MemberQuestionnaireSubmitPost200ResponseSerializer();
}

class _$MemberQuestionnaireSubmitPost200ResponseSerializer implements PrimitiveSerializer<MemberQuestionnaireSubmitPost200Response> {
  @override
  final Iterable<Type> types = const [MemberQuestionnaireSubmitPost200Response, _$MemberQuestionnaireSubmitPost200Response];

  @override
  final String wireName = r'MemberQuestionnaireSubmitPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberQuestionnaireSubmitPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ok != null) {
      yield r'ok';
      yield serializers.serialize(
        object.ok,
        specifiedType: const FullType(bool),
      );
    }
    if (object.scoring != null) {
      yield r'scoring';
      yield serializers.serialize(
        object.scoring,
        specifiedType: const FullType(MemberQuestionnaireSubmitPost200ResponseScoring),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberQuestionnaireSubmitPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberQuestionnaireSubmitPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ok':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ok = valueDes;
          break;
        case r'scoring':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemberQuestionnaireSubmitPost200ResponseScoring),
          ) as MemberQuestionnaireSubmitPost200ResponseScoring;
          result.scoring.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberQuestionnaireSubmitPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberQuestionnaireSubmitPost200ResponseBuilder();
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

