import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';

/// Replies to API calls in order and records each request, so tests check both the request a repository
/// sends and how it reads the server's answer.
class FakeAdapter implements HttpClientAdapter {
  final List<(int, Object)> replies = <(int, Object)>[];
  final List<RequestOptions> requests = <RequestOptions>[];

  void reply(Object body, [int status = 200]) => replies.add((status, body));

  RequestOptions get last => requests.last;

  Map<String, dynamic> get lastBody => Map<String, dynamic>.from(last.data as Map<dynamic, dynamic>);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (int status, Object body) = replies.removeAt(0);
    return ResponseBody.fromString(jsonEncode(body), status, headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

NiraahApi fakeApi(FakeAdapter adapter) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))..httpClientAdapter = adapter;
  return NiraahApi(dio: dio, store: MemorySessionStore());
}

/// The server's refusal for an area not on her plan (spec 010 AC48).
Map<String, dynamic> lockedBody(String area) => <String, dynamic>{
      'error': <String, dynamic>{
        'code': 'forbidden',
        'message': 'This isn\'t on your plan.',
        'details': <String, dynamic>{'area': area, 'status': 'locked', 'description': 'What it is.', 'plans': <String>['Essential', 'Complete']},
      },
    };
