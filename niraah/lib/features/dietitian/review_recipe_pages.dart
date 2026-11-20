import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/service_locator.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/clinician_ui.dart';
import '../../design_system/widgets/n_button.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/area/area_access.dart';
import '../../shared/area/area_widgets.dart';
import '../doctor/presentation/patients_pages.dart';
import '../messaging/messaging.dart';
import '../provider_work/domain/provider_work.dart';
import 'dietitian_pages.dart';
import 'dietitian_repository.dart';
import 'meal_plan_pages.dart';

/// The food-log review queue (spec 012 §5): days of logs by member, oldest first. Her dedicated clients' days are
/// hers; a consult client's day is taken from the shared queue first.
class FoodLogQueuePage extends StatefulWidget {
  const FoodLogQueuePage({super.key, this.repository});

  final DietitianRepository? repository;

  @override
  State<FoodLogQueuePage> createState() => _FoodLogQueuePageState();
}

class _FoodLogQueuePageState extends State<FoodLogQueuePage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  late Future<List<Json>> _queue = _repo.foodLogQueue();

  Future<void> _open(Json g) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FoodLogDayPage(memberId: g.str('memberId')!, day: g.str('day')!, repository: _repo),
      ),
    );
    if (mounted) setState(() => _queue = _repo.foodLogQueue());
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return DietitianShell(
      index: 2,
      title: s.dtReview,
      body: AsyncBody<List<Json>>(
        future: _queue,
        onRetry: () => setState(() => _queue = _repo.foodLogQueue()),
        builder: (BuildContext context, List<Json> rows) {
          final int dedicated = rows.where((Json g) => g.flag('dedicated')).length;
          final int meals = rows.fold<int>(0, (int a, Json g) => a + g.strs('logIds').length);
          return RefreshIndicator(
            onRefresh: () async => setState(() => _queue = _repo.foodLogQueue()),
            child: ListView(
              padding: dtPagePadding,
              children: <Widget>[
                CHero(
                  eyebrow: s.dtReview,
                  title: s.dtQueueCount(rows.length),
                  subtitle: s.dtQueueSubtitle,
                  child: CStatGrid(
                    children: <Widget>[
                      CHeroStat(label: s.dtMealsLabel, value: '$meals', icon: Icons.restaurant_menu_rounded),
                      CHeroStat(label: s.drRelDedicated, value: '$dedicated', icon: Icons.favorite_border_rounded),
                      CHeroStat(label: s.drSharedQueue, value: '${rows.length - dedicated}', icon: Icons.groups_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.md),
                if (rows.isEmpty) CEmpty(icon: Icons.task_alt_rounded, title: s.dtNoLogs),
                for (int i = 0; i < rows.length; i++)
                  CEntrance(
                    delayMs: 40 * i.clamp(0, 8),
                    child: Padding(padding: const EdgeInsets.only(bottom: NSpace.xs), child: _row(s, rows[i])),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(S s, Json g) {
    final String name = g.str('member') ?? s.drUnnamed;
    return DtCard(
      onTap: () => _open(g),
      semanticsLabel: g.str('member'),
      child: Row(
        children: <Widget>[
          CAvatar(name: name, size: 44),
          const SizedBox(width: NSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                Text(
                  '${shortDate(context, g.str('day') ?? '')} · ${s.drDue(shortDate(context, g.str('dueAt') ?? ''))}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NType.bodySm.copyWith(color: NColors.inkMuted),
                ),
                const SizedBox(height: NSpace.xxs),
                Wrap(
                  spacing: NSpace.xxs,
                  runSpacing: NSpace.xxs,
                  children: <Widget>[
                    CPill(s.dtLogs(g.strs('logIds').length), tone: CTone.plum),
                    if (!g.flag('dedicated')) CPill(g.flag('claimedByMe') ? s.drClaimedByMe : s.drSharedQueue, tone: g.flag('claimedByMe') ? CTone.sage : CTone.lavender),
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

/// One member's day (spec 012 §5 rules 2–5): each log with its dishes, computed nutrients and rule tags, her targets;
/// approve, comment (checked before sending), approve the whole day, correct a dish.
class FoodLogDayPage extends StatefulWidget {
  const FoodLogDayPage({required this.memberId, required this.day, required this.repository, super.key});

  final String memberId;
  final String day;
  final DietitianRepository repository;

  @override
  State<FoodLogDayPage> createState() => _FoodLogDayPageState();
}

class _FoodLogDayPageState extends State<FoodLogDayPage> {
  late Future<Json> _day = widget.repository.foodLogDay(widget.memberId, widget.day);
  final Set<String> _done = <String>{};
  bool _busy = false;

  Future<bool> _run(Future<void> Function() f, String done) async {
    setState(() => _busy = true);
    try {
      await f();
      if (mounted) showNote(context, done);
      return true;
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _comment(String logId) async {
    final S s = S.of(context);
    final String? text = await promptText(context, s.dtComment, s.dtCommentHint, maxLength: 280);
    if (text == null) return;
    if (await _run(() => widget.repository.review(logId, approve: false, comment: text), s.dtCommented)) setState(() => _done.add(logId));
  }

  Future<void> _correct(Json item) async {
    final S s = S.of(context);
    final Json? pick = await showModalBottomSheet<Json>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DishPicker(repository: widget.repository, foodsOnly: true),
    );
    if (pick == null || pick.str('kind') != 'food' || !mounted) return;
    final TextEditingController c = TextEditingController(text: '1');
    String unit = 'katori';
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => StatefulBuilder(
        builder: (BuildContext d, StateSetter set) => AlertDialog(
          title: Text(s.dtCorrectTo(pick.str('name') ?? '')),
          content: Row(
            children: <Widget>[
              SizedBox(
                width: 72,
                child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              ),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: DropdownButton<String>(
                  value: unit,
                  isExpanded: true,
                  items: <DropdownMenuItem<String>>[for (final String x in planUnits) DropdownMenuItem<String>(value: x, child: Text(x))],
                  onChanged: (String? v) => set(() => unit = v ?? unit),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.drSave)),
          ],
        ),
      ),
    );
    final double? count = double.tryParse(c.text.trim());
    c.dispose();
    if (ok != true || count == null) return;
    try {
      final Json d = await widget.repository.correct(item.str('id')!, foodId: pick.str('id'), count: count, unit: unit);
      if (!mounted) return;
      setState(() => _day = Future<Json>.value(d));
      showNote(context, s.dtCorrected);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    return AreaScaffold(
      title: s.dtReview,
      body: AsyncBody<Json>(
        future: _day,
        onRetry: () => setState(() => _day = widget.repository.foodLogDay(widget.memberId, widget.day)),
        builder: (BuildContext context, Json d) {
          final bool canWork = d.flag('dedicated') || d.flag('claimedByMe');
          final List<Json> logs = d.objs('logs');
          return ListView(
            padding: dtPagePadding,
            children: <Widget>[
              CHero(
                eyebrow: s.dtReview,
                title: d.str('member') ?? '',
                subtitle: shortDate(context, d.str('day') ?? ''),
                trailing: Wrap(
                  spacing: NSpace.xxs,
                  runSpacing: NSpace.xxs,
                  children: <Widget>[
                    CPill(s.dtLogs(logs.length), tone: CTone.plum),
                    if (d.obj('targets').isNotEmpty) CPill(s.dtHasTargets, tone: CTone.sage),
                  ],
                ),
              ),
              if (!canWork) ...<Widget>[
                const SizedBox(height: NSpace.md),
                NPrimaryButton(
                  label: s.dtTakeDay,
                  loading: _busy,
                  onPressed: () async {
                    try {
                      final Json r = await widget.repository.claimDay(widget.memberId, widget.day);
                      if (mounted) setState(() => _day = Future<Json>.value(r));
                    } on Object catch (e) {
                      if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
                    }
                  },
                ),
              ],
              for (int i = 0; i < logs.length; i++) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                CEntrance(delayMs: 40 * i.clamp(0, 6), child: _log(s, locale, logs[i], canWork)),
              ],
              const SizedBox(height: NSpace.lg),
              if (canWork)
                NPrimaryButton(
                  label: s.dtApproveDay,
                  loading: _busy,
                  onPressed: () async {
                    if (await _run(() => widget.repository.approveDay(widget.memberId, widget.day), s.dtDayApproved) && context.mounted) Navigator.of(context).pop();
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _log(S s, String locale, Json l, bool canWork) {
    final bool done = _done.contains(l.str('id'));
    return DtCard(
      tint: done ? NColors.brandSageLight.withValues(alpha: 0.6) : null,
      border: done ? NColors.brandSage : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              DtIconChip(icon: _slotIcon(l.str('slot')), size: 34),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Text(
                  '${slotLabelLog(s, l.str('slot'))} · ${DateFormat.jm(locale).format(DateTime.parse(l.str('at')!).toLocal())}${l.flag('hasPhoto') ? ' · ${s.dtPhoto}' : ''}',
                  style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                ),
              ),
              if (done) const Icon(Icons.check_circle_rounded, color: NColors.statusSuccess),
            ],
          ),
          const SizedBox(height: NSpace.xs),
          for (final Json it in l.objs('items'))
            Container(
              margin: const EdgeInsets.only(bottom: NSpace.xxs),
              padding: const EdgeInsets.only(left: NSpace.sm),
              decoration: BoxDecoration(color: NColors.surfacePage, borderRadius: BorderRadius.circular(NRadius.md)),
              constraints: const BoxConstraints(minHeight: 40),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${it.str('name')} · ${it.str('portion') ?? '${it.number('grams')?.toStringAsFixed(0)} g'}${it.flag('corrected') ? ' · ${s.dtCorrectedMark}' : ''}',
                      style: NType.bodySm.copyWith(color: NColors.inkPrimary),
                    ),
                  ),
                  if (canWork) IconButton(tooltip: s.dtCorrect, icon: const Icon(Icons.edit_outlined, size: 18, color: NColors.inkSecondary), onPressed: () => _correct(it)),
                ],
              ),
            ),
          const SizedBox(height: NSpace.xs),
          MacroSplit(nutrients: l.obj('totals'), compact: true),
          if (l.strs('tags').isNotEmpty) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            Semantics(
              label: l.strs('tags').join(', '),
              excludeSemantics: true,
              child: Wrap(spacing: NSpace.xxs, runSpacing: NSpace.xxs, children: <Widget>[for (final String t in l.strs('tags')) CPill(t, tone: CTone.rose)]),
            ),
          ],
          if (canWork && !done)
            Padding(
              padding: const EdgeInsets.only(top: NSpace.sm),
              child: Row(
                children: <Widget>[
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(backgroundColor: NColors.brandSageLight, foregroundColor: NColors.statusSuccess),
                    onPressed: _busy
                        ? null
                        : () async {
                            if (await _run(() => widget.repository.review(l.str('id')!, approve: true), s.dtApproved)) setState(() => _done.add(l.str('id')!));
                          },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(s.dtApprove),
                  ),
                  const SizedBox(width: NSpace.xs),
                  TextButton.icon(onPressed: _busy ? null : () => _comment(l.str('id')!), icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18), label: Text(s.dtComment)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _slotIcon(String? k) => switch (k) {
    'breakfast' => Icons.free_breakfast_outlined,
    'lunch' => Icons.lunch_dining_outlined,
    'dinner' => Icons.dinner_dining_outlined,
    'snack' => Icons.cookie_outlined,
    _ => Icons.restaurant_outlined,
  };
}

String slotLabelLog(S s, String? k) => switch (k) {
  'breakfast' => s.mealsSlotBreakfast,
  'lunch' => s.mealsSlotLunch,
  'dinner' => s.mealsSlotDinner,
  'snack' => s.mealsSlotSnack,
  _ => k ?? '',
};

/// The recipe library (spec 012 §6): published recipes from every dietitian and her drafts.
class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key, this.repository});

  final DietitianRepository? repository;

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  final TextEditingController _q = TextEditingController();
  bool _mine = false;
  late Future<List<Json>> _list = _repo.recipes();

  void _reload() => setState(() => _list = _repo.recipes(search: _q.text, mine: _mine));

  Future<void> _edit(String? id) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeEditorPage(recipeId: id, repository: _repo),
      ),
    );
    if (mounted) _reload();
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.dtRecipes,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CRole.of(context).accent,
        foregroundColor: NColors.inkPrimary,
        onPressed: () => _edit(null),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.dtNewRecipe),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, 0),
            child: DtSearchField(controller: _q, label: s.dtSearchRecipes, onSubmitted: (_) => _reload()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DtChip(
                label: s.dtMine,
                selected: _mine,
                onSelected: (bool v) => setState(() {
                  _mine = v;
                  _list = _repo.recipes(search: _q.text, mine: v);
                }),
              ),
            ),
          ),
          Expanded(
            child: AsyncBody<List<Json>>(
              future: _list,
              onRetry: _reload,
              builder: (BuildContext context, List<Json> rows) => ListView(
                padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.md, 96),
                children: <Widget>[
                  if (rows.isEmpty) CEmpty(icon: Icons.menu_book_outlined, title: s.dtNoRecipes),
                  for (int i = 0; i < rows.length; i++)
                    CEntrance(
                      delayMs: 40 * i.clamp(0, 8),
                      child: Padding(padding: const EdgeInsets.only(bottom: NSpace.xs), child: _card(s, rows[i])),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(S s, Json r) {
    final bool draft = r.str('status') == 'draft';
    return DtCard(
      onTap: () => _edit(r.str('id')),
      semanticsLabel: <String>[r.str('title') ?? '', draft ? s.dtPlanDraft : s.dtPublishedLabel, if (r.obj('perServing').isNotEmpty) nutrientLine(s, r.obj('perServing'))].join(' · '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const DtIconChip(icon: Icons.ramen_dining_outlined, size: 40),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Text(r.str('title') ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: NSpace.xs),
              CPill(draft ? s.dtPlanDraft : s.dtPublishedLabel, tone: draft ? CTone.apricot : CTone.sage),
            ],
          ),
          if (r.obj('perServing').isNotEmpty) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            MacroSplit(nutrients: r.obj('perServing'), compact: true),
          ],
        ],
      ),
    );
  }
}

/// Writing a recipe (spec 012 §6): ingredients from the food table with grams (or a requested food), steps,
/// servings, time and the tags of judgement. Nutrients and number tags are computed by the server.
class RecipeEditorPage extends StatefulWidget {
  const RecipeEditorPage({required this.recipeId, required this.repository, super.key});

  final String? recipeId;
  final DietitianRepository repository;

  @override
  State<RecipeEditorPage> createState() => _RecipeEditorPageState();
}

class _RecipeEditorPageState extends State<RecipeEditorPage> {
  static const List<String> _tags = <String>[
    'breakfast',
    'lunch',
    'dinner',
    'evening_snack',
    'vegetarian',
    'vegan',
    'jain',
    'eggetarian',
    'non_vegetarian',
    'north_indian',
    'south_indian',
    'east_indian',
    'west_indian',
    'pregnancy_safe',
  ];
  late String? _id = widget.recipeId;
  Json? _recipe;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _steps = TextEditingController();
  final TextEditingController _servings = TextEditingController(text: '1');
  final TextEditingController _time = TextEditingController();
  final List<Json> _ingredients = <Json>[];
  final Set<String> _chosen = <String>{};
  bool _loading = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (_id != null) _load();
  }

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[_title, _steps, _servings, _time]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(Json r) {
    _recipe = r;
    _id = r.str('id');
    _title.text = r.str('title') ?? '';
    _steps.text = r.strs('steps').join('\n');
    _servings.text = '${r.integer('servings')}';
    _time.text = r.number('timeMinutes')?.toStringAsFixed(0) ?? '';
    _ingredients
      ..clear()
      ..addAll(r.objs('ingredients'));
    _chosen
      ..clear()
      ..addAll(r.strs('tags').where(_tags.contains));
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final Json r = await widget.repository.recipe(_id!);
      if (mounted) setState(() => _fill(r));
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addIngredient() async {
    final S s = S.of(context);
    final Json? pick = await showModalBottomSheet<Json>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DishPicker(repository: widget.repository, foodsOnly: true),
    );
    if (pick == null || !mounted) return;
    final TextEditingController g = TextEditingController(text: '100');
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text(pick.str('name') ?? ''),
        content: TextField(
          controller: g,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: s.dtGrams),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.drSave)),
        ],
      ),
    );
    final double? grams = double.tryParse(g.text.trim());
    g.dispose();
    if (ok != true || grams == null || grams <= 0) return;
    setState(
      () => _ingredients.add(
        pick.str('kind') == 'request'
            ? <String, dynamic>{'requestId': pick.str('id'), 'name': pick.str('name'), 'grams': grams, 'requested': true}
            : <String, dynamic>{'foodId': pick.str('id'), 'name': pick.str('name'), 'grams': grams},
      ),
    );
  }

  Future<void> _save({bool publish = false}) async {
    final S s = S.of(context);
    final int? servings = int.tryParse(_servings.text.trim());
    if (_title.text.trim().isEmpty || _ingredients.isEmpty || servings == null || servings < 1) {
      showNote(context, s.dtRecipeIncomplete);
      return;
    }
    setState(() => _busy = true);
    try {
      Json r = await widget.repository.saveRecipe(_id, <String, dynamic>{
        'title': _title.text.trim(),
        'ingredients': <Json>[
          for (final Json i in _ingredients)
            if (i.str('foodId') != null)
              <String, dynamic>{'foodId': i.str('foodId'), 'grams': i.number('grams')}
            else
              <String, dynamic>{'requestId': i.str('requestId'), 'name': i.str('name'), 'grams': i.number('grams')},
        ],
        'steps': _steps.text.split('\n').map((String x) => x.trim()).where((String x) => x.isNotEmpty).toList(),
        'servings': servings,
        'timeMinutes': int.tryParse(_time.text.trim()),
        'tags': _chosen.toList(),
      });
      if (publish) r = await widget.repository.publishRecipe(r.str('id')!);
      if (!mounted) return;
      setState(() => _fill(r));
      showNote(context, publish ? s.dtRecipePublished : s.drSaved);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Json? r = _recipe;
    final bool editable = r == null || (r.flag('mine') && r.str('status') != 'withdrawn');
    return AreaScaffold(
      title: r == null ? s.dtNewRecipe : s.dtRecipe,
      body: _loading
          ? Center(child: Text(s.loading))
          : ListView(
              padding: dtPagePadding,
              children: <Widget>[
                if (r != null) ...<Widget>[
                  Wrap(
                    spacing: NSpace.xxs,
                    runSpacing: NSpace.xxs,
                    children: <Widget>[
                      CPill(r.str('status') == 'draft' ? s.dtPlanDraft : s.dtPublishedLabel, tone: r.str('status') == 'draft' ? CTone.apricot : CTone.sage),
                      CPill(s.dtVersion(r.integer('version'))),
                    ],
                  ),
                  if (r.str('status') == 'published' && editable) ...<Widget>[
                    const SizedBox(height: NSpace.xxs),
                    Text(s.dtVersionNote, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                  ],
                  const SizedBox(height: NSpace.sm),
                ],
                CPanel(
                  title: s.dtRecipe,
                  icon: Icons.ramen_dining_outlined,
                  child: Column(
                    children: <Widget>[
                      TextField(controller: _title, enabled: editable, maxLength: 120, decoration: InputDecoration(labelText: s.dtRecipeTitle)),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(controller: _servings, enabled: editable, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: s.dtServings)),
                          ),
                          const SizedBox(width: NSpace.sm),
                          Expanded(
                            child: TextField(controller: _time, enabled: editable, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: s.dtMinutes)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.dtIngredients,
                  icon: Icons.eco_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final Json i in _ingredients)
                        Container(
                          margin: const EdgeInsets.only(bottom: NSpace.xxs),
                          padding: const EdgeInsets.only(left: NSpace.sm),
                          constraints: const BoxConstraints(minHeight: 44),
                          decoration: BoxDecoration(color: NColors.surfacePage, borderRadius: BorderRadius.circular(NRadius.md)),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('${i.str('name') ?? ''} · ${i.number('grams')?.toStringAsFixed(0)} g', style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                                    if (i.flag('requested')) Text(s.dtRequestedFood, style: NType.caption.copyWith(color: NColors.statusWarningText, letterSpacing: 0)),
                                  ],
                                ),
                              ),
                              if (editable)
                                IconButton(tooltip: s.drRemoveLine, icon: const Icon(Icons.close_rounded, size: 18, color: NColors.inkMuted), onPressed: () => setState(() => _ingredients.remove(i))),
                            ],
                          ),
                        ),
                      if (editable) TextButton.icon(onPressed: _addIngredient, icon: const Icon(Icons.add_rounded), label: Text(s.dtAddIngredient)),
                      if (r != null && r.obj('perServing').isNotEmpty) ...<Widget>[
                        const SizedBox(height: NSpace.xs),
                        Text(s.dtPerServing, style: NType.caption.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w700, letterSpacing: 0)),
                        const SizedBox(height: NSpace.xs),
                        MacroSplit(nutrients: r.obj('perServing')),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.dtSteps,
                  icon: Icons.format_list_numbered_rounded,
                  child: TextField(controller: _steps, enabled: editable, minLines: 3, maxLines: 10, decoration: InputDecoration(labelText: s.dtSteps, helperText: s.dtStepsHelp)),
                ),
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.dtTags,
                  icon: Icons.sell_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        runSpacing: NSpace.xs,
                        children: <Widget>[
                          for (final String t in _tags)
                            DtChip(label: t.replaceAll('_', ' '), selected: _chosen.contains(t), onSelected: editable ? (bool v) => setState(() => v ? _chosen.add(t) : _chosen.remove(t)) : null),
                        ],
                      ),
                      if (r != null && r.strs('tags').any((String t) => !_tags.contains(t))) ...<Widget>[
                        const SizedBox(height: NSpace.xs),
                        Text(s.dtComputedTags(r.strs('tags').where((String t) => !_tags.contains(t)).join(', ')), style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.lg),
                if (editable) ...<Widget>[
                  if (r == null || r.str('status') == 'draft') ...<Widget>[NPrimaryButton(label: s.dtPublishRecipe, loading: _busy, onPressed: () => _save(publish: true)), const SizedBox(height: NSpace.xs)],
                  NSecondaryButton(label: s.drSaveDraft, onPressed: _busy ? null : _save),
                ],
              ],
            ),
    );
  }
}

/// Messages for the dietitian (spec 012 §8), the shared thread screens.
Widget dietitianMessages() => const ThreadsPage(clinician: true);
