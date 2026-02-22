//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/member_tests_get200_response_attachments_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_tests_get200_response.g.dart';

/// MemberTestsGet200Response
///
/// Properties:
/// * [attachments] 
@BuiltValue()
abstract class MemberTestsGet200Response implements Built<MemberTestsGet200Response, MemberTestsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'attachments')
  BuiltList<MemberTestsGet200ResponseAttachmentsInner>? get attachments;

  MemberTestsGet200Response._();

  factory MemberTestsGet200Response([void updates(MemberTestsGet200ResponseBuilder b)]) = _$MemberTestsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberTestsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberTestsGet200Response> get serializer => _$MemberTestsGet200ResponseSerializer();
}

class _$MemberTestsGet200ResponseSerializer implements PrimitiveSerializer<MemberTestsGet200Response> {
  @override
  final Iterable<Type> types = const [MemberTestsGet200Response, _$MemberTestsGet200Response];

  @override
  final String wireName = r'MemberTestsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberTestsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.attachments != null) {
      yield r'attachments';
      yield serializers.serialize(
        object.attachments,
        specifiedType: const FullType(BuiltList, [FullType(MemberTestsGet200ResponseAttachmentsInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberTestsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberTestsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'attachments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MemberTestsGet200ResponseAttachmentsInner)]),
          ) as BuiltList<MemberTestsGet200ResponseAttachmentsInner>;
          result.attachments.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberTestsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberTestsGet200ResponseBuilder();
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

