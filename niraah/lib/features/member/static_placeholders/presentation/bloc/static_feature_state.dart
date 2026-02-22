import 'package:equatable/equatable.dart';

class StaticFeatureState extends Equatable {
  const StaticFeatureState({
    this.items = const <String>[],
  });

  final List<String> items;

  StaticFeatureState copyWith({List<String>? items}) {
    return StaticFeatureState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => <Object?>[items];
}
