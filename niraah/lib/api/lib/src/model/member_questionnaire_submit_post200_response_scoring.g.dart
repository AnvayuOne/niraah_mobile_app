// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_questionnaire_submit_post200_response_scoring.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberQuestionnaireSubmitPost200ResponseScoring
    extends MemberQuestionnaireSubmitPost200ResponseScoring {
  @override
  final MemberQuestionnaireSubmitPost200ResponseScoringRuleScore? ruleScore;
  @override
  final String? aiInsights;

  factory _$MemberQuestionnaireSubmitPost200ResponseScoring([
    void Function(MemberQuestionnaireSubmitPost200ResponseScoringBuilder)?
    updates,
  ]) =>
      (MemberQuestionnaireSubmitPost200ResponseScoringBuilder()
            ..update(updates))
          ._build();

  _$MemberQuestionnaireSubmitPost200ResponseScoring._({
    this.ruleScore,
    this.aiInsights,
  }) : super._();
  @override
  MemberQuestionnaireSubmitPost200ResponseScoring rebuild(
    void Function(MemberQuestionnaireSubmitPost200ResponseScoringBuilder)
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberQuestionnaireSubmitPost200ResponseScoringBuilder toBuilder() =>
      MemberQuestionnaireSubmitPost200ResponseScoringBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberQuestionnaireSubmitPost200ResponseScoring &&
        ruleScore == other.ruleScore &&
        aiInsights == other.aiInsights;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ruleScore.hashCode);
    _$hash = $jc(_$hash, aiInsights.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'MemberQuestionnaireSubmitPost200ResponseScoring',
          )
          ..add('ruleScore', ruleScore)
          ..add('aiInsights', aiInsights))
        .toString();
  }
}

class MemberQuestionnaireSubmitPost200ResponseScoringBuilder
    implements
        Builder<
          MemberQuestionnaireSubmitPost200ResponseScoring,
          MemberQuestionnaireSubmitPost200ResponseScoringBuilder
        > {
  _$MemberQuestionnaireSubmitPost200ResponseScoring? _$v;

  MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder? _ruleScore;
  MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder
  get ruleScore => _$this._ruleScore ??=
      MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder();
  set ruleScore(
    MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder? ruleScore,
  ) => _$this._ruleScore = ruleScore;

  String? _aiInsights;
  String? get aiInsights => _$this._aiInsights;
  set aiInsights(String? aiInsights) => _$this._aiInsights = aiInsights;

  MemberQuestionnaireSubmitPost200ResponseScoringBuilder() {
    MemberQuestionnaireSubmitPost200ResponseScoring._defaults(this);
  }

  MemberQuestionnaireSubmitPost200ResponseScoringBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ruleScore = $v.ruleScore?.toBuilder();
      _aiInsights = $v.aiInsights;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberQuestionnaireSubmitPost200ResponseScoring other) {
    _$v = other as _$MemberQuestionnaireSubmitPost200ResponseScoring;
  }

  @override
  void update(
    void Function(MemberQuestionnaireSubmitPost200ResponseScoringBuilder)?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MemberQuestionnaireSubmitPost200ResponseScoring build() => _build();

  _$MemberQuestionnaireSubmitPost200ResponseScoring _build() {
    _$MemberQuestionnaireSubmitPost200ResponseScoring _$result;
    try {
      _$result =
          _$v ??
          _$MemberQuestionnaireSubmitPost200ResponseScoring._(
            ruleScore: _ruleScore?.build(),
            aiInsights: aiInsights,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ruleScore';
        _ruleScore?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberQuestionnaireSubmitPost200ResponseScoring',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
