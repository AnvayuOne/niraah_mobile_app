// Renders the member screens the main harness does not cover (code, account details, practice, Me, privacy,
// notifications, care, community, messages) to PNG. Runs only when SCREENSHOT_DIR is set.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/core/di/service_locator.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/design_system/tokens/tokens.dart';
import 'package:niraah/features/auth/domain/auth_repository.dart';
import 'package:niraah/features/auth/presentation/pages/account_details_page.dart';
import 'package:niraah/features/auth/presentation/pages/code_page.dart';
import 'package:niraah/features/care/domain/care.dart';
import 'package:niraah/features/care/presentation/care_pages.dart';
import 'package:niraah/features/community/presentation/community_pages.dart';
import 'package:niraah/features/labs/presentation/labs_pages.dart';
import 'package:niraah/features/me/domain/me.dart';
import 'package:niraah/features/me/presentation/me_page.dart';
import 'package:niraah/features/me/presentation/notification_settings_page.dart';
import 'package:niraah/features/me/presentation/privacy_page.dart';
import 'package:niraah/features/me/presentation/profile_page.dart';
import 'package:niraah/features/messaging/messaging.dart';
import 'package:niraah/features/practice/domain/practice.dart';
import 'package:niraah/features/practice/presentation/practice_page.dart';
import 'package:niraah/features/practice/presentation/practice_pages.dart';
import 'package:niraah/l10n/app_localizations.dart';
import 'package:niraah/sample/sample_backend.dart';

import '../member_areas/member_screens_test.dart' as m;

final String? _out = Platform.environment['SCREENSHOT_DIR'];
const GlobalObjectKey<State<StatefulWidget>> _boundary = GlobalObjectKey<State<StatefulWidget>>('member-shot');

class _Me extends m.FakeMe {
  @override
  Future<Profile> profile() async => const Profile(
        displayName: 'Meera Krishnan',
        phone: '+919876543210',
        language: 'en',
        timeZone: 'Asia/Kolkata',
        dateOfBirth: '1996-04-12',
        heightCm: 162,
        goals: <String>['Regular cycles', 'More energy'],
        recoveryEmail: 'meera@example.com',
        personalisedAi: true,
        accountKind: 'adult',
      );

  @override
  Future<NotificationSettings> notificationSettings() async => const NotificationSettings(
        categories: <NotificationCategory>[
          NotificationCategory(
            key: 'account_security',
            name: 'Account and security',
            locked: true,
            lockedReason: "We always tell you about your account's security.",
            channels: <ChannelSwitch>[ChannelSwitch(channel: 'push', enabled: true), ChannelSwitch(channel: 'sms', enabled: true), ChannelSwitch(channel: 'email', enabled: true)],
          ),
          NotificationCategory(
            key: 'reminders',
            name: 'Reminders',
            locked: false,
            lockedReason: null,
            channels: <ChannelSwitch>[ChannelSwitch(channel: 'push', enabled: true), ChannelSwitch(channel: 'sms', enabled: false), ChannelSwitch(channel: 'email', enabled: false)],
          ),
        ],
        discreetNote: 'Notifications never name a condition or a result.',
      );
}

class _Practice extends m.FakePractice {
  @override
  Future<List<PracticeSession>> library(PracticeFilters filters) async => const <PracticeSession>[m.gentle];

  @override
  Future<List<PracticeWeek>> history() async => const <PracticeWeek>[
        PracticeWeek(weekOf: '2026-11-16', sessions: <PracticeDone>[PracticeDone(title: 'Gentle flow', minutes: 15, date: '2026-11-18')]),
      ];
}

class _Care extends m.FakeCare {
  @override
  Future<ProgramsDocument> programs() async => const ProgramsDocument(
        programs: <Program>[
          Program(id: 'p1', name: 'PCOS foundations', description: 'Twelve gentle weeks of food, movement and sleep habits.', weeks: 12, suggested: true),
          Program(id: 'p2', name: 'Better sleep', description: 'Four weeks to steadier nights.', weeks: 4, suggested: false),
        ],
        enrolment: null,
      );

