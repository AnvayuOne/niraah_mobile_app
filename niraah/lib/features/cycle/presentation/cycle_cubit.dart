import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/cycle.dart';

enum CycleStatus { loading, ready, failure }

class CycleState extends Equatable {
  const CycleState({this.status = CycleStatus.loading, this.document});

  final CycleStatus status;
  final CycleDocument? document;

  @override
  List<Object?> get props => <Object?>[status, document];
}

/// Loads the Cycle document and re-reads it after every change, because the
/// server decides the summary, history and advice.
class CycleCubit extends Cubit<CycleState> {
  CycleCubit(this._repo) : super(const CycleState());

  final CycleRepository _repo;

  Future<void> load() async {
    try {
      emit(CycleState(status: CycleStatus.ready, document: await _repo.getCycle()));
    } on Exception {
      emit(const CycleState(status: CycleStatus.failure));
    }
  }

  Future<PeriodSaveResult> savePeriod(Period p, {IsoDate? replacing}) async {
    final PeriodSaveResult r = await _repo.savePeriod(p, replacing: replacing);
    if (r.ok) await load();
    return r;
  }

  Future<void> deletePeriod(IsoDate start) async {
    await _repo.deletePeriod(start);
    await load();
  }

  Future<void> setMarkers(List<CycleMarker> markers) async {
    await _repo.setMarkers(markers);
    await load();
  }

  Future<void> saveDailyLog(IsoDate date, DailyLogPatch patch) async {
    await _repo.saveDailyLog(date, patch);
    await load();
  }
}
