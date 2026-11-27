// SAMPLE "server" scoring (spec 005 "Dimensions, weights and the total").
// Generic: it reads weights, dimensions, bands, levels and flags from the
// scoring document and never refers to a question key or option value.

import 'dart:math' as math;

import '../features/assessment/domain/display_conditions.dart';
import '../features/assessment/domain/prescore.dart';
import '../features/assessment/domain/questionnaire.dart';

class ScoredDimension {
  const ScoredDimension({required this.key, required this.name, required this.raw, required this.maximum, required this.level});

  final String key;
  final String name;
  final double raw;
  final double maximum;
  final String level;

  /// Percentage of the (possibly reduced) maximum reached.
  double get percent => maximum <= 0 ? 100 : raw / maximum * 100;
}

class ScoreResult {
  const ScoreResult({
    required this.total,
    required this.totalMaximum,
    required this.band,
    required this.bandFallbackObservation,
    required this.dimensions,
    required this.flags,
    required this.flagObservations,
    required this.program,
    required this.keptAnswers,
  });

  final int total;
  final int totalMaximum;
  final Band band;
  final String bandFallbackObservation;
  final List<ScoredDimension> dimensions;
  final List<RaisedFlag> flags;
  final List<String> flagObservations;
  final String? program;

  /// Answers after the server discarded those to hidden questions.
  final Answers keptAnswers;

  /// Rule-based observations: the band's, then each flag's, at most four.
  List<String> get fallbackObservations => <String>[bandFallbackObservation, ...flagObservations].take(4).toList(growable: false);
}

class SampleScorer {
  SampleScorer(this.scoring);

  /// The parsed scoring document (design/sample/onboarding-scoring.json shape).
  final Map<String, dynamic> scoring;

  Map<String, dynamic> get _weights => scoring['weights'] as Map<String, dynamic>;

  /// Weight [option] of [question] gives [dimension]; zero when none.
  double _w(String question, String option, String dimension) {
    final Map<String, dynamic>? q = _weights[question] as Map<String, dynamic>?;
    final Map<String, dynamic>? o = q?[option] as Map<String, dynamic>?;
    return ((o?[dimension] as num?) ?? 0).toDouble();
  }

  /// The most a question can add to [dimension] with any allowed answer.
  double _highestContribution(Question q, String dimension) {
    if (q.options.isEmpty) return 0;
    if (q.type == QuestionType.multipleChoice) {
      final double together = q.options
          .where((AnswerOption o) => !o.exclusive)
          .fold<double>(0, (double s, AnswerOption o) => s + math.max(0, _w(q.key, o.value, dimension)));
      final double exclusive = q.options
          .where((AnswerOption o) => o.exclusive)
          .fold<double>(0, (double m, AnswerOption o) => math.max(m, _w(q.key, o.value, dimension)));
      return math.max(together, exclusive);
    }
    return q.options.fold<double>(0, (double m, AnswerOption o) => math.max(m, _w(q.key, o.value, dimension)));
  }

  ScoreResult score(QuestionnaireDocument doc, Answers submitted) {
    final Answers kept = DisplayConditions.withoutHidden(doc, submitted);
    final List<Question> hidden = doc.questions.where((Question q) => !DisplayConditions.isVisible(q, kept)).toList();

    final List<Map<String, dynamic>> dims = (scoring['dimensions'] as List<dynamic>).cast<Map<String, dynamic>>();
    final List<Map<String, dynamic>> levels = (scoring['levels'] as List<dynamic>).cast<Map<String, dynamic>>()
      ..sort((Map<String, dynamic> a, Map<String, dynamic> b) => (b['from'] as num).compareTo(a['from'] as num));
    final int totalMax = scoring['totalMaximum'] as int;

    String levelFor(double pct) {
      for (Map<String, dynamic> l in levels) {
        if (pct >= (l['from'] as num)) return l['label'] as String;
      }
      return levels.last['label'] as String;
    }

    double weighted = 0;
    final List<ScoredDimension> scored = <ScoredDimension>[];
    for (Map<String, dynamic> d in dims) {
      final String key = d['key'] as String;
      double max = (d['maximum'] as num).toDouble();
      for (Question q in hidden) {
        max -= _highestContribution(q, key);
      }
      double raw = 0;
      kept.forEach((String qKey, Answer a) {
        for (String v in a.values) {
          raw += _w(qKey, v, key);
        }
      });
      raw = raw.clamp(0, math.max(0, max)).toDouble();
      final double ratio = max <= 0 ? 1 : raw / max;
      weighted += ratio * (d['share'] as num);
      scored.add(ScoredDimension(key: key, name: d['name'] as String, raw: raw, maximum: max, level: levelFor(ratio * 100)));
    }
    final int total = (weighted * totalMax / 100).round();

    final Map<String, dynamic> band = (scoring['bands'] as List<dynamic>).cast<Map<String, dynamic>>().firstWhere(
          (Map<String, dynamic> b) => total >= (b['min'] as num) && total <= (b['max'] as num),
        );

    final Map<String, dynamic> raised = scoring['flagsRaised'] as Map<String, dynamic>;
    final Map<String, dynamic> catalogue = scoring['flags'] as Map<String, dynamic>;
    final List<String> flagKeys = <String>[];
    kept.forEach((String qKey, Answer a) {
      final Map<String, dynamic>? byOption = raised[qKey] as Map<String, dynamic>?;
      for (String v in a.values) {
        for (final dynamic f in (byOption?[v] as List<dynamic>?) ?? const <dynamic>[]) {
          if (!flagKeys.contains(f)) flagKeys.add(f as String);
        }
      }
    });
    final List<RaisedFlag> flags = <RaisedFlag>[];
    final List<String> flagObs = <String>[];
    for (String k in flagKeys) {
      final Map<String, dynamic> f = catalogue[k] as Map<String, dynamic>;
      flags.add(RaisedFlag(key: k, severity: severityFrom(f['severity'] as String), careMessage: f['careMessage'] as String?));
      if (f['fallbackObservation'] != null) flagObs.add(f['fallbackObservation'] as String);
    }

    String? program;
    for (final dynamic r in (scoring['programRules'] as List<dynamic>?) ?? const <dynamic>[]) {
      final Map<String, dynamic> rule = r as Map<String, dynamic>;
      final List<dynamic> whenFlags = (rule['whenFlags'] as List<dynamic>?) ?? const <dynamic>[];
      final Map<String, dynamic> below = (rule['whenDimensionBelow'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
      final bool flagHit = whenFlags.any(flagKeys.contains);
      final bool dimHit = below.entries.any((MapEntry<String, dynamic> e) {
        final ScoredDimension? d = scored.where((ScoredDimension s) => s.key == e.key).firstOrNull;
        return d != null && d.percent < (e.value as num);
      });
      if (flagHit || dimHit) {
        program = rule['name'] as String;
        break;
      }
    }

    return ScoreResult(
      total: total,
      totalMaximum: totalMax,
      band: Band(label: band['label'] as String, message: band['message'] as String, colorToken: band['color'] as String),
      bandFallbackObservation: band['fallbackObservation'] as String,
      dimensions: scored,
      flags: flags,
      flagObservations: flagObs,
      program: program,
      keptAnswers: kept,
    );
  }
}
