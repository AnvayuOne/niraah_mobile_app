// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_symptoms_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberSymptomsGet200Response extends MemberSymptomsGet200Response {
  @override
  final BuiltList<SymptomEntry>? entries;

  factory _$MemberSymptomsGet200Response([
    void Function(MemberSymptomsGet200ResponseBuilder)? updates,
  ]) => (MemberSymptomsGet200ResponseBuilder()..update(updates))._build();

  _$MemberSymptomsGet200Response._({this.entries}) : super._();
  @override
  MemberSymptomsGet200Response rebuild(
    void Function(MemberSymptomsGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberSymptomsGet200ResponseBuilder toBuilder() =>
      MemberSymptomsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberSymptomsGet200Response && entries == other.entries;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entries.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'MemberSymptomsGet200Response',
    )..add('entries', entries)).toString();
  }
}

class MemberSymptomsGet200ResponseBuilder
    implements
        Builder<
          MemberSymptomsGet200Response,
          MemberSymptomsGet200ResponseBuilder
        > {
  _$MemberSymptomsGet200Response? _$v;

  ListBuilder<SymptomEntry>? _entries;
  ListBuilder<SymptomEntry> get entries =>
      _$this._entries ??= ListBuilder<SymptomEntry>();
  set entries(ListBuilder<SymptomEntry>? entries) => _$this._entries = entries;

  MemberSymptomsGet200ResponseBuilder() {
    MemberSymptomsGet200Response._defaults(this);
  }

  MemberSymptomsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entries = $v.entries?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberSymptomsGet200Response other) {
    _$v = other as _$MemberSymptomsGet200Response;
  }

  @override
  void update(void Function(MemberSymptomsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberSymptomsGet200Response build() => _build();

  _$MemberSymptomsGet200Response _build() {
    _$MemberSymptomsGet200Response _$result;
    try {
      _$result =
          _$v ?? _$MemberSymptomsGet200Response._(entries: _entries?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entries';
        _entries?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberSymptomsGet200Response',
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
