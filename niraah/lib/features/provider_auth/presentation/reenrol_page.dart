import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/code_boxes.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../design_system/widgets/n_page.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/provider_auth.dart';

/// After a recovery code: a new authenticator before any session (spec 003 "Recovery" 2, AC25).
class ReenrolPage extends StatefulWidget {
  const ReenrolPage({super.key});

  @override
  State<ReenrolPage> createState() => _ReenrolPageState();
}

class _ReenrolPageState extends State<ReenrolPage> {
  final ProviderAuthRepository _repo = getIt<ProviderAuthRepository>();
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();
  AuthenticatorSetup? _setup;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() => _failed = false));
    _load();
  }

  Future<void> _load() async {
    final AuthenticatorSetup? setup = await _repo.startReenrol();
    if (!mounted) return;
    if (setup == null) return context.go(RouteConstants.signIn);
    setState(() => _setup = setup);
  }

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _busy = true);
    final ProviderSession? session = await _repo.confirmReenrol(_setup!.factorId, _code.text);
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
    final AuthenticatorSetup? setup = _setup;
    if (setup == null) return Scaffold(body: LoadingView(label: s.setupKeyLoading));
    return NPage(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(header: true, child: Text(s.reauthTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
          const SizedBox(height: NSpace.sm),
          Text(s.reauthBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.lg),
          Text(s.pvSetupAuthKeyLabel, style: NType.label.copyWith(color: NColors.inkMuted)),
          const SizedBox(height: NSpace.xxs),
          SelectableText(setup.secret, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: NSpace.lg),
          CodeBoxes(controller: _code, focus: _focus, label: s.pvAuthLabel),
          if (_failed) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            Semantics(liveRegion: true, child: Text(s.pvAuthFailed, style: NType.bodySm.copyWith(color: NColors.statusAttention))),
          ],
        ],
      ),
      footer: NPrimaryButton(label: s.pvAuthVerify, inactiveHint: s.pvAuthInactive, loading: _busy, onPressed: _code.text.length == 6 ? _confirm : null),
    );
  }
}
