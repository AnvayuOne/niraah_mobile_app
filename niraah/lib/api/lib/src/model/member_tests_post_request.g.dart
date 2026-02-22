// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_tests_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MemberTestsPostRequestTypeEnum _$memberTestsPostRequestTypeEnum_REPORT =
    const MemberTestsPostRequestTypeEnum._('REPORT');
const MemberTestsPostRequestTypeEnum _$memberTestsPostRequestTypeEnum_IMAGE =
    const MemberTestsPostRequestTypeEnum._('IMAGE');

MemberTestsPostRequestTypeEnum _$memberTestsPostRequestTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'REPORT':
      return _$memberTestsPostRequestTypeEnum_REPORT;
    case 'IMAGE':
      return _$memberTestsPostRequestTypeEnum_IMAGE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MemberTestsPostRequestTypeEnum>
_$memberTestsPostRequestTypeEnumValues =
    BuiltSet<MemberTestsPostRequestTypeEnum>(
      const <MemberTestsPostRequestTypeEnum>[
        _$memberTestsPostRequestTypeEnum_REPORT,
        _$memberTestsPostRequestTypeEnum_IMAGE,
      ],
    );

Serializer<MemberTestsPostRequestTypeEnum>
_$memberTestsPostRequestTypeEnumSerializer =
    _$MemberTestsPostRequestTypeEnumSerializer();

class _$MemberTestsPostRequestTypeEnumSerializer
    implements PrimitiveSerializer<MemberTestsPostRequestTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'REPORT': 'REPORT',
    'IMAGE': 'IMAGE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'REPORT': 'REPORT',
    'IMAGE': 'IMAGE',
  };

  @override
  final Iterable<Type> types = const <Type>[MemberTestsPostRequestTypeEnum];
  @override
  final String wireName = 'MemberTestsPostRequestTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MemberTestsPostRequestTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MemberTestsPostRequestTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MemberTestsPostRequestTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MemberTestsPostRequest extends MemberTestsPostRequest {
  @override
  final String r2Key;
  @override
  final String? url;
  @override
  final MemberTestsPostRequestTypeEnum type;

  factory _$MemberTestsPostRequest([
    void Function(MemberTestsPostRequestBuilder)? updates,
  ]) => (MemberTestsPostRequestBuilder()..update(updates))._build();

  _$MemberTestsPostRequest._({
    required this.r2Key,
    this.url,
    required this.type,
  }) : super._();
  @override
  MemberTestsPostRequest rebuild(
    void Function(MemberTestsPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MemberTestsPostRequestBuilder toBuilder() =>
      MemberTestsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemberTestsPostRequest &&
        r2Key == other.r2Key &&
        url == other.url &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, r2Key.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemberTestsPostRequest')
          ..add('r2Key', r2Key)
          ..add('url', url)
          ..add('type', type))
        .toString();
  }
}

class MemberTestsPostRequestBuilder
    implements Builder<MemberTestsPostRequest, MemberTestsPostRequestBuilder> {
  _$MemberTestsPostRequest? _$v;

  String? _r2Key;
  String? get r2Key => _$this._r2Key;
  set r2Key(String? r2Key) => _$this._r2Key = r2Key;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  MemberTestsPostRequestTypeEnum? _type;
  MemberTestsPostRequestTypeEnum? get type => _$this._type;
  set type(MemberTestsPostRequestTypeEnum? type) => _$this._type = type;

  MemberTestsPostRequestBuilder() {
    MemberTestsPostRequest._defaults(this);
  }

  MemberTestsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _r2Key = $v.r2Key;
      _url = $v.url;
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemberTestsPostRequest other) {
    _$v = other as _$MemberTestsPostRequest;
  }

  @override
  void update(void Function(MemberTestsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemberTestsPostRequest build() => _build();

  _$MemberTestsPostRequest _build() {
    final _$result =
        _$v ??
        _$MemberTestsPostRequest._(
          r2Key: BuiltValueNullFieldError.checkNotNull(
            r2Key,
            r'MemberTestsPostRequest',
            'r2Key',
          ),
          url: url,
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'MemberTestsPostRequest',
            'type',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
