//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/member_questionnaire_submit_post200_response_scoring_rule_score.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_questionnaire_submit_post200_response_scoring.g.dart';

/// MemberQuestionnaireSubmitPost200ResponseScoring
///
/// Properties:
/// * [ruleScore] 
/// * [aiInsights] 
@BuiltValue()
abstract class MemberQuestionnaireSubmitPost200ResponseScoring implements Built<MemberQuestionnaireSubmitPost200ResponseScoring, MemberQuestionnaireSubmitPost200ResponseScoringBuilder> {
  @BuiltValueField(wireName: r'ruleScore')
  MemberQuestionnaireSubmitPost200ResponseScoringRuleScore? get ruleScore;

  @BuiltValueField(wireName: r'aiInsights')
  String? get aiInsights;

  MemberQuestionnaireSubmitPost200ResponseScoring._();

  factory MemberQuestionnaireSubmitPost200ResponseScoring([void updates(MemberQuestionnaireSubmitPost200ResponseScoringBuilder b)]) = _$MemberQuestionnaireSubmitPost200ResponseScoring;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberQuestionnaireSubmitPost200ResponseScoringBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberQuestionnaireSubmitPost200ResponseScoring> get serializer => _$MemberQuestionnaireSubmitPost200ResponseScoringSerializer();
}

class _$MemberQuestionnaireSubmitPost200ResponseScoringSerializer implements PrimitiveSerializer<MemberQuestionnaireSubmitPost200ResponseScoring> {
  @override
  final Iterable<Type> types = const [MemberQuestionnaireSubmitPost200ResponseScoring, _$MemberQuestionnaireSubmitPost200ResponseScoring];

  @override
  final String wireName = r'MemberQuestionnaireSubmitPost200ResponseScoring';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberQuestionnaireSubmitPost200ResponseScoring object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ruleScore != null) {
      yield r'ruleScore';
      yield serializers.serialize(
        object.ruleScore,
        specifiedType: const FullType(MemberQuestionnaireSubmitPost200ResponseScoringRuleScore),
      );
    }
    if (object.aiInsights != null) {
      yield r'aiInsights';
      yield serializers.serialize(
        object.aiInsights,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberQuestionnaireSubmitPost200ResponseScoring object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberQuestionnaireSubmitPost200ResponseScoringBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ruleScore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemberQuestionnaireSubmitPost200ResponseScoringRuleScore),
          ) as MemberQuestionnaireSubmitPost200ResponseScoringRuleScore;
          result.ruleScore.replace(valueDes);
          break;
        case r'aiInsights':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.aiInsights = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberQuestionnaireSubmitPost200ResponseScoring deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberQuestionnaireSubmitPost200ResponseScoringBuilder();
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

