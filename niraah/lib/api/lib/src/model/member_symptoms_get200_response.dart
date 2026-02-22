//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/symptom_entry.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_symptoms_get200_response.g.dart';

/// MemberSymptomsGet200Response
///
/// Properties:
/// * [entries] 
@BuiltValue()
abstract class MemberSymptomsGet200Response implements Built<MemberSymptomsGet200Response, MemberSymptomsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'entries')
  BuiltList<SymptomEntry>? get entries;

  MemberSymptomsGet200Response._();

  factory MemberSymptomsGet200Response([void updates(MemberSymptomsGet200ResponseBuilder b)]) = _$MemberSymptomsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberSymptomsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberSymptomsGet200Response> get serializer => _$MemberSymptomsGet200ResponseSerializer();
}

class _$MemberSymptomsGet200ResponseSerializer implements PrimitiveSerializer<MemberSymptomsGet200Response> {
  @override
  final Iterable<Type> types = const [MemberSymptomsGet200Response, _$MemberSymptomsGet200Response];

  @override
  final String wireName = r'MemberSymptomsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberSymptomsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.entries != null) {
      yield r'entries';
      yield serializers.serialize(
        object.entries,
        specifiedType: const FullType(BuiltList, [FullType(SymptomEntry)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberSymptomsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberSymptomsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SymptomEntry)]),
          ) as BuiltList<SymptomEntry>;
          result.entries.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberSymptomsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberSymptomsGet200ResponseBuilder();
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

