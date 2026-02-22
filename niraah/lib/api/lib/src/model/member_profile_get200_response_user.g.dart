// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_profile_get200_response_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberProfileGet200ResponseUser
    extends MemberProfileGet200ResponseUser {
  @override
  final String? id;
  @override
  final String? name;

  factory _$MemberProfileGet200ResponseUser([
    void Function(MemberProfileGet200ResponseUserBuilder)? updates,
  ]) => (MemberProfileGet200ResponseUserBuilder()..update(updates))._build();

  _$MemberProfileGet200ResponseUser._({this.id, this.name}) : super._();
  @override
  MemberProfileGet200ResponseUser rebuild(
    void Function(MemberProfileGet200ResponseUserBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberProfileGet200ResponseUserBuilder toBuilder() =>
      MemberProfileGet200ResponseUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberProfileGet200ResponseUser &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberProfileGet200ResponseUser')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class MemberProfileGet200ResponseUserBuilder
    implements
        Builder<
          MemberProfileGet200ResponseUser,
          MemberProfileGet200ResponseUserBuilder
        > {
  _$MemberProfileGet200ResponseUser? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  MemberProfileGet200ResponseUserBuilder() {
    MemberProfileGet200ResponseUser._defaults(this);
  }

  MemberProfileGet200ResponseUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberProfileGet200ResponseUser other) {
    _$v = other as _$MemberProfileGet200ResponseUser;
  }

  @override
  void update(void Function(MemberProfileGet200ResponseUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberProfileGet200ResponseUser build() => _build();

  _$MemberProfileGet200ResponseUser _build() {
    final _$result =
        _$v ?? _$MemberProfileGet200ResponseUser._(id: id, name: name);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
