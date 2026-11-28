import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cycle/domain/cycle.dart';
import '../domain/home.dart';

enum HomeStatus { loading, ready, failure }

class HomeState extends Equatable {
  const HomeState({this.status = HomeStatus.loading, this.document});

  final HomeStatus status;
  final HomeDocument? document;

  @override
  List<Object?> get props => <Object?>[status, document];
}

/// Loads the Home document and sends her changes back. After each change the
/// document is read again, because the server decides what Home shows.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repo) : super(const HomeState());

  final HomeRepository _repo;

  Future<void> load() async {
    try {
      emit(HomeState(status: HomeStatus.ready, document: await _repo.getHome()));
    } on Exception {
      emit(const HomeState(status: HomeStatus.failure));
    }
  }

  Future<void> _then(Future<void> Function() change) async {
    try {
      await change();
      await load();
    } on Exception {
      emit(HomeState(status: HomeStatus.failure, document: state.document));
    }
  }

  Future<void> logPeriodStart(IsoDate date) => _then(() => _repo.logPeriodStart(date));

  Future<void> saveLog(DailyLogPatch patch) => _then(() => _repo.saveTodayLog(patch));

  Future<void> hidePreScore() => _then(_repo.hidePreScoreCard);
}
