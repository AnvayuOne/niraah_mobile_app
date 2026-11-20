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

/// "Sign in as" (spec 003 "The sign-in screen" 1–2a, amended 2026-11-18). The choice only picks the field; it is
/// never sent to the server, and the workspace after sign-in follows the account's role (AC3). Admin is web only.
enum SignInAs { member, doctor, dietitian, trainer }

/// One sign-in screen for every role (spec 003): Member types a mobile number, everyone else an email.
/// It never says whether an account exists.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _field = TextEditingController();
  SignInAs _as = SignInAs.member;
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

  Future<void> _continue() async {
    final S s = S.of(context);
    final SignInInput input = SignInInput.parse(_field.text);
    // What was typed must fit the choice (AC1); a mismatch is refused here, without a server call.
    if (_as == SignInAs.member && input is! PhoneInput) {
      setState(() => _message = s.signInNeedNumber);
      return;
    }
    if (_as != SignInAs.member && input is! EmailInput) {
      setState(() => _message = s.signInNeedEmail);
      return;
    }
    switch (input) {
      case UnrecognisedInput():
        setState(() => _message = s.signInUnrecognised);
      case EmailInput(:final String email):
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
          case FailureResult<void>(:final String message):
            // Limits and send failures come back as words to show (spec 003 "Limits" 3).
            setState(() => _message = message == 'not_connected' ? s.notConnectedYet : message);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool member = _as == SignInAs.member;
    final Map<SignInAs, String> labels = <SignInAs, String>{
      SignInAs.member: s.signInAsMember,
      SignInAs.doctor: s.signInAsDoctor,
      SignInAs.dietitian: s.signInAsDietitian,
      SignInAs.trainer: s.signInAsTrainer,
    };
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
            Text(member ? s.signInBody : s.signInStaffBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
            const SizedBox(height: NSpace.lg),
            Text(s.signInAs, style: NType.label.copyWith(color: NColors.inkSecondary)),
            const SizedBox(height: NSpace.xs),
            Wrap(
              spacing: NSpace.xs,
              runSpacing: NSpace.xs,
              children: <Widget>[
                for (final SignInAs k in SignInAs.values)
                  ChoiceChip(
                    label: Text(labels[k]!),
                    selected: _as == k,
                    onSelected: (_) => setState(() {
                      _as = k;
                      _field.clear();
                      _message = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: NSpace.lg),
            TextField(
              key: ValueKey<bool>(member),
              controller: _field,
              keyboardType: member ? TextInputType.phone : TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.go,
              autofillHints: member ? const <String>[AutofillHints.telephoneNumberNational] : const <String>[AutofillHints.email],
              onSubmitted: (_) => _continue(),
              decoration: InputDecoration(
                labelText: member ? s.signInNumberLabel : s.signInEmailLabel,
                prefixIcon: !member
                    ? const Icon(Icons.mail_outline_rounded, color: NColors.inkMuted)
                    : Padding(
                        padding: const EdgeInsets.only(left: NSpace.md, right: NSpace.xs),
                        child: Align(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Text(s.signInCountryCode, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                        ),
                      ),
                prefixIconConstraints: const BoxConstraints(minWidth: NLayout.minTapTarget, minHeight: NLayout.minTapTarget),
              ),
            ),
            const SizedBox(height: NSpace.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                _message ?? (member ? s.signInNumberHint : s.signInEmailHint),
                style: NType.bodySm.copyWith(color: _message != null ? NColors.statusAttention : NColors.inkMuted),
              ),
            ),
            const SizedBox(height: NSpace.md),
            // Spec 006 "Applying by herself": linked from sign-in. The application, with its human check, opens on
            // the website; once her sign-in is set up she completes it here on the status page.
            TextButton(
              onPressed: () => launchUrl(applyPageUrl(), mode: LaunchMode.externalApplication),
              child: Text(s.pvApplyLink, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
      footer: NPrimaryButton(
        label: s.continueLabel,
        inactiveHint: member ? s.signInEnterNumber : s.signInEnterEmail,
        loading: _busy,
        onPressed: _field.text.trim().isEmpty ? null : _continue,
      ),
    );
  }
}
