//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_questionnaire_submit_post200_response_scoring_rule_score.g.dart';

/// MemberQuestionnaireSubmitPost200ResponseScoringRuleScore
///
/// Properties:
/// * [total] 
/// * [risk] 
/// * [flags] 
@BuiltValue()
abstract class MemberQuestionnaireSubmitPost200ResponseScoringRuleScore implements Built<MemberQuestionnaireSubmitPost200ResponseScoringRuleScore, MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder> {
  @BuiltValueField(wireName: r'total')
  num? get total;

  @BuiltValueField(wireName: r'risk')
  String? get risk;

  @BuiltValueField(wireName: r'flags')
  BuiltList<String>? get flags;

  MemberQuestionnaireSubmitPost200ResponseScoringRuleScore._();

  factory MemberQuestionnaireSubmitPost200ResponseScoringRuleScore([void updates(MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder b)]) = _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScore;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberQuestionnaireSubmitPost200ResponseScoringRuleScore> get serializer => _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreSerializer();
}

class _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreSerializer implements PrimitiveSerializer<MemberQuestionnaireSubmitPost200ResponseScoringRuleScore> {
  @override
  final Iterable<Type> types = const [MemberQuestionnaireSubmitPost200ResponseScoringRuleScore, _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScore];

  @override
  final String wireName = r'MemberQuestionnaireSubmitPost200ResponseScoringRuleScore';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberQuestionnaireSubmitPost200ResponseScoringRuleScore object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.total != null) {
      yield r'total';
      yield serializers.serialize(
        object.total,
        specifiedType: const FullType(num),
      );
    }
    if (object.risk != null) {
      yield r'risk';
      yield serializers.serialize(
        object.risk,
        specifiedType: const FullType(String),
      );
    }
    if (object.flags != null) {
      yield r'flags';
      yield serializers.serialize(
        object.flags,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberQuestionnaireSubmitPost200ResponseScoringRuleScore object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.total = valueDes;
          break;
        case r'risk':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.risk = valueDes;
          break;
        case r'flags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.flags.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberQuestionnaireSubmitPost200ResponseScoringRuleScore deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder();
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

