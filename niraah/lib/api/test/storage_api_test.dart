import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for StorageApi
void main() {
  final instance = Openapi().getStorageApi();

  group(StorageApi, () {
    // Get presigned upload URL
    //
    // Generate a presigned URL for uploading files to R2 storage
    //
    //Future<R2PresignPost200Response> r2PresignPost(R2PresignPostRequest r2PresignPostRequest) async
    test('test r2PresignPost', () async {
      // TODO
    });

  });
}
