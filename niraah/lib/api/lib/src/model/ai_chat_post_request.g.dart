// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AiChatPostRequest extends AiChatPostRequest {
  @override
  final BuiltList<AiChatPostRequestMessagesInner> messages;
  @override
  final bool? isGuest;

  factory _$AiChatPostRequest([
    void Function(AiChatPostRequestBuilder)? updates,
  ]) => (AiChatPostRequestBuilder()..update(updates))._build();

  _$AiChatPostRequest._({required this.messages, this.isGuest}) : super._();
  @override
  AiChatPostRequest rebuild(void Function(AiChatPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AiChatPostRequestBuilder toBuilder() =>
      AiChatPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AiChatPostRequest &&
        messages == other.messages &&
        isGuest == other.isGuest;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, messages.hashCode);
    _$hash = $jc(_$hash, isGuest.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AiChatPostRequest')
          ..add('messages', messages)
          ..add('isGuest', isGuest))
        .toString();
  }
}

class AiChatPostRequestBuilder
    implements Builder<AiChatPostRequest, AiChatPostRequestBuilder> {
  _$AiChatPostRequest? _$v;

  ListBuilder<AiChatPostRequestMessagesInner>? _messages;
  ListBuilder<AiChatPostRequestMessagesInner> get messages =>
      _$this._messages ??= ListBuilder<AiChatPostRequestMessagesInner>();
  set messages(ListBuilder<AiChatPostRequestMessagesInner>? messages) =>
      _$this._messages = messages;

  bool? _isGuest;
  bool? get isGuest => _$this._isGuest;
  set isGuest(bool? isGuest) => _$this._isGuest = isGuest;

  AiChatPostRequestBuilder() {
    AiChatPostRequest._defaults(this);
  }

  AiChatPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _messages = $v.messages.toBuilder();
      _isGuest = $v.isGuest;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AiChatPostRequest other) {
    _$v = other as _$AiChatPostRequest;
  }

  @override
  void update(void Function(AiChatPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AiChatPostRequest build() => _build();

  _$AiChatPostRequest _build() {
    _$AiChatPostRequest _$result;
    try {
      _$result =
          _$v ??
          _$AiChatPostRequest._(messages: messages.build(), isGuest: isGuest);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'messages';
        messages.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AiChatPostRequest',
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
