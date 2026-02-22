import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for PlansApi
void main() {
  final instance = Openapi().getPlansApi();

  group(PlansApi, () {
    // Get all health plans
    //
    // Retrieve list of health plans (diet, exercise, medication, supplements)
    //
    //Future<PlansGet200Response> plansGet() async
    test('test plansGet', () async {
      // TODO
    });

    // Create health plan
    //
    // Create a new health plan for a member (requires DOCTOR, DIETICIAN, or ADMIN role)
    //
    //Future<PlansPost200Response> plansPost(PlansPostRequest plansPostRequest) async
    test('test plansPost', () async {
      // TODO
    });

  });
}
