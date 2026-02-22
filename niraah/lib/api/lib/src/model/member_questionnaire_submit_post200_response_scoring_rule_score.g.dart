// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_questionnaire_submit_post200_response_scoring_rule_score.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScore
    extends MemberQuestionnaireSubmitPost200ResponseScoringRuleScore {
  @override
  final num? total;
  @override
  final String? risk;
  @override
  final BuiltList<String>? flags;

  factory _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScore([
    void Function(
      MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder,
    )?
    updates,
  ]) =>
      (MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder()
            ..update(updates))
          ._build();

  _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScore._({
    this.total,
    this.risk,
    this.flags,
  }) : super._();
  @override
  MemberQuestionnaireSubmitPost200ResponseScoringRuleScore rebuild(
    void Function(
      MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder toBuilder() =>
      MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberQuestionnaireSubmitPost200ResponseScoringRuleScore &&
        total == other.total &&
        risk == other.risk &&
        flags == other.flags;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, risk.hashCode);
    _$hash = $jc(_$hash, flags.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'MemberQuestionnaireSubmitPost200ResponseScoringRuleScore',
          )
          ..add('total', total)
          ..add('risk', risk)
          ..add('flags', flags))
        .toString();
  }
}

class MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder
    implements
        Builder<
          MemberQuestionnaireSubmitPost200ResponseScoringRuleScore,
          MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder
        > {
  _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScore? _$v;

  num? _total;
  num? get total => _$this._total;
  set total(num? total) => _$this._total = total;

  String? _risk;
  String? get risk => _$this._risk;
  set risk(String? risk) => _$this._risk = risk;

  ListBuilder<String>? _flags;
  ListBuilder<String> get flags => _$this._flags ??= ListBuilder<String>();
  set flags(ListBuilder<String>? flags) => _$this._flags = flags;

  MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder() {
    MemberQuestionnaireSubmitPost200ResponseScoringRuleScore._defaults(this);
  }

  MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _risk = $v.risk;
      _flags = $v.flags?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberQuestionnaireSubmitPost200ResponseScoringRuleScore other) {
    _$v = other as _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScore;
  }

  @override
  void update(
    void Function(
      MemberQuestionnaireSubmitPost200ResponseScoringRuleScoreBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MemberQuestionnaireSubmitPost200ResponseScoringRuleScore build() => _build();

  _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScore _build() {
    _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScore _$result;
    try {
      _$result =
          _$v ??
          _$MemberQuestionnaireSubmitPost200ResponseScoringRuleScore._(
            total: total,
            risk: risk,
            flags: _flags?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'flags';
        _flags?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberQuestionnaireSubmitPost200ResponseScoringRuleScore',
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
