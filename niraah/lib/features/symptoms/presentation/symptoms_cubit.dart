import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/symptoms.dart';

enum SymptomsStatus { loading, ready, failure }

class SymptomsState extends Equatable {
  const SymptomsState({this.status = SymptomsStatus.loading, this.document});

  final SymptomsStatus status;
  final SymptomsDocument? document;

  @override
  List<Object?> get props => <Object?>[status, document];
}

class SymptomsCubit extends Cubit<SymptomsState> {
  SymptomsCubit(this._repo) : super(const SymptomsState());

  final SymptomsRepository _repo;

  Future<void> load() async {
    try {
      emit(SymptomsState(status: SymptomsStatus.ready, document: await _repo.getSymptoms()));
    } on Exception {
      emit(const SymptomsState(status: SymptomsStatus.failure));
    }
  }

  /// Logs for today; the document is read again after a saved entry.
  Future<SymptomLogResult> log(String symptom, int severity, String? note) async {
    final SymptomsDocument? doc = state.document;
    if (doc == null) return const SymptomLogResult.refused(SymptomLogError.unknownSymptom);
    final SymptomLogResult r = await _repo.logSymptom(date: doc.today, symptom: symptom, severity: severity, note: note);
    if (r.ok) await load();
    return r;
  }
}
