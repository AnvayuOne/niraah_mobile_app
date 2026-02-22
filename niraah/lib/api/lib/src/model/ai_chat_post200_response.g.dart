// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AiChatPost200ResponseRoleEnum _$aiChatPost200ResponseRoleEnum_assistant =
    const AiChatPost200ResponseRoleEnum._('assistant');

AiChatPost200ResponseRoleEnum _$aiChatPost200ResponseRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'assistant':
      return _$aiChatPost200ResponseRoleEnum_assistant;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AiChatPost200ResponseRoleEnum>
_$aiChatPost200ResponseRoleEnumValues = BuiltSet<AiChatPost200ResponseRoleEnum>(
  const <AiChatPost200ResponseRoleEnum>[
    _$aiChatPost200ResponseRoleEnum_assistant,
  ],
);

Serializer<AiChatPost200ResponseRoleEnum>
_$aiChatPost200ResponseRoleEnumSerializer =
    _$AiChatPost200ResponseRoleEnumSerializer();

class _$AiChatPost200ResponseRoleEnumSerializer
    implements PrimitiveSerializer<AiChatPost200ResponseRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'assistant': 'assistant',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'assistant': 'assistant',
  };

  @override
  final Iterable<Type> types = const <Type>[AiChatPost200ResponseRoleEnum];
  @override
  final String wireName = 'AiChatPost200ResponseRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    AiChatPost200ResponseRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AiChatPost200ResponseRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AiChatPost200ResponseRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AiChatPost200Response extends AiChatPost200Response {
  @override
  final AiChatPost200ResponseRoleEnum? role;
  @override
  final String? content;

  factory _$AiChatPost200Response([
    void Function(AiChatPost200ResponseBuilder)? updates,
  ]) => (AiChatPost200ResponseBuilder()..update(updates))._build();

  _$AiChatPost200Response._({this.role, this.content}) : super._();
  @override
  AiChatPost200Response rebuild(
    void Function(AiChatPost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AiChatPost200ResponseBuilder toBuilder() =>
      AiChatPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AiChatPost200Response &&
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
    return (newBuiltValueToStringHelper(r'AiChatPost200Response')
          ..add('role', role)
          ..add('content', content))
        .toString();
  }
}

class AiChatPost200ResponseBuilder
    implements Builder<AiChatPost200Response, AiChatPost200ResponseBuilder> {
  _$AiChatPost200Response? _$v;

  AiChatPost200ResponseRoleEnum? _role;
  AiChatPost200ResponseRoleEnum? get role => _$this._role;
  set role(AiChatPost200ResponseRoleEnum? role) => _$this._role = role;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  AiChatPost200ResponseBuilder() {
    AiChatPost200Response._defaults(this);
  }

  AiChatPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _content = $v.content;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AiChatPost200Response other) {
    _$v = other as _$AiChatPost200Response;
  }

  @override
  void update(void Function(AiChatPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AiChatPost200Response build() => _build();

  _$AiChatPost200Response _build() {
    final _$result =
        _$v ?? _$AiChatPost200Response._(role: role, content: content);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
