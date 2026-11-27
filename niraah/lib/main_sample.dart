import 'app/app_bootstrap.dart';
import 'sample/sample_registration.dart';

/// Sample-data entry point for building and reviewing screens before their
/// specs are approved (constitution §2 rule 6). Run with:
///   flutter run -t lib/main_sample.dart
/// Never use this target for a release build.
Future<void> main() async {
  await AppBootstrap.run(registerSampleRepositories);
}
