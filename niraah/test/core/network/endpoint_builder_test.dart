import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/network/endpoint_builder.dart';

void main() {
  test('replaces path params', () {
    final String endpoint = EndpointBuilder.withPathParams(
      '/users/{userId}/posts/{postId}',
      <String, String>{'userId': '10', 'postId': '3'},
    );

    expect(endpoint, '/users/10/posts/3');
  });
}
