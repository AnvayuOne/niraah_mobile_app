// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserRoleEnum _$userRoleEnum_MEMBER = const UserRoleEnum._('MEMBER');
const UserRoleEnum _$userRoleEnum_DOCTOR = const UserRoleEnum._('DOCTOR');
const UserRoleEnum _$userRoleEnum_DIETICIAN = const UserRoleEnum._('DIETICIAN');
const UserRoleEnum _$userRoleEnum_ADMIN = const UserRoleEnum._('ADMIN');

UserRoleEnum _$userRoleEnumValueOf(String name) {
  switch (name) {
    case 'MEMBER':
      return _$userRoleEnum_MEMBER;
    case 'DOCTOR':
      return _$userRoleEnum_DOCTOR;
    case 'DIETICIAN':
      return _$userRoleEnum_DIETICIAN;
    case 'ADMIN':
      return _$userRoleEnum_ADMIN;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UserRoleEnum> _$userRoleEnumValues =
    BuiltSet<UserRoleEnum>(const <UserRoleEnum>[
      _$userRoleEnum_MEMBER,
      _$userRoleEnum_DOCTOR,
      _$userRoleEnum_DIETICIAN,
      _$userRoleEnum_ADMIN,
    ]);

Serializer<UserRoleEnum> _$userRoleEnumSerializer = _$UserRoleEnumSerializer();

class _$UserRoleEnumSerializer implements PrimitiveSerializer<UserRoleEnum> {
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
  final Iterable<Type> types = const <Type>[UserRoleEnum];
  @override
  final String wireName = 'UserRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    UserRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UserRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UserRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$User extends User {
  @override
  final String? id;
  @override
  final String? phone;
  @override
  final String? name;
  @override
  final UserRoleEnum? role;

  factory _$User([void Function(UserBuilder)? updates]) =>
      (UserBuilder()..update(updates))._build();

  _$User._({this.id, this.phone, this.name, this.role}) : super._();
  @override
  User rebuild(void Function(UserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserBuilder toBuilder() => UserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
        id == other.id &&
        phone == other.phone &&
        name == other.name &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'User')
          ..add('id', id)
          ..add('phone', phone)
          ..add('name', name)
          ..add('role', role))
        .toString();
  }
}

class UserBuilder implements Builder<User, UserBuilder> {
  _$User? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  UserRoleEnum? _role;
  UserRoleEnum? get role => _$this._role;
  set role(UserRoleEnum? role) => _$this._role = role;

  UserBuilder() {
    User._defaults(this);
  }

  UserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _phone = $v.phone;
      _name = $v.name;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(User other) {
    _$v = other as _$User;
  }

  @override
  void update(void Function(UserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  User build() => _build();

  _$User _build() {
    final _$result =
        _$v ?? _$User._(id: id, phone: phone, name: name, role: role);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
