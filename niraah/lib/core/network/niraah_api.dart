import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/session_store.dart';
import '../errors/api_exception.dart';

/// An error from `/api/v1`, in the contract's ErrorBody shape. `message` is safe to show as is and never
/// reveals whether an account exists (spec 003 "Not revealing accounts").
class ApiError {
  const ApiError({required this.code, required this.message, this.field, this.retryAfterSeconds, this.details});

  final String code;
  final String message;
  final String? field;
  final int? retryAfterSeconds;

  /// Extra facts about a refusal, such as why a period was refused (spec 010 §3, AC15).
  final Map<String, dynamic>? details;

  static const ApiError network = ApiError(code: 'network', message: "We couldn't reach Niraah. Check your connection and try again.");

  static ApiError from(DioException e) {
    final Object? data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      final Map<dynamic, dynamic> err = data['error'] as Map<dynamic, dynamic>;
      return ApiError(
        code: '${err['code'] ?? 'server_error'}',
        message: '${err['message'] ?? network.message}',
        field: err['field'] as String?,
        retryAfterSeconds: err['retryAfterSeconds'] as int?,
        details: err['details'] is Map ? Map<String, dynamic>.from(err['details'] as Map) : null,
      );
    }
    return network;
  }
}

sealed class ApiResult<T> {
  const ApiResult();

  /// The data, or an [ApiException] carrying the server's words, for screens whose cubits show a
  /// failure state on any exception.
  T orThrow() => switch (this) {
        ApiOk<T>(:T data) => data,
        ApiFail<T>(:ApiError error, :final int status) => throw ApiException(message: error.message, statusCode: status),
      };
}

class ApiOk<T> extends ApiResult<T> {
  const ApiOk(this.data);
  final T data;
}

class ApiFail<T> extends ApiResult<T> {
  const ApiFail(this.error, {this.status = 0});
  final ApiError error;
  final int status;
}

/// The mobile app's client for `/api/v1` (constitution §3.3: the same API as the web app). It says it
/// is the mobile app, so the server returns tokens in the body; it sends the access token as a bearer
/// token, and on a 401 refreshes once and retries (spec 003 "Sessions" 1).
class NiraahApi {
  NiraahApi({required Dio dio, required this.store}) : _dio = dio {
    _dio.options.headers['x-niraah-client'] = 'mobile';
    _dio.options.contentType = Headers.jsonContentType;
  }

  final Dio _dio;
  final SessionStore store;

  /// True once the server refuses her session and it cannot be refreshed (for example after a local
  /// server restart). The router listens and sends her to sign in instead of retrying forever.
  static final ValueNotifier<bool> sessionLost = ValueNotifier<bool>(false);

  Future<ApiResult<Map<String, dynamic>>> get(String path) => _call('GET', path, null);

  Future<ApiResult<Map<String, dynamic>>> post(String path, [Map<String, dynamic>? body]) => _call('POST', path, body ?? <String, dynamic>{});

  Future<ApiResult<Map<String, dynamic>>> put(String path, Map<String, dynamic> body) => _call('PUT', path, body);

  Future<ApiResult<Map<String, dynamic>>> patch(String path, Map<String, dynamic> body) => _call('PATCH', path, body);

  Future<ApiResult<Map<String, dynamic>>> delete(String path) => _call('DELETE', path, null);

