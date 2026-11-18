import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/instructor/instructor_pages.dart';
import 'package:niraah/features/instructor/instructor_repository.dart';
import 'package:niraah/features/provider_work/domain/provider_work.dart';

import '../helpers/fake_api.dart';
import '../helpers/pump_app.dart';

class FakeInstructor implements InstructorRepository {
  @override
  Future<List<Json>> students() async => <Json>[
        <String, dynamic>{
          'id': 'm1',
          'firstName': 'Asha',
          'attendance': <String, dynamic>{'booked': 3, 'attended': 2, 'lastAttended': null},
          'cyclePhase': 'luteal',
          'practiceProgress': <String, dynamic>{'sessionsCompleted': 9, 'currentStreakDays': 2, 'minutesThisMonth': 140},
        },
      ];

  @override
  Future<Json> home() async => <String, dynamic>{
        'today': <Object>[],
        'next': null,
        'needsMe': <String, dynamic>{'requests': 1, 'attendanceToConfirm': 0, 'contentReturned': 2, 'classesWithoutBookings': 0},
      };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> settle(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late FakeAdapter adapter;
  setUp(() => adapter = FakeAdapter());

  test('a class is scheduled with no fee field; cancelling sends the reason (spec 013 AC14, AC16)', () async {
    final ApiInstructorRepository repo = ApiInstructorRepository(fakeApi(adapter));
    adapter
      ..reply(<String, dynamic>{'ids': <String>['c1'], 'seriesId': null})
      ..reply(<String, dynamic>{'cancelled': true, 'late': false});
    await repo.createClass(<String, dynamic>{'title': 'Gentle flow', 'startsAt': '2026-11-20T07:00:00+05:30', 'minutes': 60, 'capacity': 10});
    expect(adapter.lastBody.keys, isNot(contains('fee')));
    await repo.cancel('c1', 'I\'m unwell');
    expect(adapter.last.path, '/instructor/classes/c1/cancel-with-reason');
    expect(adapter.lastBody, <String, dynamic>{'reason': 'I\'m unwell'});
  });

  test('attendance is corrected through spec 014\'s endpoint (AC18)', () async {
    final ApiInstructorRepository repo = ApiInstructorRepository(fakeApi(adapter));
    adapter.reply(<String, dynamic>{'attended': true});
    await repo.correctAttendance('b1', true);
    expect(adapter.last.method, 'PUT');
    expect(adapter.last.path, '/class-bookings/b1/attendance');
  });

  testWidgets('students show the four facts only (spec 013 §5, AC1)', (WidgetTester tester) async {
    await tester.pumpApp(StudentsPage(repository: FakeInstructor()));
    await settle(tester);
    expect(find.text('Asha'), findsOneWidget);
    expect(find.textContaining('attended 2 of 3'), findsOneWidget);
    expect(find.textContaining('luteal phase'), findsOneWidget);
    expect(find.textContaining('140 min this month'), findsOneWidget);
  });

  testWidgets('home shows what needs her as counts (spec 013 §1)', (WidgetTester tester) async {
    await tester.pumpApp(InstructorHomePage(repository: FakeInstructor()));
    await settle(tester);
    expect(find.text('Student requests waiting'), findsOneWidget);
    expect(find.text('Sessions returned by a reviewer'), findsOneWidget);
    expect(find.text('No classes today.'), findsOneWidget);
  });
}
