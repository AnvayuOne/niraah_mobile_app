// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plans_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PlansPostRequestTypeEnum _$plansPostRequestTypeEnum_DIET =
    const PlansPostRequestTypeEnum._('DIET');
const PlansPostRequestTypeEnum _$plansPostRequestTypeEnum_EXERCISE =
    const PlansPostRequestTypeEnum._('EXERCISE');
const PlansPostRequestTypeEnum _$plansPostRequestTypeEnum_MEDICATION =
    const PlansPostRequestTypeEnum._('MEDICATION');
const PlansPostRequestTypeEnum _$plansPostRequestTypeEnum_SUPPLEMENT =
    const PlansPostRequestTypeEnum._('SUPPLEMENT');

PlansPostRequestTypeEnum _$plansPostRequestTypeEnumValueOf(String name) {
  switch (name) {
    case 'DIET':
      return _$plansPostRequestTypeEnum_DIET;
    case 'EXERCISE':
      return _$plansPostRequestTypeEnum_EXERCISE;
    case 'MEDICATION':
      return _$plansPostRequestTypeEnum_MEDICATION;
    case 'SUPPLEMENT':
      return _$plansPostRequestTypeEnum_SUPPLEMENT;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlansPostRequestTypeEnum> _$plansPostRequestTypeEnumValues =
    BuiltSet<PlansPostRequestTypeEnum>(const <PlansPostRequestTypeEnum>[
      _$plansPostRequestTypeEnum_DIET,
      _$plansPostRequestTypeEnum_EXERCISE,
      _$plansPostRequestTypeEnum_MEDICATION,
      _$plansPostRequestTypeEnum_SUPPLEMENT,
    ]);

Serializer<PlansPostRequestTypeEnum> _$plansPostRequestTypeEnumSerializer =
    _$PlansPostRequestTypeEnumSerializer();

class _$PlansPostRequestTypeEnumSerializer
    implements PrimitiveSerializer<PlansPostRequestTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'DIET': 'DIET',
    'EXERCISE': 'EXERCISE',
    'MEDICATION': 'MEDICATION',
    'SUPPLEMENT': 'SUPPLEMENT',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'DIET': 'DIET',
    'EXERCISE': 'EXERCISE',
    'MEDICATION': 'MEDICATION',
    'SUPPLEMENT': 'SUPPLEMENT',
  };

  @override
  final Iterable<Type> types = const <Type>[PlansPostRequestTypeEnum];
  @override
  final String wireName = 'PlansPostRequestTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PlansPostRequestTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PlansPostRequestTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PlansPostRequestTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PlansPostRequest extends PlansPostRequest {
  @override
  final String memberId;
  @override
  final PlansPostRequestTypeEnum type;
  @override
  final String title;
  @override
  final String? description;
  @override
  final Date? startDate;
  @override
  final Date? endDate;

  factory _$PlansPostRequest([
    void Function(PlansPostRequestBuilder)? updates,
  ]) => (PlansPostRequestBuilder()..update(updates))._build();

  _$PlansPostRequest._({
    required this.memberId,
    required this.type,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
  }) : super._();
  @override
  PlansPostRequest rebuild(void Function(PlansPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlansPostRequestBuilder toBuilder() =>
      PlansPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlansPostRequest &&
        memberId == other.memberId &&
        type == other.type &&
        title == other.title &&
        description == other.description &&
        startDate == other.startDate &&
        endDate == other.endDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, memberId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlansPostRequest')
          ..add('memberId', memberId)
          ..add('type', type)
          ..add('title', title)
          ..add('description', description)
          ..add('startDate', startDate)
          ..add('endDate', endDate))
        .toString();
  }
}

class PlansPostRequestBuilder
    implements Builder<PlansPostRequest, PlansPostRequestBuilder> {
  _$PlansPostRequest? _$v;

  String? _memberId;
  String? get memberId => _$this._memberId;
  set memberId(String? memberId) => _$this._memberId = memberId;

  PlansPostRequestTypeEnum? _type;
  PlansPostRequestTypeEnum? get type => _$this._type;
  set type(PlansPostRequestTypeEnum? type) => _$this._type = type;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  Date? _startDate;
  Date? get startDate => _$this._startDate;
  set startDate(Date? startDate) => _$this._startDate = startDate;

  Date? _endDate;
  Date? get endDate => _$this._endDate;
  set endDate(Date? endDate) => _$this._endDate = endDate;

  PlansPostRequestBuilder() {
    PlansPostRequest._defaults(this);
  }

  PlansPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _memberId = $v.memberId;
      _type = $v.type;
      _title = $v.title;
      _description = $v.description;
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlansPostRequest other) {
    _$v = other as _$PlansPostRequest;
  }

  @override
  void update(void Function(PlansPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlansPostRequest build() => _build();

  _$PlansPostRequest _build() {
    final _$result =
        _$v ??
        _$PlansPostRequest._(
          memberId: BuiltValueNullFieldError.checkNotNull(
            memberId,
            r'PlansPostRequest',
            'memberId',
          ),
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'PlansPostRequest',
            'type',
          ),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'PlansPostRequest',
            'title',
          ),
          description: description,
          startDate: startDate,
          endDate: endDate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
