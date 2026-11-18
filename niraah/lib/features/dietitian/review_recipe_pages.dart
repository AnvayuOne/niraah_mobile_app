import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/service_locator.dart';
import '../../design_system/tokens/tokens.dart';
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
        builder: (BuildContext context, List<Json> rows) => rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(NSpace.lg),
                child: EmptyNote(text: s.dtNoLogs),
              )
            : RefreshIndicator(
                onRefresh: () async => setState(() => _queue = _repo.foodLogQueue()),
                child: ListView(
                  padding: const EdgeInsets.all(NSpace.lg),
                  children: <Widget>[
                    for (final Json g in rows) ...<Widget>[
                      NCard(
                        onTap: () => _open(g),
                        semanticsLabel: g.str('member'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(g.str('member') ?? s.drUnnamed, style: NType.body.copyWith(fontWeight: FontWeight.w700)),
                            Text(
                              <String>[
                                shortDate(context, g.str('day') ?? ''),
                                s.dtLogs(g.strs('logIds').length),
                                s.drDue(shortDate(context, g.str('dueAt') ?? '')),
                                if (!g.flag('dedicated')) (g.flag('claimedByMe') ? s.drClaimedByMe : s.drSharedQueue),
                              ].join(' · '),
                              style: NType.caption.copyWith(color: NColors.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: NSpace.xs),
                    ],
                  ],
                ),
              ),
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
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              Text('${d.str('member') ?? ''} · ${shortDate(context, d.str('day') ?? '')}', style: NType.h4),
              if (d.obj('targets').isNotEmpty) Text(s.dtHasTargets, style: NType.caption.copyWith(color: NColors.inkSecondary)),
              if (!canWork) ...<Widget>[
                const SizedBox(height: NSpace.sm),
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
              for (final Json l in d.objs('logs')) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                NCard(
                  color: _done.contains(l.str('id')) ? NColors.brandSageLight : NColors.surfaceCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${slotLabelLog(s, l.str('slot'))} · ${DateFormat.jm(locale).format(DateTime.parse(l.str('at')!).toLocal())}${l.flag('hasPhoto') ? ' · ${s.dtPhoto}' : ''}',
                        style: NType.body.copyWith(fontWeight: FontWeight.w700),
                      ),
                      for (final Json it in l.objs('items'))
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${it.str('name')} · ${it.str('portion') ?? '${it.number('grams')?.toStringAsFixed(0)} g'}${it.flag('corrected') ? ' · ${s.dtCorrectedMark}' : ''}',
                                style: NType.bodySm,
                              ),
                            ),
                            if (canWork) IconButton(tooltip: s.dtCorrect, icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _correct(it)),
                          ],
                        ),
                      Text(nutrientLine(s, l.obj('totals')), style: NType.caption.copyWith(color: NColors.inkSecondary)),
                      if (l.strs('tags').isNotEmpty) Text(l.strs('tags').join(', '), style: NType.caption.copyWith(color: NColors.inkMuted)),
                      if (canWork && !_done.contains(l.str('id')))
                        Wrap(
                          spacing: NSpace.xs,
                          children: <Widget>[
                            OutlinedButton(
                              onPressed: _busy
                                  ? null
                                  : () async {
                                      if (await _run(() => widget.repository.review(l.str('id')!, approve: true), s.dtApproved)) setState(() => _done.add(l.str('id')!));
                                    },
                              child: Text(s.dtApprove),
                            ),
                            TextButton(onPressed: _busy ? null : () => _comment(l.str('id')!), child: Text(s.dtComment)),
                          ],
                        ),
                    ],
                  ),
                ),
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
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _edit(null), icon: const Icon(Icons.add_rounded), label: Text(s.dtNewRecipe)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, 0),
            child: TextField(
              controller: _q,
              onSubmitted: (_) => _reload(),
              decoration: InputDecoration(labelText: s.dtSearchRecipes, prefixIcon: const Icon(Icons.search_rounded)),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: NSpace.lg),
              child: FilterChip(
                label: Text(s.dtMine),
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
              builder: (BuildContext context, List<Json> rows) => rows.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(NSpace.lg),
                      child: EmptyNote(text: s.dtNoRecipes),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, 96),
                      children: <Widget>[
                        for (final Json r in rows)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(r.str('title') ?? ''),
                            subtitle: Text(
                              <String>[r.str('status') == 'draft' ? s.dtPlanDraft : s.dtPublishedLabel, if (r.obj('perServing').isNotEmpty) nutrientLine(s, r.obj('perServing'))].join(' · '),
                            ),
                            onTap: () => _edit(r.str('id')),
                          ),
                      ],
                    ),
            ),
          ),
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
              padding: const EdgeInsets.all(NSpace.lg),
              children: <Widget>[
                if (r != null)
                  Text('${r.str('status') == 'draft' ? s.dtPlanDraft : s.dtPublishedLabel} · ${s.dtVersion(r.integer('version'))}', style: NType.caption.copyWith(color: NColors.inkSecondary)),
                if (r != null && r.str('status') == 'published' && editable) Text(s.dtVersionNote, style: NType.caption.copyWith(color: NColors.inkMuted)),
                TextField(
                  controller: _title,
                  enabled: editable,
                  maxLength: 120,
                  decoration: InputDecoration(labelText: s.dtRecipeTitle),
                ),
                NSectionTitle(s.dtIngredients),
                for (final Json i in _ingredients)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${i.str('name') ?? ''} · ${i.number('grams')?.toStringAsFixed(0)} g'),
                    subtitle: i.flag('requested') ? Text(s.dtRequestedFood) : null,
                    trailing: editable ? IconButton(tooltip: s.drRemoveLine, icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _ingredients.remove(i))) : null,
                  ),
                if (editable) TextButton.icon(onPressed: _addIngredient, icon: const Icon(Icons.add_rounded), label: Text(s.dtAddIngredient)),
                if (r != null && r.obj('perServing').isNotEmpty) Text('${s.dtPerServing}: ${nutrientLine(s, r.obj('perServing'))}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _servings,
                        enabled: editable,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: s.dtServings),
                      ),
                    ),
                    const SizedBox(width: NSpace.sm),
                    Expanded(
                      child: TextField(
                        controller: _time,
                        enabled: editable,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: s.dtMinutes),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: _steps,
                  enabled: editable,
                  minLines: 3,
                  maxLines: 10,
                  decoration: InputDecoration(labelText: s.dtSteps, helperText: s.dtStepsHelp),
                ),
                NSectionTitle(s.dtTags),
                Wrap(
                  spacing: NSpace.xs,
                  runSpacing: NSpace.xs,
                  children: <Widget>[
                    for (final String t in _tags)
                      FilterChip(label: Text(t.replaceAll('_', ' ')), selected: _chosen.contains(t), onSelected: editable ? (bool v) => setState(() => v ? _chosen.add(t) : _chosen.remove(t)) : null),
                  ],
                ),
                if (r != null && r.strs('tags').any((String t) => !_tags.contains(t)))
                  Text(s.dtComputedTags(r.strs('tags').where((String t) => !_tags.contains(t)).join(', ')), style: NType.caption.copyWith(color: NColors.inkSecondary)),
                const SizedBox(height: NSpace.lg),
                if (editable) ...<Widget>[
                  NSecondaryButton(label: s.drSaveDraft, onPressed: _busy ? null : _save),
                  const SizedBox(height: NSpace.xs),
                  if (r == null || r.str('status') == 'draft') NPrimaryButton(label: s.dtPublishRecipe, loading: _busy, onPressed: () => _save(publish: true)),
                ],
              ],
            ),
    );
  }
}

/// Messages for the dietitian (spec 012 §8), the shared thread screens.
Widget dietitianMessages() => const ThreadsPage(clinician: true);
