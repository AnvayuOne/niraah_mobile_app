// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plans_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlansPost200Response extends PlansPost200Response {
  @override
  final Plan? plan;

  factory _$PlansPost200Response([
    void Function(PlansPost200ResponseBuilder)? updates,
  ]) => (PlansPost200ResponseBuilder()..update(updates))._build();

  _$PlansPost200Response._({this.plan}) : super._();
  @override
  PlansPost200Response rebuild(
    void Function(PlansPost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PlansPost200ResponseBuilder toBuilder() =>
      PlansPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlansPost200Response && plan == other.plan;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'PlansPost200Response',
    )..add('plan', plan)).toString();
  }
}

class PlansPost200ResponseBuilder
    implements Builder<PlansPost200Response, PlansPost200ResponseBuilder> {
  _$PlansPost200Response? _$v;

  PlanBuilder? _plan;
  PlanBuilder get plan => _$this._plan ??= PlanBuilder();
  set plan(PlanBuilder? plan) => _$this._plan = plan;

  PlansPost200ResponseBuilder() {
    PlansPost200Response._defaults(this);
  }

  PlansPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plan = $v.plan?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlansPost200Response other) {
    _$v = other as _$PlansPost200Response;
  }

  @override
  void update(void Function(PlansPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlansPost200Response build() => _build();

  _$PlansPost200Response _build() {
    _$PlansPost200Response _$result;
    try {
      _$result = _$v ?? _$PlansPost200Response._(plan: _plan?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'plan';
        _plan?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'PlansPost200Response',
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
