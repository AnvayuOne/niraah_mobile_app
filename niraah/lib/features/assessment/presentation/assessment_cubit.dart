import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/helpers/result.dart';
import '../domain/assessment_repository.dart';
import '../domain/display_conditions.dart';
import '../domain/prescore.dart';
import '../domain/questionnaire.dart';

enum AssessmentStatus { initial, loading, ready, saving, minimumAge, submitting, done, failure }

class AssessmentState extends Equatable {
  const AssessmentState({
    this.status = AssessmentStatus.initial,
    this.session,
    this.answers = const <String, Answer>{},
    this.currentKey,
    this.preScore,
    this.failure,
  });

  final AssessmentStatus status;
  final AssessmentSession? session;
  final Answers answers;
  final String? currentKey;
  final PreScore? preScore;
  final String? failure;

  QuestionnaireDocument? get document => session?.document;

  List<Question> get visible => document == null ? const <Question>[] : DisplayConditions.visible(document!, answers);

  Question? get current => currentKey == null ? null : document?.question(currentKey!);

  /// 1-based step among the questions she will currently see.
  int get step => visible.indexWhere((Question q) => q.key == currentKey) + 1;

  bool get isLast => step == visible.length;

  AssessmentState copyWith({
    AssessmentStatus? status,
    AssessmentSession? session,
    Answers? answers,
    String? currentKey,
    PreScore? preScore,
    String? failure,
  }) =>
      AssessmentState(
        status: status ?? this.status,
        session: session ?? this.session,
        answers: answers ?? this.answers,
        currentKey: currentKey ?? this.currentKey,
        preScore: preScore ?? this.preScore,
        failure: failure,
      );

  @override
  List<Object?> get props => <Object?>[status, session, answers, currentKey, preScore, failure];
}

/// What moving on from a question led to.
enum Advance { nextQuestion, readyToSubmit, minimumAge, failed }

class AssessmentCubit extends Cubit<AssessmentState> {
  AssessmentCubit(this._repo, {this.summaryWait = const Duration(seconds: 20), this.pollEvery = const Duration(seconds: 1)})
      : super(const AssessmentState());

  final AssessmentRepository _repo;

  /// How long the processing screen waits for the AI summary (spec 007 §4).
  final Duration summaryWait;
  final Duration pollEvery;

  Future<void> load() async {
    if (state.session != null) return;
    emit(state.copyWith(status: AssessmentStatus.loading));
    final Result<AssessmentSession> r = await _repo.startOrResume();
    switch (r) {
      case Success<AssessmentSession>(:final AssessmentSession data):
        final List<Question> vis = DisplayConditions.visible(data.document, data.answers);
        final Question first = vis.firstWhere((Question q) => !data.answers.containsKey(q.key), orElse: () => vis.last);
        emit(AssessmentState(status: AssessmentStatus.ready, session: data, answers: data.answers, currentKey: first.key));
      case FailureResult<AssessmentSession>(:final String message):
        emit(state.copyWith(status: AssessmentStatus.failure, failure: message));
    }
  }

  Future<bool> recordConsent({required bool healthData, required bool doctorReview}) async {
    final AssessmentSession? s = state.session;
    if (s == null) return false;
    final Result<void> r = await _repo.recordConsent(healthData: healthData, doctorReview: doctorReview, textVersion: s.consentTextVersion);
    return r is Success<void>;
  }

  /// Sets an answer. A changed answer that hides later questions discards
  /// their answers (spec 007 §2.5).
  void answer(String key, Answer value) {
    final QuestionnaireDocument? doc = state.document;
    if (doc == null) return;
    final Answers next = Map<String, Answer>.of(state.answers)..[key] = value;
    emit(state.copyWith(answers: DisplayConditions.withoutHidden(doc, next)));
  }

  void clearAnswer(String key) {
    final QuestionnaireDocument? doc = state.document;
    if (doc == null) return;
    final Answers next = Map<String, Answer>.of(state.answers)..remove(key);
    emit(state.copyWith(answers: DisplayConditions.withoutHidden(doc, next)));
  }

  /// Saves the current answer and moves on.
  Future<Advance> next() async {
    final AssessmentSession? s = state.session;
    final Question? q = state.current;
    if (s == null || q == null) return Advance.failed;
    final Answer? a = state.answers[q.key];
    if (a != null) {
      emit(state.copyWith(status: AssessmentStatus.saving));
      final Result<SaveOutcome> r = await _repo.saveAnswer(s.assessmentId, q.key, a);
      if (r case FailureResult<SaveOutcome>(:final String message)) {
        emit(state.copyWith(status: AssessmentStatus.ready, failure: message));
        return Advance.failed;
      }
      if ((r as Success<SaveOutcome>).data == SaveOutcome.minimumAgeStop) {
        emit(state.copyWith(status: AssessmentStatus.minimumAge, answers: const <String, Answer>{}));
        return Advance.minimumAge;
      }
    }
    final List<Question> vis = state.visible;
    final int i = vis.indexWhere((Question x) => x.key == q.key);
    if (i < vis.length - 1) {
      emit(state.copyWith(status: AssessmentStatus.ready, currentKey: vis[i + 1].key));
      return Advance.nextQuestion;
    }
    emit(state.copyWith(status: AssessmentStatus.ready));
    return Advance.readyToSubmit;
  }

  /// Goes back one question. Returns false at the first question.
  bool back() {
    final List<Question> vis = state.visible;
    final int i = vis.indexWhere((Question x) => x.key == state.currentKey);
    if (i <= 0) return false;
    emit(state.copyWith(currentKey: vis[i - 1].key));
    return true;
  }

  /// Submits, then waits up to [summaryWait] for the AI's observations. If
  /// they do not come, the rule-based observations stay (spec 007 §4).
  Future<bool> submitAndWait() async {
    final AssessmentSession? s = state.session;
    if (s == null) return false;
    emit(state.copyWith(status: AssessmentStatus.submitting));
    final Result<PreScore> r = await _repo.submit(s.assessmentId, state.answers);
    if (r case FailureResult<PreScore>(:final String message)) {
      emit(state.copyWith(status: AssessmentStatus.failure, failure: message));
      return false;
    }
    PreScore p = (r as Success<PreScore>).data;
    final DateTime until = DateTime.now().add(summaryWait);
    while (DateTime.now().isBefore(until)) {
      final Result<List<String>?> ai = await _repo.aiObservations(p.id);
      if (ai case Success<List<String>?>(:final List<String>? data) when data != null && data.isNotEmpty) {
        p = p.withObservations(data, ObservationSource.ai);
        break;
      }
      await Future<void>.delayed(pollEvery);
    }
    emit(state.copyWith(status: AssessmentStatus.done, preScore: p));
    return true;
  }
}
