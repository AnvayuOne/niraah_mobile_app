// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PlanTypeEnum _$planTypeEnum_DIET = const PlanTypeEnum._('DIET');
const PlanTypeEnum _$planTypeEnum_EXERCISE = const PlanTypeEnum._('EXERCISE');
const PlanTypeEnum _$planTypeEnum_MEDICATION = const PlanTypeEnum._(
  'MEDICATION',
);
const PlanTypeEnum _$planTypeEnum_SUPPLEMENT = const PlanTypeEnum._(
  'SUPPLEMENT',
);

PlanTypeEnum _$planTypeEnumValueOf(String name) {
  switch (name) {
    case 'DIET':
      return _$planTypeEnum_DIET;
    case 'EXERCISE':
      return _$planTypeEnum_EXERCISE;
    case 'MEDICATION':
      return _$planTypeEnum_MEDICATION;
    case 'SUPPLEMENT':
      return _$planTypeEnum_SUPPLEMENT;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlanTypeEnum> _$planTypeEnumValues =
    BuiltSet<PlanTypeEnum>(const <PlanTypeEnum>[
      _$planTypeEnum_DIET,
      _$planTypeEnum_EXERCISE,
      _$planTypeEnum_MEDICATION,
      _$planTypeEnum_SUPPLEMENT,
    ]);

Serializer<PlanTypeEnum> _$planTypeEnumSerializer = _$PlanTypeEnumSerializer();

class _$PlanTypeEnumSerializer implements PrimitiveSerializer<PlanTypeEnum> {
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
  final Iterable<Type> types = const <Type>[PlanTypeEnum];
  @override
  final String wireName = 'PlanTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PlanTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PlanTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PlanTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$Plan extends Plan {
  @override
  final String? id;
  @override
  final String? memberId;
  @override
  final PlanTypeEnum? type;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final Date? startDate;
  @override
  final Date? endDate;

  factory _$Plan([void Function(PlanBuilder)? updates]) =>
      (PlanBuilder()..update(updates))._build();

  _$Plan._({
    this.id,
    this.memberId,
    this.type,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
  }) : super._();
  @override
  Plan rebuild(void Function(PlanBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlanBuilder toBuilder() => PlanBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Plan &&
        id == other.id &&
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
    _$hash = $jc(_$hash, id.hashCode);
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
    return (newBuiltValueToStringHelper(r'Plan')
          ..add('id', id)
          ..add('memberId', memberId)
          ..add('type', type)
          ..add('title', title)
          ..add('description', description)
          ..add('startDate', startDate)
          ..add('endDate', endDate))
        .toString();
  }
}

class PlanBuilder implements Builder<Plan, PlanBuilder> {
  _$Plan? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _memberId;
  String? get memberId => _$this._memberId;
  set memberId(String? memberId) => _$this._memberId = memberId;

  PlanTypeEnum? _type;
  PlanTypeEnum? get type => _$this._type;
  set type(PlanTypeEnum? type) => _$this._type = type;

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

  PlanBuilder() {
    Plan._defaults(this);
  }

  PlanBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
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
  void replace(Plan other) {
    _$v = other as _$Plan;
  }

  @override
  void update(void Function(PlanBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Plan build() => _build();

  _$Plan _build() {
    final _$result =
        _$v ??
        _$Plan._(
          id: id,
          memberId: memberId,
          type: type,
          title: title,
          description: description,
          startDate: startDate,
          endDate: endDate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
