// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_profile_get200_response_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminProfileGet200ResponseUser extends AdminProfileGet200ResponseUser {
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? phone;

  factory _$AdminProfileGet200ResponseUser([
    void Function(AdminProfileGet200ResponseUserBuilder)? updates,
  ]) => (AdminProfileGet200ResponseUserBuilder()..update(updates))._build();

  _$AdminProfileGet200ResponseUser._({this.name, this.email, this.phone})
    : super._();
  @override
  AdminProfileGet200ResponseUser rebuild(
    void Function(AdminProfileGet200ResponseUserBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminProfileGet200ResponseUserBuilder toBuilder() =>
      AdminProfileGet200ResponseUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminProfileGet200ResponseUser &&
        name == other.name &&
        email == other.email &&
        phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminProfileGet200ResponseUser')
          ..add('name', name)
          ..add('email', email)
          ..add('phone', phone))
        .toString();
  }
}

class AdminProfileGet200ResponseUserBuilder
    implements
        Builder<
          AdminProfileGet200ResponseUser,
          AdminProfileGet200ResponseUserBuilder
        > {
  _$AdminProfileGet200ResponseUser? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  AdminProfileGet200ResponseUserBuilder() {
    AdminProfileGet200ResponseUser._defaults(this);
  }

  AdminProfileGet200ResponseUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _email = $v.email;
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminProfileGet200ResponseUser other) {
    _$v = other as _$AdminProfileGet200ResponseUser;
  }

  @override
  void update(void Function(AdminProfileGet200ResponseUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminProfileGet200ResponseUser build() => _build();

  _$AdminProfileGet200ResponseUser _build() {
    final _$result =
        _$v ??
        _$AdminProfileGet200ResponseUser._(
          name: name,
          email: email,
          phone: phone,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
