// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_get200_response_recent_members_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminStatsGet200ResponseRecentMembersInner
    extends AdminStatsGet200ResponseRecentMembersInner {
  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? createdAt;
  @override
  final String? role;

  factory _$AdminStatsGet200ResponseRecentMembersInner([
    void Function(AdminStatsGet200ResponseRecentMembersInnerBuilder)? updates,
  ]) => (AdminStatsGet200ResponseRecentMembersInnerBuilder()..update(updates))
      ._build();

  _$AdminStatsGet200ResponseRecentMembersInner._({
    this.id,
    this.name,
    this.createdAt,
    this.role,
  }) : super._();
  @override
  AdminStatsGet200ResponseRecentMembersInner rebuild(
    void Function(AdminStatsGet200ResponseRecentMembersInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminStatsGet200ResponseRecentMembersInnerBuilder toBuilder() =>
      AdminStatsGet200ResponseRecentMembersInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminStatsGet200ResponseRecentMembersInner &&
        id == other.id &&
        name == other.name &&
        createdAt == other.createdAt &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminStatsGet200ResponseRecentMembersInner',
          )
          ..add('id', id)
          ..add('name', name)
          ..add('createdAt', createdAt)
          ..add('role', role))
        .toString();
  }
}

class AdminStatsGet200ResponseRecentMembersInnerBuilder
    implements
        Builder<
          AdminStatsGet200ResponseRecentMembersInner,
          AdminStatsGet200ResponseRecentMembersInnerBuilder
        > {
  _$AdminStatsGet200ResponseRecentMembersInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  String? _role;
  String? get role => _$this._role;
  set role(String? role) => _$this._role = role;

  AdminStatsGet200ResponseRecentMembersInnerBuilder() {
    AdminStatsGet200ResponseRecentMembersInner._defaults(this);
  }

  AdminStatsGet200ResponseRecentMembersInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _createdAt = $v.createdAt;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminStatsGet200ResponseRecentMembersInner other) {
    _$v = other as _$AdminStatsGet200ResponseRecentMembersInner;
  }

  @override
  void update(
    void Function(AdminStatsGet200ResponseRecentMembersInnerBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminStatsGet200ResponseRecentMembersInner build() => _build();

  _$AdminStatsGet200ResponseRecentMembersInner _build() {
    final _$result =
        _$v ??
        _$AdminStatsGet200ResponseRecentMembersInner._(
          id: id,
          name: name,
          createdAt: createdAt,
          role: role,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
