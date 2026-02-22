import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/member/static_placeholders/presentation/bloc/static_feature_cubit.dart';

void main() {
  test('static feature cubit exposes placeholder items', () {
    final StaticFeatureCubit cubit = StaticFeatureCubit();
    expect(cubit.state.items, isNotEmpty);
    expect(cubit.state.items.first, contains('Awaiting API'));
    cubit.close();
  });
}
