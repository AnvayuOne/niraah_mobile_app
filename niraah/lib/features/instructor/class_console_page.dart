import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/service_locator.dart';
import '../../core/video/device_permissions.dart';
import '../../core/video/video_engine.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/loading_view.dart';
import '../../design_system/widgets/n_button.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/area/area_access.dart';
import '../../shared/area/area_widgets.dart';
import '../../shared/widgets/room_widgets.dart';
import '../consults/presentation/consult_room_cubit.dart' show RoomTimer, TimerRunning, TimerTimeUp, clockText, roomTimer;
import '../provider_work/domain/provider_work.dart';
import 'class_console_cubit.dart';
import 'instructor_repository.dart';

/// The live class console on the phone (spec 013 §4; spec 014 §8): her video full width with the controls below and
/// the class facts in a sheet. Students' cameras appear only when a student turned hers on.
class ClassConsolePage extends StatelessWidget {
  const ClassConsolePage({required this.classId, super.key, this.repository, this.engines, this.permissions, this.pollEvery = const Duration(seconds: 10)});

  final String classId;
  final InstructorRepository? repository;
  final VideoEngineFactory? engines;
  final DevicePermissions? permissions;
  final Duration? pollEvery;

  @override
  Widget build(BuildContext context) => BlocProvider<ClassConsoleCubit>(
        create: (_) => ClassConsoleCubit(
          repository: repository ?? getIt<InstructorRepository>(),
          engines: engines ?? getIt<VideoEngineFactory>(),
          permissions: permissions ?? getIt<DevicePermissions>(),
          classId: classId,
          pollEvery: pollEvery,
        )..start(),
        child: const _ConsoleView(),
      );
}

class _ConsoleView extends StatefulWidget {
  const _ConsoleView();

  @override
  State<_ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends State<_ConsoleView> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      unawaited(context.read<ClassConsoleCubit>().tick());
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _end(ClassConsoleCubit cubit) async {
    final S s = S.of(context);
    if (!await confirmLeave(context, s, text: s.icEndConfirm, confirm: s.icEnd)) return;
    final Object? e = await cubit.endClass();
    if (mounted) showNote(context, e == null ? s.icEnded : failureText(e, s.commonLoadError));
  }

