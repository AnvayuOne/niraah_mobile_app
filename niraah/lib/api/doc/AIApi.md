# openapi.api.AIApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://niraahwellness.com/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**aiChatPost**](AIApi.md#aichatpost) | **POST** /ai/chat | Chat with Niraah AI


# **aiChatPost**
> AiChatPost200Response aiChatPost(aiChatPostRequest)

Chat with Niraah AI

Send messages to AI chatbot for health guidance and platform information

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAIApi();
final AiChatPostRequest aiChatPostRequest = ; // AiChatPostRequest | 

try {
    final response = api.aiChatPost(aiChatPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AIApi->aiChatPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **aiChatPostRequest** | [**AiChatPostRequest**](AiChatPostRequest.md)|  | 

### Return type

[**AiChatPost200Response**](AiChatPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

