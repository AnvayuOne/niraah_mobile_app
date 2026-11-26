import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/generated/niraah_assets.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_illustration.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../../../shared/helpers/money.dart';
import '../domain/consults.dart';
import 'consult_cubits.dart';
import 'consult_widgets.dart';

/// "Find a specialist" (spec 014 §2; spec 010 §9 rules 1, 2 and 4): approved, bookable clinicians, soonest first,
/// her dedicated clinician first and labelled; filters by type, speciality, language and day; her included consults
/// with how many remain and a pooled booking; the specialist guide, which never changes the order (AC7).
class FindSpecialistPage extends StatelessWidget {
  const FindSpecialistPage({super.key, this.repository});

  final ConsultsRepository? repository;

  @override
  Widget build(BuildContext context) {
    final ConsultsRepository repo = repository ?? getIt<ConsultsRepository>();
    return RepositoryProvider<ConsultsRepository>.value(
      value: repo,
      child: BlocProvider<SpecialistsCubit>(create: (_) => SpecialistsCubit(repo)..load(), child: const _SpecialistsView()),
    );
  }
}

class _SpecialistsView extends StatelessWidget {
  const _SpecialistsView();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.csFindTitle,
      actions: <Widget>[
        IconButton(tooltip: s.csAppointmentsTitle, icon: const Icon(Icons.event_note_rounded), onPressed: () => context.push(RouteConstants.appointments)),
      ],
      body: BlocBuilder<SpecialistsCubit, SpecialistsState>(
        builder: (BuildContext context, SpecialistsState st) {
          final SpecialistsCubit cubit = context.read<SpecialistsCubit>();
          if (st.status == LoadStatus.failure) {
            if (st.error is AreaLocked) return AreaLockedView(refusal: st.error! as AreaLocked);
            return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: cubit.load);
          }
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.md, NSpace.lg, NSpace.xl),
              children: <Widget>[
                const Center(child: NIllustration(asset: NImages.i03FemaleGynecologistClipboard, height: NSpace.xl3 * 2, entrance: NEntrance.float)),
                const ConsultWellnessNote(),
                _GuideCard(onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SpecialistGuidePage(repository: context.read<ConsultsRepository>())))),
                for (final IncludedConsults i in st.included) ...<Widget>[const SizedBox(height: NSpace.sm), _IncludedCard(included: i)],
                const SizedBox(height: NSpace.md),
                _Filters(filters: st.filters, onChange: cubit.load),
                if (st.status == LoadStatus.loading)
                  SizedBox(height: NSpace.xl3 * 2, child: LoadingView(label: s.loading))
                else if (st.specialists.isEmpty)
                  EmptyNote(
                    text: st.filters.isEmpty ? s.csNoneBookable : s.csNoneFound,
                    actionLabel: st.filters.isEmpty ? null : s.csClearFilters,
                    onAction: st.filters.isEmpty ? null : () => cubit.load(const DirectoryFilters()),
                  )
                else
                  for (final Specialist x in st.specialists) ...<Widget>[
                    SpecialistCard(specialist: x, onTap: () => context.push('${RouteConstants.bookDoctor}/${Uri.encodeComponent(x.id)}')),
                    const SizedBox(height: NSpace.sm),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return NCard(
      color: NColors.brandLavenderLight,
      onTap: onTap,
      semanticsLabel: s.csGuideTitle,
      child: Row(
        children: <Widget>[
          const Icon(Icons.explore_outlined, color: NColors.inkSecondary),
          const SizedBox(width: NSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s.csGuideTitle, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                Text(s.csGuideBody, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
        ],
      ),
    );
  }
}

/// Members with included consults see how many remain and that the consult will be with an available clinician
/// (spec 010 §9.2); with none left, the reset date (spec 010 "Limits and plans").
class _IncludedCard extends StatelessWidget {
  const _IncludedCard({required this.included});

  final IncludedConsults included;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String type = typeName(s, included.type);
    return NCard(
      color: NColors.brandSageLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            included.remaining == null ? s.csIncludedUnlimited(type) : s.csIncludedLeft(type, included.remaining!),
            style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: NSpace.xxs),
          if (included.usable) ...<Widget>[
            Text(s.csIncludedPooled(type.toLowerCase()), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push(Uri(path: RouteConstants.bookPooled, queryParameters: <String, String>{'type': included.type}).toString()),
                child: Text(s.csChooseATime),
              ),
            ),
          ] else
            Text(included.refillsAt == null ? s.csIncludedUsedUp : s.csIncludedRefills(shortDate(context, included.refillsAt!)), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
        ],
      ),
    );
  }
}

