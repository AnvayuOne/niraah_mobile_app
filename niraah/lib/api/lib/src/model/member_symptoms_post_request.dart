//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member_symptoms_post_request.g.dart';

/// MemberSymptomsPostRequest
///
/// Properties:
/// * [symptom] - Symptom name
/// * [intensity] - Symptom intensity (1-10)
/// * [notes] - Additional notes
@BuiltValue()
abstract class MemberSymptomsPostRequest implements Built<MemberSymptomsPostRequest, MemberSymptomsPostRequestBuilder> {
  /// Symptom name
  @BuiltValueField(wireName: r'symptom')
  String get symptom;

  /// Symptom intensity (1-10)
  @BuiltValueField(wireName: r'intensity')
  num get intensity;

  /// Additional notes
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  MemberSymptomsPostRequest._();

  factory MemberSymptomsPostRequest([void updates(MemberSymptomsPostRequestBuilder b)]) = _$MemberSymptomsPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberSymptomsPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemberSymptomsPostRequest> get serializer => _$MemberSymptomsPostRequestSerializer();
}

class _$MemberSymptomsPostRequestSerializer implements PrimitiveSerializer<MemberSymptomsPostRequest> {
  @override
  final Iterable<Type> types = const [MemberSymptomsPostRequest, _$MemberSymptomsPostRequest];

  @override
  final String wireName = r'MemberSymptomsPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemberSymptomsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'symptom';
    yield serializers.serialize(
      object.symptom,
      specifiedType: const FullType(String),
    );
    yield r'intensity';
    yield serializers.serialize(
      object.intensity,
      specifiedType: const FullType(num),
    );
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
    MemberSymptomsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MemberSymptomsPostRequestBuilder result,
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
  MemberSymptomsPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberSymptomsPostRequestBuilder();
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

