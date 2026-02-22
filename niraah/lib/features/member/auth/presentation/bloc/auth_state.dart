import 'package:equatable/equatable.dart';

import '../../../../../core/state/status.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = Status.initial,
    this.message,
    this.isOtpRequested = false,
    this.isAuthenticated = false,
  });

  final Status status;
  final String? message;
  final bool isOtpRequested;
  final bool isAuthenticated;

  AuthState copyWith({
    Status? status,
    String? message,
    bool? isOtpRequested,
    bool? isAuthenticated,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message,
      isOtpRequested: isOtpRequested ?? this.isOtpRequested,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, message, isOtpRequested, isAuthenticated];
}
