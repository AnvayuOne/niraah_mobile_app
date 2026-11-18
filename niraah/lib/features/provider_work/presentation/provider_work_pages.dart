import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/provider_work.dart';

/// Wraps a provider screen in its workspace frame (the doctor shell, or a plain page).
typedef ProviderFrame = Widget Function(BuildContext context, String title, Widget body);

Widget plainFrame(BuildContext context, String title, Widget body) => AreaScaffold(title: title, body: body);

String rupeesFromPaise(int paise) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: paise % 100 == 0 ? 0 : 2).format(paise / 100);

/// Earnings (spec 011 §14; spec 008): balances, each line with the kind of work, date and state, the rules in
/// plain words, payouts, and cash-out of the available balance.
class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key, this.repository, this.frame = plainFrame});

  final ProviderWorkRepository? repository;
  final ProviderFrame frame;

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  late final ProviderWorkRepository _repo = widget.repository ?? getIt<ProviderWorkRepository>();
  late Future<(Json, List<Json>)> _data = _load();
  bool _busy = false;

  Future<(Json, List<Json>)> _load() async => (await _repo.earnings(), await _repo.payouts());

  Future<void> _cashOut() async {
    final S s = S.of(context);
    setState(() => _busy = true);
    try {
      await _repo.requestPayout();
      if (!mounted) return;
      showNote(context, s.earnPayoutRequested);
      setState(() => _data = _load());
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _state(S s, String st) => switch (st) {
    'pending' => s.earnPending,
    'available' => s.earnAvailable,
    'paid' => s.earnPaid,
    'reversed' => s.earnReversed,
    _ => st,
  };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return widget.frame(
      context,
      s.earnTitle,
      AsyncBody<(Json, List<Json>)>(
        future: _data,
        onRetry: () => setState(() => _data = _load()),
        builder: (BuildContext context, (Json, List<Json>) d) {
          final (Json e, List<Json> payouts) = d;
          final int available = e.integer('availablePaise');
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              NCard(
                color: NColors.brandSageLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.earnAvailable, style: NType.caption.copyWith(color: NColors.inkSecondary)),
                    Text(rupeesFromPaise(available), style: NType.h2.copyWith(color: NColors.inkPrimary)),
                    const SizedBox(height: NSpace.xs),
                    Text(
                      '${s.earnPending}: ${rupeesFromPaise(e.integer('pendingPaise'))} · ${s.earnPaid}: ${rupeesFromPaise(e.integer('paidPaise'))}',
                      style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                    ),
                    const SizedBox(height: NSpace.sm),
                    NPrimaryButton(label: s.earnCashOut, loading: _busy, inactiveHint: s.earnNothingAvailable, onPressed: available > 0 ? _cashOut : null),
                  ],
                ),
              ),
              NSectionTitle(s.earnLines),
              if (e.objs('lines').isEmpty) EmptyNote(text: s.earnNoLines),
              for (final Json l in e.objs('lines'))
                Padding(
                  padding: const EdgeInsets.only(bottom: NSpace.xs),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(l.str('kind') ?? '', style: NType.body.copyWith(color: NColors.inkPrimary)),
                            Text(
                              <String>[
                                shortDate(context, l.str('date') ?? ''),
                                _state(s, l.str('status') ?? ''),
                                if (l.str('availableOn') != null) s.earnAvailableOn(shortDate(context, l.str('availableOn')!)),
                              ].join(' · '),
                              style: NType.caption.copyWith(color: NColors.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        l.str('display') ?? rupeesFromPaise(l.integer('amountPaise')),
                        style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              NSectionTitle(s.earnRules),
              for (final Json r in e.objs('rules'))
                Text(
                  r.number('sharePercent') != null
                      ? s.earnRuleShare(r.str('kind') ?? '', r.number('sharePercent')!.toStringAsFixed(0))
                      : s.earnRuleAmount(r.str('kind') ?? '', rupeesFromPaise(r.integer('amountPaise'))),
                  style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                ),
              NSectionTitle(s.earnPayouts),
              if (payouts.isEmpty) EmptyNote(text: s.earnNoPayouts),
              for (final Json p in payouts)
                Padding(
                  padding: const EdgeInsets.only(bottom: NSpace.xs),
                  child: NCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${rupeesFromPaise(p.integer('sentPaise'))} · ${p.str('status')}',
                          style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                        ),
                        if (p.integer('taxWithheldPaise') > 0) Text(s.earnTaxWithheld(rupeesFromPaise(p.integer('taxWithheldPaise'))), style: NType.caption.copyWith(color: NColors.inkSecondary)),
                        if (p.obj('steps').str('requested') != null)
                          Text(s.earnRequestedOn(shortDate(context, p.obj('steps').str('requested')!)), style: NType.caption.copyWith(color: NColors.inkSecondary)),
                        if (p.str('failureReason') != null) Text(p.str('failureReason')!, style: NType.caption.copyWith(color: NColors.statusAttention)),
                        if (p.str('note') != null) Text(p.str('note')!, style: NType.caption.copyWith(color: NColors.inkMuted)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Schedule (spec 011 §11; spec 014): the next two weeks by day, with appointments, holds and review hours, times
/// in her time zone; blocked time and extra hours as exceptions. Weekly hours are edited on the web for now.
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, this.repository, this.frame = plainFrame, this.clock});

  final ProviderWorkRepository? repository;
  final ProviderFrame frame;
  final DateTime Function()? clock;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final ProviderWorkRepository _repo = widget.repository ?? getIt<ProviderWorkRepository>();
  late Future<(Json, Json)> _data = _load();

  Future<(Json, Json)> _load() async {
    final DateTime now = (widget.clock ?? DateTime.now)();
    final DateTime from = DateTime(now.year, now.month, now.day);
    return (await _repo.schedule(from, from.add(const Duration(days: 14))), await _repo.availability());
  }

  void _reload() => setState(() => _data = _load());

  Future<void> _addException() async {
    final S s = S.of(context);
    final DateTime now = DateTime.now();
    final DateTime? day = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: now.add(const Duration(days: 90)));
    if (day == null || !mounted) return;
    final TimeOfDay? start = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0), helpText: s.schedFrom);
    if (start == null || !mounted) return;
    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute),
      helpText: s.schedTo,
    );
    if (end == null || !mounted) return;
    final String? kind = await showDialog<String>(
      context: context,
      builder: (BuildContext c) => SimpleDialog(
        title: Text(s.schedExceptionKind),
        children: <Widget>[
          SimpleDialogOption(onPressed: () => Navigator.of(c).pop('blocked'), child: Text(s.schedBlocked)),
          SimpleDialogOption(onPressed: () => Navigator.of(c).pop('extra_consults'), child: Text(s.schedExtra)),
        ],
      ),
    );
    if (kind == null || !mounted) return;
    try {
      await _repo.addException(kind, DateTime(day.year, day.month, day.day, start.hour, start.minute), DateTime(day.year, day.month, day.day, end.hour, end.minute));
      if (!mounted) return;
      showNote(context, s.schedSaved);
      _reload();
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  Future<void> _removeException(String id) async {
    try {
      await _repo.removeException(id);
      _reload();
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    }
  }

  String _state(S s, String st) => switch (st) {
    'being_booked' => s.schedBeingBooked,
    'confirmed' => s.schedConfirmed,
    'in_progress' => s.schedInProgress,
    'completed' => s.schedCompleted,
    'cancelled' => s.schedCancelled,
    'no_show' => s.schedNoShow,
    _ => st,
  };

  /// 0 = Sunday, as the server stores it; 1 January 2023 was a Sunday.
  static String _weekday(String locale, int d) => DateFormat.E(locale).format(DateTime(2023, 1, 1 + d % 7));
  static String _hm(String? t) => t == null ? '' : (t.length >= 5 ? t.substring(0, 5) : t);

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    return widget.frame(
      context,
      s.schedTitle,
      AsyncBody<(Json, Json)>(
        future: _data,
        onRetry: _reload,
        builder: (BuildContext context, (Json, Json) d) {
          final (Json sched, Json avail) = d;
          final Map<String, List<Json>> byDay = <String, List<Json>>{};
          for (final Json a in sched.objs('appointments')) {
            final DateTime t = DateTime.parse(a.str('startsAt')!).toLocal();
            (byDay[DateFormat('EEEE d MMMM', locale).format(t)] ??= <Json>[]).add(a);
          }
          final List<Json> consultHours = avail.objs('hours').where((Json h) => h.str('kind') == 'consults').toList();
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              if (sched.str('timeZone') != null) Text(s.schedTimeZone(sched.str('timeZone')!), style: NType.caption.copyWith(color: NColors.inkMuted)),
              if (consultHours.isEmpty) ...<Widget>[const SizedBox(height: NSpace.sm), EmptyNote(text: s.schedNoHours)],
              NSectionTitle(s.schedNextTwoWeeks),
              if (byDay.isEmpty) EmptyNote(text: s.schedNoAppointments),
              for (final MapEntry<String, List<Json>> day in byDay.entries) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: NSpace.sm, bottom: NSpace.xs),
                  child: Text(
                    day.key,
                    style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                  ),
                ),
                for (final Json a in day.value)
                  NCard(
                    child: Text(
                      <String>[
                        '${DateFormat.jm(locale).format(DateTime.parse(a.str('startsAt')!).toLocal())}–${DateFormat.jm(locale).format(DateTime.parse(a.str('endsAt')!).toLocal())}',
                        a.str('memberName') ?? s.schedHold,
                        _state(s, a.str('state') ?? ''),
                      ].join(' · '),
                      style: NType.body.copyWith(color: NColors.inkPrimary),
                    ),
                  ),
              ],
              NSectionTitle(s.schedWeeklyHours),
              if (avail.objs('hours').isEmpty) Text(s.schedNoWeeklyHours, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              for (final Json h in avail.objs('hours'))
                Text(
                  '${_weekday(locale, h.integer('weekday'))} ${_hm(h.str('start'))}–${_hm(h.str('end'))} · ${h.str('kind') == 'consults' ? s.schedConsults : s.schedReviewsOnCall}',
                  style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                ),
              const SizedBox(height: NSpace.xxs),
              Text(s.schedHoursOnWeb, style: NType.caption.copyWith(color: NColors.inkMuted)),
              NSectionTitle(s.schedExceptions),
              for (final Json x in avail.objs('exceptions'))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(x.str('kind') == 'blocked' ? s.schedBlocked : s.schedExtra),
                  subtitle: Text(
                    '${DateFormat('d MMM, h:mm a', locale).format(DateTime.parse(x.str('startsAt')!).toLocal())} – ${DateFormat.jm(locale).format(DateTime.parse(x.str('endsAt')!).toLocal())}',
                  ),
                  trailing: IconButton(tooltip: s.schedRemove, icon: const Icon(Icons.delete_outline_rounded), onPressed: () => _removeException(x.str('id')!)),
                ),
              const SizedBox(height: NSpace.xs),
              NSecondaryButton(label: s.schedAddException, onPressed: _addException),
            ],
          );
        },
      ),
    );
  }
}

