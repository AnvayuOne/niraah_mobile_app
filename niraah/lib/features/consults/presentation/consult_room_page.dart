import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/video/device_permissions.dart';
import '../../../core/video/video_engine.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/widgets/room_widgets.dart';
import '../domain/consults.dart';
import 'consult_room_cubit.dart';
import 'consult_widgets.dart';

/// The consult room (spec 014 §5): the permission explanation and her preview with camera and microphone switchable,
/// a calm waiting state, the call with mute, camera, switch camera and leave, "Reconnecting", audio only on a weak link,
/// the timer and time-up, and the recording mark with her stop control (AC51, AC52). No health detail is shown here
/// (§5 "Privacy" 1), and there is no in-room chat, so nothing said in the room is kept (AC27).
class ConsultRoomPage extends StatelessWidget {
  const ConsultRoomPage({required this.appointmentId, super.key, this.repository, this.engines, this.permissions, this.clock});

  final String appointmentId;
  final ConsultsRepository? repository;
  final VideoEngineFactory? engines;
  final DevicePermissions? permissions;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) => BlocProvider<ConsultRoomCubit>(
        create: (_) => ConsultRoomCubit(
          repository: repository ?? getIt<ConsultsRepository>(),
          engines: engines ?? getIt<VideoEngineFactory>(),
          permissions: permissions ?? getIt<DevicePermissions>(),
          appointmentId: appointmentId,
          clock: clock,
        )..start(),
        child: const _RoomView(),
      );
}

class _RoomView extends StatefulWidget {
  const _RoomView();

  @override
  State<_RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<_RoomView> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // The timer is text that changes once a second; nothing moves.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      unawaited(context.read<ConsultRoomCubit>().tick());
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _leave(ConsultRoomCubit cubit) async {
    if (await confirmLeave(context, S.of(context))) await cubit.leave();
  }

  Future<void> _stopRecording(ConsultRoomCubit cubit) async {
    final S s = S.of(context);
    final Object? e = await cubit.stopRecording();
    if (!mounted) return;
    showNote(context, e == null ? s.csRecordingStopped : failureText(e, s.commonLoadError));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<ConsultRoomCubit, ConsultRoomState>(
      builder: (BuildContext context, ConsultRoomState st) {
        final ConsultRoomCubit cubit = context.read<ConsultRoomCubit>();
        final Appointment? a = st.appointment;
        final String name = a?.clinicianName ?? s.rmYourClinician;
        return AreaScaffold(
          title: a?.clinicianName == null ? s.csRoomTitle : s.rmWithClinician(a!.clinicianName!),
          body: switch (st.phase) {
            RoomPhase.loading => LoadingView(label: s.loading),
            RoomPhase.notOpen => RoomMessage(
                title: s.csRoomNotOpen,
                body: st.opensAt == null ? null : s.csRoomOpensAt(whenText(context, st.opensAt!)),
                action: NSecondaryButton(label: s.csRoomCheckAgain, onPressed: cubit.start),
              ),
            RoomPhase.closed => RoomMessage(title: st.message ?? s.rmClosed),
            RoomPhase.error => RoomMessage(
                title: st.room == null ? s.rmLoadError : s.rmJoinFailed,
                action: NSecondaryButton(label: s.tryAgain, onPressed: st.room == null ? cubit.start : cubit.join),
              ),
            RoomPhase.preview || RoomPhase.joining => _preview(context, s, st, cubit),
            RoomPhase.waiting || RoomPhase.connected || RoomPhase.reconnecting => _call(context, s, st, cubit, name),
            RoomPhase.dropped => RoomMessage(title: s.rmDropped, action: NPrimaryButton(label: s.rmRejoin, onPressed: cubit.join)),
            RoomPhase.left => RoomMessage(
                title: st.closedByTime ? s.rmClosed : s.rmLeft,
                action: st.closedByTime || cubit.timer is TimerClosed ? null : NSecondaryButton(label: s.rmGoBackIn, onPressed: cubit.reenter),
              ),
          },
        );
      },
    );
  }

