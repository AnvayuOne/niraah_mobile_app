# openapi.api.MemberApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://niraahwellness.com/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**memberAiPrescoreGet**](MemberApi.md#memberaiprescoreget) | **GET** /member/ai-prescore | Get AI prescore results
[**memberAppointmentsGet**](MemberApi.md#memberappointmentsget) | **GET** /member/appointments | Get member appointments
[**memberAppointmentsPost**](MemberApi.md#memberappointmentspost) | **POST** /member/appointments | Request new appointment
[**memberProfileGet**](MemberApi.md#memberprofileget) | **GET** /member/profile | Get member profile
[**memberProfilePost**](MemberApi.md#memberprofilepost) | **POST** /member/profile | Update member profile
[**memberQuestionnaireSubmitPost**](MemberApi.md#memberquestionnairesubmitpost) | **POST** /member/questionnaire/submit | Submit health questionnaire
[**memberSummaryGet**](MemberApi.md#membersummaryget) | **GET** /member/summary | Get member health summary
[**memberSymptomsGet**](MemberApi.md#membersymptomsget) | **GET** /member/symptoms | Get symptom log entries
[**memberSymptomsPost**](MemberApi.md#membersymptomspost) | **POST** /member/symptoms | Add symptom log entry
[**memberTestsGet**](MemberApi.md#membertestsget) | **GET** /member/tests | Get test attachments
[**memberTestsPost**](MemberApi.md#membertestspost) | **POST** /member/tests | Upload test attachment


# **memberAiPrescoreGet**
> MemberAiPrescoreGet200Response memberAiPrescoreGet()

Get AI prescore results

Retrieve previously calculated PCOS risk score and AI insights

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();

try {
    final response = api.memberAiPrescoreGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberAiPrescoreGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MemberAiPrescoreGet200Response**](MemberAiPrescoreGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **memberAppointmentsGet**
> MemberAppointmentsGet200Response memberAppointmentsGet()

Get member appointments

Retrieve all appointments for authenticated member

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();

try {
    final response = api.memberAppointmentsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberAppointmentsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MemberAppointmentsGet200Response**](MemberAppointmentsGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **memberAppointmentsPost**
> MemberAppointmentsPost200Response memberAppointmentsPost(memberAppointmentsPostRequest)

Request new appointment

Create a new appointment request. System will automatically attempt to assign an available doctor.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();
final MemberAppointmentsPostRequest memberAppointmentsPostRequest = ; // MemberAppointmentsPostRequest | 

try {
    final response = api.memberAppointmentsPost(memberAppointmentsPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberAppointmentsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **memberAppointmentsPostRequest** | [**MemberAppointmentsPostRequest**](MemberAppointmentsPostRequest.md)|  | 

### Return type

[**MemberAppointmentsPost200Response**](MemberAppointmentsPost200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **memberProfileGet**
> MemberProfileGet200Response memberProfileGet()

Get member profile

Retrieve authenticated member's profile information

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();

try {
    final response = api.memberProfileGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberProfileGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MemberProfileGet200Response**](MemberProfileGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **memberProfilePost**
> MemberProfilePost200Response memberProfilePost(memberProfilePostRequest)

Update member profile

Update authenticated member's profile information

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();
final MemberProfilePostRequest memberProfilePostRequest = ; // MemberProfilePostRequest | 

try {
    final response = api.memberProfilePost(memberProfilePostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberProfilePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **memberProfilePostRequest** | [**MemberProfilePostRequest**](MemberProfilePostRequest.md)|  | 

### Return type

[**MemberProfilePost200Response**](MemberProfilePost200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **memberQuestionnaireSubmitPost**
> MemberQuestionnaireSubmitPost200Response memberQuestionnaireSubmitPost(body)

Submit health questionnaire

Submit health questionnaire with rule-based and AI-powered PCOS risk scoring

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();
final JsonObject body = Object; // JsonObject | 

try {
    final response = api.memberQuestionnaireSubmitPost(body);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberQuestionnaireSubmitPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | **JsonObject**|  | 

### Return type

[**MemberQuestionnaireSubmitPost200Response**](MemberQuestionnaireSubmitPost200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **memberSummaryGet**
> MemberSummaryGet200Response memberSummaryGet()

Get member health summary

Retrieve health metrics including points, streak, adherence, and next appointment

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();

try {
    final response = api.memberSummaryGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberSummaryGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MemberSummaryGet200Response**](MemberSummaryGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **memberSymptomsGet**
> MemberSymptomsGet200Response memberSymptomsGet(limit)

Get symptom log entries

Retrieve symptom tracking log entries for authenticated member

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();
final int limit = 56; // int | Maximum number of entries to return

try {
    final response = api.memberSymptomsGet(limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberSymptomsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**| Maximum number of entries to return | [optional] [default to 5]

### Return type

[**MemberSymptomsGet200Response**](MemberSymptomsGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **memberSymptomsPost**
> MemberSymptomsPost200Response memberSymptomsPost(memberSymptomsPostRequest)

Add symptom log entry

Create a new symptom tracking entry

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();
final MemberSymptomsPostRequest memberSymptomsPostRequest = ; // MemberSymptomsPostRequest | 

try {
    final response = api.memberSymptomsPost(memberSymptomsPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberSymptomsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **memberSymptomsPostRequest** | [**MemberSymptomsPostRequest**](MemberSymptomsPostRequest.md)|  | 

### Return type

[**MemberSymptomsPost200Response**](MemberSymptomsPost200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **memberTestsGet**
> MemberTestsGet200Response memberTestsGet()

Get test attachments

Retrieve uploaded test reports and images for authenticated member

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();

try {
    final response = api.memberTestsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberTestsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MemberTestsGet200Response**](MemberTestsGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **memberTestsPost**
> memberTestsPost(memberTestsPostRequest)

Upload test attachment

Create a test attachment record after uploading to R2

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMemberApi();
final MemberTestsPostRequest memberTestsPostRequest = ; // MemberTestsPostRequest | 

try {
    api.memberTestsPost(memberTestsPostRequest);
} on DioException catch (e) {
    print('Exception when calling MemberApi->memberTestsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **memberTestsPostRequest** | [**MemberTestsPostRequest**](MemberTestsPostRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