/// Password and authenticator code again before signing (spec 011 §7 "Signing" 1, AC22). Null when she cancels.
Future<String?> staffCheck(BuildContext context, ProviderWorkRepository repo) => showDialog<String>(
  context: context,
  builder: (_) => _StaffCheckDialog(repo: repo),
);

class _StaffCheckDialog extends StatefulWidget {
  const _StaffCheckDialog({required this.repo});

  final ProviderWorkRepository repo;

  @override
  State<_StaffCheckDialog> createState() => _StaffCheckDialogState();
}

class _StaffCheckDialogState extends State<_StaffCheckDialog> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _code = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final String proof = await widget.repo.freshStaff(_password.text, _code.text.trim());
      if (mounted) Navigator.of(context).pop(proof);
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AlertDialog(
      title: Text(s.staffCheckTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(s.staffCheckBody, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: s.staffCheckPassword),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(labelText: s.staffCheckCode),
            onChanged: (_) => setState(() {}),
          ),
          if (_error != null) Text(_error!, style: NType.bodySm.copyWith(color: NColors.statusAttention)),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.commonCancel)),
        FilledButton(onPressed: !_busy && _password.text.isNotEmpty && _code.text.trim().length == 6 ? _go : null, child: Text(s.freshConfirm)),
      ],
    );
  }
}
