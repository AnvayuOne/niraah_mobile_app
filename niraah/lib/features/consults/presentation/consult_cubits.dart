import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/payments/payment_checkout.dart';
import '../domain/consults.dart';

enum LoadStatus { loading, ready, failure }

/// "Find a specialist" (spec 014 §2, spec 010 §9): the list for her filters, and her included consults by type.
class SpecialistsState extends Equatable {
  const SpecialistsState({this.status = LoadStatus.loading, this.filters = const DirectoryFilters(), this.specialists = const <Specialist>[], this.included = const <IncludedConsults>[], this.error});

  final LoadStatus status;
  final DirectoryFilters filters;
  final List<Specialist> specialists;
  final List<IncludedConsults> included;

  /// What failed: an `AreaLocked` shows the area's "not on your plan" state.
  final Object? error;

  @override
  List<Object?> get props => <Object?>[status, filters, specialists, included, error];
}

class SpecialistsCubit extends Cubit<SpecialistsState> {
  SpecialistsCubit(this._repo) : super(const SpecialistsState());

  final ConsultsRepository _repo;

  Future<void> load([DirectoryFilters? filters]) async {
    final DirectoryFilters f = filters ?? state.filters;
    emit(SpecialistsState(filters: f, included: state.included));
    try {
      final List<Specialist> list = await _repo.specialists(f);
      List<IncludedConsults> included = state.included;
      try {
        included = await _repo.included();
      } on Object {
        // Entitlements only add the "included consults" card; the list stands without them.
      }
      emit(SpecialistsState(status: LoadStatus.ready, filters: f, specialists: list, included: included));
    } on Object catch (e) {
      emit(SpecialistsState(status: LoadStatus.failure, filters: f, included: state.included, error: e));
    }
  }
}

/// Picking a time and holding it (spec 014 §3 "Steps" 1): times are read a week at a time, up to the horizon.
class SlotsState extends Equatable {
  const SlotsState({this.status = LoadStatus.loading, this.from, this.list, this.error, this.holding = false});

  final LoadStatus status;
  final DateTime? from;
  final SlotList? list;
  final Object? error;
  final bool holding;

  SlotsState copyWith({LoadStatus? status, DateTime? from, SlotList? list, Object? error, bool? holding}) =>
      SlotsState(status: status ?? this.status, from: from ?? this.from, list: list ?? this.list, error: error, holding: holding ?? this.holding);

  @override
  List<Object?> get props => <Object?>[status, from, list, error, holding];
}

typedef SlotLoader = Future<SlotList> Function(DateTime from, DateTime to);

class SlotsCubit extends Cubit<SlotsState> {
  SlotsCubit(this._loader, {DateTime Function()? clock, this.horizonDays = 30}) : _clock = clock ?? DateTime.now, super(const SlotsState());

  final SlotLoader _loader;
  final DateTime Function() _clock;
  final int horizonDays;

  static const Duration window = Duration(days: 7);

  bool get canGoLater {
    final DateTime? from = state.from;
    return from != null && from.add(window).isBefore(_clock().add(Duration(days: horizonDays)));
  }

  bool get canGoEarlier {
    final DateTime? from = state.from;
    return from != null && from.isAfter(_clock().add(const Duration(minutes: 1)));
  }

  Future<void> load([DateTime? from]) async {
    final DateTime start = from ?? _clock();
    emit(SlotsState(from: start));
    try {
      emit(SlotsState(status: LoadStatus.ready, from: start, list: await _loader(start, start.add(window))));
    } on Object catch (e) {
      emit(SlotsState(status: LoadStatus.failure, from: start, error: e));
    }
  }

  /// While a time is being held, the times can't be tapped again.
  void holding(bool on) => emit(state.copyWith(holding: on));

  Future<void> later() => load(state.from!.add(window));

  Future<void> earlier() {
    final DateTime back = state.from!.subtract(window);
    final DateTime now = _clock();
    return load(back.isBefore(now) ? now : back);
  }
}

/// Consent, reason and confirmation of a hold (spec 014 §3 "Steps" 2-5). The hold runs out at [Appointment.holdExpiresAt].
class ConfirmState extends Equatable {
  const ConfirmState({required this.appointment, this.consents = const <String>{}, this.busy = false, this.outcome, this.error});

  final Appointment appointment;
  final Set<String> consents;
  final bool busy;
  final ConfirmOutcome? outcome;
  final Object? error;

  @override
  List<Object?> get props => <Object?>[appointment, consents, busy, outcome, error];
}

