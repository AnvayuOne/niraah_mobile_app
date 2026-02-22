# openapi.api.StorageApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://niraahwellness.com/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**r2PresignPost**](StorageApi.md#r2presignpost) | **POST** /r2/presign | Get presigned upload URL


# **r2PresignPost**
> R2PresignPost200Response r2PresignPost(r2PresignPostRequest)

Get presigned upload URL

Generate a presigned URL for uploading files to R2 storage

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getStorageApi();
final R2PresignPostRequest r2PresignPostRequest = ; // R2PresignPostRequest | 

try {
    final response = api.r2PresignPost(r2PresignPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageApi->r2PresignPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **r2PresignPostRequest** | [**R2PresignPostRequest**](R2PresignPostRequest.md)|  | 

### Return type

[**R2PresignPost200Response**](R2PresignPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

