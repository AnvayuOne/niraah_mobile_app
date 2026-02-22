// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r2_presign_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$R2PresignPost200Response extends R2PresignPost200Response {
  @override
  final String? url;
  @override
  final String? key;

  factory _$R2PresignPost200Response([
    void Function(R2PresignPost200ResponseBuilder)? updates,
  ]) => (R2PresignPost200ResponseBuilder()..update(updates))._build();

  _$R2PresignPost200Response._({this.url, this.key}) : super._();
  @override
  R2PresignPost200Response rebuild(
    void Function(R2PresignPost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  R2PresignPost200ResponseBuilder toBuilder() =>
      R2PresignPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is R2PresignPost200Response &&
        url == other.url &&
        key == other.key;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'R2PresignPost200Response')
          ..add('url', url)
          ..add('key', key))
        .toString();
  }
}

class R2PresignPost200ResponseBuilder
    implements
        Builder<R2PresignPost200Response, R2PresignPost200ResponseBuilder> {
  _$R2PresignPost200Response? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  R2PresignPost200ResponseBuilder() {
    R2PresignPost200Response._defaults(this);
  }

  R2PresignPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _key = $v.key;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(R2PresignPost200Response other) {
    _$v = other as _$R2PresignPost200Response;
  }

  @override
  void update(void Function(R2PresignPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  R2PresignPost200Response build() => _build();

  _$R2PresignPost200Response _build() {
    final _$result = _$v ?? _$R2PresignPost200Response._(url: url, key: key);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
