// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_tests_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MemberTestsGet200Response extends MemberTestsGet200Response {
  @override
  final BuiltList<MemberTestsGet200ResponseAttachmentsInner>? attachments;

  factory _$MemberTestsGet200Response([
    void Function(MemberTestsGet200ResponseBuilder)? updates,
  ]) => (MemberTestsGet200ResponseBuilder()..update(updates))._build();

  _$MemberTestsGet200Response._({this.attachments}) : super._();
  @override
  MemberTestsGet200Response rebuild(
    void Function(MemberTestsGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberTestsGet200ResponseBuilder toBuilder() =>
      MemberTestsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberTestsGet200Response &&
        attachments == other.attachments;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, attachments.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'MemberTestsGet200Response',
    )..add('attachments', attachments)).toString();
  }
}

class MemberTestsGet200ResponseBuilder
    implements
        Builder<MemberTestsGet200Response, MemberTestsGet200ResponseBuilder> {
  _$MemberTestsGet200Response? _$v;

  ListBuilder<MemberTestsGet200ResponseAttachmentsInner>? _attachments;
  ListBuilder<MemberTestsGet200ResponseAttachmentsInner> get attachments =>
      _$this._attachments ??=
          ListBuilder<MemberTestsGet200ResponseAttachmentsInner>();
  set attachments(
    ListBuilder<MemberTestsGet200ResponseAttachmentsInner>? attachments,
  ) => _$this._attachments = attachments;

  MemberTestsGet200ResponseBuilder() {
    MemberTestsGet200Response._defaults(this);
  }

  MemberTestsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _attachments = $v.attachments?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberTestsGet200Response other) {
    _$v = other as _$MemberTestsGet200Response;
  }

  @override
  void update(void Function(MemberTestsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberTestsGet200Response build() => _build();

  _$MemberTestsGet200Response _build() {
    _$MemberTestsGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$MemberTestsGet200Response._(attachments: _attachments?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'attachments';
        _attachments?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberTestsGet200Response',
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
