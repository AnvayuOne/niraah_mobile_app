// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SymptomEntry extends SymptomEntry {
  @override
  final String? id;
  @override
  final DateTime? date;
  @override
  final SymptomEntrySymptoms? symptoms;
  @override
  final String? notes;

  factory _$SymptomEntry([void Function(SymptomEntryBuilder)? updates]) =>
      (SymptomEntryBuilder()..update(updates))._build();

  _$SymptomEntry._({this.id, this.date, this.symptoms, this.notes}) : super._();
  @override
  SymptomEntry rebuild(void Function(SymptomEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SymptomEntryBuilder toBuilder() => SymptomEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SymptomEntry &&
        id == other.id &&
        date == other.date &&
        symptoms == other.symptoms &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, symptoms.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SymptomEntry')
          ..add('id', id)
          ..add('date', date)
          ..add('symptoms', symptoms)
          ..add('notes', notes))
        .toString();
  }
}

class SymptomEntryBuilder
    implements Builder<SymptomEntry, SymptomEntryBuilder> {
  _$SymptomEntry? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _date;
  DateTime? get date => _$this._date;
  set date(DateTime? date) => _$this._date = date;

  SymptomEntrySymptomsBuilder? _symptoms;
  SymptomEntrySymptomsBuilder get symptoms =>
      _$this._symptoms ??= SymptomEntrySymptomsBuilder();
  set symptoms(SymptomEntrySymptomsBuilder? symptoms) =>
      _$this._symptoms = symptoms;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  SymptomEntryBuilder() {
    SymptomEntry._defaults(this);
  }

  SymptomEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _date = $v.date;
      _symptoms = $v.symptoms?.toBuilder();
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SymptomEntry other) {
    _$v = other as _$SymptomEntry;
  }

  @override
  void update(void Function(SymptomEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SymptomEntry build() => _build();

  _$SymptomEntry _build() {
    _$SymptomEntry _$result;
    try {
      _$result =
          _$v ??
          _$SymptomEntry._(
            id: id,
            date: date,
            symptoms: _symptoms?.build(),
            notes: notes,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'symptoms';
        _symptoms?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SymptomEntry',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
