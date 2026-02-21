import '../../../../core/state/base_event.dart';

sealed class HomeEvent extends BaseEvent {
  const HomeEvent();
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}

class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}
