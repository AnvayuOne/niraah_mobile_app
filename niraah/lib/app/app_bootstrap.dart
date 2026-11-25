import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../core/di/service_locator.dart';
import '../core/state/app_bloc_observer.dart';
import '../design_system/theme/theme_controller.dart';
import '../design_system/widgets/answer_card.dart';
import '../design_system/widgets/n_illustration.dart';
import 'app.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> run(RepositoryRegistrar registerRepositories) async {
    await runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        configureDependencies(registerRepositories);
        await NOptionImages.load();
        await NDarkImages.load();
        await NThemeController.instance.load();
        Bloc.observer = AppBlocObserver();
        runApp(const NiraahApp());
      },
      (Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint('Uncaught app error: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      },
    );
  }
}
