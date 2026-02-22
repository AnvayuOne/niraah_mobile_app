// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_questionnaire_submit_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberQuestionnaireSubmitPost200Response
    extends MemberQuestionnaireSubmitPost200Response {
  @override
  final bool? ok;
  @override
  final MemberQuestionnaireSubmitPost200ResponseScoring? scoring;

  factory _$MemberQuestionnaireSubmitPost200Response([
    void Function(MemberQuestionnaireSubmitPost200ResponseBuilder)? updates,
  ]) => (MemberQuestionnaireSubmitPost200ResponseBuilder()..update(updates))
      ._build();

  _$MemberQuestionnaireSubmitPost200Response._({this.ok, this.scoring})
    : super._();
  @override
  MemberQuestionnaireSubmitPost200Response rebuild(
    void Function(MemberQuestionnaireSubmitPost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberQuestionnaireSubmitPost200ResponseBuilder toBuilder() =>
      MemberQuestionnaireSubmitPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberQuestionnaireSubmitPost200Response &&
        ok == other.ok &&
        scoring == other.scoring;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, scoring.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'MemberQuestionnaireSubmitPost200Response',
          )
          ..add('ok', ok)
          ..add('scoring', scoring))
        .toString();
  }
}

class MemberQuestionnaireSubmitPost200ResponseBuilder
    implements
        Builder<
          MemberQuestionnaireSubmitPost200Response,
          MemberQuestionnaireSubmitPost200ResponseBuilder
        > {
  _$MemberQuestionnaireSubmitPost200Response? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  MemberQuestionnaireSubmitPost200ResponseScoringBuilder? _scoring;
  MemberQuestionnaireSubmitPost200ResponseScoringBuilder get scoring =>
      _$this._scoring ??=
          MemberQuestionnaireSubmitPost200ResponseScoringBuilder();
  set scoring(
    MemberQuestionnaireSubmitPost200ResponseScoringBuilder? scoring,
  ) => _$this._scoring = scoring;

  MemberQuestionnaireSubmitPost200ResponseBuilder() {
    MemberQuestionnaireSubmitPost200Response._defaults(this);
  }

  MemberQuestionnaireSubmitPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ok = $v.ok;
      _scoring = $v.scoring?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberQuestionnaireSubmitPost200Response other) {
    _$v = other as _$MemberQuestionnaireSubmitPost200Response;
  }

  @override
  void update(
    void Function(MemberQuestionnaireSubmitPost200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MemberQuestionnaireSubmitPost200Response build() => _build();

  _$MemberQuestionnaireSubmitPost200Response _build() {
    _$MemberQuestionnaireSubmitPost200Response _$result;
    try {
      _$result =
          _$v ??
          _$MemberQuestionnaireSubmitPost200Response._(
            ok: ok,
            scoring: _scoring?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'scoring';
        _scoring?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberQuestionnaireSubmitPost200Response',
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
