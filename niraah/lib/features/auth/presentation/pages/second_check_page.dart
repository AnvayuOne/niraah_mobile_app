import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/code_boxes.dart';
import '../../../../design_system/widgets/date_of_birth_input.dart';
import '../../../../design_system/widgets/loading_view.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';
import '../../domain/auth_repository.dart';

/// The second check (spec 003 "Second check"), mirroring apps/web/src/app/sign-in/second-check.
/// Nothing about the account is shown here (AC46). "This is not my account" is always offered.
class SecondCheckPage extends StatefulWidget {
  const SecondCheckPage({super.key});

  @override
  State<SecondCheckPage> createState() => _SecondCheckPageState();
}

class _SecondCheckPageState extends State<SecondCheckPage> {
  final SecondCheckRepository _repo = getIt<SecondCheckRepository>();
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();
  SecondCheckOptions? _options;
  SecondCheckMethod? _method;
  DateTime? _dob;
  bool _emailSent = false;
  bool _confirmNew = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() => _error = null));
    _load();
  }

  Future<void> _load() async {
    final SecondCheckOptions? o = await _repo.options();
    if (!mounted) return;
    if (o == null) return context.go(RouteConstants.signIn);
    setState(() {
      _options = o;
      _method = o.methods.contains(SecondCheckMethod.dateOfBirth) ? SecondCheckMethod.dateOfBirth : o.methods.firstOrNull;
    });
  }

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _answer => switch (_method) {
        SecondCheckMethod.dateOfBirth => _dob == null
            ? ''
            : '${_dob!.year.toString().padLeft(4, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
        SecondCheckMethod.recoveryEmail => _code.text,
        SecondCheckMethod.knownDevice => 'device',
        null => '',
      };

  bool get _ready => switch (_method) {
        SecondCheckMethod.dateOfBirth => _dob != null,
        SecondCheckMethod.recoveryEmail => _emailSent && _code.text.length == 6,
        SecondCheckMethod.knownDevice => true,
        null => false,
      };

  Future<void> _check() async {
    setState(() => _busy = true);
    final SecondCheckAnswer r = await _repo.answer(_method!, _answer);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case SecondCheckPassed():
        context.go(RouteConstants.home);
      case SecondCheckWrong(:final String message, :final bool ended):
        if (ended) {
          await _repo.signOut();
          if (mounted) context.go(RouteConstants.signIn);
        } else {
          setState(() => _error = message);
        }
    }
  }

  Future<void> _startOver() async {
    setState(() => _busy = true);
    final bool ok = await _repo.notMyAccount();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) context.go(RouteConstants.accountDetails);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final SecondCheckOptions? o = _options;
    if (o == null) return Scaffold(body: LoadingView(label: s.loading));

    if (_confirmNew) {
      return NPage(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(header: true, child: Text(s.scNotMineTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
            const SizedBox(height: NSpace.sm),
            Text(s.scNotMineBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
            const SizedBox(height: NSpace.xl),
            NSecondaryButton(label: s.scCancel, onPressed: () => setState(() => _confirmNew = false)),
          ],
        ),
        footer: NPrimaryButton(label: s.scNotMineConfirm, loading: _busy, onPressed: _startOver),
      );
    }

    return NPage(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(header: true, child: Text(s.scTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
          const SizedBox(height: NSpace.sm),
          Text(o.contactSupport ? s.scSupport : s.scBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.lg),
          if (_method == SecondCheckMethod.dateOfBirth)
            DateOfBirthInput(
              value: _dob,
              onChanged: (DateTime d) => setState(() {
                _dob = d;
                _error = null;
              }),
              placeholder: s.scDobPlaceholder,
              chosenLabel: s.scDobChosen,
            ),
          if (_method == SecondCheckMethod.recoveryEmail)
            _emailSent
                ? CodeBoxes(controller: _code, focus: _focus, label: s.scEmailCodeLabel)
                : NSecondaryButton(
                    label: s.scEmailOption,
                    onPressed: () async {
                      final bool sent = await _repo.sendEmailCode();
                      if (mounted) setState(() => _emailSent = sent);
                    },
                  ),
          if (_method == SecondCheckMethod.knownDevice) Text(s.scDeviceBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          if (_error != null) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            Semantics(liveRegion: true, child: Text(_error!, style: NType.bodySm.copyWith(color: NColors.statusAttention))),
          ],
          if (_emailSent && _method == SecondCheckMethod.recoveryEmail) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            Text(s.scEmailSent, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
          ],
          const SizedBox(height: NSpace.md),
          for (final SecondCheckMethod m in o.methods.where((SecondCheckMethod m) => m != _method))
            TextButton(
              onPressed: () => setState(() {
                _method = m;
                _error = null;
                _code.clear();
              }),
              child: Text(switch (m) {
                SecondCheckMethod.dateOfBirth => s.scDobLabel,
                SecondCheckMethod.recoveryEmail => s.scEmailOption,
                SecondCheckMethod.knownDevice => s.scDeviceOption,
              }),
            ),
          TextButton(onPressed: () => setState(() => _confirmNew = true), child: Text(s.scNotMine)),
        ],
      ),
      footer: _method == null ? null : NPrimaryButton(label: s.scCheck, inactiveHint: s.scInactive, loading: _busy, onPressed: _ready ? _check : null),
    );
  }
}
