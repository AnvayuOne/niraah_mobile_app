import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/video/device_permissions.dart';
import '../../../core/video/video_engine.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/widgets/room_widgets.dart';

/// The video vendor's app id for the device check, which runs at any time, outside a room's join window, so there is
/// no room token to take it from. Public, not a secret: `--dart-define=NIRAAH_AGORA_APP_ID=...`. Without it the check
/// asks for the permissions only and says the preview and connection test run in the room.
const String agoraAppIdForDeviceCheck = String.fromEnvironment('NIRAAH_AGORA_APP_ID');

/// The device check from the appointment screen (spec 014 §4.4): camera preview, microphone level and a connection
/// test. Nothing from it is sent to the Niraah API.
class DeviceCheckPage extends StatefulWidget {
  const DeviceCheckPage({super.key, this.engines, this.permissions, this.appId = agoraAppIdForDeviceCheck});

  final VideoEngineFactory? engines;
  final DevicePermissions? permissions;
  final String appId;

  @override
  State<DeviceCheckPage> createState() => _DeviceCheckPageState();
}

class _DeviceCheckPageState extends State<DeviceCheckPage> {
  late final DevicePermissions _permissions = widget.permissions ?? getIt<DevicePermissions>();
  VideoEngine? _engine;
  StreamSubscription<VideoEvent>? _sub;
  MediaAccess? _access;
  bool _asking = false;
  bool _failed = false;
  int _level = 0;
  int? _probe;

  Future<void> _start() async {
    setState(() => _asking = true);
    final MediaAccess access = await _permissions.request();
    if (!mounted) return;
    setState(() {
      _asking = false;
      _access = access;
    });
    if (access == MediaAccess.denied || widget.appId.isEmpty) return;
    try {
      final VideoEngine e = (widget.engines ?? getIt<VideoEngineFactory>())();
      _engine = e;
      _sub = e.events.listen((VideoEvent ev) {
        if (!mounted) return;
        if (ev is VideoMicLevel) setState(() => _level = ev.level);
        if (ev is VideoProbe) setState(() => _probe = ev.quality);
      });
      await e.initialize(widget.appId);
      if (access == MediaAccess.granted) await e.startPreview();
      await e.startMicrophoneTest();
      await e.startConnectionTest();
      if (mounted) setState(() {});
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    final VideoEngine? e = _engine;
    if (e != null) {
      unawaited(() async {
        try {
          await e.stopMicrophoneTest();
          await e.stopConnectionTest();
        } on Object {
          // Released below anyway.
        }
        await e.dispose();
      }());
    }
    super.dispose();
  }

  String _connection(S s) => switch (_probe) {
        null || 0 => s.dcTesting,
        6 => s.dcDown,
        final int q when q >= 4 => s.dcPoor,
        _ => s.dcGood,
      };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final MediaAccess? a = _access;
    final bool full = _engine != null && !_failed;
    return AreaScaffold(
      title: s.dcTitle,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          Text(s.dcBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.md),
          if (a == null)
            NPrimaryButton(label: s.dcStart, loading: _asking, onPressed: _asking ? null : _start)
          else ...<Widget>[
            if (a != MediaAccess.granted) PermissionStep(access: a, asking: false, onAllow: _start, onSettings: _permissions.openSettings),
            if (_failed) Text(s.dcFailed, style: NType.body.copyWith(color: NColors.inkPrimary)),
            if (!full && !_failed && a != MediaAccess.denied) Text(s.dcAllowedOnly, style: NType.body.copyWith(color: NColors.inkPrimary)),
            if (full) ...<Widget>[
              NSectionTitle(s.dcCamera),
              if (a == MediaAccess.granted) ...<Widget>[
                LocalPreview(engine: _engine, on: true),
                Text(s.dcCameraOk, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              ] else
                Text(s.dcBlocked, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              NSectionTitle(s.dcMicrophone),
              Text(s.dcMicSpeak, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.xs),
              Semantics(label: s.dcMicrophone, value: '$_level', child: LinearProgressIndicator(value: _level / 255, minHeight: NSpace.xs)),
              NSectionTitle(s.dcConnection),
              Semantics(liveRegion: true, child: Text(_connection(s), style: NType.body.copyWith(color: NColors.inkPrimary))),
            ],
          ],
        ],
      ),
    );
  }
}
