import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/code_boxes.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../../me/domain/me.dart';
import '../../me/presentation/fresh_check.dart';
import '../domain/account.dart';

enum SessionsStatus { loading, ready, failure }

class SessionsState extends Equatable {
  const SessionsState({this.status = SessionsStatus.loading, this.sessions = const <SignedInSession>[], this.busy = false});

  final SessionsStatus status;
  final List<SignedInSession> sessions;
  final bool busy;

  @override
  List<Object?> get props => <Object?>[status, sessions, busy];
}

/// Her signed-in devices (spec 003 "Sessions" 7, 8): device, approximate city and last active time; end any one, or
/// all of them.
class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit(this._repo) : super(const SessionsState());

  final AccountRepository _repo;

  Future<void> load() async {
    try {
      final List<SignedInSession> list = await _repo.sessions();
      // This device first, then the most recently active.
      list.sort((SignedInSession a, SignedInSession b) => a.current != b.current ? (a.current ? -1 : 1) : b.lastActiveAt.compareTo(a.lastActiveAt));
      emit(SessionsState(status: SessionsStatus.ready, sessions: list));
    } on Object {
      emit(SessionsState(status: SessionsStatus.failure, sessions: state.sessions));
    }
  }

  /// Null when it worked; otherwise what went wrong.
  Future<Object?> end(String id) async {
    emit(SessionsState(status: state.status, sessions: state.sessions, busy: true));
    try {
      await _repo.endSession(id);
      await load();
      return null;
    } on Object catch (e) {
      emit(SessionsState(status: state.status, sessions: state.sessions));
      return e;
    }
  }

  Future<Object?> endAll() async {
    emit(SessionsState(status: state.status, sessions: state.sessions, busy: true));
    try {
      await _repo.signOutEverywhere();
      return null;
    } on Object catch (e) {
      emit(SessionsState(status: state.status, sessions: state.sessions));
      return e;
    }
  }
}

class SignedInDevicesPage extends StatelessWidget {
  const SignedInDevicesPage({super.key, this.repository});

  final AccountRepository? repository;

  @override
  Widget build(BuildContext context) => BlocProvider<SessionsCubit>(
        create: (_) => SessionsCubit(repository ?? getIt<AccountRepository>())..load(),
        child: const _SessionsView(),
      );
}

class _SessionsView extends StatelessWidget {
  const _SessionsView();

