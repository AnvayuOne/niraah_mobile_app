import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for AdminApi
void main() {
  final instance = Openapi().getAdminApi();

  group(AdminApi, () {
    // Get admin profile
    //
    // Retrieve authenticated admin's profile information
    //
    //Future<AdminProfileGet200Response> adminProfileGet() async
    test('test adminProfileGet', () async {
      // TODO
    });

    // Get admin dashboard statistics
    //
    // Retrieve platform statistics including member count, appointments, and recent activity
    //
    //Future<AdminStatsGet200Response> adminStatsGet() async
    test('test adminStatsGet', () async {
      // TODO
    });

  });
}
