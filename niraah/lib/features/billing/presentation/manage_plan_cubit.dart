import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/billing.dart';

enum PlanStatus { loading, ready, failure }

class ManagePlanState extends Equatable {
  const ManagePlanState({this.status = PlanStatus.loading, this.subscription, this.busy = false});

  final PlanStatus status;

  /// Null when she has no plan yet.
  final Subscription? subscription;
  final bool busy;

  @override
  List<Object?> get props => <Object?>[status, subscription, busy];
}

/// The outcome of an action on her plan: the server's date or result, or its words when refused.
class PlanActionResult {
  const PlanActionResult.ok({this.endsAt, this.change}) : error = null;
  const PlanActionResult.refused(Object this.error)
      : endsAt = null,
        change = null;

  final String? endsAt;
  final PlanChange? change;
  final Object? error;

  bool get ok => error == null;
}

/// "Manage plan" (spec 008 §4; spec 010 §5.6): cancel in no more than two steps, undo before the validity ends, change
/// plan. The plan is read again after each action, because the server decides what she holds.
class ManagePlanCubit extends Cubit<ManagePlanState> {
  ManagePlanCubit(this._repo) : super(const ManagePlanState());

  final BillingRepository _repo;

  Future<void> load() async {
    try {
      emit(ManagePlanState(status: PlanStatus.ready, subscription: await _repo.current()));
    } on Object {
      emit(ManagePlanState(status: PlanStatus.failure, subscription: state.subscription));
    }
  }

  Future<PlanActionResult> _run(Future<PlanActionResult> Function() action) async {
    emit(ManagePlanState(status: state.status, subscription: state.subscription, busy: true));
    try {
      final PlanActionResult r = await action();
      await load();
      return r;
    } on Object catch (e) {
      emit(ManagePlanState(status: state.status, subscription: state.subscription));
      return PlanActionResult.refused(e);
    }
  }

  /// She keeps the plan until the returned date; no further charge (AC13).
  Future<PlanActionResult> cancel() => _run(() async => PlanActionResult.ok(endsAt: await _repo.cancel()));

  Future<PlanActionResult> undo() => _run(() async {
        await _repo.undoCancel();
        return const PlanActionResult.ok();
      });

  Future<PlanActionResult> change(String priceId) => _run(() async => PlanActionResult.ok(change: await _repo.change(priceId)));
}
