// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r2_presign_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$R2PresignPostRequest extends R2PresignPostRequest {
  @override
  final String key;
  @override
  final String contentType;

  factory _$R2PresignPostRequest([
    void Function(R2PresignPostRequestBuilder)? updates,
  ]) => (R2PresignPostRequestBuilder()..update(updates))._build();

  _$R2PresignPostRequest._({required this.key, required this.contentType})
    : super._();
  @override
  R2PresignPostRequest rebuild(
    void Function(R2PresignPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  R2PresignPostRequestBuilder toBuilder() =>
      R2PresignPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is R2PresignPostRequest &&
        key == other.key &&
        contentType == other.contentType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'R2PresignPostRequest')
          ..add('key', key)
          ..add('contentType', contentType))
        .toString();
  }
}

class R2PresignPostRequestBuilder
    implements Builder<R2PresignPostRequest, R2PresignPostRequestBuilder> {
  _$R2PresignPostRequest? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

  R2PresignPostRequestBuilder() {
    R2PresignPostRequest._defaults(this);
  }

  R2PresignPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _contentType = $v.contentType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(R2PresignPostRequest other) {
    _$v = other as _$R2PresignPostRequest;
  }

  @override
  void update(void Function(R2PresignPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  R2PresignPostRequest build() => _build();

  _$R2PresignPostRequest _build() {
    final _$result =
        _$v ??
        _$R2PresignPostRequest._(
          key: BuiltValueNullFieldError.checkNotNull(
            key,
            r'R2PresignPostRequest',
            'key',
          ),
          contentType: BuiltValueNullFieldError.checkNotNull(
            contentType,
            r'R2PresignPostRequest',
            'contentType',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
