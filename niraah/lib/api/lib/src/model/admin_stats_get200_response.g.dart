// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminStatsGet200Response extends AdminStatsGet200Response {
  @override
  final num? members;
  @override
  final num? appointments;
  @override
  final BuiltList<AdminStatsGet200ResponseRecentMembersInner>? recentMembers;

  factory _$AdminStatsGet200Response([
    void Function(AdminStatsGet200ResponseBuilder)? updates,
  ]) => (AdminStatsGet200ResponseBuilder()..update(updates))._build();

  _$AdminStatsGet200Response._({
    this.members,
    this.appointments,
    this.recentMembers,
  }) : super._();
  @override
  AdminStatsGet200Response rebuild(
    void Function(AdminStatsGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminStatsGet200ResponseBuilder toBuilder() =>
      AdminStatsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminStatsGet200Response &&
        members == other.members &&
        appointments == other.appointments &&
        recentMembers == other.recentMembers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, members.hashCode);
    _$hash = $jc(_$hash, appointments.hashCode);
    _$hash = $jc(_$hash, recentMembers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminStatsGet200Response')
          ..add('members', members)
          ..add('appointments', appointments)
          ..add('recentMembers', recentMembers))
        .toString();
  }
}

class AdminStatsGet200ResponseBuilder
    implements
        Builder<AdminStatsGet200Response, AdminStatsGet200ResponseBuilder> {
  _$AdminStatsGet200Response? _$v;

  num? _members;
  num? get members => _$this._members;
  set members(num? members) => _$this._members = members;

  num? _appointments;
  num? get appointments => _$this._appointments;
  set appointments(num? appointments) => _$this._appointments = appointments;

  ListBuilder<AdminStatsGet200ResponseRecentMembersInner>? _recentMembers;
  ListBuilder<AdminStatsGet200ResponseRecentMembersInner> get recentMembers =>
      _$this._recentMembers ??=
          ListBuilder<AdminStatsGet200ResponseRecentMembersInner>();
  set recentMembers(
    ListBuilder<AdminStatsGet200ResponseRecentMembersInner>? recentMembers,
  ) => _$this._recentMembers = recentMembers;

  AdminStatsGet200ResponseBuilder() {
    AdminStatsGet200Response._defaults(this);
  }

  AdminStatsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _members = $v.members;
      _appointments = $v.appointments;
      _recentMembers = $v.recentMembers?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminStatsGet200Response other) {
    _$v = other as _$AdminStatsGet200Response;
  }

  @override
  void update(void Function(AdminStatsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminStatsGet200Response build() => _build();

  _$AdminStatsGet200Response _build() {
    _$AdminStatsGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminStatsGet200Response._(
            members: members,
            appointments: appointments,
            recentMembers: _recentMembers?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'recentMembers';
        _recentMembers?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminStatsGet200Response',
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
