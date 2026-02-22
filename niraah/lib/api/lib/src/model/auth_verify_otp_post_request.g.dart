// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_verify_otp_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthVerifyOtpPostRequest extends AuthVerifyOtpPostRequest {
  @override
  final String phone;
  @override
  final String code;

  factory _$AuthVerifyOtpPostRequest([
    void Function(AuthVerifyOtpPostRequestBuilder)? updates,
  ]) => (AuthVerifyOtpPostRequestBuilder()..update(updates))._build();

  _$AuthVerifyOtpPostRequest._({required this.phone, required this.code})
    : super._();
  @override
  AuthVerifyOtpPostRequest rebuild(
    void Function(AuthVerifyOtpPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthVerifyOtpPostRequestBuilder toBuilder() =>
      AuthVerifyOtpPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthVerifyOtpPostRequest &&
        phone == other.phone &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthVerifyOtpPostRequest')
          ..add('phone', phone)
          ..add('code', code))
        .toString();
  }
}

class AuthVerifyOtpPostRequestBuilder
    implements
        Builder<AuthVerifyOtpPostRequest, AuthVerifyOtpPostRequestBuilder> {
  _$AuthVerifyOtpPostRequest? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  AuthVerifyOtpPostRequestBuilder() {
    AuthVerifyOtpPostRequest._defaults(this);
  }

  AuthVerifyOtpPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthVerifyOtpPostRequest other) {
    _$v = other as _$AuthVerifyOtpPostRequest;
  }

  @override
  void update(void Function(AuthVerifyOtpPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthVerifyOtpPostRequest build() => _build();

  _$AuthVerifyOtpPostRequest _build() {
    final _$result =
        _$v ??
        _$AuthVerifyOtpPostRequest._(
          phone: BuiltValueNullFieldError.checkNotNull(
            phone,
            r'AuthVerifyOtpPostRequest',
            'phone',
          ),
          code: BuiltValueNullFieldError.checkNotNull(
            code,
            r'AuthVerifyOtpPostRequest',
            'code',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
