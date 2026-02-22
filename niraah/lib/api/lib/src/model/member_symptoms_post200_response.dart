//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/symptom_entry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_symptoms_post200_response.g.dart';

/// MemberSymptomsPost200Response
///
/// Properties:
/// * [ok] 
/// * [entry] 
@BuiltValue()
abstract class MemberSymptomsPost200Response implements Built<MemberSymptomsPost200Response, MemberSymptomsPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'ok')
  bool? get ok;

  @BuiltValueField(wireName: r'entry')
  SymptomEntry? get entry;

  MemberSymptomsPost200Response._();

  factory MemberSymptomsPost200Response([void updates(MemberSymptomsPost200ResponseBuilder b)]) = _$MemberSymptomsPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberSymptomsPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberSymptomsPost200Response> get serializer => _$MemberSymptomsPost200ResponseSerializer();
}

class _$MemberSymptomsPost200ResponseSerializer implements PrimitiveSerializer<MemberSymptomsPost200Response> {
  @override
  final Iterable<Type> types = const [MemberSymptomsPost200Response, _$MemberSymptomsPost200Response];

  @override
  final String wireName = r'MemberSymptomsPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberSymptomsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ok != null) {
      yield r'ok';
      yield serializers.serialize(
        object.ok,
        specifiedType: const FullType(bool),
      );
    }
    if (object.entry != null) {
      yield r'entry';
      yield serializers.serialize(
        object.entry,
        specifiedType: const FullType(SymptomEntry),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MemberSymptomsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberSymptomsPost200ResponseBuilder result,
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
        case r'entry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SymptomEntry),
          ) as SymptomEntry;
          result.entry.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemberSymptomsPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberSymptomsPost200ResponseBuilder();
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

