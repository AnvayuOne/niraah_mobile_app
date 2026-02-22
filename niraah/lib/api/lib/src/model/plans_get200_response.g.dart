// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plans_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlansGet200Response extends PlansGet200Response {
  @override
  final BuiltList<Plan>? plans;

  factory _$PlansGet200Response([
    void Function(PlansGet200ResponseBuilder)? updates,
  ]) => (PlansGet200ResponseBuilder()..update(updates))._build();

  _$PlansGet200Response._({this.plans}) : super._();
  @override
  PlansGet200Response rebuild(
    void Function(PlansGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PlansGet200ResponseBuilder toBuilder() =>
      PlansGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlansGet200Response && plans == other.plans;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plans.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'PlansGet200Response',
    )..add('plans', plans)).toString();
  }
}

class PlansGet200ResponseBuilder
    implements Builder<PlansGet200Response, PlansGet200ResponseBuilder> {
  _$PlansGet200Response? _$v;

  ListBuilder<Plan>? _plans;
  ListBuilder<Plan> get plans => _$this._plans ??= ListBuilder<Plan>();
  set plans(ListBuilder<Plan>? plans) => _$this._plans = plans;

  PlansGet200ResponseBuilder() {
    PlansGet200Response._defaults(this);
  }

  PlansGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plans = $v.plans?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlansGet200Response other) {
    _$v = other as _$PlansGet200Response;
  }

  @override
  void update(void Function(PlansGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlansGet200Response build() => _build();

  _$PlansGet200Response _build() {
    _$PlansGet200Response _$result;
    try {
      _$result = _$v ?? _$PlansGet200Response._(plans: _plans?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'plans';
        _plans?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'PlansGet200Response',
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
