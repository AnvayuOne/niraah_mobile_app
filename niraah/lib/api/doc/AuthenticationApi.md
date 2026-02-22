# openapi.api.AuthenticationApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://niraahwellness.com/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authLoginPasswordPost**](AuthenticationApi.md#authloginpasswordpost) | **POST** /auth/login-password | Login with email and password
[**authRequestOtpPost**](AuthenticationApi.md#authrequestotppost) | **POST** /auth/request-otp | Request OTP for phone login
[**authVerifyOtpPost**](AuthenticationApi.md#authverifyotppost) | **POST** /auth/verify-otp | Verify OTP and get auth token


# **authLoginPasswordPost**
> AuthLoginPasswordPost200Response authLoginPasswordPost(authLoginPasswordPostRequest)

Login with email and password

Authenticate using email and password (temporary password: 12345)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAuthenticationApi();
final AuthLoginPasswordPostRequest authLoginPasswordPostRequest = ; // AuthLoginPasswordPostRequest | 

try {
    final response = api.authLoginPasswordPost(authLoginPasswordPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthenticationApi->authLoginPasswordPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authLoginPasswordPostRequest** | [**AuthLoginPasswordPostRequest**](AuthLoginPasswordPostRequest.md)|  | 

### Return type

[**AuthLoginPasswordPost200Response**](AuthLoginPasswordPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRequestOtpPost**
> AuthRequestOtpPost200Response authRequestOtpPost(authRequestOtpPostRequest)

Request OTP for phone login

Send an OTP to the user's phone number for authentication

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAuthenticationApi();
final AuthRequestOtpPostRequest authRequestOtpPostRequest = ; // AuthRequestOtpPostRequest | 

try {
    final response = api.authRequestOtpPost(authRequestOtpPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthenticationApi->authRequestOtpPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authRequestOtpPostRequest** | [**AuthRequestOtpPostRequest**](AuthRequestOtpPostRequest.md)|  | 

### Return type

[**AuthRequestOtpPost200Response**](AuthRequestOtpPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authVerifyOtpPost**
> AuthVerifyOtpPost200Response authVerifyOtpPost(authVerifyOtpPostRequest)

Verify OTP and get auth token

Verify the OTP code and receive a JWT token for authentication

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAuthenticationApi();
final AuthVerifyOtpPostRequest authVerifyOtpPostRequest = ; // AuthVerifyOtpPostRequest | 

try {
    final response = api.authVerifyOtpPost(authVerifyOtpPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthenticationApi->authVerifyOtpPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authVerifyOtpPostRequest** | [**AuthVerifyOtpPostRequest**](AuthVerifyOtpPostRequest.md)|  | 

### Return type

[**AuthVerifyOtpPost200Response**](AuthVerifyOtpPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

