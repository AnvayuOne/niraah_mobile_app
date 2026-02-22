//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plans_post_request.g.dart';

/// PlansPostRequest
///
/// Properties:
/// * [memberId] - Target member ID
/// * [type] 
/// * [title] 
/// * [description] 
/// * [startDate] 
/// * [endDate] 
@BuiltValue()
abstract class PlansPostRequest implements Built<PlansPostRequest, PlansPostRequestBuilder> {
  /// Target member ID
  @BuiltValueField(wireName: r'memberId')
  String get memberId;

  @BuiltValueField(wireName: r'type')
  PlansPostRequestTypeEnum get type;
  // enum typeEnum {  DIET,  EXERCISE,  MEDICATION,  SUPPLEMENT,  };

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'startDate')
  Date? get startDate;

  @BuiltValueField(wireName: r'endDate')
  Date? get endDate;

  PlansPostRequest._();

  factory PlansPostRequest([void updates(PlansPostRequestBuilder b)]) = _$PlansPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlansPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlansPostRequest> get serializer => _$PlansPostRequestSerializer();
}

class _$PlansPostRequestSerializer implements PrimitiveSerializer<PlansPostRequest> {
  @override
  final Iterable<Type> types = const [PlansPostRequest, _$PlansPostRequest];

  @override
  final String wireName = r'PlansPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlansPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'memberId';
    yield serializers.serialize(
      object.memberId,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(PlansPostRequestTypeEnum),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.startDate != null) {
      yield r'startDate';
      yield serializers.serialize(
        object.startDate,
        specifiedType: const FullType(Date),
      );
    }
    if (object.endDate != null) {
      yield r'endDate';
      yield serializers.serialize(
        object.endDate,
        specifiedType: const FullType(Date),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PlansPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlansPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'memberId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.memberId = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlansPostRequestTypeEnum),
          ) as PlansPostRequestTypeEnum;
          result.type = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'startDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.startDate = valueDes;
          break;
        case r'endDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.endDate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlansPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlansPostRequestBuilder();
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

class PlansPostRequestTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'DIET')
  static const PlansPostRequestTypeEnum DIET = _$plansPostRequestTypeEnum_DIET;
  @BuiltValueEnumConst(wireName: r'EXERCISE')
  static const PlansPostRequestTypeEnum EXERCISE = _$plansPostRequestTypeEnum_EXERCISE;
  @BuiltValueEnumConst(wireName: r'MEDICATION')
  static const PlansPostRequestTypeEnum MEDICATION = _$plansPostRequestTypeEnum_MEDICATION;
  @BuiltValueEnumConst(wireName: r'SUPPLEMENT')
  static const PlansPostRequestTypeEnum SUPPLEMENT = _$plansPostRequestTypeEnum_SUPPLEMENT;

  static Serializer<PlansPostRequestTypeEnum> get serializer => _$plansPostRequestTypeEnumSerializer;

  const PlansPostRequestTypeEnum._(String name): super(name);

  static BuiltSet<PlansPostRequestTypeEnum> get values => _$plansPostRequestTypeEnumValues;
  static PlansPostRequestTypeEnum valueOf(String name) => _$plansPostRequestTypeEnumValueOf(name);
}