  Future<void> _endAll(BuildContext context) async {
    final S s = S.of(context);
    final SessionsCubit cubit = context.read<SessionsCubit>();
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text(s.acctEndAllTitle),
        content: Text(s.acctEndAllBody),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.acctEndAll)),
        ],
      ),
    );
    if (!(yes ?? false) || !context.mounted) return;
    final Object? e = await cubit.endAll();
    if (!context.mounted) return;
    if (e == null) {
      context.go(RouteConstants.signIn);
    } else {
      showNote(context, failureText(e, s.commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    return AreaScaffold(
      title: s.acctDevicesTitle,
      body: BlocBuilder<SessionsCubit, SessionsState>(
        builder: (BuildContext context, SessionsState st) {
          final SessionsCubit cubit = context.read<SessionsCubit>();
          if (st.status == SessionsStatus.loading) return LoadingView(label: s.loading);
          if (st.status == SessionsStatus.failure) return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: cubit.load);
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              Text(s.acctDevicesBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.sm),
              for (final SignedInSession x in st.sessions) ...<Widget>[
                NCard(
                  child: Row(
                    children: <Widget>[
                      Icon(x.deviceType == 'web' ? Icons.laptop_rounded : Icons.smartphone_rounded, color: NColors.inkSecondary),
                      const SizedBox(width: NSpace.sm),
                      Expanded(
                        child: MergeSemantics(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(<String>[x.deviceType, if (x.city != null) x.city!].join(' · '), style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                              Text(x.current ? s.acctThisDevice : s.acctLastActive(DateFormat('d MMM, h:mm a', locale).format(x.lastActiveAt)), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                            ],
                          ),
                        ),
                      ),
                      if (!x.current)
                        TextButton(
                          onPressed: st.busy
                              ? null
                              : () async {
                                  final Object? e = await cubit.end(x.id);
                                  if (context.mounted) showNote(context, e == null ? s.acctEnded : failureText(e, s.commonLoadError));
                                },
                          child: Text(s.acctEnd),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.xs),
              ],
              const SizedBox(height: NSpace.md),
              NSecondaryButton(label: s.acctEndAll, onPressed: st.busy ? null : () => _endAll(context)),
            ],
          );
        },
      ),
    );
  }
}

/// Changing her mobile number from settings (spec 003 "Changing a mobile number" 1, 2): a fresh code on the current
/// number, then the new number and its code. A change started by a recovery link waits 24 hours, and can be cancelled
/// here (rule 4).
class ChangeNumberPage extends StatefulWidget {
  const ChangeNumberPage({super.key, this.repository, this.me});

  final AccountRepository? repository;
  final MeRepository? me;

  @override
  State<ChangeNumberPage> createState() => _ChangeNumberPageState();
}

class _ChangeNumberPageState extends State<ChangeNumberPage> {
  late final AccountRepository _repo = widget.repository ?? getIt<AccountRepository>();
  late final MeRepository _me = widget.me ?? getIt<MeRepository>();
  late Future<List<PendingNumberChange>> _pending = _repo.pendingNumberChanges();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final FocusNode _codeFocus = FocusNode();
  bool _codeSent = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _phone.addListener(() => setState(() {}));
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  /// Ten digits, with or without +91, spaces or dashes (spec 003 "The sign-in screen" 2, 3).
  bool get _numberOk {
    String d = _phone.text.replaceAll(RegExp(r'[\s-]'), '');
    if (d.startsWith('+91')) d = d.substring(3);
    return RegExp(r'^\d{10}$').hasMatch(d);
  }

  Future<void> _send() async {
    final S s = S.of(context);
    final String? proof = await freshCheck(context, _me);
    if (proof == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await _repo.startNumberChange(proofId: proof, phone: _phone.text);
      if (!mounted) return;
      setState(() => _codeSent = true);
      _codeFocus.requestFocus();
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final S s = S.of(context);
    setState(() => _busy = true);
    try {
      await _repo.confirmNumberChange(_code.text);
      if (!mounted) return;
      showNote(context, s.acctNumberChanged);
      Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(PendingNumberChange c) async {
    final S s = S.of(context);
    try {
      await _repo.cancelNumberChange(c.id);
      if (!mounted) return;
      showNote(context, s.acctChangeCancelled);
      setState(() => _pending = _repo.pendingNumberChanges());
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.acctNumberTitle,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          FutureBuilder<List<PendingNumberChange>>(
            future: _pending,
            builder: (BuildContext context, AsyncSnapshot<List<PendingNumberChange>> snap) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final PendingNumberChange c in snap.data ?? const <PendingNumberChange>[]) ...<Widget>[
                  NCard(
                    color: NColors.surfaceWarm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(s.acctPendingChange(c.newNumberEnding, shortDate(context, c.effectiveAt.toIso8601String())), style: NType.body.copyWith(color: NColors.inkPrimary)),
                        TextButton(onPressed: () => _cancel(c), child: Text(s.acctCancelChange)),
                      ],
                    ),
                  ),
                  const SizedBox(height: NSpace.sm),
                ],
              ],
            ),
          ),
          Text(s.acctNumberBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.sm),
          TextField(
            controller: _phone,
            enabled: !_codeSent,
            keyboardType: TextInputType.phone,
            autofillHints: const <String>[AutofillHints.telephoneNumber],
            decoration: InputDecoration(labelText: s.acctNewNumber, prefixText: '+91 '),
          ),
          const SizedBox(height: NSpace.md),
          if (!_codeSent)
            NPrimaryButton(label: s.acctSendCode, loading: _busy, inactiveHint: s.signInEnterNumber, onPressed: _numberOk ? _send : null)
          else ...<Widget>[
            Text(s.acctCodeSent, style: NType.body.copyWith(color: NColors.inkSecondary)),
            const SizedBox(height: NSpace.sm),
            CodeBoxes(controller: _code, focus: _codeFocus, label: s.codeFieldLabel),
            const SizedBox(height: NSpace.md),
            NPrimaryButton(label: s.acctConfirmNumber, loading: _busy, onPressed: _code.text.length == 6 ? _confirm : null),
          ],
        ],
      ),
    );
  }
}

/// Adding, changing or removing her recovery email (spec 003 "Recovery" 4; "Sensitive actions": a fresh code first).
/// It counts once she opens the link sent to it.
class RecoveryEmailPage extends StatefulWidget {
  const RecoveryEmailPage({super.key, this.repository, this.me, this.current});

  final AccountRepository? repository;
  final MeRepository? me;

  /// Her recovery email now, when she has one.
  final String? current;

  @override
  State<RecoveryEmailPage> createState() => _RecoveryEmailPageState();
}

class _RecoveryEmailPageState extends State<RecoveryEmailPage> {
  late final AccountRepository _repo = widget.repository ?? getIt<AccountRepository>();
  late final MeRepository _me = widget.me ?? getIt<MeRepository>();
  final TextEditingController _email = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  bool get _emailOk => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());

  Future<void> _run(Future<void> Function(String proof) action, String done) async {
    final S s = S.of(context);
    final String? proof = await freshCheck(context, _me);
    if (proof == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await action(proof);
      if (!mounted) return;
      showNote(context, done);
      Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.profileRecoveryEmail,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          Text(s.acctEmailBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          if (widget.current != null) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            Text(s.acctEmailNow(widget.current!), style: NType.body.copyWith(color: NColors.inkPrimary)),
          ],
          const SizedBox(height: NSpace.sm),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.email],
            maxLength: 254,
            decoration: InputDecoration(labelText: widget.current == null ? s.acctEmailAdd : s.acctEmailNew),
          ),
          const SizedBox(height: NSpace.md),
          NPrimaryButton(
            label: s.acctEmailSave,
            loading: _busy,
            inactiveHint: s.signInEnterEmail,
            onPressed: _emailOk ? () => _run((String p) => _repo.setRecoveryEmail(proofId: p, email: _email.text), s.acctEmailSent) : null,
          ),
          if (widget.current != null) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            TextButton(onPressed: _busy ? null : () => _run(_repo.removeRecoveryEmail, s.acctEmailRemoved), child: Text(s.acctEmailRemove)),
          ],
        ],
      ),
    );
  }
}
