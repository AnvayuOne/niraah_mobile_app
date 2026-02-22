// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_profile_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminProfileGet200Response extends AdminProfileGet200Response {
  @override
  final AdminProfileGet200ResponseUser? user;

  factory _$AdminProfileGet200Response([
    void Function(AdminProfileGet200ResponseBuilder)? updates,
  ]) => (AdminProfileGet200ResponseBuilder()..update(updates))._build();

  _$AdminProfileGet200Response._({this.user}) : super._();
  @override
  AdminProfileGet200Response rebuild(
    void Function(AdminProfileGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminProfileGet200ResponseBuilder toBuilder() =>
      AdminProfileGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminProfileGet200Response && user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'AdminProfileGet200Response',
    )..add('user', user)).toString();
  }
}

class AdminProfileGet200ResponseBuilder
    implements
        Builder<AdminProfileGet200Response, AdminProfileGet200ResponseBuilder> {
  _$AdminProfileGet200Response? _$v;

  AdminProfileGet200ResponseUserBuilder? _user;
  AdminProfileGet200ResponseUserBuilder get user =>
      _$this._user ??= AdminProfileGet200ResponseUserBuilder();
  set user(AdminProfileGet200ResponseUserBuilder? user) => _$this._user = user;

  AdminProfileGet200ResponseBuilder() {
    AdminProfileGet200Response._defaults(this);
  }

  AdminProfileGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminProfileGet200Response other) {
    _$v = other as _$AdminProfileGet200Response;
  }

  @override
  void update(void Function(AdminProfileGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminProfileGet200Response build() => _build();

  _$AdminProfileGet200Response _build() {
    _$AdminProfileGet200Response _$result;
    try {
      _$result = _$v ?? _$AdminProfileGet200Response._(user: _user?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        _user?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminProfileGet200Response',
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