class ConfirmCubit extends Cubit<ConfirmState> {
  ConfirmCubit(this._repo, Appointment held, {DateTime Function()? clock, Future<void> Function(Duration)? sleep})
      : _clock = clock ?? DateTime.now,
        _sleep = sleep ?? Future<void>.delayed,
        super(ConfirmState(appointment: held));

  final ConsultsRepository _repo;
  final DateTime Function() _clock;
  final Future<void> Function(Duration) _sleep;

  /// Time left on the hold; zero once it has run out (AC10).
  Duration get remaining {
    final DateTime? until = state.appointment.holdExpiresAt;
    if (until == null) return Duration.zero;
    final Duration d = until.difference(_clock());
    return d.isNegative ? Duration.zero : d;
  }

  bool get expired => state.appointment.holdExpiresAt != null && remaining == Duration.zero;

  void toggle(String category, bool on) {
    final Set<String> next = <String>{...state.consents};
    on ? next.add(category) : next.remove(category);
    emit(ConfirmState(appointment: state.appointment, consents: next));
  }

  /// Sends only the categories she agreed to, in the contract's order (AC15).
  Future<ConfirmOutcome?> confirm(String? reason, {bool? recordConsent}) async {
    emit(ConfirmState(appointment: state.appointment, consents: state.consents, busy: true));
    try {
      final ConfirmOutcome o = await _repo.confirm(
        state.appointment.id,
        consents: <String>[for (final String c in consultCategories) if (state.consents.contains(c)) c],
        reason: reason,
        recordConsent: recordConsent,
      );
      emit(ConfirmState(appointment: o is Confirmed ? o.appointment : state.appointment, consents: state.consents, outcome: o));
      return o;
    } on Object catch (e) {
      emit(ConfirmState(appointment: state.appointment, consents: state.consents, error: e));
      return null;
    }
  }

  /// A paid consult (§3 "Steps" 4): the gateway's checkout for the server's order, then the appointment is read from
  /// the server until the verified payment has confirmed it (AC11; spec 008 §5.6). Nothing the phone reports confirms
  /// anything. A cancelled or failed checkout leaves the time held, so she can pay again or give it back.
  Future<PaymentResult> pay(PaymentCheckout gateway, Checkout checkout, {required String description, void Function()? onConfirming}) async {
    emit(ConfirmState(appointment: state.appointment, consents: state.consents, busy: true));
    final PaymentResult r = await payAndConfirm(
      gateway: gateway,
      checkout: checkout,
      description: description,
      onConfirming: onConfirming,
      clock: _clock,
      sleep: _sleep,
      check: () async {
        final Appointment a = await _repo.appointment(state.appointment.id);
        if (a.live) {
          emit(ConfirmState(appointment: a, consents: state.consents, busy: true));
          return ServerPaymentState.confirmed;
        }
        // The hold ran out first: the server refunds a late payment in full (spec 008 §6.3).
        if (a.status == 'expired' || a.status == 'cancelled') return ServerPaymentState.lapsed;
        return ServerPaymentState.waiting;
      },
    );
    emit(ConfirmState(appointment: state.appointment, consents: state.consents, outcome: r.outcome == PaymentOutcome.confirmed ? Confirmed(state.appointment) : state.outcome));
    return r;
  }

  /// Gives the time back (a hold is simply released, §6).
  Future<void> release() async {
    try {
      await _repo.cancel(state.appointment.id);
    } on Object {
      // The hold runs out by itself anyway (AC10).
    }
  }
}

/// Her appointments (spec 010 §9.3), upcoming first, then past.
class AppointmentsState extends Equatable {
  const AppointmentsState({this.status = LoadStatus.loading, this.upcoming = const <Appointment>[], this.past = const <Appointment>[], this.error});

  final LoadStatus status;
  final List<Appointment> upcoming;
  final List<Appointment> past;
  final Object? error;

  @override
  List<Object?> get props => <Object?>[status, upcoming, past, error];
}

