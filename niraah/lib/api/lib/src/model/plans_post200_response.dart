//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/plan.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plans_post200_response.g.dart';

/// PlansPost200Response
///
/// Properties:
/// * [plan] 
@BuiltValue()
abstract class PlansPost200Response implements Built<PlansPost200Response, PlansPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'plan')
  Plan? get plan;

  PlansPost200Response._();

  factory PlansPost200Response([void updates(PlansPost200ResponseBuilder b)]) = _$PlansPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlansPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlansPost200Response> get serializer => _$PlansPost200ResponseSerializer();
}

class _$PlansPost200ResponseSerializer implements PrimitiveSerializer<PlansPost200Response> {
  @override
  final Iterable<Type> types = const [PlansPost200Response, _$PlansPost200Response];

  @override
  final String wireName = r'PlansPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlansPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.plan != null) {
      yield r'plan';
      yield serializers.serialize(
        object.plan,
        specifiedType: const FullType(Plan),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PlansPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlansPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Plan),
          ) as Plan;
          result.plan.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlansPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlansPost200ResponseBuilder();
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

