// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_verify_otp_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthVerifyOtpPost200Response extends AuthVerifyOtpPost200Response {
  @override
  final String? token;
  @override
  final User? user;

  factory _$AuthVerifyOtpPost200Response([
    void Function(AuthVerifyOtpPost200ResponseBuilder)? updates,
  ]) => (AuthVerifyOtpPost200ResponseBuilder()..update(updates))._build();

  _$AuthVerifyOtpPost200Response._({this.token, this.user}) : super._();
  @override
  AuthVerifyOtpPost200Response rebuild(
    void Function(AuthVerifyOtpPost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthVerifyOtpPost200ResponseBuilder toBuilder() =>
      AuthVerifyOtpPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthVerifyOtpPost200Response &&
        token == other.token &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthVerifyOtpPost200Response')
          ..add('token', token)
          ..add('user', user))
        .toString();
  }
}

class AuthVerifyOtpPost200ResponseBuilder
    implements
        Builder<
          AuthVerifyOtpPost200Response,
          AuthVerifyOtpPost200ResponseBuilder
        > {
  _$AuthVerifyOtpPost200Response? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  UserBuilder? _user;
  UserBuilder get user => _$this._user ??= UserBuilder();
  set user(UserBuilder? user) => _$this._user = user;

  AuthVerifyOtpPost200ResponseBuilder() {
    AuthVerifyOtpPost200Response._defaults(this);
  }

  AuthVerifyOtpPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _user = $v.user?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthVerifyOtpPost200Response other) {
    _$v = other as _$AuthVerifyOtpPost200Response;
  }

  @override
  void update(void Function(AuthVerifyOtpPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthVerifyOtpPost200Response build() => _build();

  _$AuthVerifyOtpPost200Response _build() {
    _$AuthVerifyOtpPost200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthVerifyOtpPost200Response._(token: token, user: _user?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        _user?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AuthVerifyOtpPost200Response',
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
