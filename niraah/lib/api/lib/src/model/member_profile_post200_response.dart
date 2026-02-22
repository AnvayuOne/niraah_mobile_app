//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_profile_post200_response.g.dart';

/// MemberProfilePost200Response
///
/// Properties:
/// * [ok] 
@BuiltValue()
abstract class MemberProfilePost200Response implements Built<MemberProfilePost200Response, MemberProfilePost200ResponseBuilder> {
  @BuiltValueField(wireName: r'ok')
  bool? get ok;

  MemberProfilePost200Response._();

  factory MemberProfilePost200Response([void updates(MemberProfilePost200ResponseBuilder b)]) = _$MemberProfilePost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberProfilePost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberProfilePost200Response> get serializer => _$MemberProfilePost200ResponseSerializer();
}

class _$MemberProfilePost200ResponseSerializer implements PrimitiveSerializer<MemberProfilePost200Response> {
  @override
  final Iterable<Type> types = const [MemberProfilePost200Response, _$MemberProfilePost200Response];

  @override
  final String wireName = r'MemberProfilePost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberProfilePost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ok != null) {
      yield r'ok';
      yield serializers.serialize(
        object.ok,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberProfilePost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberProfilePost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ok':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ok = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberProfilePost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberProfilePost200ResponseBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

