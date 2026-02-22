import 'package:equatable/equatable.dart';

import '../../../../../core/state/status.dart';

class MemberDataState extends Equatable {
  const MemberDataState({
    this.status = Status.initial,
    this.title = '',
    this.payload = const <String>[],
    this.message,
  });

  final Status status;
  final String title;
  final List<String> payload;
  final String? message;

  MemberDataState copyWith({
    Status? status,
    String? title,
    List<String>? payload,
    String? message,
  }) {
    return MemberDataState(
      status: status ?? this.status,
      title: title ?? this.title,
      payload: payload ?? this.payload,
      message: message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, title, payload, message];
}