/// Type, speciality, language and day (spec 014 §2.3). The order is the server's: soonest first.
class _Filters extends StatelessWidget {
  const _Filters({required this.filters, required this.onChange});

  final DirectoryFilters filters;
  final Future<void> Function(DirectoryFilters) onChange;

  DirectoryFilters _with({String? type, bool clearType = false}) =>
      DirectoryFilters(type: clearType ? null : (type ?? filters.type), speciality: filters.speciality, language: filters.language, day: filters.day);

  Future<void> _more(BuildContext context) async {
    final DirectoryFilters? f = await showModalBottomSheet<DirectoryFilters>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MoreFilters(filters: filters),
    );
    if (f != null) await onChange(f);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final int extra = <Object?>[filters.speciality, filters.language, filters.day].whereType<Object>().length;
    return Padding(
      padding: const EdgeInsets.only(bottom: NSpace.sm),
      child: Wrap(
        spacing: NSpace.xs,
        runSpacing: NSpace.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ChoiceChip(label: Text(s.csFilterAll), selected: filters.type == null, onSelected: (_) => onChange(_with(clearType: true))),
          ChoiceChip(label: Text(s.csFilterDoctors), selected: filters.type == 'doctor', onSelected: (_) => onChange(_with(type: 'doctor'))),
          ChoiceChip(label: Text(s.csFilterDietitians), selected: filters.type == 'dietitian', onSelected: (_) => onChange(_with(type: 'dietitian'))),
          ActionChip(avatar: const Icon(Icons.tune_rounded, size: 18), label: Text(extra == 0 ? s.csMoreFilters : s.csMoreFiltersOn(extra)), onPressed: () => _more(context)),
        ],
      ),
    );
  }
}

class _MoreFilters extends StatefulWidget {
  const _MoreFilters({required this.filters});

  final DirectoryFilters filters;

  @override
  State<_MoreFilters> createState() => _MoreFiltersState();
}

class _MoreFiltersState extends State<_MoreFilters> {
  late final TextEditingController _speciality = TextEditingController(text: widget.filters.speciality);
  late final TextEditingController _language = TextEditingController(text: widget.filters.language);
  late String? _day = widget.filters.day;

  @override
  void dispose() {
    _speciality.dispose();
    _language.dispose();
    super.dispose();
  }

  String? _clean(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    String two(int v) => v.toString().padLeft(2, '0');
    return Padding(
      padding: EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, NSpace.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(header: true, child: Text(s.csMoreFilters, style: NType.h4.copyWith(color: NColors.inkPrimary))),
          const SizedBox(height: NSpace.sm),
          TextField(controller: _speciality, maxLength: 60, decoration: InputDecoration(labelText: s.csFilterSpeciality)),
          TextField(controller: _language, maxLength: 30, decoration: InputDecoration(labelText: s.csFilterLanguage)),
          OutlinedButton.icon(
            icon: const Icon(Icons.event_rounded),
            label: Text(_day == null ? s.csFilterDay : s.csFilterDayOn(shortDate(context, _day!))),
            onPressed: () async {
              final DateTime now = DateTime.now();
              final DateTime? d = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: now.add(const Duration(days: 30)));
              if (d != null) setState(() => _day = '${d.year}-${two(d.month)}-${two(d.day)}');
            },
          ),
          const SizedBox(height: NSpace.md),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(DirectoryFilters(type: widget.filters.type, speciality: _clean(_speciality), language: _clean(_language), day: _day)),
            child: Text(s.csApplyFilters),
          ),
          TextButton(onPressed: () => Navigator.of(context).pop(DirectoryFilters(type: widget.filters.type)), child: Text(s.csClearFilters)),
        ],
      ),
    );
  }
}

