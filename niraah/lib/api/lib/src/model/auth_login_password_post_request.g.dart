// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login_password_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthLoginPasswordPostRequestRoleEnum
_$authLoginPasswordPostRequestRoleEnum_DOCTOR =
    const AuthLoginPasswordPostRequestRoleEnum._('DOCTOR');
const AuthLoginPasswordPostRequestRoleEnum
_$authLoginPasswordPostRequestRoleEnum_ADMIN =
    const AuthLoginPasswordPostRequestRoleEnum._('ADMIN');
const AuthLoginPasswordPostRequestRoleEnum
_$authLoginPasswordPostRequestRoleEnum_OTHER =
    const AuthLoginPasswordPostRequestRoleEnum._('OTHER');

AuthLoginPasswordPostRequestRoleEnum
_$authLoginPasswordPostRequestRoleEnumValueOf(String name) {
  switch (name) {
    case 'DOCTOR':
      return _$authLoginPasswordPostRequestRoleEnum_DOCTOR;
    case 'ADMIN':
      return _$authLoginPasswordPostRequestRoleEnum_ADMIN;
    case 'OTHER':
      return _$authLoginPasswordPostRequestRoleEnum_OTHER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AuthLoginPasswordPostRequestRoleEnum>
_$authLoginPasswordPostRequestRoleEnumValues =
    BuiltSet<AuthLoginPasswordPostRequestRoleEnum>(
      const <AuthLoginPasswordPostRequestRoleEnum>[
        _$authLoginPasswordPostRequestRoleEnum_DOCTOR,
        _$authLoginPasswordPostRequestRoleEnum_ADMIN,
        _$authLoginPasswordPostRequestRoleEnum_OTHER,
      ],
    );

Serializer<AuthLoginPasswordPostRequestRoleEnum>
_$authLoginPasswordPostRequestRoleEnumSerializer =
    _$AuthLoginPasswordPostRequestRoleEnumSerializer();

class _$AuthLoginPasswordPostRequestRoleEnumSerializer
    implements PrimitiveSerializer<AuthLoginPasswordPostRequestRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'DOCTOR': 'DOCTOR',
    'ADMIN': 'ADMIN',
    'OTHER': 'OTHER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'DOCTOR': 'DOCTOR',
    'ADMIN': 'ADMIN',
    'OTHER': 'OTHER',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AuthLoginPasswordPostRequestRoleEnum,
  ];
  @override
  final String wireName = 'AuthLoginPasswordPostRequestRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthLoginPasswordPostRequestRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthLoginPasswordPostRequestRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthLoginPasswordPostRequestRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthLoginPasswordPostRequest extends AuthLoginPasswordPostRequest {
  @override
  final String email;
  @override
  final String password;
  @override
  final AuthLoginPasswordPostRequestRoleEnum? role;

  factory _$AuthLoginPasswordPostRequest([
    void Function(AuthLoginPasswordPostRequestBuilder)? updates,
  ]) => (AuthLoginPasswordPostRequestBuilder()..update(updates))._build();

  _$AuthLoginPasswordPostRequest._({
    required this.email,
    required this.password,
    this.role,
  }) : super._();
  @override
  AuthLoginPasswordPostRequest rebuild(
    void Function(AuthLoginPasswordPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthLoginPasswordPostRequestBuilder toBuilder() =>
      AuthLoginPasswordPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthLoginPasswordPostRequest &&
        email == other.email &&
        password == other.password &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthLoginPasswordPostRequest')
          ..add('email', email)
          ..add('password', password)
          ..add('role', role))
        .toString();
  }
}

class AuthLoginPasswordPostRequestBuilder
    implements
        Builder<
          AuthLoginPasswordPostRequest,
          AuthLoginPasswordPostRequestBuilder
        > {
  _$AuthLoginPasswordPostRequest? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  AuthLoginPasswordPostRequestRoleEnum? _role;
  AuthLoginPasswordPostRequestRoleEnum? get role => _$this._role;
  set role(AuthLoginPasswordPostRequestRoleEnum? role) => _$this._role = role;

  AuthLoginPasswordPostRequestBuilder() {
    AuthLoginPasswordPostRequest._defaults(this);
  }

  AuthLoginPasswordPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _password = $v.password;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthLoginPasswordPostRequest other) {
    _$v = other as _$AuthLoginPasswordPostRequest;
  }

  @override
  void update(void Function(AuthLoginPasswordPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthLoginPasswordPostRequest build() => _build();

  _$AuthLoginPasswordPostRequest _build() {
    final _$result =
        _$v ??
        _$AuthLoginPasswordPostRequest._(
          email: BuiltValueNullFieldError.checkNotNull(
            email,
            r'AuthLoginPasswordPostRequest',
            'email',
          ),
          password: BuiltValueNullFieldError.checkNotNull(
            password,
            r'AuthLoginPasswordPostRequest',
            'password',
          ),
          role: role,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
