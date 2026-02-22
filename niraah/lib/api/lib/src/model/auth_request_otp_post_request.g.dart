// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request_otp_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthRequestOtpPostRequestRoleEnum
_$authRequestOtpPostRequestRoleEnum_MEMBER =
    const AuthRequestOtpPostRequestRoleEnum._('MEMBER');
const AuthRequestOtpPostRequestRoleEnum
_$authRequestOtpPostRequestRoleEnum_DOCTOR =
    const AuthRequestOtpPostRequestRoleEnum._('DOCTOR');
const AuthRequestOtpPostRequestRoleEnum
_$authRequestOtpPostRequestRoleEnum_DIETICIAN =
    const AuthRequestOtpPostRequestRoleEnum._('DIETICIAN');
const AuthRequestOtpPostRequestRoleEnum
_$authRequestOtpPostRequestRoleEnum_ADMIN =
    const AuthRequestOtpPostRequestRoleEnum._('ADMIN');

AuthRequestOtpPostRequestRoleEnum _$authRequestOtpPostRequestRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'MEMBER':
      return _$authRequestOtpPostRequestRoleEnum_MEMBER;
    case 'DOCTOR':
      return _$authRequestOtpPostRequestRoleEnum_DOCTOR;
    case 'DIETICIAN':
      return _$authRequestOtpPostRequestRoleEnum_DIETICIAN;
    case 'ADMIN':
      return _$authRequestOtpPostRequestRoleEnum_ADMIN;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AuthRequestOtpPostRequestRoleEnum>
_$authRequestOtpPostRequestRoleEnumValues =
    BuiltSet<AuthRequestOtpPostRequestRoleEnum>(
      const <AuthRequestOtpPostRequestRoleEnum>[
        _$authRequestOtpPostRequestRoleEnum_MEMBER,
        _$authRequestOtpPostRequestRoleEnum_DOCTOR,
        _$authRequestOtpPostRequestRoleEnum_DIETICIAN,
        _$authRequestOtpPostRequestRoleEnum_ADMIN,
      ],
    );

Serializer<AuthRequestOtpPostRequestRoleEnum>
_$authRequestOtpPostRequestRoleEnumSerializer =
    _$AuthRequestOtpPostRequestRoleEnumSerializer();

class _$AuthRequestOtpPostRequestRoleEnumSerializer
    implements PrimitiveSerializer<AuthRequestOtpPostRequestRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'MEMBER': 'MEMBER',
    'DOCTOR': 'DOCTOR',
    'DIETICIAN': 'DIETICIAN',
    'ADMIN': 'ADMIN',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MEMBER': 'MEMBER',
    'DOCTOR': 'DOCTOR',
    'DIETICIAN': 'DIETICIAN',
    'ADMIN': 'ADMIN',
  };

  @override
  final Iterable<Type> types = const <Type>[AuthRequestOtpPostRequestRoleEnum];
  @override
  final String wireName = 'AuthRequestOtpPostRequestRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthRequestOtpPostRequestRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthRequestOtpPostRequestRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthRequestOtpPostRequestRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthRequestOtpPostRequest extends AuthRequestOtpPostRequest {
  @override
  final String phone;
  @override
  final bool? signup;
  @override
  final AuthRequestOtpPostRequestRoleEnum? role;

  factory _$AuthRequestOtpPostRequest([
    void Function(AuthRequestOtpPostRequestBuilder)? updates,
  ]) => (AuthRequestOtpPostRequestBuilder()..update(updates))._build();

  _$AuthRequestOtpPostRequest._({required this.phone, this.signup, this.role})
    : super._();
  @override
  AuthRequestOtpPostRequest rebuild(
    void Function(AuthRequestOtpPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthRequestOtpPostRequestBuilder toBuilder() =>
      AuthRequestOtpPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRequestOtpPostRequest &&
        phone == other.phone &&
        signup == other.signup &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, signup.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthRequestOtpPostRequest')
          ..add('phone', phone)
          ..add('signup', signup)
          ..add('role', role))
        .toString();
  }
}

class AuthRequestOtpPostRequestBuilder
    implements
        Builder<AuthRequestOtpPostRequest, AuthRequestOtpPostRequestBuilder> {
  _$AuthRequestOtpPostRequest? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  bool? _signup;
  bool? get signup => _$this._signup;
  set signup(bool? signup) => _$this._signup = signup;

  AuthRequestOtpPostRequestRoleEnum? _role;
  AuthRequestOtpPostRequestRoleEnum? get role => _$this._role;
  set role(AuthRequestOtpPostRequestRoleEnum? role) => _$this._role = role;

  AuthRequestOtpPostRequestBuilder() {
    AuthRequestOtpPostRequest._defaults(this);
  }

  AuthRequestOtpPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _signup = $v.signup;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthRequestOtpPostRequest other) {
    _$v = other as _$AuthRequestOtpPostRequest;
  }

  @override
  void update(void Function(AuthRequestOtpPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthRequestOtpPostRequest build() => _build();

  _$AuthRequestOtpPostRequest _build() {
    final _$result =
        _$v ??
        _$AuthRequestOtpPostRequest._(
          phone: BuiltValueNullFieldError.checkNotNull(
            phone,
            r'AuthRequestOtpPostRequest',
            'phone',
          ),
          signup: signup,
          role: role,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
