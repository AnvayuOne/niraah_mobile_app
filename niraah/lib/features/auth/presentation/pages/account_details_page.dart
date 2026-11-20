import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';
import '../../../../shared/helpers/result.dart';
import '../../domain/auth_repository.dart';

/// Create-account details (spec 010 §1.3): the name she wants to be called,
/// agreement to the terms and privacy notice, and an optional recovery email.
/// Date of birth and health consent come later, with the assessment.
class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  /// The legal texts' versions are recorded with her agreement. These will
  /// come from the server once spec 003's endpoints exist.
  static const String termsVersion = 'terms-draft-1';
  static const String privacyVersion = 'privacy-draft-1';

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  bool _agreed = false;
  bool _busy = false;
  String? _emailMessage;
  String? _message;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _email.addListener(() => setState(() => _emailMessage = null));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final S s = S.of(context);
    final String email = _email.text.trim();
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _emailMessage = s.detailsEmailInvalid);
      return;
    }
    setState(() => _busy = true);
    final Result<void> r = await getIt<AuthRepository>().saveAccountDetails(
      displayName: _name.text.trim(),
      termsVersion: AccountDetailsPage.termsVersion,
      privacyVersion: AccountDetailsPage.privacyVersion,
      recoveryEmail: email.isEmpty ? null : email,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case Success<void>():
        context.go(RouteConstants.assessmentStart);
      case FailureResult<void>(:final String message):
        // The server's words are safe to show; 'not_connected' only comes from the offline stand-ins.
        setState(() => _message = message == 'not_connected' ? s.notConnectedYet : message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ready = _name.text.trim().isNotEmpty && _agreed;
    return NPage(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.detailsTitle, style: NType.h2.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.xs),
          Text(s.detailsBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.xl),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            autofillHints: const <String>[AutofillHints.givenName],
            decoration: InputDecoration(labelText: s.detailsNameLabel, hintText: s.detailsNameHint),
          ),
          const SizedBox(height: NSpace.md),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            autofillHints: const <String>[AutofillHints.email],
            decoration: InputDecoration(labelText: s.detailsEmailLabel, helperText: s.detailsEmailHelp, helperMaxLines: 3, errorText: _emailMessage),
          ),
          const SizedBox(height: NSpace.lg),
          MergeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Checkbox(value: _agreed, onChanged: (bool? v) => setState(() => _agreed = v ?? false)),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Padding(
                      padding: const EdgeInsets.only(top: NSpace.sm),
                      child: Text(s.detailsAgree, style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: NSpace.xs,
            children: <Widget>[
              TextButton(onPressed: () => context.push(RouteConstants.support), child: Text(s.detailsTermsLink)),
              TextButton(onPressed: () => context.push(RouteConstants.support), child: Text(s.detailsPrivacyLink)),
            ],
          ),
          if (_message != null) Text(_message!, style: NType.bodySm.copyWith(color: NColors.statusAttention)),
        ],
      ),
      footer: NPrimaryButton(
        label: s.detailsContinue,
        inactiveHint: s.detailsContinueHint,
        loading: _busy,
        onPressed: ready ? _submit : null,
      ),
    );
  }
}
