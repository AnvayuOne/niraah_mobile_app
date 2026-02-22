import 'package:flutter_bloc/flutter_bloc.dart';

import 'static_feature_state.dart';

class StaticFeatureCubit extends Cubit<StaticFeatureState> {
  StaticFeatureCubit()
      : super(
          const StaticFeatureState(
            items: <String>[
              'Health Connect integration - Awaiting API',
              'Notification quiet hours - Awaiting API',
              'Payment flow - Awaiting API',
              'Meal photo calorie estimation - Awaiting API',
              'Workout/Yoga dynamic catalog - Awaiting API',
              'Video call join checks - Awaiting API',
              'Community join workflow - Awaiting API',
              'Care team rich chat threads - Awaiting API',
            ],
          ),
        );
}
