// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HealthGet200Response extends HealthGet200Response {
  @override
  final bool? ok;
  @override
  final String? name;

  factory _$HealthGet200Response([
    void Function(HealthGet200ResponseBuilder)? updates,
  ]) => (HealthGet200ResponseBuilder()..update(updates))._build();

  _$HealthGet200Response._({this.ok, this.name}) : super._();
  @override
  HealthGet200Response rebuild(
    void Function(HealthGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  HealthGet200ResponseBuilder toBuilder() =>
      HealthGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HealthGet200Response &&
        ok == other.ok &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HealthGet200Response')
          ..add('ok', ok)
          ..add('name', name))
        .toString();
  }
}

class HealthGet200ResponseBuilder
    implements Builder<HealthGet200Response, HealthGet200ResponseBuilder> {
  _$HealthGet200Response? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  HealthGet200ResponseBuilder() {
    HealthGet200Response._defaults(this);
  }

  HealthGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ok = $v.ok;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HealthGet200Response other) {
    _$v = other as _$HealthGet200Response;
  }

  @override
  void update(void Function(HealthGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HealthGet200Response build() => _build();

  _$HealthGet200Response _build() {
    final _$result = _$v ?? _$HealthGet200Response._(ok: ok, name: name);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
