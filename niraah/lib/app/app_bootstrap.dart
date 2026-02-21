import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/service_locator.dart';
import '../core/state/app_bloc_observer.dart';
import 'app.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    configureDependencies();
    Bloc.observer = AppBlocObserver();

    await runZonedGuarded(
      () async => runApp(const NiraahApp()),
      (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('Uncaught app error: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      },
    );
  }
}
