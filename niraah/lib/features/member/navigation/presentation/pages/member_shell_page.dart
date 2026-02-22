import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../design_system/widgets/brand_logo_header.dart';
import '../../../../../shared/constants/route_constants.dart';
import '../widgets/member_bottom_nav_bar.dart';
import 'tabs/care_tab_page.dart';
import 'tabs/community_tab_page.dart';
import 'tabs/dashboard_tab_page.dart';
import 'tabs/profile_tab_page.dart';
import 'tabs/programs_tab_page.dart';

class MemberShellPage extends StatefulWidget {
  const MemberShellPage({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

  @override
  State<MemberShellPage> createState() => _MemberShellPageState();
}

class _MemberShellPageState extends State<MemberShellPage> {
  static const List<Widget> _tabs = <Widget>[
    DashboardTabPage(),
    CareTabPage(),
    ProgramsTabPage(),
    CommunityTabPage(),
    ProfileTabPage(),
  ];

  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didUpdateWidget(covariant MemberShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      final int nextIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
      if (nextIndex != _currentIndex) {
        _currentIndex = nextIndex;
        _pageController.jumpToPage(nextIndex);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    switch (index) {
      case 0:
        context.go(RouteConstants.memberHome);
        break;
      case 1:
        context.go(RouteConstants.memberCare);
        break;
      case 2:
        context.go(RouteConstants.memberPrograms);
        break;
      case 3:
        context.go(RouteConstants.memberCommunity);
        break;
      case 4:
        context.go(RouteConstants.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && _currentIndex != 0) {
          _goToTab(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const BrandLogoHeader(showMenu: true),
          toolbarHeight: 62,
          titleSpacing: 12,
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _tabs,
        ),
        bottomNavigationBar: MemberBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _goToTab,
        ),
      ),
    );
  }
}
