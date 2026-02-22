// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request_otp_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthRequestOtpPost200Response extends AuthRequestOtpPost200Response {
  @override
  final bool? ok;
  @override
  final String? code;

  factory _$AuthRequestOtpPost200Response([
    void Function(AuthRequestOtpPost200ResponseBuilder)? updates,
  ]) => (AuthRequestOtpPost200ResponseBuilder()..update(updates))._build();

  _$AuthRequestOtpPost200Response._({this.ok, this.code}) : super._();
  @override
  AuthRequestOtpPost200Response rebuild(
    void Function(AuthRequestOtpPost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthRequestOtpPost200ResponseBuilder toBuilder() =>
      AuthRequestOtpPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRequestOtpPost200Response &&
        ok == other.ok &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthRequestOtpPost200Response')
          ..add('ok', ok)
          ..add('code', code))
        .toString();
  }
}

class AuthRequestOtpPost200ResponseBuilder
    implements
        Builder<
          AuthRequestOtpPost200Response,
          AuthRequestOtpPost200ResponseBuilder
        > {
  _$AuthRequestOtpPost200Response? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  AuthRequestOtpPost200ResponseBuilder() {
    AuthRequestOtpPost200Response._defaults(this);
  }

  AuthRequestOtpPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ok = $v.ok;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthRequestOtpPost200Response other) {
    _$v = other as _$AuthRequestOtpPost200Response;
  }

  @override
  void update(void Function(AuthRequestOtpPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthRequestOtpPost200Response build() => _build();

  _$AuthRequestOtpPost200Response _build() {
    final _$result =
        _$v ?? _$AuthRequestOtpPost200Response._(ok: ok, code: code);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
