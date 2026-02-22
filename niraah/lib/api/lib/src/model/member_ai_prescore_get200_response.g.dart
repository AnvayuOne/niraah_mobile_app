// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_ai_prescore_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberAiPrescoreGet200Response extends MemberAiPrescoreGet200Response {
  @override
  final num? total;
  @override
  final String? risk;
  @override
  final BuiltList<String>? flags;
  @override
  final String? aiInsights;

  factory _$MemberAiPrescoreGet200Response([
    void Function(MemberAiPrescoreGet200ResponseBuilder)? updates,
  ]) => (MemberAiPrescoreGet200ResponseBuilder()..update(updates))._build();

  _$MemberAiPrescoreGet200Response._({
    this.total,
    this.risk,
    this.flags,
    this.aiInsights,
  }) : super._();
  @override
  MemberAiPrescoreGet200Response rebuild(
    void Function(MemberAiPrescoreGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberAiPrescoreGet200ResponseBuilder toBuilder() =>
      MemberAiPrescoreGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberAiPrescoreGet200Response &&
        total == other.total &&
        risk == other.risk &&
        flags == other.flags &&
        aiInsights == other.aiInsights;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, risk.hashCode);
    _$hash = $jc(_$hash, flags.hashCode);
    _$hash = $jc(_$hash, aiInsights.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberAiPrescoreGet200Response')
          ..add('total', total)
          ..add('risk', risk)
          ..add('flags', flags)
          ..add('aiInsights', aiInsights))
        .toString();
  }
}

class MemberAiPrescoreGet200ResponseBuilder
    implements
        Builder<
          MemberAiPrescoreGet200Response,
          MemberAiPrescoreGet200ResponseBuilder
        > {
  _$MemberAiPrescoreGet200Response? _$v;

  num? _total;
  num? get total => _$this._total;
  set total(num? total) => _$this._total = total;

  String? _risk;
  String? get risk => _$this._risk;
  set risk(String? risk) => _$this._risk = risk;

  ListBuilder<String>? _flags;
  ListBuilder<String> get flags => _$this._flags ??= ListBuilder<String>();
  set flags(ListBuilder<String>? flags) => _$this._flags = flags;

  String? _aiInsights;
  String? get aiInsights => _$this._aiInsights;
  set aiInsights(String? aiInsights) => _$this._aiInsights = aiInsights;

  MemberAiPrescoreGet200ResponseBuilder() {
    MemberAiPrescoreGet200Response._defaults(this);
  }

  MemberAiPrescoreGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _risk = $v.risk;
      _flags = $v.flags?.toBuilder();
      _aiInsights = $v.aiInsights;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberAiPrescoreGet200Response other) {
    _$v = other as _$MemberAiPrescoreGet200Response;
  }

  @override
  void update(void Function(MemberAiPrescoreGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberAiPrescoreGet200Response build() => _build();

  _$MemberAiPrescoreGet200Response _build() {
    _$MemberAiPrescoreGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$MemberAiPrescoreGet200Response._(
            total: total,
            risk: risk,
            flags: _flags?.build(),
            aiInsights: aiInsights,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'flags';
        _flags?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberAiPrescoreGet200Response',
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
