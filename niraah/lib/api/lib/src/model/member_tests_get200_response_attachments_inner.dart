//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/member_tests_get200_response_attachments_inner_uploader.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_tests_get200_response_attachments_inner.g.dart';

/// MemberTestsGet200ResponseAttachmentsInner
///
/// Properties:
/// * [id] 
/// * [type] 
/// * [r2Key] 
/// * [url] 
/// * [uploadedAt] 
/// * [uploader] 
@BuiltValue()
abstract class MemberTestsGet200ResponseAttachmentsInner implements Built<MemberTestsGet200ResponseAttachmentsInner, MemberTestsGet200ResponseAttachmentsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'type')
  MemberTestsGet200ResponseAttachmentsInnerTypeEnum? get type;
  // enum typeEnum {  REPORT,  IMAGE,  };

  @BuiltValueField(wireName: r'r2Key')
  String? get r2Key;

  @BuiltValueField(wireName: r'url')
  String? get url;

  @BuiltValueField(wireName: r'uploadedAt')
  DateTime? get uploadedAt;

  @BuiltValueField(wireName: r'uploader')
  MemberTestsGet200ResponseAttachmentsInnerUploader? get uploader;

  MemberTestsGet200ResponseAttachmentsInner._();

  factory MemberTestsGet200ResponseAttachmentsInner([void updates(MemberTestsGet200ResponseAttachmentsInnerBuilder b)]) = _$MemberTestsGet200ResponseAttachmentsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberTestsGet200ResponseAttachmentsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberTestsGet200ResponseAttachmentsInner> get serializer => _$MemberTestsGet200ResponseAttachmentsInnerSerializer();
}

class _$MemberTestsGet200ResponseAttachmentsInnerSerializer implements PrimitiveSerializer<MemberTestsGet200ResponseAttachmentsInner> {
  @override
  final Iterable<Type> types = const [MemberTestsGet200ResponseAttachmentsInner, _$MemberTestsGet200ResponseAttachmentsInner];

  @override
  final String wireName = r'MemberTestsGet200ResponseAttachmentsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberTestsGet200ResponseAttachmentsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(MemberTestsGet200ResponseAttachmentsInnerTypeEnum),
      );
    }
    if (object.r2Key != null) {
      yield r'r2Key';
      yield serializers.serialize(
        object.r2Key,
        specifiedType: const FullType(String),
      );
    }
    if (object.url != null) {
      yield r'url';
      yield serializers.serialize(
        object.url,
        specifiedType: const FullType(String),
      );
    }
    if (object.uploadedAt != null) {
      yield r'uploadedAt';
      yield serializers.serialize(
        object.uploadedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.uploader != null) {
      yield r'uploader';
      yield serializers.serialize(
        object.uploader,
        specifiedType: const FullType(MemberTestsGet200ResponseAttachmentsInnerUploader),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberTestsGet200ResponseAttachmentsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberTestsGet200ResponseAttachmentsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemberTestsGet200ResponseAttachmentsInnerTypeEnum),
          ) as MemberTestsGet200ResponseAttachmentsInnerTypeEnum;
          result.type = valueDes;
          break;
        case r'r2Key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.r2Key = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'uploadedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.uploadedAt = valueDes;
          break;
        case r'uploader':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemberTestsGet200ResponseAttachmentsInnerUploader),
          ) as MemberTestsGet200ResponseAttachmentsInnerUploader;
          result.uploader.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberTestsGet200ResponseAttachmentsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberTestsGet200ResponseAttachmentsInnerBuilder();
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

class MemberTestsGet200ResponseAttachmentsInnerTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'REPORT')
  static const MemberTestsGet200ResponseAttachmentsInnerTypeEnum REPORT = _$memberTestsGet200ResponseAttachmentsInnerTypeEnum_REPORT;
  @BuiltValueEnumConst(wireName: r'IMAGE')
  static const MemberTestsGet200ResponseAttachmentsInnerTypeEnum IMAGE = _$memberTestsGet200ResponseAttachmentsInnerTypeEnum_IMAGE;

  static Serializer<MemberTestsGet200ResponseAttachmentsInnerTypeEnum> get serializer => _$memberTestsGet200ResponseAttachmentsInnerTypeEnumSerializer;

  const MemberTestsGet200ResponseAttachmentsInnerTypeEnum._(String name): super(name);

  static BuiltSet<MemberTestsGet200ResponseAttachmentsInnerTypeEnum> get values => _$memberTestsGet200ResponseAttachmentsInnerTypeEnumValues;
  static MemberTestsGet200ResponseAttachmentsInnerTypeEnum valueOf(String name) => _$memberTestsGet200ResponseAttachmentsInnerTypeEnumValueOf(name);
}