  String _phase(S s, String key) => switch (key) {
        'menstrual' => s.homePhaseMenstrual,
        'follicular' => s.homePhaseFollicular,
        'ovulatory' => s.homePhaseOvulatory,
        'luteal' => s.homePhaseLuteal,
        _ => key,
      };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<ClassConsoleCubit, ConsoleState>(
      builder: (BuildContext context, ConsoleState st) {
        final ClassConsoleCubit cubit = context.read<ClassConsoleCubit>();
        return AreaScaffold(
          title: s.icOpenRoom,
          body: switch (st.phase) {
            ConsolePhase.loading => LoadingView(label: s.loading),
            ConsolePhase.shut => RoomMessage(title: st.message ?? s.rmClosed, action: st.notOpen ? NSecondaryButton(label: s.csRoomCheckAgain, onPressed: cubit.start) : null),
            ConsolePhase.error => RoomMessage(title: s.rmJoinFailed, action: NSecondaryButton(label: s.tryAgain, onPressed: cubit.start)),
            ConsolePhase.ended => RoomMessage(title: s.icEnded),
            ConsolePhase.dropped || ConsolePhase.left => RoomMessage(
                title: st.phase == ConsolePhase.dropped ? s.rmDropped : s.rmLeft,
                action: NPrimaryButton(label: s.rmRejoin, onPressed: cubit.startClass),
              ),
            ConsolePhase.preview || ConsolePhase.starting => _before(s, st, cubit),
            ConsolePhase.live || ConsolePhase.reconnecting => _live(s, st, cubit),
          },
        );
      },
    );
  }

  Widget _before(S s, ConsoleState st, ClassConsoleCubit cubit) {
    final bool starting = st.phase == ConsolePhase.starting;
    return ListView(
      padding: const EdgeInsets.all(NSpace.lg),
      children: <Widget>[
        Text(s.icCheckBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
        const SizedBox(height: NSpace.sm),
        PermissionStep(access: st.access, asking: st.asking, onAllow: cubit.allowDevices, onSettings: cubit.openSettings),
        if (st.access != null && st.access != MediaAccess.denied) ...<Widget>[
          const SizedBox(height: NSpace.md),
          LocalPreview(engine: cubit.engine, on: st.cameraOn),
          const SizedBox(height: NSpace.sm),
          CallControls(mic: st.mic, camera: st.cameraOn, cameraAllowed: st.access == MediaAccess.granted, onMic: cubit.toggleMic, onCamera: cubit.toggleCamera, onSwitch: cubit.switchCamera),
        ],
        if (st.message != null) Padding(padding: const EdgeInsets.only(top: NSpace.sm), child: Text(st.message!, style: NType.body.copyWith(color: NColors.inkPrimary))),
        const SizedBox(height: NSpace.md),
        NPrimaryButton(label: s.icStart, loading: starting, onPressed: st.access == null || starting ? null : cubit.startClass),
      ],
    );
  }

  Widget _live(S s, ConsoleState st, ClassConsoleCubit cubit) {
    final Json c = st.console;
    final DateTime? endsAt = DateTime.tryParse(c.str('endsAt') ?? '')?.toLocal();
    final RoomTimer? t = endsAt == null ? null : roomTimer(DateTime.now(), endsAt, null);
    final String timer = switch (t) {
      TimerRunning(:final Duration remaining) => s.rmRemaining(clockText(remaining)),
      TimerTimeUp(:final Duration closesIn) => s.rmTimeUp(clockText(closesIn)),
      _ => '',
    };
    final List<String> joined = c.strs('joined');
    final Json phases = c.obj('phaseCounts');
    final VideoEngine? e = cubit.engine;
    final List<MapEntry<String, int?>> cams = st.cameras.entries.where((MapEntry<String, int?> x) => x.value != null).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: VideoStage(
            remote: st.cameraOn && e != null ? e.localView() : null,
            title: s.rmCameraOff,
            note: s.icCheckBody,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (st.phase == ConsolePhase.reconnecting) RoomBanner(title: s.rmReconnecting, body: s.rmReconnectingNote),
              Text(<String>[s.icPresent(c.integer('presentCount')), if (timer.isNotEmpty) timer].join(' · '), textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkPrimary)),
              Text(joined.isEmpty ? s.icNoneJoined : s.icJoined(joined.join(', ')), textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              // Only as the server gives it: with 5 or more present (spec 013 AC5).
              if (phases.isNotEmpty)
                Text(<String>[for (final MapEntry<String, dynamic> p in phases.entries) s.icPhaseCount(_phase(s, p.key), (p.value as num).toInt())].join(' · '),
                    textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              if (cams.isNotEmpty && e != null) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                Text(s.icStudentCameras, style: NType.caption.copyWith(color: NColors.inkMuted)),
                SizedBox(
                  height: 96,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      for (final MapEntry<String, int?> cam in cams)
                        Padding(
                          padding: const EdgeInsets.only(right: NSpace.xs),
                          child: SizedBox(width: 72, child: ClipRRect(borderRadius: BorderRadius.circular(NRadius.sm), child: e.remoteView(cam.key, cam.value!))),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: NSpace.xs),
              CallControls(
                mic: st.mic,
                camera: st.cameraOn,
                cameraAllowed: st.access == MediaAccess.granted,
                onMic: cubit.toggleMic,
                onCamera: cubit.toggleCamera,
                onSwitch: cubit.switchCamera,
                onLeave: () async {
                  if (await confirmLeave(context, s)) await cubit.leave();
                },
              ),
              TextButton(onPressed: () => _end(cubit), child: Text(s.icEnd)),
              const SizedBox(height: NSpace.xs),
            ],
          ),
        ),
      ],
    );
  }
}
