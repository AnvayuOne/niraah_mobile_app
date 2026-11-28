import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/code_boxes.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../design_system/widgets/n_page.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/provider_auth.dart';

/// Authenticator step (spec 003), mirroring
/// apps/web/src/app/sign-in/authenticator/authenticator-form.tsx: six boxes,
/// or a single-use recovery code instead. Success routes by role and status.
class AuthenticatorPage extends StatefulWidget {
  const AuthenticatorPage({super.key});

  @override
  State<AuthenticatorPage> createState() => _AuthenticatorPageState();
}

class _AuthenticatorPageState extends State<AuthenticatorPage> {
  final TextEditingController _code = TextEditingController();
  final TextEditingController _recovery = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _useRecovery = false;
  bool _failed = false;
  bool _busy = false;

  ProviderAuthRepository get _repo => getIt<ProviderAuthRepository>();

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() => _failed = false));
    _recovery.addListener(() => setState(() => _failed = false));
  }

  @override
  void dispose() {
    _code.dispose();
    _recovery.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _ready => _useRecovery ? _recovery.text.trim().isNotEmpty : _code.text.length == 6;

  Future<void> _verify() async {
    setState(() => _busy = true);
    final ProviderSession? session;
    try {
      session = await _repo.verifySecondFactor(
        _useRecovery ? _recovery.text : _code.text,
        _useRecovery ? SecondFactorKind.recovery : SecondFactorKind.authenticator,
      );
    } on NewAuthenticatorRequired {
      // A recovery code works once, then a new authenticator is required (spec 003 AC25).
      if (mounted) context.go(RouteConstants.signInNewAuthenticator);
      return;
    }
    if (!mounted) return;
    if (session == null) {
      setState(() {
        _busy = false;
        _failed = true;
      });
      return;
    }
    context.go(homeFor(session));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return NPage(
      onBack: () => context.pop(),
      backLabel: s.back,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(header: true, child: Text(s.pvAuthTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
          const SizedBox(height: NSpace.xs),
          Text(s.pvAuthBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.xl),
          if (_useRecovery) ...<Widget>[
            TextField(
              controller: _recovery,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(labelText: s.pvAuthRecoveryLabel, helperText: s.pvAuthRecoveryHint, hintText: 'xxxx-xxxx'),
            ),
          ] else
            CodeBoxes(controller: _code, focus: _focus, label: s.pvAuthLabel),
          if (_failed) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            Semantics(liveRegion: true, child: Text(s.pvAuthFailed, style: NType.bodySm.copyWith(color: NColors.statusAttention))),
          ],
          if (_repo.sampleMode && !_useRecovery) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            Text(s.pvAuthSampleHint, style: NType.label.copyWith(color: NColors.inkMuted)),
          ],
          const SizedBox(height: NSpace.sm),
          TextButton(
            onPressed: () => setState(() {
              _useRecovery = !_useRecovery;
              _failed = false;
            }),
            child: Text(_useRecovery ? s.pvAuthUseAuthenticator : s.pvAuthUseRecovery),
          ),
        ],
      ),
      footer: NPrimaryButton(label: s.pvAuthVerify, inactiveHint: s.pvAuthInactive, loading: _busy, onPressed: _ready ? _verify : null),
    );
  }
}
