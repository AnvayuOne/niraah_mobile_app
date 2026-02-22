import 'package:built_value/serializer.dart';

Object? encodeQueryParameter(
  Serializers serializers,
  Object? value,
  FullType specifiedType,
) {
  if (value == null) {
    return null;
  }

  final Object? serialized = serializers.serialize(
    value,
    specifiedType: specifiedType,
  );
  if (serialized == null) {
    return null;
  }
  return serialized.toString();
}
