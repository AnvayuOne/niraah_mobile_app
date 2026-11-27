import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/clinician_ui.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/provider_work.dart';

/// Wraps a provider screen in its workspace frame (the doctor shell, or a plain page).
typedef ProviderFrame = Widget Function(BuildContext context, String title, Widget body);

Widget plainFrame(BuildContext context, String title, Widget body) => AreaScaffold(title: title, body: body);

const EdgeInsets _page = EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl);

/// One stacked bar of amounts, each in its colour.
class _SplitBar extends StatelessWidget {
  const _SplitBar({required this.parts});

  final List<(int, Color)> parts;

  @override
  Widget build(BuildContext context) {
    final int total = parts.fold<int>(0, (int a, (int, Color) p) => a + p.$1);
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(NRadius.pill),
        child: SizedBox(
          height: 12,
          child: total <= 0
              ? ColoredBox(color: NColors.surfaceBackdrop, child: SizedBox.expand())
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final (int v, Color c) in parts)
                      if (v > 0) Expanded(flex: (v * 1000 ~/ total).clamp(1, 1000), child: ColoredBox(color: c)),
                  ],
                ),
        ),
      ),
    );
  }
}

/// A legend row: colour, label and amount.
class _Money extends StatelessWidget {
  const _Money({required this.color, required this.label, required this.amount, this.strong = false});

  final Color color;
  final String label;
  final String amount;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: <Widget>[
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: NSpace.xs),
        Expanded(child: Text(label, style: NType.bodySm.copyWith(color: NColors.inkSecondary))),
        Text(
          amount,
          style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: strong ? FontWeight.w800 : FontWeight.w600, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
        ),
      ],
    ),
  );
}

