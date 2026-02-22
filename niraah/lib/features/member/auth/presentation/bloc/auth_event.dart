import '../../../../../core/state/base_event.dart';

sealed class AuthEvent extends BaseEvent {
  const AuthEvent();
}

class AuthRequestOtpPressed extends AuthEvent {
  const AuthRequestOtpPressed(this.phone);
  final String phone;
}

class AuthVerifyOtpPressed extends AuthEvent {
  const AuthVerifyOtpPressed({
    required this.phone,
    required this.code,
  });

  final String phone;
  final String code;
}
