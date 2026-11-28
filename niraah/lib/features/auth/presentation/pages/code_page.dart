import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/code_boxes.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/helpers/result.dart';
import '../../domain/auth_repository.dart';

/// The one-time code step (spec 003): the number with a way to change it,
/// six boxes, resend after 30 seconds, and the time the code stays valid.
class CodePage extends StatefulWidget {
  const CodePage({required this.phone, super.key});

  final PhoneInput phone;

  static const Duration resendAfter = Duration(seconds: 30);
  static const Duration codeValidFor = Duration(minutes: 10);

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _tick;
  late DateTime _sentAt;
  Duration _elapsed = Duration.zero;
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _restartClock();
    _code.addListener(() => setState(() => _message = null));
  }

  void _restartClock() {
    _sentAt = DateTime.now();
    _elapsed = Duration.zero;
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed = DateTime.now().difference(_sentAt));
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _expired => _elapsed >= CodePage.codeValidFor;

  Future<void> _resend() async {
    _code.clear();
    final Result<void> r = await getIt<AuthRepository>().requestCode(widget.phone.e164);
    if (!mounted) return;
    switch (r) {
      case Success<void>():
        setState(_restartClock);
      case FailureResult<void>(:String message):
        setState(() => _message = message == 'not_connected' ? S.of(context).notConnectedYet : message);
    }
  }

  Future<void> _verify() async {
    final S s = S.of(context);
    setState(() => _busy = true);
    final Result<CodeOutcome> r = await getIt<AuthRepository>().verifyCode(widget.phone.e164, _code.text);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case Success<CodeOutcome>(:CodeOutcome data):
        context.go(routeForOutcome(data));
      case FailureResult<CodeOutcome>(:String message):
        // Server messages are written to be shown as they are (spec 003 "Not revealing accounts").
        setState(() => _message = switch (message) {
              'not_connected' => s.notConnectedYet,
              'code_rejected' => s.codeNotAccepted,
              _ => message,
            });
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final int resendIn = (CodePage.resendAfter - _elapsed).inSeconds.clamp(0, 30);
    final Duration left = CodePage.codeValidFor - _elapsed;
    final String mm = left.inMinutes.clamp(0, 10).toString();
    final String ss = (left.inSeconds % 60).clamp(0, 59).toString().padLeft(2, '0');
    return NPage(
      onBack: () => context.pop(),
      backLabel: s.back,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.codeTitle, style: NType.h2.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.xs),
          Text(s.codeBody(widget.phone.display), style: NType.body.copyWith(color: NColors.inkSecondary)),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () => context.pop(), child: Text(s.codeChangeNumber)),
          ),
          const SizedBox(height: NSpace.lg),
          CodeBoxes(controller: _code, focus: _focus, label: s.codeFieldLabel),
          const SizedBox(height: NSpace.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              _message ?? (_expired ? s.codeExpired : s.codeExpiresIn(mm, ss)),
              style: NType.bodySm.copyWith(color: _message != null ? NColors.statusAttention : NColors.inkMuted),
            ),
          ),
          const SizedBox(height: NSpace.xs),
          TextButton(
            onPressed: resendIn == 0 ? _resend : null,
            child: Text(resendIn == 0 ? s.codeResend : s.codeResendIn(resendIn)),
          ),
        ],
      ),
      footer: NPrimaryButton(
        label: s.codeVerify,
        inactiveHint: s.codeContinueHint,
        loading: _busy,
        onPressed: _code.text.length == 6 && !_expired ? _verify : null,
      ),
    );
  }
}