/// A soft warning line.
class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(NSpace.sm),
    decoration: BoxDecoration(color: NColors.statusWarningLight, borderRadius: BorderRadius.circular(NRadius.lg)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.info_outline_rounded, size: 20, color: NColors.statusWarningText),
        const SizedBox(width: NSpace.xs),
        Expanded(child: Text(text, style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
      ],
    ),
  );
}

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
          final int pending = e.integer('pendingPaise');
          final int paid = e.integer('paidPaise');
          final CRole role = CRole.of(context);
          return ListView(
            padding: _page,
            children: <Widget>[
              CHero(
                eyebrow: s.earnTitle,
                title: rupeesFromPaise(available),
                subtitle: s.earnAvailable,
                child: Container(
                  padding: const EdgeInsets.all(NSpace.sm + 2),
                  decoration: BoxDecoration(color: NColors.surfaceCard.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(NRadius.lg), border: Border.all(color: NColors.lineDefault)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _SplitBar(parts: <(int, Color)>[(available, role.accent), (pending, NColors.brandApricot), (paid, NColors.brandSage)]),
                      const SizedBox(height: NSpace.sm),
                      _Money(color: role.accent, label: s.earnAvailable, amount: rupeesFromPaise(available), strong: true),
                      _Money(color: NColors.brandApricot, label: s.earnPending, amount: rupeesFromPaise(pending)),
                      _Money(color: NColors.brandSage, label: s.earnPaid, amount: rupeesFromPaise(paid)),
                      const SizedBox(height: NSpace.sm),
                      NPrimaryButton(label: s.earnCashOut, loading: _busy, inactiveHint: s.earnNothingAvailable, onPressed: available > 0 ? _cashOut : null),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.earnLines,
                icon: Icons.receipt_long_outlined,
                child: e.objs('lines').isEmpty
                    ? CEmpty(icon: Icons.receipt_long_outlined, title: s.earnNoLines)
                    : Column(
                        children: <Widget>[
                          for (Json l in e.objs('lines'))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: NSpace.xxs + 2),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(color: role.light, borderRadius: BorderRadius.circular(NRadius.md)),
                                    child: Icon(_lineIcon(l.str('status')), size: 18, color: role.accent),
                                  ),
                                  const SizedBox(width: NSpace.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(l.str('kind') ?? '', style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                                        Text(
                                          <String>[
                                            shortDate(context, l.str('date') ?? ''),
                                            _state(s, l.str('status') ?? ''),
                                            if (l.str('availableOn') != null) s.earnAvailableOn(shortDate(context, l.str('availableOn')!)),
                                          ].join(' · '),
                                          style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: NSpace.xs),
                                  Text(
                                    l.str('display') ?? rupeesFromPaise(l.integer('amountPaise')),
                                    style: NType.body.copyWith(
                                      color: l.str('status') == 'reversed' ? NColors.inkMuted : NColors.inkPrimary,
                                      fontWeight: FontWeight.w700,
                                      decoration: l.str('status') == 'reversed' ? TextDecoration.lineThrough : null,
                                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.earnRules,
                icon: Icons.rule_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (Json r in e.objs('rules'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: NSpace.xxs + 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Container(width: 6, height: 6, decoration: BoxDecoration(color: role.accent, shape: BoxShape.circle)),
                            ),
                            const SizedBox(width: NSpace.xs),
                            Expanded(
                              child: Text(
                                r.number('sharePercent') != null
                                    ? s.earnRuleShare(r.str('kind') ?? '', r.number('sharePercent')!.toStringAsFixed(0))
                                    : s.earnRuleAmount(r.str('kind') ?? '', rupeesFromPaise(r.integer('amountPaise'))),
                                style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.earnPayouts,
                icon: Icons.account_balance_outlined,
                child: payouts.isEmpty
                    ? CEmpty(icon: Icons.account_balance_outlined, title: s.earnNoPayouts)
                    : Column(
                        children: <Widget>[
                          for (Json p in payouts)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: NSpace.xs),
                              padding: const EdgeInsets.all(NSpace.sm),
                              decoration: BoxDecoration(color: NColors.surfacePage, borderRadius: BorderRadius.circular(NRadius.lg)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(rupeesFromPaise(p.integer('sentPaise')), style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                                      ),
                                      CPill(p.str('status') ?? '', tone: p.str('status') == 'failed' ? CTone.red : (p.str('status') == 'paid' ? CTone.sage : CTone.apricot)),
                                    ],
                                  ),
                                  if (p.integer('taxWithheldPaise') > 0)
                                    Text(s.earnTaxWithheld(rupeesFromPaise(p.integer('taxWithheldPaise'))), style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                                  if (p.obj('steps').str('requested') != null)
                                    Text(s.earnRequestedOn(shortDate(context, p.obj('steps').str('requested')!)), style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                                  if (p.str('failureReason') != null) Text(p.str('failureReason')!, style: NType.caption.copyWith(color: NColors.statusAttention, letterSpacing: 0)),
                                  if (p.str('note') != null) Text(p.str('note')!, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _lineIcon(String? st) => switch (st) {
    'paid' => Icons.check_circle_outline_rounded,
    'available' => Icons.account_balance_wallet_outlined,
    'reversed' => Icons.undo_rounded,
    _ => Icons.hourglass_top_rounded,
  };
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

  /// The day shown on the timeline; null shows the first day with an appointment.
  DateTime? _selected;

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
          final CRole role = CRole.of(context);
          final DateTime now = (widget.clock ?? DateTime.now)();
          final DateTime from = DateTime(now.year, now.month, now.day);
          final List<DateTime> days = <DateTime>[for (int i = 0; i < 14; i++) DateTime(from.year, from.month, from.day + i)];
          final Map<DateTime, List<Json>> byDay = <DateTime, List<Json>>{};
          for (Json a in sched.objs('appointments')) {
            final DateTime t = DateTime.parse(a.str('startsAt')!).toLocal();
            (byDay[DateTime(t.year, t.month, t.day)] ??= <Json>[]).add(a);
          }
          for (List<Json> l in byDay.values) {
            l.sort((Json a, Json b) => a.str('startsAt')!.compareTo(b.str('startsAt')!));
          }
          final DateTime sel = _selected ?? days.firstWhere(byDay.containsKey, orElse: () => days.first);
          final List<Json> dayAppts = byDay[sel] ?? const <Json>[];
          final List<Json> consultHours = avail.objs('hours').where((Json h) => h.str('kind') == 'consults').toList();
          final Map<int, List<Json>> hoursByDay = <int, List<Json>>{};
          for (Json h in avail.objs('hours')) {
            (hoursByDay[h.integer('weekday')] ??= <Json>[]).add(h);
          }
          final List<int> weekdays = hoursByDay.keys.toList()..sort((int a, int b) => ((a + 6) % 7).compareTo((b + 6) % 7));
          return ListView(
            padding: _page,
            children: <Widget>[
              CHero(
                eyebrow: s.schedTitle,
                title: s.schedNextTwoWeeks,
                subtitle: <String>[
                  s.schedAppointmentsCount(sched.objs('appointments').length),
                  if (sched.str('timeZone') != null) s.schedTimeZone(sched.str('timeZone')!),
                ].join(' · '),
                child: SizedBox(
                  height: 74,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    separatorBuilder: (_, _) => const SizedBox(width: NSpace.xs),
                    itemBuilder: (BuildContext context, int i) {
                      final DateTime day = days[i];
                      final bool on = day == sel;
                      final int n = byDay[day]?.length ?? 0;
                      return Semantics(
                        button: true,
                        selected: on,
                        label: '${DateFormat('EEEE d MMMM', locale).format(day)}, ${s.schedAppointmentsCount(n)}',
                        excludeSemantics: true,
                        child: Material(
                          color: on ? role.light : NColors.surfaceCard.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(NRadius.lg),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(NRadius.lg),
                            onTap: () => setState(() => _selected = day),
                            child: Container(
                              width: 50,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(NRadius.lg), border: Border.all(color: on ? role.accent : NColors.lineDefault, width: on ? 1.5 : 1)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(DateFormat.E(locale).format(day), style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                                  Text('${day.day}', style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
                                  const SizedBox(height: 3),
                                  Container(width: 6, height: 6, decoration: BoxDecoration(color: n > 0 ? role.accent : Colors.transparent, shape: BoxShape.circle)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (consultHours.isEmpty) ...<Widget>[const SizedBox(height: NSpace.sm), _Notice(text: s.schedNoHours)],
              const SizedBox(height: NSpace.md),
              CPanel(
                title: DateFormat('EEEE d MMMM', locale).format(sel),
                note: s.schedAppointmentsCount(dayAppts.length),
                icon: Icons.schedule_rounded,
                child: dayAppts.isEmpty
                    ? CEmpty(icon: Icons.event_available_outlined, title: byDay.isEmpty ? s.schedNoAppointments : s.schedNothingThisDay)
                    : Column(
                        children: <Widget>[
                          for (int i = 0; i < dayAppts.length; i++)
                            CEntrance(delayMs: 50 * i, child: _slot(s, locale, dayAppts[i], role, last: i == dayAppts.length - 1)),
                        ],
                      ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.schedWeeklyHours,
                note: s.schedHoursOnWeb,
                icon: Icons.view_week_outlined,
                child: avail.objs('hours').isEmpty
                    ? Text(s.schedNoWeeklyHours, style: NType.bodySm.copyWith(color: NColors.inkSecondary))
                    : Column(
                        children: <Widget>[
                          for (final int wd in weekdays)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: NSpace.xxs),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 48,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(_weekday(locale, wd), style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Wrap(
                                      spacing: NSpace.xxs,
                                      runSpacing: NSpace.xxs,
                                      children: <Widget>[
                                        for (Json h in hoursByDay[wd]!)
                                          Semantics(
                                            label: '${_weekday(locale, wd)} ${_hm(h.str('start'))}–${_hm(h.str('end'))} · ${h.str('kind') == 'consults' ? s.schedConsults : s.schedReviewsOnCall}',
                                            excludeSemantics: true,
                                            child: CPill(
                                              '${_hm(h.str('start'))}–${_hm(h.str('end'))} · ${h.str('kind') == 'consults' ? s.schedConsults : s.schedReviewsOnCall}',
                                              tone: h.str('kind') == 'consults' ? CTone.sage : CTone.lavender,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.schedExceptions,
                icon: Icons.event_busy_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (Json x in avail.objs('exceptions'))
                      Container(
                        margin: const EdgeInsets.only(bottom: NSpace.xs),
                        padding: const EdgeInsets.only(left: NSpace.sm),
                        decoration: BoxDecoration(color: NColors.surfacePage, borderRadius: BorderRadius.circular(NRadius.lg)),
                        child: Row(
                          children: <Widget>[
                            Icon(x.str('kind') == 'blocked' ? Icons.block_rounded : Icons.add_circle_outline_rounded, size: 20, color: x.str('kind') == 'blocked' ? NColors.inkSecondary : role.accent),
                            const SizedBox(width: NSpace.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(x.str('kind') == 'blocked' ? s.schedBlocked : s.schedExtra, style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                                  Text(
                                    '${DateFormat('d MMM, h:mm a', locale).format(DateTime.parse(x.str('startsAt')!).toLocal())} – ${DateFormat.jm(locale).format(DateTime.parse(x.str('endsAt')!).toLocal())}',
                                    style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(tooltip: s.schedRemove, icon: Icon(Icons.delete_outline_rounded, color: NColors.inkSecondary), onPressed: () => _removeException(x.str('id')!)),
                          ],
                        ),
                      ),
                    NSecondaryButton(label: s.schedAddException, onPressed: _addException),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// One appointment on the day's timeline: times, a rail with a dot in the state's colour, and the card.
  Widget _slot(S s, String locale, Json a, CRole role, {required bool last}) {
    final String st = a.str('state') ?? '';
    final Color dot = switch (st) {
      'confirmed' => role.accent,
      'in_progress' => NColors.statusSuccess,
      'cancelled' || 'no_show' => NColors.inkMuted,
      _ => NColors.brandApricot,
    };
    final String start = DateFormat.jm(locale).format(DateTime.parse(a.str('startsAt')!).toLocal());
    final String end = DateFormat.jm(locale).format(DateTime.parse(a.str('endsAt')!).toLocal());
    return Semantics(
      label: <String>['$start–$end', a.str('memberName') ?? s.schedHold, _state(s, st)].join(' · '),
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              width: 62,
              child: Padding(
                padding: const EdgeInsets.only(top: NSpace.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(start, style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, letterSpacing: 0, fontSize: 12.5)),
                    Text(end, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0, fontSize: 11)),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 18,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: NSpace.xs + 3),
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: dot, shape: BoxShape.circle, border: Border.all(color: NColors.surfaceCard, width: 2))),
                  Expanded(child: Container(width: 2, color: last ? Colors.transparent : NColors.lineDefault)),
                ],
              ),
            ),
            const SizedBox(width: NSpace.xs),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: NSpace.xs),
                padding: const EdgeInsets.all(NSpace.sm),
                decoration: BoxDecoration(
                  color: st == 'cancelled' || st == 'no_show' ? NColors.surfacePage : role.light.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(NRadius.lg),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        a.str('memberName') ?? s.schedHold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: NSpace.xs),
                    CPill(_state(s, st), tone: switch (st) {
                      'confirmed' => CTone.plum,
                      'in_progress' || 'completed' => CTone.sage,
                      'cancelled' || 'no_show' => CTone.quiet,
                      _ => CTone.apricot,
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
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
