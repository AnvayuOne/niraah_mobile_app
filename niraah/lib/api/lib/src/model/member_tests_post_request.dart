//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_tests_post_request.g.dart';

/// MemberTestsPostRequest
///
/// Properties:
/// * [r2Key] - R2 storage key
/// * [url] - Public URL
/// * [type] 
@BuiltValue()
abstract class MemberTestsPostRequest implements Built<MemberTestsPostRequest, MemberTestsPostRequestBuilder> {
  /// R2 storage key
  @BuiltValueField(wireName: r'r2Key')
  String get r2Key;

  /// Public URL
  @BuiltValueField(wireName: r'url')
  String? get url;

  @BuiltValueField(wireName: r'type')
  MemberTestsPostRequestTypeEnum get type;
  // enum typeEnum {  REPORT,  IMAGE,  };

  MemberTestsPostRequest._();

  factory MemberTestsPostRequest([void updates(MemberTestsPostRequestBuilder b)]) = _$MemberTestsPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberTestsPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberTestsPostRequest> get serializer => _$MemberTestsPostRequestSerializer();
}

class _$MemberTestsPostRequestSerializer implements PrimitiveSerializer<MemberTestsPostRequest> {
  @override
  final Iterable<Type> types = const [MemberTestsPostRequest, _$MemberTestsPostRequest];

  @override
  final String wireName = r'MemberTestsPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberTestsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'r2Key';
    yield serializers.serialize(
      object.r2Key,
      specifiedType: const FullType(String),
    );
    if (object.url != null) {
      yield r'url';
      yield serializers.serialize(
        object.url,
        specifiedType: const FullType(String),
      );
    }
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(MemberTestsPostRequestTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberTestsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberTestsPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemberTestsPostRequestTypeEnum),
          ) as MemberTestsPostRequestTypeEnum;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberTestsPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberTestsPostRequestBuilder();
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

class MemberTestsPostRequestTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'REPORT')
  static const MemberTestsPostRequestTypeEnum REPORT = _$memberTestsPostRequestTypeEnum_REPORT;
  @BuiltValueEnumConst(wireName: r'IMAGE')
  static const MemberTestsPostRequestTypeEnum IMAGE = _$memberTestsPostRequestTypeEnum_IMAGE;

  static Serializer<MemberTestsPostRequestTypeEnum> get serializer => _$memberTestsPostRequestTypeEnumSerializer;

  const MemberTestsPostRequestTypeEnum._(String name): super(name);

  static BuiltSet<MemberTestsPostRequestTypeEnum> get values => _$memberTestsPostRequestTypeEnumValues;
  static MemberTestsPostRequestTypeEnum valueOf(String name) => _$memberTestsPostRequestTypeEnumValueOf(name);
}

