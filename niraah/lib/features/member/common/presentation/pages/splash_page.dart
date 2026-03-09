import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../design_system/widgets/app_scaffold.dart';
import '../../../../../shared/constants/route_constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _scheduleRedirect();
  }

  Future<void> _scheduleRedirect() async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (!mounted) {
      return;
    }
    context.go(RouteConstants.auth);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: const Center(
        child: Image(
          image: AssetImage('assets/logo/niraah-logo.png'),
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
