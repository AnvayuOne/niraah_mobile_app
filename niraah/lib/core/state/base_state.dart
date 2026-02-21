import 'package:equatable/equatable.dart';

import 'status.dart';

class BaseState extends Equatable {
  const BaseState({
    this.status = Status.initial,
    this.message,
  });

  final Status status;
  final String? message;

  BaseState copyWith({
    Status? status,
    String? message,
  }) {
    return BaseState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, message];
}
