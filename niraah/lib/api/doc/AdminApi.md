# openapi.api.AdminApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://niraahwellness.com/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminProfileGet**](AdminApi.md#adminprofileget) | **GET** /admin/profile | Get admin profile
[**adminStatsGet**](AdminApi.md#adminstatsget) | **GET** /admin/stats | Get admin dashboard statistics


# **adminProfileGet**
> AdminProfileGet200Response adminProfileGet()

Get admin profile

Retrieve authenticated admin's profile information

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAdminApi();

try {
    final response = api.adminProfileGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminProfileGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminProfileGet200Response**](AdminProfileGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminStatsGet**
> AdminStatsGet200Response adminStatsGet()

Get admin dashboard statistics

Retrieve platform statistics including member count, appointments, and recent activity

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAdminApi();

try {
    final response = api.adminStatsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminStatsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminStatsGet200Response**](AdminStatsGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

