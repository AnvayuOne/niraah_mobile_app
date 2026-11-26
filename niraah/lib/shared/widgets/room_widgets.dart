import 'package:material_ui/material_ui.dart';

import '../../core/video/device_permissions.dart';
import '../../core/video/video_engine.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/n_button.dart';
import '../../l10n/app_localizations.dart';
import '../area/area_widgets.dart';

/// Pieces shared by the consult room, the class room, the instructor's console and the device check (spec 014 §4.4,
/// §5, §8; spec 013 §4). Calm and plain: nothing flashes, and nothing here shows health detail.

/// A centred message with an optional action: not open yet, closed, dropped, left.
class RoomMessage extends StatelessWidget {
  const RoomMessage({required this.title, super.key, this.body, this.action});

  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          const SizedBox(height: NSpace.xl),
          Semantics(header: true, child: Text(title, textAlign: TextAlign.center, style: NType.h3.copyWith(color: NColors.inkPrimary))),
          if (body != null) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            Text(body!, textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkSecondary)),
          ],
          if (action != null) ...<Widget>[const SizedBox(height: NSpace.lg), action!],
        ],
      );
}

/// Why the app asks for the camera and microphone, the button that asks, and what she allowed (spec 014 §5
/// "Entering" 3).
class PermissionStep extends StatelessWidget {
  const PermissionStep({required this.access, required this.asking, required this.onAllow, required this.onSettings, super.key, this.why});

  final MediaAccess? access;
  final bool asking;
  final VoidCallback onAllow;
  final VoidCallback onSettings;
  final String? why;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return NCard(
      color: NColors.brandLavenderLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(header: true, child: Text(s.rmPermissionTitle, style: NType.h4.copyWith(color: NColors.inkPrimary))),
          const SizedBox(height: NSpace.xxs),
          Text(switch (access) {
            null => why ?? s.rmPermissionWhy,
            MediaAccess.granted => why ?? s.rmPermissionWhy,
            MediaAccess.audioOnly => s.rmAudioOnlyPermission,
            MediaAccess.denied => s.rmDenied,
          }, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          if (access == null) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            NSecondaryButton(label: s.rmAllow, onPressed: asking ? null : onAllow),
          ],
          if (access == MediaAccess.denied || access == MediaAccess.audioOnly)
            TextButton(onPressed: onSettings, child: Text(s.rmOpenSettings)),
        ],
      ),
    );
  }
}

/// Her own camera, or "Camera off".
class LocalPreview extends StatelessWidget {
  const LocalPreview({required this.engine, required this.on, super.key});

  final VideoEngine? engine;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Semantics(
      label: s.rmYou,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(NRadius.md),
          child: ColoredBox(
            color: NColors.surfaceWarm,
            child: on && engine != null ? engine!.localView() : Center(child: Text(s.rmCameraOff, style: NType.body.copyWith(color: NColors.inkSecondary))),
          ),
        ),
      ),
    );
  }
}

/// The other side's video, or a calm placeholder with her name, and her own camera small in the corner.
class VideoStage extends StatelessWidget {
  const VideoStage({required this.title, required this.note, super.key, this.remote, this.local, this.overlay = const <Widget>[]});

  final Widget? remote;
  final Widget? local;
  final String title;
  final String note;
  final List<Widget> overlay;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(NSpace.sm),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(NRadius.md),
                child: ColoredBox(
                  color: NColors.surfaceWarm,
                  child: remote ??
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(NSpace.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(title, textAlign: TextAlign.center, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                              const SizedBox(height: NSpace.xs),
                              Text(note, textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                            ],
                          ),
                        ),
                      ),
                ),
              ),
            ),
            if (local != null)
              Positioned(
                right: NSpace.sm,
                bottom: NSpace.sm,
                width: 96,
                height: 128,
                child: Semantics(label: S.of(context).rmYou, child: ClipRRect(borderRadius: BorderRadius.circular(NRadius.sm), child: local)),
              ),
            ...overlay,
          ],
        ),
      );
}

/// A quiet notice in the call: reconnecting, a weak link, audio only.
class RoomBanner extends StatelessWidget {
  const RoomBanner({required this.title, super.key, this.body, this.action});

  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: NSpace.xs),
        child: Semantics(
          liveRegion: true,
          child: NCard(
            color: NColors.surfaceWarm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                if (body != null) Text(body!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                ?action,
              ],
            ),
          ),
        ),
      );
}

/// The "Recording" mark, for the whole time a consult is recorded, with her stop control (spec 014 §5 "Recording" 5).
class RecordingMark extends StatelessWidget {
  const RecordingMark({required this.label, required this.body, required this.stopLabel, required this.onStop, super.key});

  final String label;
  final String body;
  final String stopLabel;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: NSpace.xs),
        child: NCard(
          color: NColors.surfaceWarm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                const Icon(Icons.fiber_manual_record_rounded, color: NColors.inkSecondary, size: 18),
                const SizedBox(width: NSpace.xs),
                Text(label, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
              ]),
              Text(body, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              TextButton(onPressed: onStop, child: Text(stopLabel)),
            ],
          ),
        ),
      );
}

/// Microphone, camera, switch camera and leave, each at least 48 px with a label for screen readers.
class CallControls extends StatelessWidget {
  const CallControls({
    required this.mic,
    required this.camera,
    required this.cameraAllowed,
    required this.onMic,
    required this.onCamera,
    required this.onSwitch,
    super.key,
    this.onLeave,
    this.showMic = true,
  });

  final bool mic;
  final bool camera;
  final bool cameraAllowed;
  final VoidCallback onMic;
  final VoidCallback onCamera;
  final VoidCallback onSwitch;
  final VoidCallback? onLeave;
  final bool showMic;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: NSpace.sm,
      children: <Widget>[
        if (showMic)
          IconButton.filledTonal(
            tooltip: mic ? s.rmMicMute : s.rmMicUnmute,
            onPressed: onMic,
            icon: Icon(mic ? Icons.mic_rounded : Icons.mic_off_rounded),
          ),
        IconButton.filledTonal(
          tooltip: camera ? s.rmCameraTurnOff : s.rmCameraTurnOn,
          onPressed: cameraAllowed ? onCamera : null,
          icon: Icon(camera ? Icons.videocam_rounded : Icons.videocam_off_rounded),
        ),
        IconButton.filledTonal(tooltip: s.rmSwitchCamera, onPressed: camera ? onSwitch : null, icon: const Icon(Icons.cameraswitch_rounded)),
        if (onLeave != null) IconButton.filled(tooltip: s.rmLeave, onPressed: onLeave, icon: const Icon(Icons.call_end_rounded)),
      ],
    );
  }
}

/// "Leave the room? You can come back while the room is open."
Future<bool> confirmLeave(BuildContext context, S s, {String? text, String? confirm}) async =>
    await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        content: Text(text ?? s.rmLeaveConfirm),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(s.rmStay)),
          FilledButton(onPressed: () => Navigator.of(c).pop(true), child: Text(confirm ?? s.rmLeave)),
        ],
      ),
    ) ??
    false;