/// One clinician in the list: name, title, specialities, languages, years, next free time, fee with GST and rating
/// (spec 014 §2.1; spec 010 §9.1). Her dedicated clinician carries the server's label.
class SpecialistCard extends StatelessWidget {
  const SpecialistCard({required this.specialist, required this.onTap, super.key});

  final Specialist specialist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Specialist x = specialist;
    final String name = x.name ?? typeName(s, x.type);
    final List<String> facts = <String>[
      x.title,
      ...x.specialities,
      if (x.yearsExperience != null) s.csYears(x.yearsExperience!),
    ];
    return NCard(
      onTap: onTap,
      semanticsLabel: name,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SpecialistAvatar(name: x.name),
          const SizedBox(width: NSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (x.label != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: NSpace.xxs),
                    child: Text(x.label!, style: NType.caption.copyWith(color: NColors.actionLink, fontWeight: FontWeight.w700)),
                  ),
                Text(name, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                Text(facts.join(' · '), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                if (x.languages.isNotEmpty) Text(s.csSpeaks(x.languages.join(', ')), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                const SizedBox(height: NSpace.xxs),
                if (x.nextSlot != null) Text(s.csNextFree(whenText(context, x.nextSlot!)), style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                Wrap(
                  spacing: NSpace.sm,
                  children: <Widget>[
                    if (x.feePaise != null) Text(s.csFee(rupees(x.feePaise!)), style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                    if (x.ratingCount > 0 && x.ratingAverage != null) Text(s.csRating(x.ratingAverage!.toStringAsFixed(1), x.ratingCount), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
        ],
      ),
    );
  }
}

/// The specialist guide (spec 009 `specialist_guide`; spec 010 §8.10; spec 014 §2.5): which kind of specialist fits
/// her concern. It names a kind, never a person and never a diagnosis, and the list's order is untouched (AC7).
class SpecialistGuidePage extends StatefulWidget {
  const SpecialistGuidePage({required this.repository, super.key});

  final ConsultsRepository repository;

  @override
  State<SpecialistGuidePage> createState() => _SpecialistGuidePageState();
}

class _SpecialistGuidePageState extends State<SpecialistGuidePage> {
  final TextEditingController _concern = TextEditingController();
  SpecialistGuide? _answer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _concern.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _concern.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    setState(() => _busy = true);
    try {
      final SpecialistGuide g = await widget.repository.guide(_concern.text);
      if (mounted) setState(() => _answer = g);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final SpecialistGuide? g = _answer;
    return AreaScaffold(
      title: s.csGuideTitle,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          Text(s.csGuideIntro, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.sm),
          TextField(controller: _concern, maxLength: 500, minLines: 2, maxLines: 5, decoration: InputDecoration(labelText: s.csGuideConcern)),
          const SizedBox(height: NSpace.sm),
          FilledButton(onPressed: _concern.text.trim().isEmpty || _busy ? null : _ask, child: Text(s.csGuideAsk)),
          if (g != null) ...<Widget>[
            NSectionTitle(s.csGuideAnswer),
            if (g.suggestions.isEmpty) EmptyNote(text: s.csGuideNone),
            for (final ({String kind, String reason}) x in g.suggestions) ...<Widget>[
              NCard(
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(x.kind, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                      Text(x.reason, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NSpace.xs),
            ],
            if (g.note.isNotEmpty) Text(g.note, style: NType.caption.copyWith(color: NColors.inkMuted)),
            if (g.madeByModel) Text(s.csGuideByAi, style: NType.caption.copyWith(color: NColors.inkMuted)),
          ],
        ],
      ),
    );
  }
}