  @override
  Future<CheckInsDocument> checkIns() async => const CheckInsDocument(due: null, trend: <TrendPoint>[]);
}

class _Messages implements MessagingRepository {
  @override
  Future<Map<String, dynamic>> threads() async => <String, dynamic>{
        'messagingOnPlan': true,
        'threads': <dynamic>[
          <String, dynamic>{'id': 't1', 'with': <String, dynamic>{'name': 'Dr Anjali Rao'}, 'lastMessageAt': '2026-11-19T10:00:00Z', 'unread': 2, 'canSend': true},
        ],
        'canStart': <dynamic>[
          <String, dynamic>{'id': 'p1', 'name': 'Priya Shah', 'role': 'Dietitian'},
        ],
      };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _loadFonts() async {
  Future<ByteData> font(String file) async => ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync());
  final FontLoader sans = FontLoader('PlusJakartaSans');
  for (String w in <String>['400', '500', '600', '700', '800']) {
    sans.addFont(font('PlusJakartaSans-$w.ttf'));
  }
  await sans.load();
  final FontLoader display = FontLoader('CormorantGaramond');
  for (String w in <String>['500', '600', '700']) {
    display.addFont(font('CormorantGaramond-$w.ttf'));
  }
  await display.load();
  final File icons = File('${Platform.environment['FLUTTER_ROOT'] ?? ''}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    await (FontLoader('MaterialIcons')..addFont(Future<ByteData>.value(ByteData.sublistView(icons.readAsBytesSync())))).load();
  }
}

Widget _frame(Widget child) => RepaintBoundary(
      key: _boundary,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.current,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        routerConfig: GoRouter(routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => child)]),
      ),
    );

Future<void> _shot(WidgetTester tester, String name) async {
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.runAsync(() async {
    final RenderRepaintBoundary rb = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await rb.toImage(pixelRatio: 2);
    final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_out!).createSync(recursive: true);
    File('${_out!}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  NColors.dark = Platform.environment['SCREENSHOT_DARK'] == '1';
  setUpAll(() async {
    await _loadFonts();
    if (!getIt.isRegistered<AuthRepository>()) getIt.registerSingleton<AuthRepository>(SampleAuthRepository());
  });

  final Map<String, Widget Function()> screens = <String, Widget Function()>{
    'm01-code': () => const CodePage(phone: PhoneInput('9876543210')),
    'm02-account-details': () => const AccountDetailsPage(),
    'm03-practice': () => PracticePage(repository: _Practice()),
    'm04-practice-session': () => PracticeSessionPage(sessionId: 's1', repository: _Practice()),
    'm05-practice-library': () => PracticeLibraryPage(repository: _Practice()),
    'm06-practice-history': () => PracticeHistoryPage(repository: _Practice()),
    'm07-me': () => MePage(repository: _Me()),
    'm08-profile': () => ProfilePage(repository: _Me()),
    'm09-privacy': () => PrivacyPage(repository: _Me()),
    'm10-notifications': () => NotificationSettingsPage(repository: _Me()),
    'm11-programs': () => ProgramsPage(repository: _Care()),
    'm12-care-plan': () => CarePlanPage(repository: _Care()),
    'm13-check-ins': () => CheckInsPage(repository: _Care()),
    'm14-community': () => CommunityPage(repository: m.FakeCommunity()),
    'm15-labs': () => LabsPage(repository: m.FakeLabs()),
    'm16-messages': () => ThreadsPage(repository: _Messages()),
  };

  for (MapEntry<String, Widget Function()> e in screens.entries) {
    testWidgets(e.key, (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_frame(e.value()));
      await _shot(tester, e.key);
      expect(tester.takeException(), isNull);
    }, skip: _out == null);
  }
}