class AppointmentsCubit extends Cubit<AppointmentsState> {
  AppointmentsCubit(this._repo, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now, super(const AppointmentsState());

  final ConsultsRepository _repo;
  final DateTime Function() _clock;

  Future<void> load() async {
    emit(const AppointmentsState());
    try {
      final List<Appointment> all = await _repo.appointments();
      final DateTime now = _clock();
      final List<Appointment> upcoming = all.where((Appointment a) => a.upcoming(now)).toList()..sort((Appointment a, Appointment b) => a.startsAt.compareTo(b.startsAt));
      final List<Appointment> past = all.where((Appointment a) => !a.upcoming(now)).toList()..sort((Appointment a, Appointment b) => b.startsAt.compareTo(a.startsAt));
      emit(AppointmentsState(status: LoadStatus.ready, upcoming: upcoming, past: past));
    } on Object catch (e) {
      emit(AppointmentsState(status: LoadStatus.failure, error: e));
    }
  }
}

/// One appointment and what she can do with it (spec 014 §4-§6). Each action reports the server's outcome, and the
/// appointment is read again afterwards, because the server decides the state.
class AppointmentState extends Equatable {
  const AppointmentState({this.status = LoadStatus.loading, this.appointment, this.busy = false, this.error, this.failure});

  final LoadStatus status;
  final Appointment? appointment;
  final bool busy;
  final Object? error;

  /// After "the call did not work": what she may choose (§6 "Technical failure").
  final FailureReport? failure;

  AppointmentState copyWith({LoadStatus? status, Appointment? appointment, bool? busy, FailureReport? failure}) =>
      AppointmentState(status: status ?? this.status, appointment: appointment ?? this.appointment, busy: busy ?? this.busy, failure: failure ?? this.failure);

  @override
  List<Object?> get props => <Object?>[status, appointment, busy, error, failure];
}

/// The result of an action: the server's outcome key, or its words when refused.
class ActionResult {
  const ActionResult.ok([this.outcome]) : error = null;
  const ActionResult.refused(Object this.error) : outcome = null;

  final String? outcome;
  final Object? error;

  bool get ok => error == null;
}

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit(this._repo, this.id, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now, super(const AppointmentState());

  final ConsultsRepository _repo;
  final String id;
  final DateTime Function() _clock;

  DateTime get now => _clock();

  Future<void> load() async {
    try {
      emit(state.copyWith(status: LoadStatus.ready, appointment: await _repo.appointment(id), busy: false));
    } on Object catch (e) {
      emit(AppointmentState(status: LoadStatus.failure, appointment: state.appointment, error: e, failure: state.failure));
    }
  }

  Future<ActionResult> _run(Future<String?> Function() action) async {
    emit(state.copyWith(busy: true));
    try {
      final String? outcome = await action();
      await load();
      return ActionResult.ok(outcome);
    } on Object catch (e) {
      emit(state.copyWith(busy: false));
      return ActionResult.refused(e);
    }
  }

  /// `released`, `refunded`, `unit_returned` or `kept` (AC35).
  Future<ActionResult> cancel() => _run(() => _repo.cancel(id));

  /// Up to the cut-off, at most the set number of times (AC34); the server refuses otherwise.
  Future<ActionResult> reschedule(DateTime to) => _run(() async {
        await _repo.reschedule(id, to);
        return 'moved';
      });

  Future<ActionResult> acceptProposal() => _run(() async {
        await _repo.acceptProposal(id);
        return 'moved';
      });

  /// Her money or her unit back instead of another time (AC37, AC38).
  Future<ActionResult> declineOffer() => _run(() => _repo.declineOffer(id));

  /// Another time; the new appointment carries over what was paid or used. Returns the new appointment's id.
  Future<ActionResult> rebook(DateTime to) async {
    emit(state.copyWith(busy: true));
    try {
      final Appointment next = await _repo.rebook(id, to);
      emit(state.copyWith(busy: false));
      return ActionResult.ok(next.id);
    } on Object catch (e) {
      emit(state.copyWith(busy: false));
      return ActionResult.refused(e);
    }
  }

  /// "The call did not work" (§6 "Technical failure"), within 24 hours of the consult.
  Future<ActionResult> reportFailure() async {
    emit(state.copyWith(busy: true));
    try {
      final FailureReport r = await _repo.reportFailure(id);
      emit(state.copyWith(busy: false, failure: r));
      return ActionResult.ok(r.memberChoice ? 'member_choice' : 'waiting');
    } on Object catch (e) {
      emit(state.copyWith(busy: false));
      return ActionResult.refused(e);
    }
  }

  Future<ActionResult> rate(int rating, String? comment) => _run(() async {
        await _repo.rate(id, rating, comment);
        return 'rated';
      });

  /// Whether "the call did not work" can still be reported: from the start until a day after the end.
  bool get canReportFailure {
    final Appointment? a = state.appointment;
    if (a == null || !<String>['confirmed', 'in_progress', 'completed', 'no_show'].contains(a.status)) return false;
    final DateTime t = now;
    return !t.isBefore(a.startsAt) && t.isBefore(a.endsAt.add(const Duration(days: 1)));
  }
}
