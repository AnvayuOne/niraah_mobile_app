// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_tests_get200_response_attachments_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MemberTestsGet200ResponseAttachmentsInnerTypeEnum
_$memberTestsGet200ResponseAttachmentsInnerTypeEnum_REPORT =
    const MemberTestsGet200ResponseAttachmentsInnerTypeEnum._('REPORT');
const MemberTestsGet200ResponseAttachmentsInnerTypeEnum
_$memberTestsGet200ResponseAttachmentsInnerTypeEnum_IMAGE =
    const MemberTestsGet200ResponseAttachmentsInnerTypeEnum._('IMAGE');

MemberTestsGet200ResponseAttachmentsInnerTypeEnum
_$memberTestsGet200ResponseAttachmentsInnerTypeEnumValueOf(String name) {
  switch (name) {
    case 'REPORT':
      return _$memberTestsGet200ResponseAttachmentsInnerTypeEnum_REPORT;
    case 'IMAGE':
      return _$memberTestsGet200ResponseAttachmentsInnerTypeEnum_IMAGE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MemberTestsGet200ResponseAttachmentsInnerTypeEnum>
_$memberTestsGet200ResponseAttachmentsInnerTypeEnumValues =
    BuiltSet<MemberTestsGet200ResponseAttachmentsInnerTypeEnum>(
      const <MemberTestsGet200ResponseAttachmentsInnerTypeEnum>[
        _$memberTestsGet200ResponseAttachmentsInnerTypeEnum_REPORT,
        _$memberTestsGet200ResponseAttachmentsInnerTypeEnum_IMAGE,
      ],
    );

Serializer<MemberTestsGet200ResponseAttachmentsInnerTypeEnum>
_$memberTestsGet200ResponseAttachmentsInnerTypeEnumSerializer =
    _$MemberTestsGet200ResponseAttachmentsInnerTypeEnumSerializer();

class _$MemberTestsGet200ResponseAttachmentsInnerTypeEnumSerializer
    implements
        PrimitiveSerializer<MemberTestsGet200ResponseAttachmentsInnerTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'REPORT': 'REPORT',
    'IMAGE': 'IMAGE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'REPORT': 'REPORT',
    'IMAGE': 'IMAGE',
  };

  @override
  final Iterable<Type> types = const <Type>[
    MemberTestsGet200ResponseAttachmentsInnerTypeEnum,
  ];
  @override
  final String wireName = 'MemberTestsGet200ResponseAttachmentsInnerTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MemberTestsGet200ResponseAttachmentsInnerTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MemberTestsGet200ResponseAttachmentsInnerTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MemberTestsGet200ResponseAttachmentsInnerTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MemberTestsGet200ResponseAttachmentsInner
    extends MemberTestsGet200ResponseAttachmentsInner {
  @override
  final String? id;
  @override
  final MemberTestsGet200ResponseAttachmentsInnerTypeEnum? type;
  @override
  final String? r2Key;
  @override
  final String? url;
  @override
  final DateTime? uploadedAt;
  @override
  final MemberTestsGet200ResponseAttachmentsInnerUploader? uploader;

  factory _$MemberTestsGet200ResponseAttachmentsInner([
    void Function(MemberTestsGet200ResponseAttachmentsInnerBuilder)? updates,
  ]) => (MemberTestsGet200ResponseAttachmentsInnerBuilder()..update(updates))
      ._build();

  _$MemberTestsGet200ResponseAttachmentsInner._({
    this.id,
    this.type,
    this.r2Key,
    this.url,
    this.uploadedAt,
    this.uploader,
  }) : super._();
  @override
  MemberTestsGet200ResponseAttachmentsInner rebuild(
    void Function(MemberTestsGet200ResponseAttachmentsInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberTestsGet200ResponseAttachmentsInnerBuilder toBuilder() =>
      MemberTestsGet200ResponseAttachmentsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberTestsGet200ResponseAttachmentsInner &&
        id == other.id &&
        type == other.type &&
        r2Key == other.r2Key &&
        url == other.url &&
        uploadedAt == other.uploadedAt &&
        uploader == other.uploader;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, r2Key.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, uploadedAt.hashCode);
    _$hash = $jc(_$hash, uploader.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'MemberTestsGet200ResponseAttachmentsInner',
          )
          ..add('id', id)
          ..add('type', type)
          ..add('r2Key', r2Key)
          ..add('url', url)
          ..add('uploadedAt', uploadedAt)
          ..add('uploader', uploader))
        .toString();
  }
}

class MemberTestsGet200ResponseAttachmentsInnerBuilder
    implements
        Builder<
          MemberTestsGet200ResponseAttachmentsInner,
          MemberTestsGet200ResponseAttachmentsInnerBuilder
        > {
  _$MemberTestsGet200ResponseAttachmentsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  MemberTestsGet200ResponseAttachmentsInnerTypeEnum? _type;
  MemberTestsGet200ResponseAttachmentsInnerTypeEnum? get type => _$this._type;
  set type(MemberTestsGet200ResponseAttachmentsInnerTypeEnum? type) =>
      _$this._type = type;

  String? _r2Key;
  String? get r2Key => _$this._r2Key;
  set r2Key(String? r2Key) => _$this._r2Key = r2Key;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  DateTime? _uploadedAt;
  DateTime? get uploadedAt => _$this._uploadedAt;
  set uploadedAt(DateTime? uploadedAt) => _$this._uploadedAt = uploadedAt;

  MemberTestsGet200ResponseAttachmentsInnerUploaderBuilder? _uploader;
  MemberTestsGet200ResponseAttachmentsInnerUploaderBuilder get uploader =>
      _$this._uploader ??=
          MemberTestsGet200ResponseAttachmentsInnerUploaderBuilder();
  set uploader(
    MemberTestsGet200ResponseAttachmentsInnerUploaderBuilder? uploader,
  ) => _$this._uploader = uploader;

  MemberTestsGet200ResponseAttachmentsInnerBuilder() {
    MemberTestsGet200ResponseAttachmentsInner._defaults(this);
  }

  MemberTestsGet200ResponseAttachmentsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _r2Key = $v.r2Key;
      _url = $v.url;
      _uploadedAt = $v.uploadedAt;
      _uploader = $v.uploader?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberTestsGet200ResponseAttachmentsInner other) {
    _$v = other as _$MemberTestsGet200ResponseAttachmentsInner;
  }

  @override
  void update(
    void Function(MemberTestsGet200ResponseAttachmentsInnerBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MemberTestsGet200ResponseAttachmentsInner build() => _build();

  _$MemberTestsGet200ResponseAttachmentsInner _build() {
    _$MemberTestsGet200ResponseAttachmentsInner _$result;
    try {
      _$result =
          _$v ??
          _$MemberTestsGet200ResponseAttachmentsInner._(
            id: id,
            type: type,
            r2Key: r2Key,
            url: url,
            uploadedAt: uploadedAt,
            uploader: _uploader?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'uploader';
        _uploader?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MemberTestsGet200ResponseAttachmentsInner',
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
