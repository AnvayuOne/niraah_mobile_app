import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';
import '../../../../shared/helpers/result.dart';
import '../../../provider_auth/application_repository.dart';
import '../../domain/auth_repository.dart';

/// One sign-in for everyone (changed 2026-11-27 at the product owner's request; replaces "Sign in as"). What she types
/// decides the path: a mobile number gets a one-time code, an email goes to password and authenticator. The server
/// returns the account's workspace and she lands there (member home, assessment, create account, doctor, dietitian,
/// trainer, admin notice, provider status). A new number creates a member account, so sign-up is members only;
/// doctors and others join through the Apply link and their invites. It never says whether an account exists.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _field = TextEditingController();
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _field.addListener(() => setState(() => _message = null));
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  /// Digits so far (with or without +91, spaces or dashes): show the +91 prefix and treat it as a number.
  bool get _looksLikeNumber {
    final String t = _field.text.trim();
    return t.isNotEmpty && RegExp(r'^\+?[\d\s-]+$').hasMatch(t);
  }

  Future<void> _continue() async {
    final S s = S.of(context);
    final SignInInput input = SignInInput.parse(_field.text);
    switch (input) {
      case UnrecognisedInput():
        setState(() => _message = s.signInUnrecognised);
      case EmailInput(:String email):
        context.push(RouteConstants.signInPassword, extra: email);
      case final PhoneInput phone:
        if (!phone.isValid) {
          setState(() => _message = s.signInPhoneInvalid);
          return;
        }
        setState(() => _busy = true);
        final Result<void> r = await getIt<AuthRepository>().requestCode(phone.e164);
        if (!mounted) return;
        setState(() => _busy = false);
        switch (r) {
          case Success<void>():
            context.push(RouteConstants.signInCode, extra: phone);
          case FailureResult<void>(:String message):
            // Limits and send failures come back as words to show (spec 003 "Limits" 3).
            setState(() => _message = message == 'not_connected' ? s.notConnectedYet : message);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool number = _looksLikeNumber;
    return NPage(
      decor: true,
      onBack: () => context.go(RouteConstants.welcome),
      backLabel: s.back,
      body: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.signInTitle, style: NType.h2.copyWith(color: NColors.inkPrimary)),
            const SizedBox(height: NSpace.xs),
            Text(s.signInAnyBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
            const SizedBox(height: NSpace.lg),
            TextField(
              key: const ValueKey<String>('sign-in-field'),
              controller: _field,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.go,
              autofillHints: const <String>[AutofillHints.telephoneNumberNational, AutofillHints.email],
              onSubmitted: (_) => _continue(),
              decoration: InputDecoration(
                labelText: s.signInAnyLabel,
                prefixIcon: number
                    ? Padding(
                        padding: const EdgeInsets.only(left: NSpace.md, right: NSpace.xs),
                        child: Align(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Text(s.signInCountryCode, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                        ),
                      )
                    : Icon(Icons.person_outline_rounded, color: NColors.inkMuted),
                prefixIconConstraints: const BoxConstraints(minWidth: NLayout.minTapTarget, minHeight: NLayout.minTapTarget),
              ),
            ),
            const SizedBox(height: NSpace.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                _message ?? s.signInAnyHint,
                style: NType.bodySm.copyWith(color: _message != null ? NColors.statusAttention : NColors.inkMuted),
              ),
            ),
            const SizedBox(height: NSpace.lg),
            // Sign-up is for members: a new mobile number creates her account.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(NSpace.md),
              decoration: BoxDecoration(color: NColors.brandBlushLight, borderRadius: BorderRadius.circular(NRadius.lg)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.favorite_border_rounded, size: 20, color: NColors.brandRosewood),
                  const SizedBox(width: NSpace.sm),
                  Expanded(child: Text(s.signInNewHere, style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
                ],
              ),
            ),
            const SizedBox(height: NSpace.sm),
            // Spec 006 "Applying by herself": linked from sign-in. Unchanged: doctors and others apply on the website and
            // finish set-up from their invite.
            TextButton(
              onPressed: () => launchUrl(applyPageUrl(), mode: LaunchMode.externalApplication),
              child: Text(s.pvApplyLink, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
      footer: NPrimaryButton(
        label: s.continueLabel,
        inactiveHint: s.signInEnterAny,
        loading: _busy,
        onPressed: _field.text.trim().isEmpty ? null : _continue,
      ),
    );
  }
}
