import '../../../core/network/niraah_api.dart';
import '../../../shared/area/area_access.dart';
import '../domain/care.dart';

/// Programs, care plan, tasks and check-ins on `/api/v1` (spec 010 §10, §11).
class ApiCareRepository implements CareRepository {
  ApiCareRepository(this._api);

  final NiraahApi _api;

  @override
  Future<ProgramsDocument> programs() async {
    final Map<String, dynamic> r = (await _api.get('/me/programs')).orArea();
    return ProgramsDocument(
      programs: <Program>[
        for (final dynamic p in r['programs'] as List<dynamic>)
          Program(
            id: (p as Map<String, dynamic>)['id'] as String,
            name: p['name'] as String,
            description: p['description'] as String,
            weeks: (p['weeks'] as num?)?.toInt(),
            suggested: p['suggested'] as bool,
          ),
      ],
      enrolment: _enrolment(r['enrolment']),
    );
  }

  @override
  Future<Enrolment?> enrol(String programId, {String? startOn}) async =>
      _enrolment((await _api.post('/me/programs/enrolment', <String, dynamic>{'programId': programId, 'startOn': ?startOn})).orArea()['enrolment']);

  @override
  Future<Enrolment?> setProgramStatus(String status) async => _enrolment((await _api.put('/me/programs/enrolment/status', <String, dynamic>{'status': status})).orArea()['enrolment']);

  @override
  Future<CarePlanDocument> carePlan() async {
    final Map<String, dynamic> r = (await _api.get('/me/care-plan')).orArea();
    final Map<String, dynamic>? p = r['plan'] as Map<String, dynamic>?;
    return CarePlanDocument(
      plan: p == null
          ? null
          : SignedPlan(
              doctor: p['doctor'] as String?,
              signedOn: p['signedOn'] as String,
              sections: <CarePlanSection>[
                for (final dynamic s in p['sections'] as List<dynamic>) CarePlanSection(kind: (s as Map<String, dynamic>)['kind'] as String, text: s['text'] as String),
              ],
            ),
      waiting: r['waiting'] as String?,
      history: <({String doctor, String signedOn})>[
        for (final dynamic h in r['history'] as List<dynamic>) (doctor: ((h as Map<String, dynamic>)['doctor'] as String?) ?? '', signedOn: h['signedOn'] as String),
      ],
    );
  }

  @override
  Future<CareTasks> tasks() async {
    final Map<String, dynamic> r = (await _api.get('/me/tasks')).orArea();
    final List<dynamic>? today = r['today'] as List<dynamic>?;
    return CareTasks(
      today: today == null
          ? null
          : <CareTask>[for (final dynamic t in today) CareTask(id: (t as Map<String, dynamic>)['id'] as String, title: t['title'] as String, done: t['done'] as bool)],
      week: <({String date, int done})>[
        for (final dynamic d in r['week'] as List<dynamic>) (date: (d as Map<String, dynamic>)['date'] as String, done: (d['done'] as num).toInt()),
      ],
    );
  }

  @override
  Future<void> tick(String taskId, bool done) async => (await _api.put('/me/tasks/${Uri.encodeComponent(taskId)}', <String, dynamic>{'done': done})).orArea();

  @override
  Future<CheckInsDocument> checkIns() async {
    final Map<String, dynamic> r = (await _api.get('/me/check-ins')).orArea();
    final Map<String, dynamic>? due = r['due'] as Map<String, dynamic>?;
    return CheckInsDocument(
      due: due == null ? null : CheckInDue(weekStart: due['weekStart'] as String, fields: (due['fields'] as List<dynamic>).cast<String>()),
      trend: _trend(r['trend']),
    );
  }

  @override
  Future<List<TrendPoint>> submitCheckIn(CheckInAnswers a) async => _trend((await _api.post('/me/check-ins', <String, dynamic>{
        'weightKg': ?a.weightKg,
        'waistCm': ?a.waistCm,
        'energy': ?a.energy,
        'cravings': ?a.cravings,
        'note': ?a.note,
      }))
          .orArea()['trend']);

  static List<TrendPoint> _trend(Object? list) => <TrendPoint>[
        for (final dynamic t in list as List<dynamic>)
          TrendPoint(
            week: (t as Map<String, dynamic>)['week'] as String,
            energy: (t['energy'] as num?)?.toInt(),
            cravings: (t['cravings'] as num?)?.toInt(),
            weightKg: (t['weightKg'] as num?)?.toDouble(),
            waistCm: (t['waistCm'] as num?)?.toDouble(),
          ),
      ];

  static Enrolment? _enrolment(Object? e) {
    if (e is! Map<String, dynamic>) return null;
    return Enrolment(
      programId: e['programId'] as String,
      name: e['name'] as String,
      status: e['status'] as String,
      startedOn: e['startedOn'] as String,
      week: (e['week'] as num).toInt(),
      weeks: (e['weeks'] as num?)?.toInt(),
    );
  }
}
