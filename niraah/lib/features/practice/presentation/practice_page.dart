import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/area_navigation.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/payments/payment_checkout.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/bottom_nav.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../../../shared/helpers/money.dart';
import '../../../shared/widgets/payment_flow.dart';
import '../../cycle/domain/cycle.dart';
import '../../home/domain/home.dart';
import '../../home/presentation/home_labels.dart';
import '../domain/practice.dart';

/// The Practice tab (spec 010 §7): one or two sessions for today by her phase, the live class schedule, the
/// library and what she did. No streaks that can be broken (rule 6).
class PracticePage extends StatefulWidget {
  const PracticePage({super.key, this.repository, this.gateway});

  final PracticeRepository? repository;
  final PaymentCheckout? gateway;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late final PracticeRepository _repo = widget.repository ?? getIt<PracticeRepository>();
  late Future<PracticeToday> _today = _repo.today();
  late Future<LiveClasses?> _classes = _loadClasses();

  /// Live classes are their own area: a refusal there (a teen account, AC53) leaves the rest of Practice working.
  Future<LiveClasses?> _loadClasses() async {
    try {
      return await _repo.liveClasses();
    } on AreaLocked {
      return null;
    }
  }

  void _reload() => setState(() {
        _today = _repo.today();
        _classes = _loadClasses();
      });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      body: SafeArea(
        child: AsyncBody<PracticeToday>(
          future: _today,
          onRetry: _reload,
          builder: (BuildContext context, PracticeToday today) => RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, NSpace.xl),
              children: <Widget>[
                Semantics(header: true, child: Text(s.practiceTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
                const SizedBox(height: NSpace.xs),
                Text(_phaseLine(s, today.phase), style: NType.body.copyWith(color: NColors.inkSecondary)),
                NSectionTitle(s.practiceForToday),
                if (today.sessions.isEmpty)
                  EmptyNote(text: s.practiceTodayEmpty, actionLabel: s.practiceBrowse, onAction: () => context.push(RouteConstants.practiceLibrary))
                else
                  for (final PracticeSession p in today.sessions) ...<Widget>[SessionTile(session: p, onDone: _reload), const SizedBox(height: NSpace.sm)],
                NSectionTitle(s.practiceLiveTitle),
                FutureBuilder<LiveClasses?>(
                  future: _classes,
                  builder: (BuildContext context, AsyncSnapshot<LiveClasses?> snap) {
                    if (snap.connectionState != ConnectionState.done) return Text(s.loading, style: NType.bodySm.copyWith(color: NColors.inkMuted));
                    if (snap.hasError) return EmptyNote(text: s.commonLoadError, actionLabel: s.tryAgain, onAction: _reload);
                    final LiveClasses? c = snap.data;
                    if (c == null) return const SizedBox.shrink();
                    return _LiveClassesView(classes: c, repo: _repo, gateway: widget.gateway, onChanged: () => setState(() => _classes = _loadClasses()));
                  },
                ),
                NSectionTitle(s.practiceMore),
                NCard(
                  onTap: () => context.push(RouteConstants.practiceLibrary),
                  semanticsLabel: s.practiceBrowse,
                  child: _LinkRow(icon: Icons.video_library_outlined, text: s.practiceBrowse),
                ),
                const SizedBox(height: NSpace.sm),
                NCard(
                  onTap: () => context.push(RouteConstants.practiceHistory),
                  semanticsLabel: s.practiceHistoryTitle,
                  child: _LinkRow(icon: Icons.event_note_outlined, text: s.practiceHistoryTitle),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NBottomNav(
        labels: <String>[for (final Area a in Area.values) s.areaName(a)],
        index: 3,
        onSelected: (int i) {
          if (i != 3) goToArea(context, Area.values[i]);
        },
      ),
    );
  }

  static String _phaseLine(S s, String? phase) {
    final Phase? p = phaseFrom(phase);
    return p == null ? s.practiceNoPhase : s.practiceForPhase(s.phaseEstimated(p));
  }
}

Phase? phaseFrom(String? key) {
  for (final Phase p in Phase.values) {
    if (p.name == key) return p;
  }
  return null;
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Icon(icon, color: NColors.inkSecondary),
          const SizedBox(width: NSpace.sm),
          Expanded(child: Text(text, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
          Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
        ],
      );
}

/// A session in a list: title, length and level, opening its page.
class SessionTile extends StatelessWidget {
  const SessionTile({required this.session, required this.onDone, super.key});

  final PracticeSession session;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String meta = <String>[s.practiceMinutes(session.minutes), if (session.level != null) session.level!].join(' · ');
    return NCard(
      color: NColors.brandSageLight,
      semanticsLabel: '${session.title}, $meta',
      onTap: () async {
        final bool? done = await context.push<bool>('${RouteConstants.practiceSession}/${session.id}');
        if (done ?? false) onDone();
      },
      child: Row(
        children: <Widget>[
          Icon(Icons.self_improvement_rounded, color: NColors.inkPrimary),
          const SizedBox(width: NSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(session.title, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: NSpace.xxs),
                Text(meta, style: NType.caption.copyWith(color: NColors.inkSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
        ],
      ),
    );
  }
}

/// The schedule with instructor, time in her time zone and places left (spec 010 §7 rule 5), and her booked classes
/// with the way into the class room (spec 014 §8). During the trial included classes show as starting with her first
/// payment; she can still pay the per-class fee (spec 014 §8 "Booking" 3).
class _LiveClassesView extends StatefulWidget {
  const _LiveClassesView({required this.classes, required this.repo, required this.onChanged, this.gateway});

  final LiveClasses classes;
  final PracticeRepository repo;
  final VoidCallback onChanged;
  final PaymentCheckout? gateway;

  @override
  State<_LiveClassesView> createState() => _LiveClassesViewState();
}

class _LiveClassesViewState extends State<_LiveClassesView> {
  late Future<List<ClassBooking>> _bookings = _loadBookings();
  bool _busy = false;

  PracticeRepository get repo => widget.repo;
  LiveClasses get classes => widget.classes;

  Future<List<ClassBooking>> _loadBookings() async {
    try {
      return await repo.classBookings();
    } on Object {
      // Her bookings only add the "Your classes" list; the schedule stands without them.
      return const <ClassBooking>[];
    }
  }

  void _changed() {
    setState(() => _bookings = _loadBookings());
    widget.onChanged();
  }

  /// A unit from her plan when she has one; otherwise the place is held while she pays the fee the server set (AC42).
  /// Declining or a payment that does not go through gives the place back.
  Future<void> _book(BuildContext context, LiveClass c) async {
    final S s = S.of(context);
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final BookingOutcome o = await repo.book(c.id);
      if (!context.mounted) return;
      switch (o) {
        case ClassBooked():
          showNote(context, s.practiceBooked);
        case ClassPaymentNeeded(:final String bookingId, :final int amountPaise, :final Checkout? checkout):
          await _pay(context, s, bookingId, amountPaise, checkout);
      }
      _changed();
    } on Object catch (e) {
      if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pay(BuildContext context, S s, String bookingId, int amountPaise, Checkout? checkout) async {
    final bool go = checkout != null &&
        (await showDialog<bool>(
              context: context,
              builder: (BuildContext c) => AlertDialog(
                title: Text(s.practicePayTitle),
                content: Text(s.practicePayBody(rupees(amountPaise))),
                actions: <Widget>[
                  TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(s.practiceNotNow)),
                  FilledButton(onPressed: () => Navigator.of(c).pop(true), child: Text(s.practicePay(rupees(amountPaise)))),
                ],
              ),
            ) ??
            false);
    if (!go || !context.mounted) {
      await _giveBack(bookingId);
      return;
    }
    final PaymentResult r = await runPayment(
      context,
      (void Function() onConfirming) => payAndConfirm(
        gateway: widget.gateway ?? getIt<PaymentCheckout>(),
        checkout: checkout,
        description: s.payDescClass,
        onConfirming: onConfirming,
        
        check: () async {
          final ClassBooking? b = (await repo.classBookings()).where((ClassBooking x) => x.id == bookingId).firstOrNull;
          if (b == null || b.status == 'held') return ServerPaymentState.waiting;
          return b.booked ? ServerPaymentState.confirmed : ServerPaymentState.lapsed;
        },
      ),
    );
    if (r.outcome == PaymentOutcome.cancelled || r.outcome == PaymentOutcome.failed) await _giveBack(bookingId);
    if (context.mounted) showNote(context, paymentNote(s, r) ?? s.practicePaidBooked);
  }

  Future<void> _giveBack(String bookingId) async {
    try {
      await repo.cancelBooking(bookingId);
    } on Object {
      // A held place runs out by itself anyway.
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    final DateTime now = DateTime.now();
    return FutureBuilder<List<ClassBooking>>(
      future: _bookings,
      builder: (BuildContext context, AsyncSnapshot<List<ClassBooking>> snap) {
        final List<ClassBooking> mine = <ClassBooking>[...?snap.data?.where((ClassBooking b) => b.booked && b.endsAt.isAfter(now))]
          ..sort((ClassBooking a, ClassBooking b) => a.startsAt.compareTo(b.startsAt));
        final Set<String> booked = <String>{for (final ClassBooking b in mine) b.classId};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (mine.isNotEmpty) ...<Widget>[
              Semantics(header: true, child: Text(s.clYourClasses, style: NType.h4.copyWith(color: NColors.inkPrimary))),
              const SizedBox(height: NSpace.xs),
              for (final ClassBooking b in mine) ...<Widget>[
                _ClassShell(
                  booked: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _ClassDateTile(date: b.startsAt, locale: locale),
                      const SizedBox(width: NSpace.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(b.title, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                            Text('${_hm(b.startsAt, locale)} – ${_hm(b.endsAt, locale)}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                            const SizedBox(height: NSpace.xs),
                            FilledButton.icon(
                              onPressed: () => context.push('${RouteConstants.classes}/${Uri.encodeComponent(b.classId)}/room'),
                              style: FilledButton.styleFrom(
                                backgroundColor: NColors.statusSuccess,
                                foregroundColor: NColors.inkOnBrand,
                                minimumSize: const Size(0, NLayout.minTapTarget),
                                padding: const EdgeInsets.symmetric(horizontal: NSpace.md),
                                shape: const StadiumBorder(),
                              ),
                              icon: const Icon(Icons.videocam_rounded, size: 18),
                              label: Text(s.clJoin),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.sm),
              ],
              const SizedBox(height: NSpace.xs),
            ],
            if (classes.access == ClassAccess.afterTrial)
              Container(
                margin: const EdgeInsets.only(bottom: NSpace.sm),
                padding: const EdgeInsets.all(NSpace.sm),
                decoration: BoxDecoration(color: NColors.brandApricotLight, borderRadius: BorderRadius.circular(NRadius.md)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.info_outline_rounded, size: 18, color: NColors.inkMuted),
                    const SizedBox(width: NSpace.xs),
                    Expanded(
                      child: Text(classes.startsOn == null ? s.practiceClassesAfterTrial : s.areaStartsOn(classes.startsOn!), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                    ),
                  ],
                ),
              ),
            if (classes.classes.isEmpty) EmptyNote(text: s.practiceClassesEmpty, picture: EmptyArt.classes),
            for (final LiveClass c in classes.classes) ...<Widget>[
              _LiveClassCard(
                c: c,
                locale: locale,
                booked: booked.contains(c.id),
                placesText: c.placesLeft > 0 ? s.practicePlacesLeft(c.placesLeft) : s.practiceClassFull,
                bookLabel: s.practiceBook,
                bookedLabel: s.csStatusConfirmed,
                onBook: c.placesLeft > 0 && !_busy ? () => _book(context, c) : null,
              ),
              const SizedBox(height: NSpace.sm),
            ],
          ],
        );
      },
    );
  }
}

String _hm(DateTime t, String locale) => DateFormat('h:mm a', locale).format(t.toLocal()).toLowerCase();

/// The white class card; a booked class gets a sage border.
class _ClassShell extends StatelessWidget {
  const _ClassShell({required this.child, this.booked = false});

  final Widget child;
  final bool booked;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(NSpace.md),
        decoration: BoxDecoration(
          color: NColors.surfaceCard,
          borderRadius: BorderRadius.circular(NRadius.lg),
          boxShadow: NShadow.sm,
          border: Border.all(color: booked ? NColors.brandSage : NColors.lineDefault.withValues(alpha: 0.6), width: booked ? 1.5 : 1),
        ),
        child: child,
      );
}

/// Month, day and weekday on a sage tile.
class _ClassDateTile extends StatelessWidget {
  const _ClassDateTile({required this.date, required this.locale});

  final DateTime date;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final DateTime d = date.toLocal();
    return ExcludeSemantics(
      child: Container(
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: NSpace.xs),
        decoration: BoxDecoration(color: NColors.brandSageLight, borderRadius: BorderRadius.circular(NRadius.md)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(DateFormat('MMM', locale).format(d).toUpperCase(), style: NType.caption.copyWith(color: NColors.statusSuccess, letterSpacing: 1)),
            Text('${d.day}', style: NType.h3.copyWith(fontFamily: NType.sansFamily, fontWeight: FontWeight.w700, fontSize: 24, color: NColors.inkPrimary, height: 1.15)),
            Text(DateFormat('EEE', locale).format(d), style: NType.label.copyWith(color: NColors.inkMuted)),
          ],
        ),
      ),
    );
  }
}

/// One live class: a sage date tile, title, time range, teacher and level, how full it is, and "Book a place" or a
/// green "Booked" badge.
class _LiveClassCard extends StatelessWidget {
  const _LiveClassCard({
    required this.c,
    required this.locale,
    required this.booked,
    required this.placesText,
    required this.bookLabel,
    required this.bookedLabel,
    required this.onBook,
  });

  final LiveClass c;
  final String locale;
  final bool booked;
  final String placesText;
  final String bookLabel;
  final String bookedLabel;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final bool full = c.placesLeft <= 0;
    return _ClassShell(
      booked: booked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ClassDateTile(date: c.startsAt, locale: locale),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.title, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                    const SizedBox(height: 2),
                    Text('${_hm(c.startsAt, locale)} – ${_hm(c.endsAt, locale)}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                    if (c.instructor != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.self_improvement_rounded, size: 15, color: NColors.inkMuted),
                            const SizedBox(width: 4),
                            Flexible(child: Text(c.instructor!, overflow: TextOverflow.ellipsis, style: NType.label.copyWith(color: NColors.inkMuted))),
                          ],
                        ),
                      ),
                    if (c.level != null) ...<Widget>[
                      const SizedBox(height: NSpace.xxs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: NSpace.xs, vertical: 3),
                        decoration: BoxDecoration(color: NColors.brandLavenderLight, borderRadius: BorderRadius.circular(NRadius.pill)),
                        child: Text(c.level!, style: NType.label.copyWith(color: NColors.brandPlum, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NSpace.sm),
          Divider(height: 1, color: NColors.lineDefault),
          const SizedBox(height: NSpace.sm),
          Row(
            children: <Widget>[
              Icon(full ? Icons.event_busy_rounded : Icons.people_outline_rounded, size: 16, color: full ? NColors.inkMuted : NColors.statusSuccess),
              const SizedBox(width: 6),
              Expanded(
                child: Text(placesText, style: NType.label.copyWith(color: full ? NColors.inkMuted : NColors.inkSecondary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: NSpace.xs),
              if (booked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: 8),
                  decoration: BoxDecoration(color: NColors.statusSuccessLight, borderRadius: BorderRadius.circular(NRadius.pill)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.check_circle_rounded, size: 16, color: NColors.statusSuccess),
                      const SizedBox(width: 4),
                      Text(bookedLabel, style: NType.label.copyWith(color: NColors.statusSuccess, fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              else if (!full)
                FilledButton(
                  onPressed: onBook,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, NLayout.minTapTarget),
                    padding: const EdgeInsets.symmetric(horizontal: NSpace.md),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(bookLabel),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
