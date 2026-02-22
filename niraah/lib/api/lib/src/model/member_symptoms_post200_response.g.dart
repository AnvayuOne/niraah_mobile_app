// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_symptoms_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberSymptomsPost200Response extends MemberSymptomsPost200Response {
  @override
  final bool? ok;
  @override
  final SymptomEntry? entry;

  factory _$MemberSymptomsPost200Response([
    void Function(MemberSymptomsPost200ResponseBuilder)? updates,
  ]) => (MemberSymptomsPost200ResponseBuilder()..update(updates))._build();

  _$MemberSymptomsPost200Response._({this.ok, this.entry}) : super._();
  @override
  MemberSymptomsPost200Response rebuild(
    void Function(MemberSymptomsPost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberSymptomsPost200ResponseBuilder toBuilder() =>
      MemberSymptomsPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberSymptomsPost200Response &&
        ok == other.ok &&
        entry == other.entry;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, entry.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberSymptomsPost200Response')
          ..add('ok', ok)
          ..add('entry', entry))
        .toString();
  }
}

class MemberSymptomsPost200ResponseBuilder
    implements
        Builder<
          MemberSymptomsPost200Response,
          MemberSymptomsPost200ResponseBuilder
        > {
  _$MemberSymptomsPost200Response? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  SymptomEntryBuilder? _entry;
  SymptomEntryBuilder get entry => _$this._entry ??= SymptomEntryBuilder();
  set entry(SymptomEntryBuilder? entry) => _$this._entry = entry;

  MemberSymptomsPost200ResponseBuilder() {
    MemberSymptomsPost200Response._defaults(this);
  }

  MemberSymptomsPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ok = $v.ok;
      _entry = $v.entry?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberSymptomsPost200Response other) {
    _$v = other as _$MemberSymptomsPost200Response;
  }

  @override
  void update(void Function(MemberSymptomsPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberSymptomsPost200Response build() => _build();

  _$MemberSymptomsPost200Response _build() {
    _$MemberSymptomsPost200Response _$result;
    try {
      _$result =
          _$v ??
          _$MemberSymptomsPost200Response._(ok: ok, entry: _entry?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entry';
        _entry?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberSymptomsPost200Response',
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
