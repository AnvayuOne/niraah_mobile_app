import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/state/status.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthRequestOtpPressed>(_onRequestOtp);
    on<AuthVerifyOtpPressed>(_onVerifyOtp);
  }

  static const String _validPhone = '9988776655';
  static const String _validOtp = '123456';

  Future<void> _onRequestOtp(AuthRequestOtpPressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: Status.loading, message: null, isAuthenticated: false));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (event.phone == _validPhone) {
      emit(
        state.copyWith(
          status: Status.success,
          message: 'OTP sent to $_validPhone',
          isOtpRequested: true,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: Status.failure,
        message: 'Use test number: $_validPhone',
        isOtpRequested: false,
      ),
    );
  }

  Future<void> _onVerifyOtp(AuthVerifyOtpPressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: Status.loading, message: null));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (event.phone == _validPhone && event.code == _validOtp) {
      emit(
        state.copyWith(
          status: Status.success,
          message: 'Logged in successfully',
          isAuthenticated: true,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: Status.failure,
        message: 'Invalid OTP. Use test OTP: $_validOtp',
        isAuthenticated: false,
      ),
    );
  }
}
