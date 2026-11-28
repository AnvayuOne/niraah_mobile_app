import '../../../core/di/service_locator.dart';
import '../data/health_package_reader.dart';
import 'device_sync.dart';
import 'devices.dart';

/// Syncs her connected device once each time the app opens (spec 016 §2.1), quietly: a failure leaves things as
/// they were, and the Connected devices screen offers "Sync now".
abstract final class DeviceAutoSync {
  static bool _done = false;

  static Future<void> once({HealthReader? reader}) async {
    if (_done || !getIt.isRegistered<DevicesRepository>()) return;
    _done = true;
    try {
      final DevicesRepository repo = getIt<DevicesRepository>();
      final HealthReader r = reader ?? HealthPackageReader();
      final DevicesDocument doc = await repo.load();
      final HealthSource? mine = doc.connectedOn(r.platform);
      if (mine == null || await r.availability() != HealthAvailability.available) return;
      await DeviceSync(reader: r, repository: repo).sync(mine, limits: doc.limits);
    } on Object {
      // Nothing to tell her here; the screen shows the last sync time.
    }
  }
}
