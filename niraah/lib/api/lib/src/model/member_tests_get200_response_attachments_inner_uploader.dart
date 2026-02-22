//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_tests_get200_response_attachments_inner_uploader.g.dart';

/// MemberTestsGet200ResponseAttachmentsInnerUploader
///
/// Properties:
/// * [name] 
@BuiltValue()
abstract class MemberTestsGet200ResponseAttachmentsInnerUploader implements Built<MemberTestsGet200ResponseAttachmentsInnerUploader, MemberTestsGet200ResponseAttachmentsInnerUploaderBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  MemberTestsGet200ResponseAttachmentsInnerUploader._();

  factory MemberTestsGet200ResponseAttachmentsInnerUploader([void updates(MemberTestsGet200ResponseAttachmentsInnerUploaderBuilder b)]) = _$MemberTestsGet200ResponseAttachmentsInnerUploader;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberTestsGet200ResponseAttachmentsInnerUploaderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberTestsGet200ResponseAttachmentsInnerUploader> get serializer => _$MemberTestsGet200ResponseAttachmentsInnerUploaderSerializer();
}

class _$MemberTestsGet200ResponseAttachmentsInnerUploaderSerializer implements PrimitiveSerializer<MemberTestsGet200ResponseAttachmentsInnerUploader> {
  @override
  final Iterable<Type> types = const [MemberTestsGet200ResponseAttachmentsInnerUploader, _$MemberTestsGet200ResponseAttachmentsInnerUploader];

  @override
  final String wireName = r'MemberTestsGet200ResponseAttachmentsInnerUploader';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberTestsGet200ResponseAttachmentsInnerUploader object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberTestsGet200ResponseAttachmentsInnerUploader object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberTestsGet200ResponseAttachmentsInnerUploaderBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberTestsGet200ResponseAttachmentsInnerUploader deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberTestsGet200ResponseAttachmentsInnerUploaderBuilder();
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

