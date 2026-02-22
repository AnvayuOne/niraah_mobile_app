//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/admin_stats_get200_response_recent_members_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_stats_get200_response.g.dart';

/// AdminStatsGet200Response
///
/// Properties:
/// * [members] - Total member count
/// * [appointments] - Total appointment count
/// * [recentMembers] 
@BuiltValue()
abstract class AdminStatsGet200Response implements Built<AdminStatsGet200Response, AdminStatsGet200ResponseBuilder> {
  /// Total member count
  @BuiltValueField(wireName: r'members')
  num? get members;

  /// Total appointment count
  @BuiltValueField(wireName: r'appointments')
  num? get appointments;

  @BuiltValueField(wireName: r'recentMembers')
  BuiltList<AdminStatsGet200ResponseRecentMembersInner>? get recentMembers;

  AdminStatsGet200Response._();

  factory AdminStatsGet200Response([void updates(AdminStatsGet200ResponseBuilder b)]) = _$AdminStatsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminStatsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminStatsGet200Response> get serializer => _$AdminStatsGet200ResponseSerializer();
}

class _$AdminStatsGet200ResponseSerializer implements PrimitiveSerializer<AdminStatsGet200Response> {
  @override
  final Iterable<Type> types = const [AdminStatsGet200Response, _$AdminStatsGet200Response];

  @override
  final String wireName = r'AdminStatsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminStatsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.members != null) {
      yield r'members';
      yield serializers.serialize(
        object.members,
        specifiedType: const FullType(num),
      );
    }
    if (object.appointments != null) {
      yield r'appointments';
      yield serializers.serialize(
        object.appointments,
        specifiedType: const FullType(num),
      );
    }
    if (object.recentMembers != null) {
      yield r'recentMembers';
      yield serializers.serialize(
        object.recentMembers,
        specifiedType: const FullType(BuiltList, [FullType(AdminStatsGet200ResponseRecentMembersInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminStatsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminStatsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'members':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.members = valueDes;
          break;
        case r'appointments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.appointments = valueDes;
          break;
        case r'recentMembers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminStatsGet200ResponseRecentMembersInner)]),
          ) as BuiltList<AdminStatsGet200ResponseRecentMembersInner>;
          result.recentMembers.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminStatsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminStatsGet200ResponseBuilder();
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

