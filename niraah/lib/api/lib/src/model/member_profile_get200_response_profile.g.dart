// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_profile_get200_response_profile.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberProfileGet200ResponseProfile
    extends MemberProfileGet200ResponseProfile {
  @override
  final Date? dateOfBirth;
  @override
  final String? notes;
  @override
  final JsonObject? questionnaire;

  factory _$MemberProfileGet200ResponseProfile([
    void Function(MemberProfileGet200ResponseProfileBuilder)? updates,
  ]) => (MemberProfileGet200ResponseProfileBuilder()..update(updates))._build();

  _$MemberProfileGet200ResponseProfile._({
    this.dateOfBirth,
    this.notes,
    this.questionnaire,
  }) : super._();
  @override
  MemberProfileGet200ResponseProfile rebuild(
    void Function(MemberProfileGet200ResponseProfileBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberProfileGet200ResponseProfileBuilder toBuilder() =>
      MemberProfileGet200ResponseProfileBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberProfileGet200ResponseProfile &&
        dateOfBirth == other.dateOfBirth &&
        notes == other.notes &&
        questionnaire == other.questionnaire;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dateOfBirth.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, questionnaire.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberProfileGet200ResponseProfile')
          ..add('dateOfBirth', dateOfBirth)
          ..add('notes', notes)
          ..add('questionnaire', questionnaire))
        .toString();
  }
}

class MemberProfileGet200ResponseProfileBuilder
    implements
        Builder<
          MemberProfileGet200ResponseProfile,
          MemberProfileGet200ResponseProfileBuilder
        > {
  _$MemberProfileGet200ResponseProfile? _$v;

  Date? _dateOfBirth;
  Date? get dateOfBirth => _$this._dateOfBirth;
  set dateOfBirth(Date? dateOfBirth) => _$this._dateOfBirth = dateOfBirth;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  JsonObject? _questionnaire;
  JsonObject? get questionnaire => _$this._questionnaire;
  set questionnaire(JsonObject? questionnaire) =>
      _$this._questionnaire = questionnaire;

  MemberProfileGet200ResponseProfileBuilder() {
    MemberProfileGet200ResponseProfile._defaults(this);
  }

  MemberProfileGet200ResponseProfileBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dateOfBirth = $v.dateOfBirth;
      _notes = $v.notes;
      _questionnaire = $v.questionnaire;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberProfileGet200ResponseProfile other) {
    _$v = other as _$MemberProfileGet200ResponseProfile;
  }

  @override
  void update(
    void Function(MemberProfileGet200ResponseProfileBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MemberProfileGet200ResponseProfile build() => _build();

  _$MemberProfileGet200ResponseProfile _build() {
    final _$result =
        _$v ??
        _$MemberProfileGet200ResponseProfile._(
          dateOfBirth: dateOfBirth,
          notes: notes,
          questionnaire: questionnaire,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
