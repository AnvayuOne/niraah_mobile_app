import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for AuthenticationApi
void main() {
  final instance = Openapi().getAuthenticationApi();

  group(AuthenticationApi, () {
    // Login with email and password
    //
    // Authenticate using email and password (temporary password: 12345)
    //
    //Future<AuthLoginPasswordPost200Response> authLoginPasswordPost(AuthLoginPasswordPostRequest authLoginPasswordPostRequest) async
    test('test authLoginPasswordPost', () async {
      // TODO
    });

    // Request OTP for phone login
    //
    // Send an OTP to the user's phone number for authentication
    //
    //Future<AuthRequestOtpPost200Response> authRequestOtpPost(AuthRequestOtpPostRequest authRequestOtpPostRequest) async
    test('test authRequestOtpPost', () async {
      // TODO
    });

    // Verify OTP and get auth token
    //
    // Verify the OTP code and receive a JWT token for authentication
    //
    //Future<AuthVerifyOtpPost200Response> authVerifyOtpPost(AuthVerifyOtpPostRequest authVerifyOtpPostRequest) async
    test('test authVerifyOtpPost', () async {
      // TODO
    });

  });
}
