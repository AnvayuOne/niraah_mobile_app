//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'symptom_entry_symptoms.g.dart';

/// SymptomEntrySymptoms
///
/// Properties:
/// * [symptom] 
/// * [intensity] 
@BuiltValue()
abstract class SymptomEntrySymptoms implements Built<SymptomEntrySymptoms, SymptomEntrySymptomsBuilder> {
  @BuiltValueField(wireName: r'symptom')
  String? get symptom;

  @BuiltValueField(wireName: r'intensity')
  num? get intensity;

  SymptomEntrySymptoms._();

  factory SymptomEntrySymptoms([void updates(SymptomEntrySymptomsBuilder b)]) = _$SymptomEntrySymptoms;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SymptomEntrySymptomsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SymptomEntrySymptoms> get serializer => _$SymptomEntrySymptomsSerializer();
}

class _$SymptomEntrySymptomsSerializer implements PrimitiveSerializer<SymptomEntrySymptoms> {
  @override
  final Iterable<Type> types = const [SymptomEntrySymptoms, _$SymptomEntrySymptoms];

  @override
  final String wireName = r'SymptomEntrySymptoms';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SymptomEntrySymptoms object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.symptom != null) {
      yield r'symptom';
      yield serializers.serialize(
        object.symptom,
        specifiedType: const FullType(String),
      );
    }
    if (object.intensity != null) {
      yield r'intensity';
      yield serializers.serialize(
        object.intensity,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SymptomEntrySymptoms object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SymptomEntrySymptomsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'symptom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.symptom = valueDes;
          break;
        case r'intensity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.intensity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SymptomEntrySymptoms deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SymptomEntrySymptomsBuilder();
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

