//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/symptom_entry_symptoms.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'symptom_entry.g.dart';

/// SymptomEntry
///
/// Properties:
/// * [id] 
/// * [date] 
/// * [symptoms] 
/// * [notes] 
@BuiltValue()
abstract class SymptomEntry implements Built<SymptomEntry, SymptomEntryBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  @BuiltValueField(wireName: r'symptoms')
  SymptomEntrySymptoms? get symptoms;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  SymptomEntry._();

  factory SymptomEntry([void updates(SymptomEntryBuilder b)]) = _$SymptomEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SymptomEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SymptomEntry> get serializer => _$SymptomEntrySerializer();
}

class _$SymptomEntrySerializer implements PrimitiveSerializer<SymptomEntry> {
  @override
  final Iterable<Type> types = const [SymptomEntry, _$SymptomEntry];

  @override
  final String wireName = r'SymptomEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SymptomEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.symptoms != null) {
      yield r'symptoms';
      yield serializers.serialize(
        object.symptoms,
        specifiedType: const FullType(SymptomEntrySymptoms),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SymptomEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SymptomEntryBuilder result,
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
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.date = valueDes;
          break;
        case r'symptoms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SymptomEntrySymptoms),
          ) as SymptomEntrySymptoms;
          result.symptoms.replace(valueDes);
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SymptomEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SymptomEntryBuilder();
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

