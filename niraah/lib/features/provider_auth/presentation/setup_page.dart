import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/code_boxes.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../design_system/widgets/n_page.dart';
import '../../../design_system/widgets/step_progress.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/provider_auth.dart';

/// Invited set-up (spec 003 "Setting up a provider or admin account"),
/// mirroring apps/web/src/app/setup/setup-flow.tsx: a password, an
/// authenticator, then ten recovery codes she confirms she has saved.
class SetupPage extends StatefulWidget {
  const SetupPage({required this.token, super.key});

  final String? token;

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  late final Future<InviteInfo?> _invite = widget.token == null ? Future<InviteInfo?>.value() : _repo.getInvite(widget.token!);
  final TextEditingController _password = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();
  int _step = 1;
  PasswordRejection? _rejection;
  bool _codeFailed = false;
  List<String> _codes = const <String>[];
  AuthenticatorSetup? _authenticator;
  bool _saved = false;
  bool _busy = false;

  ProviderAuthRepository get _repo => getIt<ProviderAuthRepository>();

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() => _rejection = null));
    _code.addListener(() => setState(() => _codeFailed = false));
  }

  @override
  void dispose() {
    _password.dispose();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _setPassword() async {
    setState(() => _busy = true);
    final PasswordRejection? r = await _repo.setPassword(widget.token!, _password.text);
    // Step 2's key comes from the identity provider once the password is set.
    final AuthenticatorSetup? setup = r == null ? await _repo.startAuthenticator(widget.token!) : null;
    if (!mounted) return;
    setState(() {
      _busy = false;
      _rejection = r;
      _authenticator = setup;
      if (r == null) _step = 2;
    });
  }

  Future<void> _confirmCode() async {
    setState(() => _busy = true);
    final List<String>? codes = await _repo.confirmAuthenticator(widget.token!, _code.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (codes == null) {
        _codeFailed = true;
      } else {
        _codes = codes;
        _step = 3;
      }
    });
  }

  Future<void> _finish() async {
    final ProviderSession session = await _repo.finishSetup(widget.token!);
    if (mounted) context.go(homeFor(session));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return FutureBuilder<InviteInfo?>(
      future: _invite,
      builder: (BuildContext context, AsyncSnapshot<InviteInfo?> snap) {
        if (snap.connectionState != ConnectionState.done) return Scaffold(body: LoadingView(label: s.loading));
        final InviteInfo? invite = snap.data;
        if (invite == null) {
          // A neutral page: it never says why the link failed.
          return NPage(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: NSpace.xl),
                Semantics(header: true, child: Text(s.pvSetupInvalidTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
                const SizedBox(height: NSpace.sm),
                Text(s.pvSetupInvalidBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
              ],
            ),
          );
        }
        final List<String> titles = <String>[s.pvSetupStep1, s.pvSetupStep2, s.pvSetupStep3];
        return NPage(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(header: true, child: Text(s.pvSetupWelcome(invite.name), style: NType.h2.copyWith(color: NColors.inkPrimary))),
              Text(invite.email, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
              const SizedBox(height: NSpace.lg),
              StepProgress(current: _step, total: 3, label: s.pvSetupStepOf(_step, 3), section: titles[_step - 1], onBrand: false),
              const SizedBox(height: NSpace.lg),
              ..._stepBody(s),
            ],
          ),
          footer: switch (_step) {
            1 => NPrimaryButton(label: s.pvSetupNext, inactiveHint: s.pvSetupPasswordInactive, loading: _busy, onPressed: _password.text.isEmpty ? null : _setPassword),
            2 => NPrimaryButton(label: s.pvSetupNext, inactiveHint: s.pvAuthInactive, loading: _busy, onPressed: _code.text.length == 6 ? _confirmCode : null),
            _ => NPrimaryButton(label: s.pvSetupFinish, inactiveHint: s.pvSetupFinishInactive, onPressed: _saved ? _finish : null),
          },
        );
      },
    );
  }

  List<Widget> _stepBody(S s) {
    switch (_step) {
      case 1:
        return <Widget>[
          TextField(
            controller: _password,
            obscureText: true,
            autofillHints: const <String>[AutofillHints.newPassword],
            decoration: InputDecoration(labelText: s.pvSetupPasswordLabel, helperText: s.pvSetupPasswordHint, helperMaxLines: 2),
          ),
          if (_rejection != null) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                _rejection == PasswordRejection.tooShort ? s.pvSetupPasswordTooShort : s.pvSetupPasswordBreached,
                style: NType.bodySm.copyWith(color: NColors.statusAttention),
              ),
            ),
          ],
        ];
      case 2:
        return <Widget>[
          Text(s.pvSetupAuthTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.xs),
          Text(s.pvSetupAuthBody, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(NSpace.md),
            decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.lg), border: Border.all(color: NColors.lineDefault)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s.pvSetupAuthKeyLabel, style: NType.label.copyWith(color: NColors.inkMuted)),
                SelectableText(_authenticator?.secret ?? s.setupKeyLoading, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: NSpace.md),
          CodeBoxes(controller: _code, focus: _focus, label: s.pvAuthLabel),
          if (_codeFailed) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            Semantics(liveRegion: true, child: Text(s.pvAuthFailed, style: NType.bodySm.copyWith(color: NColors.statusAttention))),
          ],
          if (_repo.sampleMode) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            Text(s.pvAuthSampleHint, style: NType.label.copyWith(color: NColors.inkMuted)),
          ],
        ];
      default:
        return <Widget>[
          Text(s.pvSetupCodesTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.xs),
          Text(s.pvSetupCodesBody, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(NSpace.md),
            decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.lg), border: Border.all(color: NColors.lineDefault)),
            child: Wrap(
              spacing: NSpace.lg,
              runSpacing: NSpace.xs,
              children: <Widget>[
                for (final String c in _codes) SelectableText(c, style: NType.body.copyWith(color: NColors.inkPrimary, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()])),
              ],
            ),
          ),
          const SizedBox(height: NSpace.sm),
          CheckboxListTile(
            value: _saved,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(s.pvSetupCodesConfirm, style: NType.body.copyWith(color: NColors.inkPrimary)),
            onChanged: (bool? v) => setState(() => _saved = v ?? false),
          ),
        ];
    }
  }
}
