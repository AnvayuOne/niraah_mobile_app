// SAMPLE ONLY. One in-memory store shared by the sample Home, Cycle and
// Symptoms repositories, like apps/web/src/sample/store.ts, so a change on one
// screen shows on the others.

import '../features/chat/domain/chat.dart';
import '../features/cycle/domain/cycle.dart';

class SampleSymptomLog {
  const SampleSymptomLog({required this.id, required this.date, required this.symptom, required this.severity, this.note});

  final String id;
  final IsoDate date;
  final String symptom;
  final int severity;
  final String? note;
}

class SampleStore {
  final List<Period> periods = <Period>[];
  final List<CycleMarker> markers = <CycleMarker>[];
  final Map<IsoDate, DailyLog> dailyLogs = <IsoDate, DailyLog>{};
  final List<SampleSymptomLog> symptomLogs = <SampleSymptomLog>[];

  /// AI Care conversations, and today's message use (resets each day).
  final List<Conversation> conversations = <Conversation>[];
  IsoDate? chatUseDate;
  int chatUseCount = 0;

  /// The privacy setting "personalised AI" (web key
  /// niraah.sample.privacy.personalisedAi), on by default.
  bool personalisedAi = true;

  int _nextId = 0;

  String newId() => 'sample-${_nextId++}';
}
