import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/wellness_advice.dart';

enum AdviceStatus { loading, ready, failure }

class WellnessAdviceState extends Equatable {
  const WellnessAdviceState({this.status = AdviceStatus.loading, this.items = const <WellnessAdvice>[], this.error});

  final AdviceStatus status;
  final List<WellnessAdvice> items;
  final Object? error;

  @override
  List<Object?> get props => <Object?>[status, items, error];
}

/// Her wellness advice, newest first (spec 010 §9.3).
class WellnessAdviceCubit extends Cubit<WellnessAdviceState> {
  WellnessAdviceCubit(this._repo) : super(const WellnessAdviceState());

  final WellnessAdviceRepository _repo;

  Future<void> load() async {
    emit(const WellnessAdviceState());
    try {
      emit(WellnessAdviceState(status: AdviceStatus.ready, items: await _repo.list()));
    } on Object catch (e) {
      emit(WellnessAdviceState(status: AdviceStatus.failure, error: e));
    }
  }
}

/// "Wellness advice from your doctor" (spec 011 §6.1, AC45; spec 010 §9.3), reached from her appointments.
class WellnessAdviceListPage extends StatelessWidget {
  const WellnessAdviceListPage({super.key, this.repository});

  final WellnessAdviceRepository? repository;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final WellnessAdviceRepository repo = repository ?? getIt<WellnessAdviceRepository>();
    return BlocProvider<WellnessAdviceCubit>(
      create: (_) => WellnessAdviceCubit(repo)..load(),
      child: AreaScaffold(
        title: s.waTitle,
        body: BlocBuilder<WellnessAdviceCubit, WellnessAdviceState>(
          builder: (BuildContext context, WellnessAdviceState st) {
            switch (st.status) {
              case AdviceStatus.loading:
                return LoadingView(label: s.loading);
              case AdviceStatus.failure:
                if (st.error is AreaLocked) return AreaLockedView(refusal: st.error! as AreaLocked);
                return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: context.read<WellnessAdviceCubit>().load);
              case AdviceStatus.ready:
                return ListView(
                  padding: const EdgeInsets.all(NSpace.lg),
                  children: <Widget>[
                    if (st.items.isEmpty) EmptyNote(text: s.waEmpty),
                    for (final WellnessAdvice a in st.items) ...<Widget>[
                      NCard(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WellnessAdvicePage(repository: repo, adviceId: a.id))),
                        semanticsLabel: '${a.title}, ${a.stateLabel}',
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(a.issuedAt == null ? a.title : shortDate(context, a.issuedAt!), style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                                  if (a.doctorName != null) Text(a.doctorName!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                                  Text(a.stateLabel, style: NType.caption.copyWith(color: NColors.inkMuted)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
                          ],
                        ),
                      ),
                      const SizedBox(height: NSpace.xs),
                    ],
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}

/// One wellness advice: the doctor and registration, assessment, supplements with how to take them, advice, when to
/// see a doctor in person, follow-up, tests advised, the wellness statement, and the signed document.
class WellnessAdvicePage extends StatefulWidget {
  const WellnessAdvicePage({required this.adviceId, super.key, this.repository});

  final String adviceId;
  final WellnessAdviceRepository? repository;

  @override
  State<WellnessAdvicePage> createState() => _WellnessAdvicePageState();
}

class _WellnessAdvicePageState extends State<WellnessAdvicePage> {
  late final WellnessAdviceRepository _repo = widget.repository ?? getIt<WellnessAdviceRepository>();
  late Future<WellnessAdvice> _advice = _repo.get(widget.adviceId);
  bool _opening = false;

  Future<void> _open() async {
    final S s = S.of(context);
    setState(() => _opening = true);
    try {
      final String url = await _repo.documentUrl(widget.adviceId);
      final bool ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok && mounted) showNote(context, s.commonLoadError);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Widget _block(String title, String? text) => text == null || text.isEmpty
      ? const SizedBox.shrink()
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            NSectionTitle(title),
            Text(text, style: NType.body.copyWith(color: NColors.inkPrimary)),
          ],
        );

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.waTitle,
      body: AsyncBody<WellnessAdvice>(
        future: _advice,
        onRetry: () => setState(() => _advice = _repo.get(widget.adviceId)),
        builder: (BuildContext context, WellnessAdvice a) => ListView(
          padding: const EdgeInsets.all(NSpace.lg),
          children: <Widget>[
            Semantics(header: true, child: Text(a.title, style: NType.h3.copyWith(color: NColors.inkPrimary))),
            Text(<String>[a.stateLabel, if (a.issuedAt != null) shortDate(context, a.issuedAt!)].join(' · '), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            if (!a.current) Text(s.waReplaced, style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
            const SizedBox(height: NSpace.sm),
            if (a.doctorName != null) Text(<String>[a.doctorName!, if (a.doctorQualification != null) a.doctorQualification!].join(', '), style: NType.body.copyWith(color: NColors.inkPrimary)),
            if (a.registrationNumber != null) Text(s.csRegistration(a.registrationNumber!, a.council ?? ''), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            _block(s.waAssessment, a.assessment),
            if (a.supplements.isNotEmpty) ...<Widget>[
              NSectionTitle(s.waSupplements),
              for (final AdviceSupplement x in a.supplements)
                Padding(
                  padding: const EdgeInsets.only(bottom: NSpace.sm),
                  child: MergeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(<String>[x.name, if (x.form != null) x.form!, if (x.strength != null) x.strength!].join(' · '), style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                        Text(<String>[if (x.dosePattern != null) x.dosePattern!, if (x.timing != null) x.timing!, if (x.duration != null) x.duration!].join(' · '), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                        if (x.instructions != null) Text(x.instructions!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                      ],
                    ),
                  ),
                ),
            ],
            _block(s.waAdvice, a.advice),
            _block(s.waSeeDoctor, a.seeDoctorLine),
            if (a.followUpOn != null) _block(s.waFollowUp, shortDate(context, a.followUpOn!)),
            if (a.testsAdvised.isNotEmpty) _block(s.waTests, a.testsAdvised.join(', ')),
            const SizedBox(height: NSpace.md),
            if (a.wellnessStatement.isNotEmpty) Text(a.wellnessStatement, style: NType.caption.copyWith(color: NColors.inkMuted)),
            if (a.verificationCode != null) Text(s.waCode(a.verificationCode!), style: NType.caption.copyWith(color: NColors.inkMuted)),
            const SizedBox(height: NSpace.md),
            NSecondaryButton(label: s.waOpenDocument, onPressed: _opening ? null : _open),
          ],
        ),
      ),
    );
  }
}
