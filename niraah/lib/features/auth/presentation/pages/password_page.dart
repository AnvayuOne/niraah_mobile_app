import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';
import '../../../provider_auth/domain/provider_auth.dart';

/// Password step for providers and admins (spec 003), mirroring
/// apps/web/src/app/sign-in/password/password-form.tsx. It always appears for
/// an email, gives one message for every failure (AC4), and never signs in on
/// its own: success opens the authenticator step (AC20).
class PasswordPage extends StatefulWidget {
  const PasswordPage({required this.email, super.key});

  final String email;

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _password = TextEditingController();
  String? _message;
  bool _forgotSent = false;
  bool _busy = false;
  bool _obscure = true;

  ProviderAuthRepository get _repo => getIt<ProviderAuthRepository>();

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() => _message = null));
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final S s = S.of(context);
    setState(() => _busy = true);
    String? message;
    try {
      final StepResult r = await _repo.checkPassword(widget.email, _password.text);
      if (r.ok) {
        if (mounted) setState(() => _busy = false);
        if (mounted) context.push(RouteConstants.signInAuthenticator);
        return;
      }
      message = r.failure == StepFailure.locked ? s.pvPasswordLocked : s.passwordRejected;
    } on Exception {
      message = s.notConnectedYet;
    }
    if (mounted) {
      setState(() {
        _busy = false;
        _message = message;
      });
    }
  }

  Future<void> _forgot() async {
    await _repo.forgotPassword(widget.email);
    if (mounted) setState(() => _forgotSent = true);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return NPage(
      onBack: () => context.pop(),
      backLabel: s.back,
      body: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(header: true, child: Text(s.passwordTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
            const SizedBox(height: NSpace.xs),
            Text(s.passwordFor(widget.email), style: NType.body.copyWith(color: NColors.inkSecondary)),
            const SizedBox(height: NSpace.xl),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const <String>[AutofillHints.password],
              onSubmitted: (_) => _password.text.isEmpty ? null : _submit(),
              decoration: InputDecoration(
                labelText: s.passwordLabel,
                suffixIcon: IconButton(
                  tooltip: s.passwordLabel,
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
            ),
            if (_message != null) ...<Widget>[
              const SizedBox(height: NSpace.xs),
              Semantics(liveRegion: true, child: Text(_message!, style: NType.bodySm.copyWith(color: NColors.statusAttention))),
            ],
            if (_repo.sampleMode) ...<Widget>[
              const SizedBox(height: NSpace.sm),
              Text(s.pvPasswordSampleHint, style: NType.label.copyWith(color: NColors.inkMuted)),
            ],
            const SizedBox(height: NSpace.sm),
            Wrap(
              spacing: NSpace.xs,
              children: <Widget>[
                TextButton(onPressed: _forgot, child: Text(s.passwordForgot)),
                TextButton(onPressed: () => context.pop(), child: Text(s.passwordChangeEmail)),
              ],
            ),
            if (_forgotSent)
              Semantics(liveRegion: true, child: Text(s.pvPasswordForgotSent, style: NType.bodySm.copyWith(color: NColors.inkSecondary))),
          ],
        ),
      ),
      footer: NPrimaryButton(
        label: s.continueLabel,
        inactiveHint: s.passwordContinueHint,
        loading: _busy,
        onPressed: _password.text.isEmpty ? null : _submit,
      ),
    );
  }
}
