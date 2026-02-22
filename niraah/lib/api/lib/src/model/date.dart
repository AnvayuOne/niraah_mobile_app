//
// SUPPORT FILE FOR GENERATED SDK
//

import 'package:built_value/serializer.dart';
import 'package:intl/intl.dart';

class Date {
  Date(DateTime dateTime) : value = DateTime(dateTime.year, dateTime.month, dateTime.day);

  final DateTime value;

  static Serializer<Date> get serializer => const DateSerializer();

  @override
  String toString() => DateFormat('yyyy-MM-dd').format(value);
}

class DateSerializer implements PrimitiveSerializer<Date> {
  const DateSerializer();

  @override
  Iterable<Type> get types => const <Type>[Date];

  @override
  String get wireName => 'date';

  @override
  Object serialize(
    Serializers serializers,
    Date object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return DateFormat('yyyy-MM-dd').format(object.value);
  }

  @override
  Date deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    if (serialized is DateTime) {
      return Date(serialized);
    }
    if (serialized is String && serialized.isNotEmpty) {
      return Date(DateTime.parse(serialized));
    }
    throw ArgumentError('Unable to deserialize Date from "$serialized"');
  }
}
