//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_stats_get200_response_recent_members_inner.g.dart';

/// AdminStatsGet200ResponseRecentMembersInner
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [createdAt] 
/// * [role] 
@BuiltValue()
abstract class AdminStatsGet200ResponseRecentMembersInner implements Built<AdminStatsGet200ResponseRecentMembersInner, AdminStatsGet200ResponseRecentMembersInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'created_at')
  String? get createdAt;

  @BuiltValueField(wireName: r'role')
  String? get role;

  AdminStatsGet200ResponseRecentMembersInner._();

  factory AdminStatsGet200ResponseRecentMembersInner([void updates(AdminStatsGet200ResponseRecentMembersInnerBuilder b)]) = _$AdminStatsGet200ResponseRecentMembersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminStatsGet200ResponseRecentMembersInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminStatsGet200ResponseRecentMembersInner> get serializer => _$AdminStatsGet200ResponseRecentMembersInnerSerializer();
}

class _$AdminStatsGet200ResponseRecentMembersInnerSerializer implements PrimitiveSerializer<AdminStatsGet200ResponseRecentMembersInner> {
  @override
  final Iterable<Type> types = const [AdminStatsGet200ResponseRecentMembersInner, _$AdminStatsGet200ResponseRecentMembersInner];

  @override
  final String wireName = r'AdminStatsGet200ResponseRecentMembersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminStatsGet200ResponseRecentMembersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(String),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminStatsGet200ResponseRecentMembersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminStatsGet200ResponseRecentMembersInnerBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdAt = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminStatsGet200ResponseRecentMembersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminStatsGet200ResponseRecentMembersInnerBuilder();
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

