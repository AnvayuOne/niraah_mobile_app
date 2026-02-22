//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/plan.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plans_get200_response.g.dart';

/// PlansGet200Response
///
/// Properties:
/// * [plans] 
@BuiltValue()
abstract class PlansGet200Response implements Built<PlansGet200Response, PlansGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'plans')
  BuiltList<Plan>? get plans;

  PlansGet200Response._();

  factory PlansGet200Response([void updates(PlansGet200ResponseBuilder b)]) = _$PlansGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlansGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlansGet200Response> get serializer => _$PlansGet200ResponseSerializer();
}

class _$PlansGet200ResponseSerializer implements PrimitiveSerializer<PlansGet200Response> {
  @override
  final Iterable<Type> types = const [PlansGet200Response, _$PlansGet200Response];

  @override
  final String wireName = r'PlansGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlansGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.plans != null) {
      yield r'plans';
      yield serializers.serialize(
        object.plans,
        specifiedType: const FullType(BuiltList, [FullType(Plan)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PlansGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlansGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plans':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Plan)]),
          ) as BuiltList<Plan>;
          result.plans.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlansGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlansGet200ResponseBuilder();
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

