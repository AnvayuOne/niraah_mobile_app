// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_post_request_messages_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AiChatPostRequestMessagesInnerRoleEnum
_$aiChatPostRequestMessagesInnerRoleEnum_user =
    const AiChatPostRequestMessagesInnerRoleEnum._('user');
const AiChatPostRequestMessagesInnerRoleEnum
_$aiChatPostRequestMessagesInnerRoleEnum_assistant =
    const AiChatPostRequestMessagesInnerRoleEnum._('assistant');

AiChatPostRequestMessagesInnerRoleEnum
_$aiChatPostRequestMessagesInnerRoleEnumValueOf(String name) {
  switch (name) {
    case 'user':
      return _$aiChatPostRequestMessagesInnerRoleEnum_user;
    case 'assistant':
      return _$aiChatPostRequestMessagesInnerRoleEnum_assistant;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AiChatPostRequestMessagesInnerRoleEnum>
_$aiChatPostRequestMessagesInnerRoleEnumValues =
    BuiltSet<AiChatPostRequestMessagesInnerRoleEnum>(
      const <AiChatPostRequestMessagesInnerRoleEnum>[
        _$aiChatPostRequestMessagesInnerRoleEnum_user,
        _$aiChatPostRequestMessagesInnerRoleEnum_assistant,
      ],
    );

Serializer<AiChatPostRequestMessagesInnerRoleEnum>
_$aiChatPostRequestMessagesInnerRoleEnumSerializer =
    _$AiChatPostRequestMessagesInnerRoleEnumSerializer();

class _$AiChatPostRequestMessagesInnerRoleEnumSerializer
    implements PrimitiveSerializer<AiChatPostRequestMessagesInnerRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'user': 'user',
    'assistant': 'assistant',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'user': 'user',
    'assistant': 'assistant',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AiChatPostRequestMessagesInnerRoleEnum,
  ];
  @override
  final String wireName = 'AiChatPostRequestMessagesInnerRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    AiChatPostRequestMessagesInnerRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AiChatPostRequestMessagesInnerRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AiChatPostRequestMessagesInnerRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AiChatPostRequestMessagesInner extends AiChatPostRequestMessagesInner {
  @override
  final AiChatPostRequestMessagesInnerRoleEnum? role;
  @override
  final String? content;

  factory _$AiChatPostRequestMessagesInner([
    void Function(AiChatPostRequestMessagesInnerBuilder)? updates,
  ]) => (AiChatPostRequestMessagesInnerBuilder()..update(updates))._build();

  _$AiChatPostRequestMessagesInner._({this.role, this.content}) : super._();
  @override
  AiChatPostRequestMessagesInner rebuild(
    void Function(AiChatPostRequestMessagesInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AiChatPostRequestMessagesInnerBuilder toBuilder() =>
      AiChatPostRequestMessagesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AiChatPostRequestMessagesInner &&
        role == other.role &&
        content == other.content;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AiChatPostRequestMessagesInner')
          ..add('role', role)
          ..add('content', content))
        .toString();
  }
}

class AiChatPostRequestMessagesInnerBuilder
    implements
        Builder<
          AiChatPostRequestMessagesInner,
          AiChatPostRequestMessagesInnerBuilder
        > {
  _$AiChatPostRequestMessagesInner? _$v;

  AiChatPostRequestMessagesInnerRoleEnum? _role;
  AiChatPostRequestMessagesInnerRoleEnum? get role => _$this._role;
  set role(AiChatPostRequestMessagesInnerRoleEnum? role) => _$this._role = role;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  AiChatPostRequestMessagesInnerBuilder() {
    AiChatPostRequestMessagesInner._defaults(this);
  }

  AiChatPostRequestMessagesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _content = $v.content;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AiChatPostRequestMessagesInner other) {
    _$v = other as _$AiChatPostRequestMessagesInner;
  }

  @override
  void update(void Function(AiChatPostRequestMessagesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AiChatPostRequestMessagesInner build() => _build();

  _$AiChatPostRequestMessagesInner _build() {
    final _$result =
        _$v ?? _$AiChatPostRequestMessagesInner._(role: role, content: content);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
