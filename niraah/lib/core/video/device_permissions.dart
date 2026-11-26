import 'package:permission_handler/permission_handler.dart';

/// What she allowed: camera and microphone, microphone only, or neither (spec 014 §5 "Entering" 3).
enum MediaAccess { granted, audioOnly, denied }

/// Asking for camera and microphone. The screens explain why first, in plain words, then call [request].
abstract class DevicePermissions {
  /// [camera] false asks for the microphone only.
  Future<MediaAccess> request({bool camera = true, bool microphone = true});

  /// Asking for the camera alone (a class member who turns her camera on, spec 014 §8.3).
  Future<bool> requestCamera();

  /// After a permanent refusal only the phone's settings can change it.
  Future<void> openSettings();
}

class PlatformDevicePermissions implements DevicePermissions {
  const PlatformDevicePermissions();

  @override
  Future<MediaAccess> request({bool camera = true, bool microphone = true}) async {
    final Map<Permission, PermissionStatus> r = await <Permission>[if (microphone) Permission.microphone, if (camera) Permission.camera].request();
    final bool mic = !microphone || (r[Permission.microphone]?.isGranted ?? false);
    final bool cam = camera && (r[Permission.camera]?.isGranted ?? false);
    if (mic && cam) return MediaAccess.granted;
    if (mic && microphone) return MediaAccess.audioOnly;
    return MediaAccess.denied;
  }

  @override
  Future<bool> requestCamera() async => (await Permission.camera.request()).isGranted;

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
