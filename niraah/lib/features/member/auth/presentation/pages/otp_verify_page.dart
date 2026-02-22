import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/state/status.dart';
import '../../../../../design_system/widgets/app_button.dart';
import '../../../../../design_system/widgets/app_scaffold.dart';
import '../../../../../design_system/widgets/app_text_field.dart';
import '../../../../../design_system/widgets/auth_card_container.dart';
import '../../../../../design_system/widgets/brand_logo_header.dart';
import '../../../../../shared/constants/route_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerifyPage extends StatefulWidget {
  const OtpVerifyPage({
    required this.phone,
    required this.flow,
    super.key,
  });

  final String phone;
  final String flow;

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final TextEditingController _otpController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSignupFlow = widget.flow == 'signup';
    return BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state.isAuthenticated) {
            if (isSignupFlow) {
              context.go(RouteConstants.questionnaire);
            } else {
              context.go(RouteConstants.memberHome);
            }
          }
        },
        builder: (BuildContext context, AuthState state) {
          return AppScaffold(
            showAppBar: false,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: <Widget>[
                    const BrandLogoHeader(showMenu: true),
                    const SizedBox(height: 18),
                    Card(
                      child: SizedBox(
                        height: 230,
                        child: Center(
                          child: Icon(
                            Icons.groups_rounded,
                            size: 120,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthCardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            isSignupFlow ? 'Sign up' : 'Member Login',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Verify OTP for ${widget.phone}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 22),
                          AppTextField(
                            label: 'Enter OTP',
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 18),
                          AppButton(
                            label: 'Verify & Continue',
                            isLoading: state.status == Status.loading,
                            onPressed: () => context.read<AuthBloc>().add(
                                  AuthVerifyOtpPressed(
                                    phone: widget.phone,
                                    code: _otpController.text.trim(),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 10),
                          AppButton(
                            label: 'Back',
                            variant: AppButtonVariant.secondary,
                            onPressed: () => context.pop(),
                          ),
                          if (state.status == Status.failure && state.message != null) ...<Widget>[
                            const SizedBox(height: 10),
                            Text(
                              state.message!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
