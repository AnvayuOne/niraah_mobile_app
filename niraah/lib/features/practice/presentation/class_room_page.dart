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
import '../../../shared/area/area_widgets.dart';
import '../../../shared/widgets/room_widgets.dart';
import '../domain/practice.dart';
import 'class_room_cubit.dart';

/// A member's live class room (spec 014 §8 "The class room"): she joins with camera and microphone off, sees and hears
/// the instructor, and can show her camera to the instructor only (AC43). No other member's name or image is shown.
class ClassRoomPage extends StatelessWidget {
  const ClassRoomPage({required this.classId, super.key, this.repository, this.engines, this.permissions});

  final String classId;
  final PracticeRepository? repository;
  final VideoEngineFactory? engines;
  final DevicePermissions? permissions;

  @override
  Widget build(BuildContext context) => BlocProvider<ClassRoomCubit>(
        create: (_) => ClassRoomCubit(
          repository: repository ?? getIt<PracticeRepository>(),
          engines: engines ?? getIt<VideoEngineFactory>(),
          permissions: permissions ?? getIt<DevicePermissions>(),
          classId: classId,
        )..start(),
        child: const _ClassRoomView(),
      );
}

class _ClassRoomView extends StatefulWidget {
  const _ClassRoomView();

  @override
  State<_ClassRoomView> createState() => _ClassRoomViewState();
}

class _ClassRoomViewState extends State<_ClassRoomView> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) unawaited(context.read<ClassRoomCubit>().tick());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<ClassRoomCubit, ClassRoomState>(
      builder: (BuildContext context, ClassRoomState st) {
        final ClassRoomCubit cubit = context.read<ClassRoomCubit>();
        return AreaScaffold(
          title: s.clRoomTitle,
          body: switch (st.phase) {
            ClassRoomPhase.loading => LoadingView(label: s.loading),
            ClassRoomPhase.shut => RoomMessage(
                title: st.message ?? s.rmClosed,
                action: st.notOpen ? NSecondaryButton(label: s.csRoomCheckAgain, onPressed: cubit.start) : null,
              ),
            ClassRoomPhase.error => RoomMessage(title: st.token == null ? s.rmLoadError : s.rmJoinFailed, action: NSecondaryButton(label: s.tryAgain, onPressed: st.token == null ? cubit.start : cubit.join)),
            ClassRoomPhase.ready || ClassRoomPhase.joining => RoomMessage(
                title: s.clRoomTitle,
                body: s.clPrivacy,
                action: NPrimaryButton(label: st.phase == ClassRoomPhase.joining ? s.rmJoining : s.clJoin, loading: st.phase == ClassRoomPhase.joining, onPressed: st.phase == ClassRoomPhase.joining ? null : cubit.join),
              ),
            ClassRoomPhase.dropped => RoomMessage(title: s.rmDropped, action: NPrimaryButton(label: s.rmRejoin, onPressed: cubit.join)),
            ClassRoomPhase.left => RoomMessage(title: s.rmLeft, action: NSecondaryButton(label: s.rmGoBackIn, onPressed: cubit.join)),
            ClassRoomPhase.waiting || ClassRoomPhase.live || ClassRoomPhase.reconnecting => _inClass(context, s, st, cubit),
          },
        );
      },
    );
  }

  Widget _inClass(BuildContext context, S s, ClassRoomState st, ClassRoomCubit cubit) {
    final VideoEngine? e = cubit.engine;
    final int? uid = st.instructorUid;
    final String? channel = st.token?.channel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: VideoStage(
            remote: st.phase == ClassRoomPhase.live && st.instructorVideo && uid != null && channel != null && e != null ? e.remoteView(channel, uid) : null,
            local: st.sharingCamera && e != null ? e.localView() : null,
            title: st.phase == ClassRoomPhase.waiting ? s.clWaitingInstructor : s.clRoomTitle,
            note: st.phase == ClassRoomPhase.waiting ? s.clPrivacy : s.rmCameraOff,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (st.phase == ClassRoomPhase.reconnecting) RoomBanner(title: s.rmReconnecting, body: s.rmReconnectingNote),
              if (st.cameraRefused) RoomBanner(title: s.dcBlocked),
              Text(st.sharingCamera ? s.clCameraSharing : s.clCameraNote, textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.xs),
              NSecondaryButton(label: st.sharingCamera ? s.clCameraOff : s.clCameraOn, onPressed: st.cameraBusy ? null : cubit.toggleCamera),
              TextButton(
                onPressed: () async {
                  if (await confirmLeave(context, s)) await cubit.leave();
                },
                child: Text(s.rmLeave),
              ),
              const SizedBox(height: NSpace.xs),
            ],
          ),
        ),
      ],
    );
  }
}
