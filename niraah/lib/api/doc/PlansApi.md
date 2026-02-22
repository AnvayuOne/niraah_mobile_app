# openapi.api.PlansApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://niraahwellness.com/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**plansGet**](PlansApi.md#plansget) | **GET** /plans | Get all health plans
[**plansPost**](PlansApi.md#planspost) | **POST** /plans | Create health plan


# **plansGet**
> PlansGet200Response plansGet()

Get all health plans

Retrieve list of health plans (diet, exercise, medication, supplements)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getPlansApi();

try {
    final response = api.plansGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlansApi->plansGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PlansGet200Response**](PlansGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **plansPost**
> PlansPost200Response plansPost(plansPostRequest)

Create health plan

Create a new health plan for a member (requires DOCTOR, DIETICIAN, or ADMIN role)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getPlansApi();
final PlansPostRequest plansPostRequest = ; // PlansPostRequest | 

try {
    final response = api.plansPost(plansPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlansApi->plansPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **plansPostRequest** | [**PlansPostRequest**](PlansPostRequest.md)|  | 

### Return type

[**PlansPost200Response**](PlansPost200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

