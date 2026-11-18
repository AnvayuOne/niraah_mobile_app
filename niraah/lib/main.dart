import 'app/api_repositories.dart';
import 'app/app_bootstrap.dart';

/// Production entry point. Never imports `lib/sample/` (constitution §2
/// rule 6); a test checks this.
Future<void> main() async {
  await AppBootstrap.run(registerApiRepositories);
}
