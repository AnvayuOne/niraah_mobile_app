// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_profile_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberProfilePost200Response extends MemberProfilePost200Response {
  @override
  final bool? ok;

  factory _$MemberProfilePost200Response([
    void Function(MemberProfilePost200ResponseBuilder)? updates,
  ]) => (MemberProfilePost200ResponseBuilder()..update(updates))._build();

  _$MemberProfilePost200Response._({this.ok}) : super._();
  @override
  MemberProfilePost200Response rebuild(
    void Function(MemberProfilePost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberProfilePost200ResponseBuilder toBuilder() =>
      MemberProfilePost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberProfilePost200Response && ok == other.ok;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'MemberProfilePost200Response',
    )..add('ok', ok)).toString();
  }
}

class MemberProfilePost200ResponseBuilder
    implements
        Builder<
          MemberProfilePost200Response,
          MemberProfilePost200ResponseBuilder
        > {
  _$MemberProfilePost200Response? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  MemberProfilePost200ResponseBuilder() {
    MemberProfilePost200Response._defaults(this);
  }

  MemberProfilePost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ok = $v.ok;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberProfilePost200Response other) {
    _$v = other as _$MemberProfilePost200Response;
  }

  @override
  void update(void Function(MemberProfilePost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberProfilePost200Response build() => _build();

  _$MemberProfilePost200Response _build() {
    final _$result = _$v ?? _$MemberProfilePost200Response._(ok: ok);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
