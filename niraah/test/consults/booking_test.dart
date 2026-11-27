import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/features/consults/data/sample_consults_repository.dart';
import 'package:niraah/features/consults/domain/consults.dart';
import 'package:niraah/features/consults/presentation/appointments_page.dart';
import 'package:niraah/features/consults/presentation/confirm_page.dart';
import 'package:niraah/features/consults/presentation/specialist_page.dart';
import 'package:niraah/features/consults/presentation/specialists_page.dart';
import 'package:niraah/l10n/app_localizations.dart';
import 'package:niraah/shared/constants/route_constants.dart';

Widget _app(SampleConsultsRepository repo, {String start = RouteConstants.bookDoctor}) => MaterialApp.router(
      theme: AppTheme.current,
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: start,
        routes: <RouteBase>[
          GoRoute(path: RouteConstants.bookDoctor, builder: (_, _) => SpecialistsPage(repository: repo)),
          GoRoute(path: '${RouteConstants.bookDoctor}/:id', builder: (_, GoRouterState st) => SpecialistPage(id: st.pathParameters['id']!, repository: repo)),
          GoRoute(path: RouteConstants.appointments, builder: (_, _) => AppointmentsPage(repository: repo)),
          GoRoute(
            path: '${RouteConstants.appointments}/:id/confirm',
            builder: (_, GoRouterState st) {
              final Map<String, Object>? extra = st.extra as Map<String, Object>?;
              return ConfirmConsultPage(id: st.pathParameters['id']!, held: extra?['appointment'] as Appointment?, specialist: extra?['specialist'] as Specialist?, repository: repo);
            },
          ),
        ],
      ),
    );

Future<void> _settle(WidgetTester t) async {
  for (int i = 0; i < 8; i++) {
    await t.pump(const Duration(milliseconds: 150));
  }
}

void main() {
  setUp(() {});

  testWidgets('lists specialists with fee and filters by kind', (WidgetTester t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(_app(SampleConsultsRepository()));
    await _settle(t);
    expect(find.text('Dr. Ananya Rao'), findsOneWidget);
    expect(find.text('Sunita Iyer'), findsOneWidget);
    expect(find.text('₹499 incl. GST'), findsOneWidget);
    await t.tap(find.text('Dietitians'));
    await _settle(t);
    expect(find.text('Dr. Ananya Rao'), findsNothing);
    expect(find.text('Sunita Iyer'), findsOneWidget);
  });

  testWidgets('pick a time, hold it, confirm an included consult, and see it booked', (WidgetTester t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final SampleConsultsRepository repo = SampleConsultsRepository();
    await t.pumpWidget(_app(repo, start: '${RouteConstants.bookDoctor}/dr-ananya'));
    await _settle(t);
    // Nothing is held until a time is chosen.
    expect(find.text('Pick a time to continue'), findsOneWidget);
    await t.drag(find.byType(ListView).first, const Offset(0, -900));
    await _settle(t);
    final Finder time = find.textContaining(RegExp(r'^\d{1,2}:\d{2}[\s\u202f](am|pm)$')).first;
    await t.ensureVisible(time);
    await t.tap(time);
    await t.pump();
    await t.tap(find.text('Hold this time'));
    await _settle(t);
    expect(find.text('Confirm your consult'), findsOneWidget);
    expect(find.text('Confirm, using an included consult'), findsOneWidget);
    await t.scrollUntilVisible(find.text('Your health profile'), 200, scrollable: find.byType(Scrollable).first);
    await t.pump();
    await t.tap(find.text('Your health profile'));
    await t.tap(find.text('Confirm, using an included consult'));
    await _settle(t);
    expect(find.text('You are booked'), findsOneWidget);
    expect((await repo.appointments()).single.status, AppointmentStatus.confirmed);
    await t.tap(find.text('See your appointments'));
    await _settle(t);
    expect(find.text('Confirmed'), findsOneWidget);
  });

  testWidgets('a paid consult asks her to finish paying on the website', (WidgetTester t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final SampleConsultsRepository repo = SampleConsultsRepository();
    await t.pumpWidget(_app(repo, start: '${RouteConstants.bookDoctor}/dt-sunita'));
    await _settle(t);
    await t.drag(find.byType(ListView).first, const Offset(0, -900));
    await _settle(t);
    final Finder time = find.textContaining(RegExp(r'^\d{1,2}:\d{2}[\s\u202f](am|pm)$')).first;
    await t.ensureVisible(time);
    await t.tap(time);
    await t.pump();
    await t.tap(find.text('Hold this time'));
    await _settle(t);
    await t.tap(find.text('Pay ₹399 and confirm'));
    await _settle(t);
    expect(find.text('Finish paying on the website'), findsOneWidget);
    await t.tap(find.text('Not now'));
    await _settle(t);
  });

  test('rupees and words read well', () {
    expect(rupees(49900), '₹499');
    expect(rupees(150000), '₹1,500');
    expect(rupees(12345), '₹123.45');
    expect(niceWord('pcos'), 'PCOS');
    expect(niceWord('weight_management'), 'Weight management');
  });
}