  Widget _recording(S s, ConsultRoomCubit cubit) => RecordingMark(label: s.csRecordingMark, body: s.csRecordingBody, stopLabel: s.csRecordingStop, onStop: () => _stopRecording(cubit));

  Widget _preview(BuildContext context, S s, ConsultRoomState st, ConsultRoomCubit cubit) {
    final Appointment? a = st.appointment;
    final bool joining = st.phase == RoomPhase.joining;
    return ListView(
      padding: const EdgeInsets.all(NSpace.lg),
      children: <Widget>[
        if (a != null) Text(s.rmStartsAt(timeText(context, a.startsAt)), style: NType.body.copyWith(color: NColors.inkSecondary)),
        const SizedBox(height: NSpace.sm),
        if (st.recording) ...<Widget>[_recording(s, cubit), const SizedBox(height: NSpace.sm)],
        PermissionStep(access: st.access, asking: st.asking, onAllow: cubit.allowDevices, onSettings: cubit.openSettings),
        if (st.access != null && st.access != MediaAccess.denied) ...<Widget>[
          const SizedBox(height: NSpace.md),
          LocalPreview(engine: cubit.engine, on: st.cameraOn),
          const SizedBox(height: NSpace.sm),
          CallControls(
            mic: st.mic,
            camera: st.cameraOn,
            cameraAllowed: st.access == MediaAccess.granted && !st.audioOnly,
            onMic: cubit.toggleMic,
            onCamera: cubit.toggleCamera,
            onSwitch: cubit.switchCamera,
          ),
        ],
        const SizedBox(height: NSpace.md),
        NPrimaryButton(label: joining ? s.rmJoining : s.rmJoinNow, loading: joining, onPressed: st.access == null || joining ? null : cubit.join),
      ],
    );
  }

  Widget _call(BuildContext context, S s, ConsultRoomState st, ConsultRoomCubit cubit, String name) {
    final RoomTimer? t = cubit.timer;
    final String timerText = switch (t) {
      TimerRunning(:final Duration remaining) => s.rmRemaining(clockText(remaining)),
      TimerTimeUp(:final Duration closesIn) => s.rmTimeUp(clockText(closesIn)),
      TimerClosed() || null => '',
    };
    final String? channel = st.room?.channel;
    final int? uid = st.remoteUid;
    final VideoEngine? engine = cubit.engine;
    final bool showRemote = st.phase != RoomPhase.waiting && st.remoteVideo && uid != null && channel != null && engine != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: VideoStage(
            remote: showRemote ? engine.remoteView(channel, uid) : null,
            local: st.cameraOn && engine != null ? engine.localView() : null,
            title: st.phase == RoomPhase.waiting ? s.rmWaitingFor(name) : name,
            note: st.phase == RoomPhase.waiting ? s.rmWaitingNote : s.rmCameraOff,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (timerText.isNotEmpty) Semantics(liveRegion: t is TimerTimeUp, child: Text(timerText, textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkSecondary))),
              if (st.phase == RoomPhase.reconnecting)
                RoomBanner(title: s.rmReconnecting, body: s.rmReconnectingNote)
              else if (st.offerAudioOnly)
                RoomBanner(title: s.rmWeak, action: TextButton(onPressed: () => cubit.setAudioOnly(true), child: Text(s.rmSwitchAudioOnly)))
              else if (st.audioOnly)
                RoomBanner(title: s.rmAudioOnlyOn, action: TextButton(onPressed: () => cubit.setAudioOnly(false), child: Text(s.rmVideoBack))),
              if (st.recording) _recording(s, cubit),
              const SizedBox(height: NSpace.xs),
              CallControls(
                mic: st.mic,
                camera: st.cameraOn,
                cameraAllowed: st.access == MediaAccess.granted && !st.audioOnly,
                onMic: cubit.toggleMic,
                onCamera: cubit.toggleCamera,
                onSwitch: cubit.switchCamera,
                onLeave: () => _leave(cubit),
              ),
              const SizedBox(height: NSpace.sm),
            ],
          ),
        ),
      ],
    );
  }
}
