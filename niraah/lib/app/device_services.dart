import 'package:get_it/get_it.dart';

import '../core/payments/payment_checkout.dart';
import '../core/payments/razorpay_checkout.dart';
import '../core/video/agora_video_engine.dart';
import '../core/video/device_permissions.dart';
import '../core/video/video_engine.dart';

/// The vendors' SDKs behind their interfaces (decisions D3, D4): video (Agora), camera and microphone permissions,
/// and the payment checkout (Razorpay). Keys and app ids come from the server's responses, never from the build.
void registerDeviceServices(GetIt getIt, {bool payments = true}) {
  getIt
    ..registerLazySingleton<VideoEngineFactory>(() => AgoraVideoEngine.new)
    ..registerLazySingleton<DevicePermissions>(() => const PlatformDevicePermissions())
    ..registerLazySingleton<PaymentCheckout>(() => payments ? RazorpayCheckout() : const UnavailableCheckout());
}

/// The sample build takes no payment: every checkout ends as not completed, so nothing pretends to be paid
/// (constitution §2 rule 6).
class UnavailableCheckout implements PaymentCheckout {
  const UnavailableCheckout();

  @override
  Future<CheckoutResult> open(Checkout checkout, {required String description}) async => const CheckoutFailed();
}
