import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_widgets.dart';
import '../data/health_package_reader.dart';
import '../domain/device_sync.dart';
import '../domain/devices.dart';
import 'reading_format.dart';

/// Connected devices (spec 016 §1, §3, §5): connect Health Connect or Apple Health with the readings she chooses,
/// sync when the screen opens and on pull to refresh, see her readings, and disconnect keeping or deleting them.
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key, this.repository, this.reader});

  final DevicesRepository? repository;
  final HealthReader? reader;

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  late final DevicesRepository _repo = widget.repository ?? getIt<DevicesRepository>();
  late final HealthReader _reader = widget.reader ?? HealthPackageReader();
  late final DeviceSync _sync = DeviceSync(reader: _reader, repository: _repo);
  late Future<DevicesDocument> _data = _openAndSync();
  bool _busy = false;

  /// Opening the screen syncs a connected source first (spec 016 §2.1).
  Future<DevicesDocument> _openAndSync() async {
    final DevicesDocument doc = await _repo.load();
    final HealthSource? mine = doc.connectedOn(_reader.platform);
    if (mine == null) return doc;
    try {
      await _sync.sync(mine, limits: doc.limits);
      return await _repo.load();
    } on Exception {
      return doc; // A failed sync leaves what was already sent on screen; "Sync now" tries again.
    }
  }

  Future<void> _refresh() async {
    final Future<DevicesDocument> next = _openAndSync();
    setState(() => _data = next);
    await next;
  }

  Future<void> _act(Future<void> Function() fn) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await fn();
    } on Exception {
      if (mounted) showNote(context, S.of(context).devFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _kindLabel(S s, String k) => switch (k) {
        HealthKinds.steps => s.devKindSteps,
        HealthKinds.activeMinutes => s.devKindActive,
        HealthKinds.sleep => s.devKindSleep,
        HealthKinds.restingHeartRate => s.devKindRestingHr,
        HealthKinds.hrv => s.devKindHrv,
        HealthKinds.weight => s.devKindWeight,
        HealthKinds.basalBodyTemperature => s.devKindTemp,
        HealthKinds.periods => s.devKindPeriods,
        _ => k,
      };

  String get _platformName => _reader.platform == HealthPlatformKind.appleHealth ? 'Apple Health' : 'Health Connect';

  /// Choose readings, agree, then the platform's own permission dialog asks for exactly those (spec 016 §1.2, §1.3).
  Future<void> _connect(DevicesDocument doc) async {
    final S s = S.of(context);
    final HealthAvailability a = await _reader.availability();
    if (!mounted) return;
    if (a == HealthAvailability.needsInstall) {
      showNote(context, s.devNeedsInstall);
      await _reader.install();
      return;
    }
    if (a == HealthAvailability.unavailable) {
      showNote(context, s.devUnavailable);
      return;
    }
    final List<String> offered = doc.offered.where(_reader.supportedKinds.contains).toList();
    final Set<String>? chosen = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext c) => _ChooseSheet(offered: offered, label: (String k) => _kindLabel(s, k), platformName: _platformName),
    );
    if (chosen == null || chosen.isEmpty || !mounted) return;
    await _act(() async {
      final bool allowed = await _reader.requestAccess(chosen);
      if (!allowed) {
        if (mounted) showNote(context, s.devDenied(_platformName));
        return;
      }
      final HealthSource source = await _repo.connect(platform: _reader.platform, deviceName: HealthPackageReader.deviceLabel(), kinds: chosen.toList());
      final SyncResult r = await _sync.sync(source, limits: doc.limits);
      if (mounted) showNote(context, s.devSynced('${r.saved}'));
      setState(() => _data = _repo.load());
    });
  }

  Future<void> _disconnect(HealthSource source) async {
    final S s = S.of(context);
    final bool? delete = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: Text(s.devDisconnectTitle),
        content: Text(s.devDisconnectBody(source.platformName)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(s.devDelete)),
          FilledButton(onPressed: () => Navigator.pop(c, false), child: Text(s.devKeep)),
        ],
      ),
    );
    if (delete == null) return;
    await _act(() async {
      await _repo.disconnect(source.id, deleteReadings: delete);
      setState(() => _data = _repo.load());
    });
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.devTitle,
      body: AsyncBody<DevicesDocument>(
        future: _data,
        onRetry: () => setState(() => _data = _openAndSync()),
        builder: (BuildContext context, DevicesDocument doc) {
          final HealthSource? mine = doc.connectedOn(_reader.platform);
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(NSpace.lg),
              children: <Widget>[
                Text(s.devIntro, style: NType.body.copyWith(color: NColors.inkSecondary)),
                const SizedBox(height: NSpace.sm),
                NCard(color: NColors.surfaceWarm, child: Text(doc.note, style: NType.bodySm.copyWith(color: NColors.inkSecondary))),
                const SizedBox(height: NSpace.md),
                if (doc.sources.isEmpty) EmptyNote(text: s.devEmpty),
                for (final HealthSource src in doc.sources) ...<Widget>[
                  NCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(src.deviceName == null ? src.platformName : '${src.platformName} · ${src.deviceName}', style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                        Text(s.devSharing(src.kinds.map((String k) => _kindLabel(s, k)).join(', ')), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                        Text(
                          !src.connected ? s.devDisconnected : (src.lastSyncedAt == null ? s.devNeverSynced : s.devLastSynced(shortDate(context, src.lastSyncedAt!.toIso8601String()))),
                          style: NType.caption.copyWith(color: NColors.inkMuted),
                        ),
                        if (src.connected) ...<Widget>[
                          const SizedBox(height: NSpace.xs),
                          Wrap(spacing: NSpace.xs, children: <Widget>[
                            if (src.platform == _reader.platform) OutlinedButton(onPressed: _busy ? null : _refresh, child: Text(s.devSyncNow)),
                            TextButton(onPressed: _busy ? null : () => _disconnect(src), child: Text(s.devDisconnect)),
                          ]),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: NSpace.xs),
                ],
                if (mine == null) ...<Widget>[
                  const SizedBox(height: NSpace.sm),
                  NPrimaryButton(label: s.devConnectWith(_platformName), loading: _busy, onPressed: _busy ? null : () => _connect(doc)),
                ],
                if (doc.sources.isNotEmpty) ...<Widget>[
                  const SizedBox(height: NSpace.lg),
                  NSectionTitle(s.devReadings),
                  if (doc.readings.isEmpty) EmptyNote(text: s.devNoReadings),
                  for (final ReadingSeries r in doc.readings) ...<Widget>[
                    NCard(
                      semanticsLabel: '${r.name}. ${s.devLatest(formatReading(r.kind, r.latest.value), shortDate(context, r.latest.date))}',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(r.name, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                          Text(s.devLatest(formatReading(r.kind, r.latest.value), shortDate(context, r.latest.date)), style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                          if (r.average7 != null) Text(s.devAverage(formatReading(r.kind, r.average7!)), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                          const SizedBox(height: NSpace.xs),
                          _Bars(days: r.days),
                        ],
                      ),
                    ),
                    const SizedBox(height: NSpace.xs),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The last 30 days as bars; the values themselves are in the card's text and semantics (spec 010 accessibility 2).
class _Bars extends StatelessWidget {
  const _Bars({required this.days});

  final List<ReadingDay> days;

  @override
  Widget build(BuildContext context) {
    final double max = days.fold<double>(1, (double m, ReadingDay d) => d.value > m ? d.value : m);
    return ExcludeSemantics(
      child: SizedBox(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            for (final ReadingDay d in days)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: FractionallySizedBox(
                    heightFactor: (d.value / max).clamp(0.05, 1.0),
                    child: DecoratedBox(decoration: BoxDecoration(color: NColors.brandLavender, borderRadius: BorderRadius.vertical(top: Radius.circular(2)))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChooseSheet extends StatefulWidget {
  const _ChooseSheet({required this.offered, required this.label, required this.platformName});

  final List<String> offered;
  final String Function(String) label;
  final String platformName;

  @override
  State<_ChooseSheet> createState() => _ChooseSheetState();
}

class _ChooseSheetState extends State<_ChooseSheet> {
  final Set<String> _chosen = <String>{};

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(NSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.devChoose, style: NType.h3.copyWith(color: NColors.inkPrimary)),
            Text(s.devChooseNote, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            const SizedBox(height: NSpace.sm),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  // Each reading is off until she turns it on (spec 016 §1.2).
                  for (final String k in widget.offered)
                    CheckboxListTile(
                      value: _chosen.contains(k),
                      title: Text(widget.label(k)),
                      onChanged: (bool? on) => setState(() => on == true ? _chosen.add(k) : _chosen.remove(k)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: NSpace.sm),
            Text(s.devConsent, style: NType.caption.copyWith(color: NColors.inkMuted)),
            const SizedBox(height: NSpace.sm),
            NPrimaryButton(label: s.devConnect, onPressed: _chosen.isEmpty ? null : () => Navigator.pop(context, _chosen), inactiveHint: s.devChoose),
          ],
        ),
      ),
    );
  }
}