  /// A POST whose answer streams as server-sent events (spec 009 chat). Yields the raw text as it
  /// arrives; a refusal before the stream starts (404, 429, or 401 after a refresh) is an [ApiFail].
  Future<ApiResult<Stream<String>>> postStream(String path, Map<String, dynamic> body, {bool retried = false}) async {
    final SessionTokens? tokens = await store.read();
    try {
      final Response<ResponseBody> res = await _dio.post<ResponseBody>(
        path,
        data: body,
        options: Options(
          responseType: ResponseType.stream,
          headers: <String, Object>{'Accept': 'text/event-stream', if (tokens != null) 'Authorization': 'Bearer ${tokens.accessToken}'},
        ),
      );
      final Stream<String> text = res.data!.stream.cast<List<int>>().transform(const Utf8Decoder(allowMalformed: true));
      return ApiOk<Stream<String>>(text);
    } on DioException catch (e) {
      final int status = e.response?.statusCode ?? 0;
      if (status == 401 && !retried && tokens != null && await _renew(tokens)) return postStream(path, body, retried: true);
      return ApiFail<Stream<String>>(const ApiError(code: 'stream_refused', message: "AI Care can't answer right now. Please try again in a little while."), status: status);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _call(String method, String path, Map<String, dynamic>? body, {bool retried = false}) async {
    final SessionTokens? tokens = await store.read();
    try {
      final Response<dynamic> res = await _dio.request<dynamic>(
        path,
        data: body,
        options: Options(method: method, headers: <String, Object>{if (tokens != null) 'Authorization': 'Bearer ${tokens.accessToken}'}),
      );
      return ApiOk<Map<String, dynamic>>(Map<String, dynamic>.from((res.data as Map?) ?? <String, dynamic>{}));
    } on DioException catch (e) {
      final int status = e.response?.statusCode ?? 0;
      if (status == 401 && !retried && tokens != null && !path.startsWith('/auth/refresh') && await _renew(tokens)) {
        return _call(method, path, body, retried: true);
      }
      // Only a session the server has really ended sends her to sign in; a refresh that failed on the network
      // keeps her tokens, and the screen shows "couldn't reach Niraah" instead.
      if (status == 401 && !path.startsWith('/auth/') && await store.read() == null) sessionLost.value = true;
      return ApiFail<Map<String, dynamic>>(ApiError.from(e), status: status);
    }
  }

  /// The refresh in flight, shared by every request that got a 401 at the same time. Refresh tokens are single
  /// use: several screens refreshing with the same token at once made all but one fail, which ended the session.
  Future<bool>? _refreshing;

  /// After a 401 made with [used]: if another request already refreshed, retry with the new token; otherwise
  /// refresh once (shared) and retry.
  Future<bool> _renew(SessionTokens used) async {
    final SessionTokens? now = await store.read();
    if (now == null) return false;
    if (now.accessToken != used.accessToken) return true;
    return _refreshing ??= _refresh(now.refreshToken).whenComplete(() => _refreshing = null);
  }

  Future<bool> _refresh(String refreshToken) async {
    try {
      final Response<dynamic> res = await _dio.post<dynamic>('/auth/refresh', data: <String, dynamic>{'refreshToken': refreshToken});
      await saveTokens(res.data);
      return true;
    } on DioException catch (e) {
      // The server refused the refresh token (ended, expired or revoked): the session is over. Any other failure
      // (no signal, timeout, server hiccup) keeps the tokens so she stays signed in.
      final int status = e.response?.statusCode ?? 0;
      if (status == 400 || status == 401 || status == 403) await store.clear();
      return false;
    }
  }

  /// Where a saved session should open when the app starts, or null when there is none (or it has ended).
  /// Used by the splash screen so she is not asked to sign in again every time she opens the app.
  Future<Map<String, dynamic>?> resumeSession() async {
    if (await store.read() == null) return null;
    final ApiResult<Map<String, dynamic>> r = await get('/auth/session');
    if (r is ApiOk<Map<String, dynamic>>) return r.data;
    // Offline, slow or refused: start at sign-in. Tokens are only wiped when the server refused them.
    return null;
  }

  /// Stores the tokens from a sign-in response, if it has any.
  Future<void> saveTokens(Object? data) async {
    if (data is Map && data['tokens'] is Map) {
      final Map<dynamic, dynamic> t = data['tokens'] as Map<dynamic, dynamic>;
      await store.write(SessionTokens(accessToken: '${t['accessToken']}', refreshToken: '${t['refreshToken']}'));
      sessionLost.value = false;
    }
  }

  Future<Map<String, String>> device() async => <String, String>{'deviceId': await store.deviceId(), 'platform': _platform};

  static String get _platform => const String.fromEnvironment('NIRAAH_PLATFORM', defaultValue: 'android');
}
