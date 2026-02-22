// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_profile_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberProfileGet200Response extends MemberProfileGet200Response {
  @override
  final MemberProfileGet200ResponseUser? user;
  @override
  final MemberProfileGet200ResponseProfile? profile;

  factory _$MemberProfileGet200Response([
    void Function(MemberProfileGet200ResponseBuilder)? updates,
  ]) => (MemberProfileGet200ResponseBuilder()..update(updates))._build();

  _$MemberProfileGet200Response._({this.user, this.profile}) : super._();
  @override
  MemberProfileGet200Response rebuild(
    void Function(MemberProfileGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberProfileGet200ResponseBuilder toBuilder() =>
      MemberProfileGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberProfileGet200Response &&
        user == other.user &&
        profile == other.profile;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, profile.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberProfileGet200Response')
          ..add('user', user)
          ..add('profile', profile))
        .toString();
  }
}

class MemberProfileGet200ResponseBuilder
    implements
        Builder<
          MemberProfileGet200Response,
          MemberProfileGet200ResponseBuilder
        > {
  _$MemberProfileGet200Response? _$v;

  MemberProfileGet200ResponseUserBuilder? _user;
  MemberProfileGet200ResponseUserBuilder get user =>
      _$this._user ??= MemberProfileGet200ResponseUserBuilder();
  set user(MemberProfileGet200ResponseUserBuilder? user) => _$this._user = user;

  MemberProfileGet200ResponseProfileBuilder? _profile;
  MemberProfileGet200ResponseProfileBuilder get profile =>
      _$this._profile ??= MemberProfileGet200ResponseProfileBuilder();
  set profile(MemberProfileGet200ResponseProfileBuilder? profile) =>
      _$this._profile = profile;

  MemberProfileGet200ResponseBuilder() {
    MemberProfileGet200Response._defaults(this);
  }

  MemberProfileGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user?.toBuilder();
      _profile = $v.profile?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberProfileGet200Response other) {
    _$v = other as _$MemberProfileGet200Response;
  }

  @override
  void update(void Function(MemberProfileGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberProfileGet200Response build() => _build();

  _$MemberProfileGet200Response _build() {
    _$MemberProfileGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$MemberProfileGet200Response._(
            user: _user?.build(),
            profile: _profile?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        _user?.build();
        _$failedField = 'profile';
        _profile?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberProfileGet200Response',
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
