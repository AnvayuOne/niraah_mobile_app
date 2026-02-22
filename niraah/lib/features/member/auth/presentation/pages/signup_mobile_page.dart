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

class SignupMobilePage extends StatefulWidget {
  const SignupMobilePage({super.key});

  @override
  State<SignupMobilePage> createState() => _SignupMobilePageState();
}

class _SignupMobilePageState extends State<SignupMobilePage> {
  final TextEditingController _phoneController = TextEditingController(text: '9988776655');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state.status == Status.success && state.isOtpRequested) {
            context.push(
              '${RouteConstants.otpVerify}?phone=${_phoneController.text.trim()}&flow=signup',
            );
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
                            'Sign up',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your account with your mobile number',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 22),
                          AppTextField(
                            label: 'Mobile number',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            hintText: 'e.g. 9990000005',
                          ),
                          const SizedBox(height: 18),
                          AppButton(
                            label: 'Send OTP',
                            isLoading: state.status == Status.loading,
                            onPressed: () => context
                                .read<AuthBloc>()
                                .add(AuthRequestOtpPressed(_phoneController.text.trim())),
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
                          const SizedBox(height: 10),
                          Text(
                            'By continuing you agree to our Terms and Privacy Policy.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            child: TextButton(
                              onPressed: () => context.go(RouteConstants.auth),
                              child: const Text('Already have an account? Sign In'),
                            ),
                          ),
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
