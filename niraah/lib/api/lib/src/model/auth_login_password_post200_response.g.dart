// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login_password_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthLoginPasswordPost200Response
    extends AuthLoginPasswordPost200Response {
  @override
  final String? token;
  @override
  final User? user;

  factory _$AuthLoginPasswordPost200Response([
    void Function(AuthLoginPasswordPost200ResponseBuilder)? updates,
  ]) => (AuthLoginPasswordPost200ResponseBuilder()..update(updates))._build();

  _$AuthLoginPasswordPost200Response._({this.token, this.user}) : super._();
  @override
  AuthLoginPasswordPost200Response rebuild(
    void Function(AuthLoginPasswordPost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthLoginPasswordPost200ResponseBuilder toBuilder() =>
      AuthLoginPasswordPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthLoginPasswordPost200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthLoginPasswordPost200Response')
          ..add('token', token)
          ..add('user', user))
        .toString();
  }
}

class AuthLoginPasswordPost200ResponseBuilder
    implements
        Builder<
          AuthLoginPasswordPost200Response,
          AuthLoginPasswordPost200ResponseBuilder
        > {
  _$AuthLoginPasswordPost200Response? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  UserBuilder? _user;
  UserBuilder get user => _$this._user ??= UserBuilder();
  set user(UserBuilder? user) => _$this._user = user;

  AuthLoginPasswordPost200ResponseBuilder() {
    AuthLoginPasswordPost200Response._defaults(this);
  }

  AuthLoginPasswordPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _user = $v.user?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthLoginPasswordPost200Response other) {
    _$v = other as _$AuthLoginPasswordPost200Response;
  }

  @override
  void update(void Function(AuthLoginPasswordPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthLoginPasswordPost200Response build() => _build();

  _$AuthLoginPasswordPost200Response _build() {
    _$AuthLoginPasswordPost200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthLoginPasswordPost200Response._(
            token: token,
            user: _user?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        _user?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AuthLoginPasswordPost200Response',
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
