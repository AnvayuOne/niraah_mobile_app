// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_profile_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberProfilePostRequest extends MemberProfilePostRequest {
  @override
  final String? name;
  @override
  final Date? dateOfBirth;
  @override
  final String? notes;
  @override
  final JsonObject? questionnaire;

  factory _$MemberProfilePostRequest([
    void Function(MemberProfilePostRequestBuilder)? updates,
  ]) => (MemberProfilePostRequestBuilder()..update(updates))._build();

  _$MemberProfilePostRequest._({
    this.name,
    this.dateOfBirth,
    this.notes,
    this.questionnaire,
  }) : super._();
  @override
  MemberProfilePostRequest rebuild(
    void Function(MemberProfilePostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberProfilePostRequestBuilder toBuilder() =>
      MemberProfilePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberProfilePostRequest &&
        name == other.name &&
        dateOfBirth == other.dateOfBirth &&
        notes == other.notes &&
        questionnaire == other.questionnaire;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, dateOfBirth.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, questionnaire.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberProfilePostRequest')
          ..add('name', name)
          ..add('dateOfBirth', dateOfBirth)
          ..add('notes', notes)
          ..add('questionnaire', questionnaire))
        .toString();
  }
}

class MemberProfilePostRequestBuilder
    implements
        Builder<MemberProfilePostRequest, MemberProfilePostRequestBuilder> {
  _$MemberProfilePostRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

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

  MemberProfilePostRequestBuilder() {
    MemberProfilePostRequest._defaults(this);
  }

  MemberProfilePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _dateOfBirth = $v.dateOfBirth;
      _notes = $v.notes;
      _questionnaire = $v.questionnaire;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberProfilePostRequest other) {
    _$v = other as _$MemberProfilePostRequest;
  }

  @override
  void update(void Function(MemberProfilePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberProfilePostRequest build() => _build();

  _$MemberProfilePostRequest _build() {
    final _$result =
        _$v ??
        _$MemberProfilePostRequest._(
          name: name,
          dateOfBirth: dateOfBirth,
          notes: notes,
          questionnaire: questionnaire,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
