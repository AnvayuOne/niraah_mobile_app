// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_symptoms_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberSymptomsPostRequest extends MemberSymptomsPostRequest {
  @override
  final String symptom;
  @override
  final num intensity;
  @override
  final String? notes;

  factory _$MemberSymptomsPostRequest([
    void Function(MemberSymptomsPostRequestBuilder)? updates,
  ]) => (MemberSymptomsPostRequestBuilder()..update(updates))._build();

  _$MemberSymptomsPostRequest._({
    required this.symptom,
    required this.intensity,
    this.notes,
  }) : super._();
  @override
  MemberSymptomsPostRequest rebuild(
    void Function(MemberSymptomsPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberSymptomsPostRequestBuilder toBuilder() =>
      MemberSymptomsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberSymptomsPostRequest &&
        symptom == other.symptom &&
        intensity == other.intensity &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, symptom.hashCode);
    _$hash = $jc(_$hash, intensity.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberSymptomsPostRequest')
          ..add('symptom', symptom)
          ..add('intensity', intensity)
          ..add('notes', notes))
        .toString();
  }
}

class MemberSymptomsPostRequestBuilder
    implements
        Builder<MemberSymptomsPostRequest, MemberSymptomsPostRequestBuilder> {
  _$MemberSymptomsPostRequest? _$v;

  String? _symptom;
  String? get symptom => _$this._symptom;
  set symptom(String? symptom) => _$this._symptom = symptom;

  num? _intensity;
  num? get intensity => _$this._intensity;
  set intensity(num? intensity) => _$this._intensity = intensity;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  MemberSymptomsPostRequestBuilder() {
    MemberSymptomsPostRequest._defaults(this);
  }

  MemberSymptomsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _symptom = $v.symptom;
      _intensity = $v.intensity;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberSymptomsPostRequest other) {
    _$v = other as _$MemberSymptomsPostRequest;
  }

  @override
  void update(void Function(MemberSymptomsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberSymptomsPostRequest build() => _build();

  _$MemberSymptomsPostRequest _build() {
    final _$result =
        _$v ??
        _$MemberSymptomsPostRequest._(
          symptom: BuiltValueNullFieldError.checkNotNull(
            symptom,
            r'MemberSymptomsPostRequest',
            'symptom',
          ),
          intensity: BuiltValueNullFieldError.checkNotNull(
            intensity,
            r'MemberSymptomsPostRequest',
            'intensity',
          ),
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
