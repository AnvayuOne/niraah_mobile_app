import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/di/service_locator.dart';
import '../../design_system/generated/niraah_assets.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/n_button.dart';
import '../../design_system/widgets/n_illustration.dart';
import 'call_engine.dart';
import 'room_controller.dart';
import 'room_repository.dart';

/// Words in the room (English, like the consult screens).
abstract final class RoomCopy {
  static const String videoConsult = 'Video consult';
  static const String joinNow = 'Join now';
  static const String joining = 'Joining…';
  static const String checkHow = 'Check how you look and sound, then join.';
  static const String micOff = 'Microphone off';
  static const String cameraOff = 'Camera off';
  static const String recordingNote = 'This consult is recorded, as you agreed when you booked.';
  static const String recording = 'Recording';
  static const String opensIn = 'The room opens in';
  static const String opensAuto = "Stay on this screen. You'll be let in as soon as it opens.";
  static const String waitingFor = 'Waiting for';
  static const String toJoin = 'to join';
  static const String waitingBody = "They'll appear here as soon as they join. You can check your camera and microphone meanwhile.";
  static const String reconnecting = 'Reconnecting…';
  static const String closesIn = 'Room closes in';
  static const String leave = 'Leave';
  static const String leaveTitle = 'Leave the consult?';
  static const String leaveBody = 'You can come back while the room is open.';
  static const String endForBoth = 'End consult for both';
  static const String endBody = 'Ending closes the room for you and the member. Leave for now if you plan to come back.';
  static const String leaveForNow = 'Leave for now';
  static const String stay = 'Stay in the call';
  static const String endedTitle = 'Consult ended';
  static const String leftTitle = 'You left the consult';
  static const String closedTitle = 'The room has closed';
  static const String endedBody = 'Thank you. Any notes or plan from this consult will appear in the app.';
  static const String leftBody = 'The room stays open until the consult ends. You can join again.';
  static const String joinAgain = 'Join again';
  static const String done = 'Done';
  static const String needMic = 'Allow the microphone';
  static const String needMicBody = 'A video consult needs your microphone. Allow it in Settings, then come back.';
  static const String openSettings = 'Open Settings';
  static const String tryAgain = 'I allowed it';
  static const String cantJoin = "Can't join right now";
  static const String back = 'Back';
  static const String theirCameraOff = 'Camera is off';
  static const String someone = 'Your specialist';
  static const String member = 'Member';
}

/// The consult room (spec 014 §5): lobby with her preview, then the call. The same room for the member and
/// for the doctor or dietitian; only the clinician can end the consult for both.
class RoomPage extends StatefulWidget {
  const RoomPage({required this.appointmentId, required this.side, super.key, this.controller});

  final String appointmentId;
  final RoomSide side;

  /// Tests pass a controller with a fake engine.
  final RoomController? controller;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

Future<({bool mic, bool camera})> _askDevicePermissions() async {
  final Map<Permission, PermissionStatus> s = await <Permission>[Permission.microphone, Permission.camera].request();
  return (mic: s[Permission.microphone]?.isGranted ?? false, camera: s[Permission.camera]?.isGranted ?? false);
}

class _RoomPageState extends State<RoomPage> {
  late final RoomController c = widget.controller ??
      RoomController(
        appointmentId: widget.appointmentId,
        side: widget.side,
        repository: getIt<RoomRepository>(),
        engineFactory: AgoraCallEngine.new,
        askPermissions: _askDevicePermissions,
      );

  @override
  void initState() {
    super.initState();
    unawaited(c.open());
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  String get _other => c.info?.otherName(widget.side) ?? (widget.side == RoomSide.member ? RoomCopy.someone : RoomCopy.member);

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(widget.side == RoomSide.member ? '/appointments' : '/doctor');
    }
  }

