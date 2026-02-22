import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/shared/constants/route_constants.dart';

void main() {
  test('member route constants are configured', () {
    expect(RouteConstants.splash, '/');
    expect(RouteConstants.auth, '/login');
    expect(RouteConstants.signup, '/signup');
    expect(RouteConstants.otpVerify, '/otp-verify');
    expect(RouteConstants.memberHome, '/member/home');
    expect(RouteConstants.staticFeatures, '/member/static-features');
  });
}
