import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/consults.dart';

/// Her consult transcript (spec 014 §5 "Reading a transcript" 1, 5, 8; constitution §7.13): fetched only when she opens
/// it, shown as text marked machine-made and unverified, her lines as "You" and the clinician's by role, never by name.
/// Nothing here can be downloaded.
class TranscriptPage extends StatefulWidget {
  const TranscriptPage({required this.appointmentId, super.key, this.repository});

  final String appointmentId;
  final ConsultsRepository? repository;

  @override
  State<TranscriptPage> createState() => _TranscriptPageState();
}

class _TranscriptPageState extends State<TranscriptPage> {
  late Future<ConsultTranscript> _load;

  ConsultsRepository get _repo => widget.repository ?? getIt<ConsultsRepository>();

  @override
  void initState() {
    super.initState();
    _load = _repo.transcript(widget.appointmentId);
  }

  static String speakerName(S s, String speaker) => switch (speaker) {
        'member' => s.csTranscriptYou,
        'doctor' => s.csTranscriptDoctor,
        'dietitian' => s.csTranscriptDietitian,
        _ => s.csTranscriptMember,
      };

  static String? _clock(double? seconds) {
    if (seconds == null) return null;
    final int t = seconds.floor();
    return '${t ~/ 60}:${(t % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.csTranscriptTitle,
      body: FutureBuilder<ConsultTranscript>(
        future: _load,
        builder: (BuildContext context, AsyncSnapshot<ConsultTranscript> snap) {
          if (snap.hasError) {
            return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: () => setState(() => _load = _repo.transcript(widget.appointmentId)));
          }
          final ConsultTranscript? t = snap.data;
          if (t == null) return LoadingView(label: s.loading);
          final String? state = switch (t.status) {
            'pending' => s.csTranscriptPending,
            'failed' => s.csTranscriptFailed,
            'none' => s.csTranscriptNone,
            _ => null,
          };
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              if (state != null)
                Text(state, style: NType.body.copyWith(color: NColors.inkSecondary))
              else ...<Widget>[
                NCard(
                  color: NColors.surfaceWarm,
                  child: Semantics(
                    label: s.csTranscriptUnverified,
                    child: Text(s.csTranscriptUnverified, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                  ),
                ),
                if (t.partial) Padding(padding: const EdgeInsets.only(top: NSpace.xs), child: Text(s.csTranscriptPartial, style: NType.bodySm.copyWith(color: NColors.inkMuted))),
                for (final String m in t.missing)
                  Text(s.csTranscriptMissing(speakerName(s, m).toLowerCase()), style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                const SizedBox(height: NSpace.sm),
                for (final TranscriptLine l in t.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: NSpace.xs),
                    child: NCard(
                      color: NColors.surfaceCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            <String>[speakerName(s, l.speaker), ?_clock(l.startSeconds)].join('  ·  '),
                            style: NType.caption.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: NSpace.xxs),
                          Text(l.text, style: NType.body.copyWith(color: NColors.inkPrimary)),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
