import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/di/service_locator.dart';
import '../features/account/presentation/account_pages.dart';
import '../features/assessment/presentation/pages/assessment_start_page.dart';
import '../features/assessment/presentation/pages/minimum_age_page.dart';
import '../features/assessment/presentation/pages/prescore_page.dart';
import '../features/assessment/presentation/pages/processing_page.dart';
import '../features/assessment/presentation/pages/question_page.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/pages/account_details_page.dart';
import '../features/auth/presentation/pages/account_status_page.dart';
import '../features/auth/presentation/pages/code_page.dart';
import '../features/auth/presentation/pages/password_page.dart';
import '../features/auth/presentation/pages/second_check_page.dart';
import '../features/auth/presentation/pages/sign_in_page.dart';
import '../features/billing/presentation/manage_plan_page.dart';
import '../features/care/presentation/care_pages.dart';
import '../features/chat/presentation/chat_home_page.dart';
import '../features/chat/presentation/conversation_page.dart';
import '../features/community/presentation/community_pages.dart';
import '../features/consults/presentation/appointments_pages.dart';
import '../features/consults/presentation/booking_pages.dart';
import '../features/consults/presentation/consult_room_page.dart';
import '../features/consults/presentation/device_check_page.dart';
import '../features/consults/presentation/specialists_page.dart';
import '../features/cycle/presentation/cycle_page.dart';
import '../features/dietitian/dietitian_pages.dart';
import '../features/dietitian/meal_plan_pages.dart';
import '../features/dietitian/review_recipe_pages.dart';
import '../features/doctor/presentation/care_plan_pages.dart';
import '../features/doctor/presentation/doctor_dashboard_page.dart';
import '../features/doctor/presentation/doctor_more_pages.dart';
import '../features/doctor/presentation/doctor_shell.dart';
import '../features/doctor/presentation/patients_pages.dart';
import '../features/doctor/presentation/review_page.dart';
import '../features/doctor/presentation/review_queue_page.dart';
import '../features/doctor/presentation/wellness_advice_pages.dart';
import '../features/home/domain/home.dart';
import '../features/home/presentation/area_coming_soon_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/instructor/class_console_page.dart';
import '../features/instructor/instructor_pages.dart';
import '../features/labs/presentation/labs_pages.dart';
import '../features/me/presentation/me_page.dart';
import '../features/me/presentation/notification_settings_page.dart';
import '../features/me/presentation/privacy_page.dart';
import '../features/me/presentation/profile_page.dart';
import '../features/meals/presentation/meal_scan_page.dart';
import '../features/meals/presentation/meals_page.dart';
import '../features/messaging/messaging.dart';
import '../features/onboarding/presentation/pages/intro_page.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';
import '../features/plans/presentation/plans_page.dart';
import '../features/practice/presentation/class_room_page.dart';
import '../features/practice/presentation/practice_page.dart';
import '../features/practice/presentation/practice_pages.dart';
import '../features/provider_auth/domain/provider_auth.dart';
import '../features/provider_auth/presentation/authenticator_page.dart';
import '../features/provider_auth/presentation/provider_pages.dart';
import '../features/provider_auth/presentation/reenrol_page.dart';
import '../features/provider_auth/presentation/setup_page.dart';
import '../features/provider_work/presentation/provider_work_pages.dart';
import '../features/symptoms/presentation/symptoms_page.dart';
import '../features/wellness_advice/presentation/wellness_advice_pages.dart';
import '../shared/constants/route_constants.dart';
import '../shared/widgets/coming_soon_page.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter create({String initialLocation = RouteConstants.splash}) => GoRouter(
        initialLocation: initialLocation,
        routes: <RouteBase>[
          GoRoute(path: RouteConstants.splash, builder: (_, _) => const SplashPage()),
          GoRoute(path: RouteConstants.intro, builder: (_, _) => const IntroPage()),
          GoRoute(path: RouteConstants.welcome, builder: (_, _) => const WelcomePage()),
          GoRoute(path: RouteConstants.signIn, builder: (_, _) => const SignInPage()),
          GoRoute(
            path: RouteConstants.signInCode,
            redirect: (_, GoRouterState st) => st.extra is PhoneInput ? null : RouteConstants.signIn,
            builder: (_, GoRouterState st) => CodePage(phone: st.extra! as PhoneInput),
          ),
          GoRoute(
            path: RouteConstants.signInPassword,
            redirect: (_, GoRouterState st) => st.extra is String ? null : RouteConstants.signIn,
            builder: (_, GoRouterState st) => PasswordPage(email: st.extra! as String),
          ),
          GoRoute(path: RouteConstants.signInSecondCheck, builder: (_, _) => const SecondCheckPage()),
          GoRoute(path: RouteConstants.accountStatus, builder: (_, GoRouterState st) => AccountStatusPage(state: st.uri.queryParameters['state'])),
          GoRoute(path: RouteConstants.accountDetails, builder: (_, _) => const AccountDetailsPage()),
          GoRoute(path: RouteConstants.assessmentStart, builder: (_, _) => const AssessmentStartPage()),
          GoRoute(path: RouteConstants.assessment, builder: (_, _) => const QuestionPage()),
          GoRoute(path: RouteConstants.processing, builder: (_, _) => const ProcessingPage()),
          GoRoute(path: RouteConstants.preScore, builder: (_, _) => const PreScorePage()),
          GoRoute(path: RouteConstants.minimumAge, builder: (_, _) => const MinimumAgePage()),
          GoRoute(path: RouteConstants.plans, builder: (_, _) => const PlansPage()),
          GoRoute(path: RouteConstants.home, builder: (_, _) => const HomePage()),
          GoRoute(
            path: '${RouteConstants.area}/:area',
            builder: (_, GoRouterState st) => AreaComingSoonPage(
              area: Area.values.firstWhere((Area a) => a.name == st.pathParameters['area'], orElse: () => Area.home),
            ),
          ),
          GoRoute(path: RouteConstants.symptoms, builder: (_, _) => const SymptomsPage()),
          GoRoute(path: RouteConstants.cycle, builder: (_, _) => const CyclePage()),
          GoRoute(path: RouteConstants.meals, builder: (_, _) => const MealsPage()),
          GoRoute(path: RouteConstants.mealScan, builder: (_, _) => const MealScanPage()),
          GoRoute(path: RouteConstants.chat, builder: (_, _) => const ChatHomePage()),
          GoRoute(
            path: '${RouteConstants.chat}/:id',
            builder: (_, GoRouterState st) => ConversationPage(
              conversationId: st.pathParameters['id']!,
              initialMessage: st.extra is String ? st.extra! as String : null,
            ),
          ),
          // Practice tab (spec 010 §7).
          GoRoute(path: RouteConstants.practice, builder: (_, _) => const PracticePage()),
          GoRoute(path: RouteConstants.practiceLibrary, builder: (_, _) => const PracticeLibraryPage()),
          GoRoute(path: RouteConstants.practiceHistory, builder: (_, _) => const PracticeHistoryPage()),
          GoRoute(path: '${RouteConstants.practiceSession}/:id', builder: (_, GoRouterState st) => PracticeSessionPage(sessionId: st.pathParameters['id']!)),
          // Me tab and the areas reached from it (spec 010 §9-§13).
          GoRoute(path: RouteConstants.me, builder: (_, _) => const MePage()),
          GoRoute(path: RouteConstants.profile, builder: (_, _) => const ProfilePage()),
          GoRoute(path: RouteConstants.privacy, builder: (_, _) => const PrivacyPage()),
          GoRoute(path: RouteConstants.notificationSettings, builder: (_, _) => const NotificationSettingsPage()),
          GoRoute(path: RouteConstants.programs, builder: (_, _) => const ProgramsPage()),
          GoRoute(path: RouteConstants.carePlan, builder: (_, _) => const CarePlanPage()),
          GoRoute(path: RouteConstants.checkIns, builder: (_, _) => const CheckInsPage()),
          GoRoute(path: RouteConstants.labs, builder: (_, _) => const LabsPage()),
          GoRoute(path: RouteConstants.community, builder: (_, _) => const CommunityPage()),
          GoRoute(path: RouteConstants.messages, builder: (_, _) => const ThreadsPage()),
          // Find a specialist, booking, appointments and the room (spec 014; spec 010 §9).
          GoRoute(path: RouteConstants.bookDoctor, builder: (_, _) => const FindSpecialistPage()),
          GoRoute(path: '${RouteConstants.bookDoctor}/:id', builder: (_, GoRouterState st) => SpecialistPage(specialistId: st.pathParameters['id']!)),
          GoRoute(path: RouteConstants.bookPooled, builder: (_, GoRouterState st) => PooledBookingPage(type: st.uri.queryParameters['type'] == 'dietitian' ? 'dietitian' : 'doctor')),
          GoRoute(path: RouteConstants.appointments, builder: (_, _) => const AppointmentsPage()),
          GoRoute(path: '${RouteConstants.appointments}/:id', builder: (_, GoRouterState st) => AppointmentPage(appointmentId: st.pathParameters['id']!)),
          GoRoute(path: '${RouteConstants.appointments}/:id/room', builder: (_, GoRouterState st) => ConsultRoomPage(appointmentId: st.pathParameters['id']!)),
          GoRoute(path: RouteConstants.deviceCheck, builder: (_, _) => const DeviceCheckPage()),
          // A live class room (spec 014 §8).
          GoRoute(path: '${RouteConstants.classes}/:id/room', builder: (_, GoRouterState st) => ClassRoomPage(classId: st.pathParameters['id']!)),
          GoRoute(path: RouteConstants.wellnessAdvice, builder: (_, _) => const WellnessAdviceListPage()),
          // Manage plan and invoices (spec 008 §4, §8).
          GoRoute(path: RouteConstants.managePlan, builder: (_, _) => const ManagePlanPage()),
          GoRoute(path: RouteConstants.invoices, builder: (_, _) => const InvoicesPage()),
          // Sign-in settings (spec 003).
          GoRoute(path: RouteConstants.signedInDevices, builder: (_, _) => const SignedInDevicesPage()),
          GoRoute(path: RouteConstants.changeNumber, builder: (_, _) => const ChangeNumberPage()),
          GoRoute(path: RouteConstants.recoveryEmail, builder: (_, GoRouterState st) => RecoveryEmailPage(current: st.extra is String ? st.extra! as String : null)),
          // No spec describes a support screen yet.
          GoRoute(path: RouteConstants.support, builder: (_, _) => const ComingSoonPage()),

          // Provider sign-in and set-up (spec 003).
          GoRoute(path: RouteConstants.signInAuthenticator, builder: (_, _) => const AuthenticatorPage()),
          GoRoute(path: RouteConstants.signInNewAuthenticator, builder: (_, _) => const ReenrolPage()),
          GoRoute(path: RouteConstants.admin, redirect: _providerGuard(ProviderRole.admin), builder: (_, _) => const RoleComingSoonPage(role: ProviderRole.admin)),
          GoRoute(path: RouteConstants.setup, builder: (_, GoRouterState st) => SetupPage(token: st.uri.queryParameters['invite'])),
          GoRoute(path: RouteConstants.providerStatus, builder: (_, _) => const ProviderStatusPage()),
          GoRoute(
            path: '/dietitian',
            redirect: _providerGuard(ProviderRole.dietitian),
            builder: (_, _) => const DietitianDashboardPage(),
            routes: <RouteBase>[
              GoRoute(path: 'clients', builder: (_, _) => const ClientsPage()),
              GoRoute(path: 'clients/:id', builder: (_, GoRouterState st) => ClientPage(memberId: st.pathParameters['id']!)),
              GoRoute(path: 'review', builder: (_, _) => const FoodLogQueuePage()),
              GoRoute(
                path: 'schedule',
                builder: (_, _) => SchedulePage(frame: (BuildContext context, String title, Widget body) => DietitianShell(index: 3, title: title, body: body)),
              ),
              GoRoute(path: 'more', builder: (_, _) => const DietitianMorePage()),
              GoRoute(path: 'meal-plans', builder: (_, _) => const MealPlansPage()),
              GoRoute(path: 'meal-plans/:id', builder: (_, GoRouterState st) => MealPlanBuilderPage(planId: st.pathParameters['id']!)),
              GoRoute(path: 'recipes', builder: (_, _) => const RecipesPage()),
              GoRoute(path: 'check-ins', builder: (_, _) => const UnreadCheckInsPage()),
              GoRoute(path: 'alerts', builder: (_, _) => const DietitianAlertsPage()),
              GoRoute(path: 'messages', builder: (_, _) => const ThreadsPage(clinician: true)),
              GoRoute(path: 'earnings', builder: (_, _) => const EarningsPage()),
              GoRoute(path: 'profile', builder: (_, _) => const DietitianProfilePage()),
            ],
          ),
          GoRoute(
            path: '/instructor',
            redirect: _providerGuard(ProviderRole.instructor),
            builder: (_, _) => const InstructorHomePage(),
            routes: <RouteBase>[
              GoRoute(path: 'sessions', builder: (_, _) => const SessionsPage()),
              GoRoute(path: 'sessions/:id', builder: (_, GoRouterState st) => ClassPage(classId: st.pathParameters['id']!)),
              GoRoute(path: 'sessions/:id/room', builder: (_, GoRouterState st) => ClassConsolePage(classId: st.pathParameters['id']!)),
              GoRoute(path: 'students', builder: (_, _) => const StudentsPage()),
              GoRoute(path: 'library', builder: (_, _) => const LibraryPage()),
              GoRoute(path: 'more', builder: (_, _) => const InstructorMorePage()),
              GoRoute(path: 'earnings', builder: (_, _) => const EarningsPage()),
              GoRoute(path: 'profile', builder: (_, _) => const InstructorProfilePage()),
            ],
          ),

          // Doctor workspace (spec 011). Only an active doctor session gets in.
          GoRoute(
            path: '/doctor',
            redirect: _providerGuard(ProviderRole.doctor),
            builder: (_, _) => const DoctorDashboardPage(),
            routes: <RouteBase>[
              GoRoute(path: 'queue', builder: (_, _) => const ReviewQueuePage()),
              GoRoute(path: 'review/:id', builder: (_, GoRouterState st) => ReviewPage(reviewId: st.pathParameters['id']!)),
              GoRoute(path: 'patients', builder: (_, _) => const PatientsPage()),
              GoRoute(path: 'patients/:id', builder: (_, GoRouterState st) => PatientPage(memberId: st.pathParameters['id']!)),
              GoRoute(
                path: 'schedule',
                builder: (_, _) => SchedulePage(frame: (BuildContext context, String title, Widget body) => DoctorShell(index: 3, title: title, body: body)),
              ),
              GoRoute(path: 'more', builder: (_, _) => const DoctorMorePage()),
              GoRoute(path: 'alerts', builder: (_, _) => const AlertsPage()),
              GoRoute(path: 'care-plans', builder: (_, _) => const CarePlanQueuePage()),
              GoRoute(path: 'care-plans/:id', builder: (_, GoRouterState st) => CarePlanReviewPage(planId: st.pathParameters['id']!)),
              GoRoute(path: 'labs', builder: (_, _) => const LabResultsPage()),
              GoRoute(path: 'advice', builder: (_, _) => const AdviceDraftsPage()),
              GoRoute(path: 'earnings', builder: (_, _) => const EarningsPage()),
              GoRoute(path: 'profile', builder: (_, _) => const DoctorProfilePage()),
              GoRoute(path: 'reviewer', builder: (_, _) => const ReviewerTasksPage()),
              GoRoute(path: 'messages', builder: (_, _) => const ThreadsPage(clinician: true)),
            ],
          ),
        ],
      );

  /// Lets in only an active provider of [role]; anyone else goes to sign-in
  /// or to her own home (spec 001 AC2, AC5). The server checks the same on
  /// every request; this only keeps the screens honest.
  static GoRouterRedirect _providerGuard(ProviderRole role) => (BuildContext context, GoRouterState state) async {
        final ProviderSession? session = await getIt<ProviderAuthRepository>().currentSession();
        if (session == null) return RouteConstants.signIn;
        if (session.role != role || session.status != ProviderStatus.active) return homeFor(session);
        return null;
      };
}