  Future<void> _confirmLeave() async {
    final bool clinician = widget.side == RoomSide.clinician;
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NColors.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(NRadius.xl))),
      builder: (BuildContext sheet) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.md, NSpace.lg, NSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: NColors.lineDefault, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: NSpace.md),
              Text(clinician ? RoomCopy.endForBoth : RoomCopy.leaveTitle, style: NType.h3.copyWith(color: NColors.inkPrimary)),
              const SizedBox(height: NSpace.xs),
              Text(clinician ? RoomCopy.endBody : RoomCopy.leaveBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.lg),
              if (clinician) ...<Widget>[
                FilledButton(
                  key: const ValueKey<String>('room-end-both'),
                  onPressed: () => Navigator.of(sheet).pop('end'),
                  style: FilledButton.styleFrom(
                    backgroundColor: NColors.statusClinicalRedFlag,
                    foregroundColor: NColors.inkOnBrand,
                    minimumSize: const Size.fromHeight(NLayout.minTapTarget + 8),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(RoomCopy.endForBoth),
                ),
                const SizedBox(height: NSpace.xs),
                OutlinedButton(
                  key: const ValueKey<String>('room-leave-for-now'),
                  onPressed: () => Navigator.of(sheet).pop('leave'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(NLayout.minTapTarget + 8), shape: const StadiumBorder()),
                  child: const Text(RoomCopy.leaveForNow),
                ),
              ] else
                FilledButton(
                  key: const ValueKey<String>('room-leave-confirm'),
                  onPressed: () => Navigator.of(sheet).pop('leave'),
                  style: FilledButton.styleFrom(
                    backgroundColor: NColors.statusClinicalRedFlag,
                    foregroundColor: NColors.inkOnBrand,
                    minimumSize: const Size.fromHeight(NLayout.minTapTarget + 8),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(RoomCopy.leave),
                ),
              TextButton(onPressed: () => Navigator.of(sheet).pop(), child: const Text(RoomCopy.stay)),
            ],
          ),
        ),
      ),
    );
    if (choice == 'end') {
      final bool ok = await c.endForBoth();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't end the consult. Try again.")));
      }
    } else if (choice == 'leave') {
      await c.leave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (BuildContext context, _) {
        final bool dark = c.phase == RoomPhase.inCall || c.phase == RoomPhase.joining;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: PopScope(
            canPop: !dark,
            onPopInvokedWithResult: (bool didPop, Object? _) {
              if (!didPop && dark) unawaited(_confirmLeave());
            },
            child: Scaffold(
              backgroundColor: dark ? const Color(0xFF1E1A1F) : NColors.surfacePage,
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(key: ValueKey<RoomPhase>(c.phase), child: _phase()),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _phase() => switch (c.phase) {
        RoomPhase.loading => const Center(child: CircularProgressIndicator()),
        RoomPhase.notOpen => _NotOpen(c: c, other: _other, onBack: _close),
        RoomPhase.needsPermission => _Message(
            art: NImages.d03VideoConsult,
            title: RoomCopy.needMic,
            body: RoomCopy.needMicBody,
            primary: RoomCopy.openSettings,
            onPrimary: () => unawaited(openAppSettings()),
            secondary: RoomCopy.tryAgain,
            onSecondary: () => unawaited(c.retryPermissions()),
            onBack: _close,
          ),
        RoomPhase.unavailable => _Message(
            art: NImages.d03VideoConsult,
            title: RoomCopy.cantJoin,
            body: c.message ?? '',
            primary: RoomCopy.back,
            onPrimary: _close,
            onBack: _close,
          ),
        RoomPhase.lobby => _Lobby(c: c, other: _other, side: widget.side, onBack: _close),
        RoomPhase.joining || RoomPhase.inCall => _Call(c: c, other: _other, onLeave: _confirmLeave),
        RoomPhase.ended => _Message(
            art: NImages.d03VideoConsult,
            title: c.endedForBoth ? RoomCopy.endedTitle : (c.roomClosed ? RoomCopy.closedTitle : RoomCopy.leftTitle),
            body: c.endedForBoth || c.roomClosed ? RoomCopy.endedBody : RoomCopy.leftBody,
            primary: RoomCopy.done,
            onPrimary: _close,
            secondary: c.endedForBoth || c.roomClosed ? null : RoomCopy.joinAgain,
            onSecondary: () => unawaited(c.rejoin()),
            onBack: _close,
          ),
      };
}

// ---------------------------------------------------------------------------------------------------------------
// Lobby

class _Lobby extends StatelessWidget {
  const _Lobby({required this.c, required this.other, required this.side, required this.onBack});

  final RoomController c;
  final String other;
  final RoomSide side;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final RoomInfo? info = c.info;
    final String when = info == null ? '' : '${DateFormat('EEE d MMM').format(info.startsAt)} · ${DateFormat('h:mm a').format(info.startsAt)} – ${DateFormat('h:mm a').format(info.endsAt)}';
    return SafeArea(
      child: Column(
        children: <Widget>[
          _TopBar(onBack: onBack, title: RoomCopy.videoConsult),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.xs, NSpace.lg, NSpace.lg),
              children: <Widget>[
                Text(other, style: NType.h2.copyWith(color: NColors.inkPrimary)),
                if (when.isNotEmpty) ...<Widget>[
                  const SizedBox(height: NSpace.xxs),
                  Text(when, style: NType.body.copyWith(color: NColors.inkSecondary)),
                ],
                const SizedBox(height: NSpace.md),
                // Her preview: portrait, but never more than about half the screen, so the notes below stay visible.
                SizedBox(
                  height: (MediaQuery.sizeOf(context).height * 0.45).clamp(220.0, 460.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(NRadius.xl),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Container(color: const Color(0xFF2A2429)),
                        if (c.cameraOn && c.engine != null) c.engine!.localView() else const _CameraOffTile(label: RoomCopy.cameraOff),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: NSpace.md,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _RoundControl(
                                key: const ValueKey<String>('lobby-mic'),
                                icon: c.micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                                label: c.micOn ? 'Mute microphone' : 'Unmute microphone',
                                active: c.micOn,
                                onTap: c.toggleMic,
                              ),
                              const SizedBox(width: NSpace.md),
                              _RoundControl(
                                key: const ValueKey<String>('lobby-camera'),
                                icon: c.cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                                label: c.cameraOn ? 'Turn camera off' : 'Turn camera on',
                                active: c.cameraOn,
                                onTap: c.cameraAllowed ? c.toggleCamera : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: NSpace.md),
                Text(RoomCopy.checkHow, textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                if (c.recording) ...<Widget>[
                  const SizedBox(height: NSpace.sm),
                  _Note(icon: Icons.fiber_manual_record_rounded, text: RoomCopy.recordingNote, color: NColors.statusClinicalRedFlag, background: NColors.statusClinicalRedFlagLight),
                ],
                if (c.message != null && c.phase == RoomPhase.lobby) ...<Widget>[
                  const SizedBox(height: NSpace.sm),
                  _Note(icon: Icons.info_outline_rounded, text: c.message!, color: NColors.statusWarningText, background: NColors.statusWarningLight),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.md),
            child: NPrimaryButton(
              key: const ValueKey<String>('room-join'),
              label: c.phase == RoomPhase.joining ? RoomCopy.joining : RoomCopy.joinNow,
              loading: c.phase == RoomPhase.joining,
              onPressed: c.phase == RoomPhase.lobby ? c.join : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// Call

class _Call extends StatelessWidget {
  const _Call({required this.c, required this.other, required this.onLeave});

  final RoomController c;
  final String other;
  final Future<void> Function() onLeave;

  static String _clock(Duration d) {
    final String m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final int? uid = c.otherUid;
    final Duration? closing = c.closingIn;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // The other person fills the screen.
        if (uid != null && c.otherCameraOn && c.engine != null)
          c.engine!.remoteView(uid, c.channel)
        else if (uid != null)
          _CameraOffTile(label: RoomCopy.theirCameraOff, name: other, large: true)
        else
          _Waiting(other: other),

        // Top: who, timer, recording.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xAA000000), Color(0x00000000)]),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.md, NSpace.xl),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(child: Text(other, overflow: TextOverflow.ellipsis, style: NType.h4.copyWith(color: Colors.white))),
                              if (uid != null && !c.otherMicOn) ...<Widget>[
                                const SizedBox(width: NSpace.xxs),
                                const Icon(Icons.mic_off_rounded, size: 16, color: Colors.white70, semanticLabel: 'Their microphone is off'),
                              ],
                            ],
                          ),
                          Text(
                            uid == null ? RoomCopy.videoConsult : _clock(c.talked),
                            key: const ValueKey<String>('room-timer'),
                            style: NType.bodySm.copyWith(color: Colors.white70, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
                          ),
                        ],
                      ),
                    ),
                    if (c.recording) const _RecPill(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Her own camera, small, top right.
        Positioned(
          top: MediaQuery.paddingOf(context).top + 72,
          right: NSpace.md,
          width: 104,
          height: 148,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NRadius.lg),
              border: Border.all(color: Colors.white24),
              boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(NRadius.lg),
              child: c.cameraOn && c.engine != null ? c.engine!.localView() : const _CameraOffTile(label: RoomCopy.cameraOff, small: true),
            ),
          ),
        ),

        // Status banners.
        if (c.reconnecting || closing != null || c.phase == RoomPhase.joining)
          Positioned(
            left: NSpace.md,
            right: NSpace.md,
            bottom: 132 + MediaQuery.paddingOf(context).bottom,
            child: Center(
              child: _Banner(
                text: c.phase == RoomPhase.joining
                    ? RoomCopy.joining
                    : c.reconnecting
                        ? RoomCopy.reconnecting
                        : '${RoomCopy.closesIn} ${closing!.inMinutes > 0 ? '${closing.inMinutes} min ${closing.inSeconds.remainder(60)} s' : '${closing.inSeconds} s'}',
                warn: !c.reconnecting && c.phase != RoomPhase.joining,
              ),
            ),
          ),

        // Controls.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[Color(0xCC000000), Color(0x00000000)]),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xl, NSpace.md, NSpace.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _RoundControl(
                      key: const ValueKey<String>('call-mic'),
                      icon: c.micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                      label: c.micOn ? 'Mute microphone' : 'Unmute microphone',
                      active: c.micOn,
                      onTap: c.toggleMic,
                    ),
                    _RoundControl(
                      key: const ValueKey<String>('call-camera'),
                      icon: c.cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                      label: c.cameraOn ? 'Turn camera off' : 'Turn camera on',
                      active: c.cameraOn,
                      onTap: c.cameraAllowed ? c.toggleCamera : null,
                    ),
                    _RoundControl(
                      key: const ValueKey<String>('call-flip'),
                      icon: Icons.cameraswitch_rounded,
                      label: 'Switch camera',
                      active: true,
                      onTap: c.cameraOn ? c.flipCamera : null,
                    ),
                    _RoundControl(
                      key: const ValueKey<String>('call-speaker'),
                      icon: c.speakerOn ? Icons.volume_up_rounded : Icons.hearing_rounded,
                      label: c.speakerOn ? 'Use earpiece' : 'Use speaker',
                      active: c.speakerOn,
                      onTap: c.toggleSpeaker,
                    ),
                    _RoundControl(
                      key: const ValueKey<String>('call-leave'),
                      icon: Icons.call_end_rounded,
                      label: RoomCopy.leave,
                      active: true,
                      danger: true,
                      onTap: onLeave,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({required this.other});
  final String other;

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF2A2429),
        padding: const EdgeInsets.symmetric(horizontal: NSpace.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Pulse(child: _Initial(name: other, size: 104)),
            const SizedBox(height: NSpace.lg),
            Text(
              '${RoomCopy.waitingFor} $other ${RoomCopy.toJoin}',
              key: const ValueKey<String>('room-waiting'),
              textAlign: TextAlign.center,
              style: NType.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: NSpace.xs),
            Text(RoomCopy.waitingBody, textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: Colors.white70)),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------------------------------------------
// Not open yet

class _NotOpen extends StatelessWidget {
  const _NotOpen({required this.c, required this.other, required this.onBack});

  final RoomController c;
  final String other;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final Duration left = c.untilOpen ?? Duration.zero;
    final Duration d = left.isNegative ? Duration.zero : left;
    final String countdown = d.inHours > 0
        ? '${d.inHours} h ${d.inMinutes.remainder(60)} min'
        : d.inMinutes > 0
            ? '${d.inMinutes} min ${d.inSeconds.remainder(60).toString().padLeft(2, '0')} s'
            : '${d.inSeconds} s';
    return SafeArea(
      child: Column(
        children: <Widget>[
          _TopBar(onBack: onBack, title: RoomCopy.videoConsult),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(NSpace.lg),
              children: <Widget>[
                const NIllustration(asset: NImages.d03VideoConsult, height: 180),
                const SizedBox(height: NSpace.lg),
                Text(other, textAlign: TextAlign.center, style: NType.h3.copyWith(color: NColors.inkPrimary)),
                const SizedBox(height: NSpace.md),
                Container(
                  padding: const EdgeInsets.all(NSpace.lg),
                  decoration: BoxDecoration(color: NColors.brandBlushLight, borderRadius: BorderRadius.circular(NRadius.xl)),
                  child: Column(
                    children: <Widget>[
                      Text(RoomCopy.opensIn, style: NType.label.copyWith(color: NColors.brandRosewood)),
                      const SizedBox(height: NSpace.xxs),
                      Text(
                        countdown,
                        key: const ValueKey<String>('room-countdown'),
                        style: NType.h1.copyWith(color: NColors.inkPrimary, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
                      ),
                      if (c.opensAt != null) Text('at ${DateFormat('h:mm a').format(c.opensAt!)}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.md),
                Text(RoomCopy.opensAuto, textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// Shared pieces

class _Message extends StatelessWidget {
  const _Message({
    required this.art,
    required this.title,
    required this.body,
    required this.primary,
    required this.onPrimary,
    required this.onBack,
    this.secondary,
    this.onSecondary,
  });

  final NImageAsset art;
  final String title;
  final String body;
  final String primary;
  final VoidCallback onPrimary;
  final String? secondary;
  final VoidCallback? onSecondary;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          children: <Widget>[
            _TopBar(onBack: onBack, title: RoomCopy.videoConsult),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(NSpace.lg),
                children: <Widget>[
                  NIllustration(asset: art, height: 180),
                  const SizedBox(height: NSpace.lg),
                  Text(title, textAlign: TextAlign.center, style: NType.h2.copyWith(color: NColors.inkPrimary)),
                  const SizedBox(height: NSpace.xs),
                  Text(body, textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkSecondary)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (secondary != null) ...<Widget>[
                    NPrimaryButton(key: const ValueKey<String>('room-secondary'), label: secondary!, onPressed: onSecondary),
                    const SizedBox(height: NSpace.xs),
                    NSecondaryButton(key: const ValueKey<String>('room-primary'), label: primary, onPressed: onPrimary),
                  ] else
                    NPrimaryButton(key: const ValueKey<String>('room-primary'), label: primary, onPressed: onPrimary),
                ],
              ),
            ),
          ],
        ),
      );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.title});
  final VoidCallback onBack;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(NSpace.sm, NSpace.xs, NSpace.md, NSpace.xs),
        child: Row(
          children: <Widget>[
            Material(
              color: NColors.surfaceCard,
              shape: const CircleBorder(),
              elevation: 0,
              child: IconButton(
                tooltip: RoomCopy.back,
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_rounded, color: NColors.inkPrimary),
              ),
            ),
            const SizedBox(width: NSpace.sm),
            Text(title, style: NType.label.copyWith(color: NColors.brandRosewood, letterSpacing: 1.2)),
          ],
        ),
      );
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({required this.icon, required this.label, required this.active, required this.onTap, super.key, this.danger = false});

  final IconData icon;
  final String label;
  final bool active;
  final bool danger;
  final FutureOr<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = danger ? NColors.statusClinicalRedFlag : (active ? Colors.white.withValues(alpha: 0.18) : Colors.white);
    final Color fg = danger ? Colors.white : (active ? Colors.white : const Color(0xFF2A2429));
    final double size = danger ? 64 : 56;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: Opacity(
          opacity: onTap == null ? 0.4 : 1,
          child: Material(
            color: bg,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap == null ? null : () => unawaited(Future<void>.value(onTap!())),
              child: SizedBox(width: size, height: size, child: Icon(icon, color: fg, size: danger ? 30 : 26)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraOffTile extends StatelessWidget {
  const _CameraOffTile({required this.label, this.name, this.small = false, this.large = false});
  final String label;
  final String? name;
  final bool small;
  final bool large;

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF2A2429),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (name != null) _Initial(name: name!, size: large ? 104 : 56) else Icon(Icons.videocam_off_rounded, color: Colors.white54, size: small ? 22 : 36),
            if (!small) ...<Widget>[
              const SizedBox(height: NSpace.sm),
              Text(label, style: NType.bodySm.copyWith(color: Colors.white70)),
            ],
          ],
        ),
      );
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name, required this.size});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String letter = name.replaceAll(RegExp(r'^(Dr\.?\s+)', caseSensitive: false), '').trim().characters.firstOrNull?.toUpperCase() ?? '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFFF3C6CF), Color(0xFFC79BB8)]),
      ),
      child: Text(letter, style: NType.h1.copyWith(color: const Color(0xFF4A2B3D), fontSize: size * 0.42)),
    );
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void initState() {
    super.initState();
    if (!(WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations)) unawaited(_a.repeat());
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _a,
        builder: (BuildContext context, Widget? child) => Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 104 + 56 * _a.value,
              height: 104 + 56 * _a.value,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF3C6CF).withValues(alpha: 0.35 * (1 - _a.value))),
            ),
            child!,
          ],
        ),
        child: widget.child,
      );
}

class _RecPill extends StatelessWidget {
  const _RecPill();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xxs),
        decoration: BoxDecoration(color: NColors.statusClinicalRedFlag, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.fiber_manual_record_rounded, size: 10, color: Colors.white),
            const SizedBox(width: 4),
            Text(RoomCopy.recording, style: NType.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, this.warn = false});
  final String text;
  final bool warn;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.xs),
          decoration: BoxDecoration(color: warn ? NColors.statusWarningLight : Colors.black54, borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!warn) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              if (warn) Icon(Icons.timer_outlined, size: 16, color: NColors.statusWarningText),
              const SizedBox(width: NSpace.xs),
              Text(text, key: const ValueKey<String>('room-banner'), style: NType.bodySm.copyWith(color: warn ? NColors.statusWarningText : Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, required this.color, required this.background});
  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(NSpace.sm),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(NRadius.md)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: NSpace.xs),
            Expanded(child: Text(text, style: NType.bodySm.copyWith(color: color))),
          ],
        ),
      );
}
