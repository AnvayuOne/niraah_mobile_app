// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom_entry_symptoms.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SymptomEntrySymptoms extends SymptomEntrySymptoms {
  @override
  final String? symptom;
  @override
  final num? intensity;

  factory _$SymptomEntrySymptoms([
    void Function(SymptomEntrySymptomsBuilder)? updates,
  ]) => (SymptomEntrySymptomsBuilder()..update(updates))._build();

  _$SymptomEntrySymptoms._({this.symptom, this.intensity}) : super._();
  @override
  SymptomEntrySymptoms rebuild(
    void Function(SymptomEntrySymptomsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SymptomEntrySymptomsBuilder toBuilder() =>
      SymptomEntrySymptomsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SymptomEntrySymptoms &&
        symptom == other.symptom &&
        intensity == other.intensity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, symptom.hashCode);
    _$hash = $jc(_$hash, intensity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SymptomEntrySymptoms')
          ..add('symptom', symptom)
          ..add('intensity', intensity))
        .toString();
  }
}

class SymptomEntrySymptomsBuilder
    implements Builder<SymptomEntrySymptoms, SymptomEntrySymptomsBuilder> {
  _$SymptomEntrySymptoms? _$v;

  String? _symptom;
  String? get symptom => _$this._symptom;
  set symptom(String? symptom) => _$this._symptom = symptom;

  num? _intensity;
  num? get intensity => _$this._intensity;
  set intensity(num? intensity) => _$this._intensity = intensity;

  SymptomEntrySymptomsBuilder() {
    SymptomEntrySymptoms._defaults(this);
  }

  SymptomEntrySymptomsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _symptom = $v.symptom;
      _intensity = $v.intensity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SymptomEntrySymptoms other) {
    _$v = other as _$SymptomEntrySymptoms;
  }

  @override
  void update(void Function(SymptomEntrySymptomsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SymptomEntrySymptoms build() => _build();

  _$SymptomEntrySymptoms _build() {
    final _$result =
        _$v ?? _$SymptomEntrySymptoms._(symptom: symptom, intensity: intensity);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
