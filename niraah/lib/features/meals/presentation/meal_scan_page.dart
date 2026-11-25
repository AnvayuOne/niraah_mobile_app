import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/generated/niraah_assets.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../design_system/widgets/n_illustration.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/meals.dart';
import 'meal_widgets.dart';
import 'scan_fx.dart';

/// The meal scanner (spec 010 §6 rules 1, 2, 4; spec 009 "Meal scan"): photo → the AI names the dishes and
/// portions → she checks and corrects them → saved. Nutrients come from the food table on the server.
class MealScanPage extends StatefulWidget {
  const MealScanPage({super.key, this.repository, this.picker});

  final MealsRepository? repository;
  final ImagePicker? picker;

  @override
  State<MealScanPage> createState() => _MealScanPageState();
}

/// One dish as she is editing it: a food from the table, or one she still has to choose.
class _Line {
  _Line({this.food, this.label, required this.count, required this.unit, this.nutrients});

  FoodRef? food;
  String? label;
  double count;
  String unit;

  /// From the scan, for the dish as scanned; cleared when she changes the dish or portion.
  Nutrients? nutrients;
}

enum _Step { pick, reading, review, saving, saved, message }

class _MealScanPageState extends State<MealScanPage> {
  late final MealsRepository _repo = widget.repository ?? getIt<MealsRepository>();
  late final ImagePicker _picker = widget.picker ?? ImagePicker();

  _Step _step = _Step.pick;
  Uint8List? _photo;
  List<_Line> _lines = <_Line>[];
  List<String> _tags = <String>[];
  MealSlot _slot = slotForNow(DateTime.now());
  String? _message;
  Meal? _saved;

  @override
  void initState() {
    super.initState();
    // The camera opens straight away; the choices stay on screen if she backs out of it.
    if (widget.picker == null) WidgetsBinding.instance.addPostFrameCallback((_) => _pick(ImageSource.camera));
  }

  Future<void> _pick(ImageSource source) async {
    // Kept small for upload: the scan needs the plate, not every pixel.
    final XFile? file = await _picker.pickImage(source: source, maxWidth: 1600, maxHeight: 1600, imageQuality: 80);
    if (file == null) return;
    final Uint8List bytes = await file.readAsBytes();
    setState(() {
      _photo = bytes;
      _step = _Step.reading;
    });
    await _scan(bytes);
  }

  Future<void> _scan(Uint8List bytes) async {
    final S s = S.of(context);
    try {
      final ScanResult r = await _repo.scan(base64Encode(bytes));
      if (!mounted) return;
      setState(() {
        switch (r) {
          case ScanOk(:List<ScanItem> items, :List<String> tags):
            _lines = <_Line>[
              for (ScanItem i in items)
                switch (i) {
                  MatchedItem(:FoodRef food, :Nutrients nutrients) => _Line(food: food, count: i.count, unit: i.unit, nutrients: nutrients),
                  NotSureItem(:String label) => _Line(label: label, count: i.count, unit: i.unit),
                },
            ];
            _tags = tags;
            _step = _Step.review;
          case ScanNoFood(:String message):
            _message = message;
            _step = _Step.message;
          case ScanLimit():
            _message = s.mealsLimit;
            _step = _Step.message;
          case ScanUnavailable():
            _message = s.mealsUnavailable;
            _step = _Step.message;
        }
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
        _step = _Step.message;
      });
    }
  }

  Future<void> _chooseFood(_Line line) async {
    final FoodOption? f = await showModalBottomSheet<FoodOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NColors.surfaceCard,
      builder: (_) => _FoodSearchSheet(repo: _repo),
    );
    if (f == null) return;
    setState(() {
      line
        ..food = FoodRef(id: f.id, name: f.name)
        ..label = null
        ..nutrients = null;
    });
  }

  Future<void> _save() async {
    setState(() => _step = _Step.saving);
    try {
      final Meal meal = await _repo.save(
        eatenAt: DateTime.now(),
        slot: _slot,
        fromScan: true,
        items: <MealItemInput>[for (final _Line l in _lines) MealItemInput(foodId: l.food!.id, count: l.count, unit: l.unit)],
      );
      if (!mounted) return;
      setState(() {
        _saved = meal;
        _step = _Step.saved;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _step = _Step.review);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  void _restart() => setState(() {
    _step = _Step.pick;
    _photo = null;
    _lines = <_Line>[];
    _tags = <String>[];
    _message = null;
    _saved = null;
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      appBar: AppBar(title: Text(s.mealsScanAction), backgroundColor: NColors.surfacePage),
      body: SafeArea(
        child: switch (_step) {
          _Step.pick => _pickView(s),
          _Step.reading => _readingView(s),
          _Step.review || _Step.saving => _reviewView(s),
          _Step.saved => _savedView(s),
          _Step.message => _messageView(s),
        },
      ),
    );
  }

  Widget _photoBox() => _photo == null
      ? const SizedBox.shrink()
      : ClipRRect(
          borderRadius: BorderRadius.circular(NRadius.xl),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.memory(_photo!, fit: BoxFit.cover),
          ),
        );

  Widget _pickView(S s) => ListView(
    padding: const EdgeInsets.all(NSpace.lg),
    children: <Widget>[
      Container(
        padding: const EdgeInsets.all(NSpace.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[NColors.brandApricotLight, NColors.brandBlushLight]),
          borderRadius: BorderRadius.circular(NRadius.xl),
        ),
        child: Column(
          children: <Widget>[
            const NLottie(path: NLotties.nutrition, size: 180),
            const SizedBox(height: NSpace.sm),
            Text(
              s.mealsScanIntro,
              textAlign: TextAlign.center,
              style: NType.body.copyWith(color: NColors.inkPrimary),
            ),
          ],
        ),
      ),
      const SizedBox(height: NSpace.lg),
      NPrimaryButton(label: s.mealsTakePhoto, onPressed: () => _pick(ImageSource.camera)),
      const SizedBox(height: NSpace.sm),
      NSecondaryButton(label: s.mealsChoosePhoto, onPressed: () => _pick(ImageSource.gallery)),
    ],
  );

  Widget _readingView(S s) => ListView(
    padding: const EdgeInsets.all(NSpace.lg),
    children: <Widget>[
      ScanningPhoto(photo: _photo!, steps: <String>[s.mealsReading, s.mealsScanStepDishes, s.mealsScanStepPortions, s.mealsScanStepNutrients]),
    ],
  );

  Widget _reviewView(S s) {
    final bool ready = _lines.isNotEmpty && _lines.every((_Line l) => l.food != null);
    return ListView(
      padding: const EdgeInsets.all(NSpace.lg),
      children: <Widget>[
        _photoBox(),
        const SizedBox(height: NSpace.lg),
        if (sumNutrients(_lines.map((_Line l) => l.nutrients)) case final Nutrients total) ...<Widget>[
          SlideInItem(
            index: 0,
            child: NutrientSummary(n: total, title: s.mealsTotals),
          ),
          const SizedBox(height: NSpace.lg),
        ],
        Semantics(
          header: true,
          child: Text(s.mealsResultTitle, style: NType.h3.copyWith(color: NColors.inkPrimary)),
        ),
        const SizedBox(height: NSpace.xxs),
        Text(s.mealsResultHint, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
        const SizedBox(height: NSpace.md),
        for (int i = 0; i < _lines.length; i++) ...<Widget>[SlideInItem(index: i + 1, child: _lineCard(s, _lines[i])), const SizedBox(height: NSpace.sm)],
        if (_tags.isNotEmpty) ...<Widget>[TagChips(tags: _tags), const SizedBox(height: NSpace.sm)],
        Text(s.mealsAiMark, style: NType.caption.copyWith(color: NColors.inkMuted)),
        const SizedBox(height: NSpace.lg),
        Text(s.mealsSlot, style: NType.h4.copyWith(color: NColors.inkPrimary)),
        const SizedBox(height: NSpace.xs),
        Wrap(
          spacing: NSpace.xs,
          children: <Widget>[for (MealSlot m in MealSlot.values) ChoiceChip(label: Text(slotName(s, m)), selected: _slot == m, onSelected: (_) => setState(() => _slot = m))],
        ),
        const SizedBox(height: NSpace.lg),
        NPrimaryButton(label: s.mealsSave, inactiveHint: s.mealsSaveInactive, loading: _step == _Step.saving, onPressed: ready ? _save : null),
      ],
    );
  }

  Widget _lineCard(S s, _Line l) {
    final bool unsure = l.food == null;
    return MealCard(
      color: unsure ? NColors.statusWarningLight : NColors.surfaceCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () => _chooseFood(l),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: NSpace.xxs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(unsure ? (l.label ?? s.mealsNotSureHint) : l.food!.name, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                        if (unsure) Text(s.mealsNotSureHint, style: NType.caption.copyWith(color: NColors.actionLink)),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: s.mealsRemove,
                icon: Icon(Icons.close_rounded, color: NColors.inkMuted),
                onPressed: () => setState(() => _lines.remove(l)),
              ),
            ],
          ),
          const SizedBox(height: NSpace.xs),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded),
                onPressed: l.count > 0.5
                    ? () => setState(
                        () => l
                          ..count = l.count - 0.5
                          ..nutrients = null,
                      )
                    : null,
              ),
              Text(formatNumber(l.count), style: NType.body.copyWith(fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: l.count < 20
                    ? () => setState(
                        () => l
                          ..count = l.count + 0.5
                          ..nutrients = null,
                      )
                    : null,
              ),
              const SizedBox(width: NSpace.xs),
              DropdownButton<String>(
                value: portionUnits.contains(l.unit) ? l.unit : 'serving',
                underline: const SizedBox.shrink(),
                items: <DropdownMenuItem<String>>[for (String u in portionUnits) DropdownMenuItem<String>(value: u, child: Text(u))],
                onChanged: (String? u) {
                  if (u != null) {
                    setState(
                      () => l
                        ..unit = u
                        ..nutrients = null,
                    );
                  }
                },
              ),
            ],
          ),
          if (l.nutrients != null) NutrientRow(n: l.nutrients!),
        ],
      ),
    );
  }

  Widget _savedView(S s) {
    final Meal m = _saved!;
    return ListView(
      padding: const EdgeInsets.all(NSpace.lg),
      children: <Widget>[
        MealCard(
          color: NColors.brandSageLight,
          child: Row(
            children: <Widget>[
              Icon(Icons.check_circle_rounded, color: NColors.statusSuccess, size: 32),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Text('${s.mealsSaved} · ${slotName(s, m.slot)}', style: NType.h4.copyWith(color: NColors.inkPrimary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: NSpace.md),
        MealCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (LoggedItem i in m.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: NSpace.xs),
                  child: Text('${i.name} · ${i.portion ?? '${formatNumber(i.grams)} g'}', style: NType.body.copyWith(color: NColors.inkPrimary)),
                ),
              const SizedBox(height: NSpace.xs),
              NutrientSummary(n: m.totals, title: s.mealsTotals),
              const SizedBox(height: NSpace.xs),
              TagChips(tags: m.tags),
            ],
          ),
        ),
        if (m.suggestion != null) ...<Widget>[
          const SizedBox(height: NSpace.md),
          MealCard(
            color: NColors.brandLavenderLight,
            child: Text(m.suggestion!, style: NType.body.copyWith(color: NColors.inkPrimary)),
          ),
        ],
        const SizedBox(height: NSpace.lg),
        NPrimaryButton(label: s.mealsDone, onPressed: () => context.pop(true)),
        const SizedBox(height: NSpace.sm),
        NSecondaryButton(label: s.mealsScanAnother, onPressed: _restart),
      ],
    );
  }

  Widget _messageView(S s) => ListView(
    padding: const EdgeInsets.all(NSpace.lg),
    children: <Widget>[
      _photoBox(),
      const SizedBox(height: NSpace.lg),
      MealCard(
        color: NColors.statusInfoLight,
        child: Text(_message ?? s.mealsUnavailable, style: NType.body.copyWith(color: NColors.inkPrimary)),
      ),
      const SizedBox(height: NSpace.lg),
      NPrimaryButton(label: s.tryAgain, onPressed: _restart),
    ],
  );
}

/// "Not sure — what is this?": a search of the food table (spec 009 "Meal scan" 3).
class _FoodSearchSheet extends StatefulWidget {
  const _FoodSearchSheet({required this.repo});

  final MealsRepository repo;

  @override
  State<_FoodSearchSheet> createState() => _FoodSearchSheetState();
}

class _FoodSearchSheetState extends State<_FoodSearchSheet> {
  List<FoodOption> _results = <FoodOption>[];
  bool _searched = false;
  Timer? _debounce;

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (q.trim().length < 2) return;
      try {
        final List<FoodOption> r = await widget.repo.searchFoods(q.trim());
        if (mounted) setState(() => (_results = r, _searched = true));
      } on Exception {
        if (mounted) setState(() => (_results = <FoodOption>[], _searched = true));
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Padding(
      padding: EdgeInsets.only(left: NSpace.lg, right: NSpace.lg, top: NSpace.lg, bottom: MediaQuery.of(context).viewInsets.bottom + NSpace.lg),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.mealsSearchTitle, style: NType.h3.copyWith(color: NColors.inkPrimary)),
            const SizedBox(height: NSpace.sm),
            TextField(
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(hintText: s.mealsSearchHint, prefixIcon: const Icon(Icons.search_rounded)),
            ),
            const SizedBox(height: NSpace.sm),
            Expanded(
              child: _searched && _results.isEmpty
                  ? Text(s.mealsSearchNone, style: NType.body.copyWith(color: NColors.inkSecondary))
                  : ListView(
                      children: <Widget>[
                        for (FoodOption f in _results)
                          ListTile(title: Text(f.name), subtitle: f.regionalNames.isEmpty ? null : Text(f.regionalNames.take(3).join(', ')), onTap: () => Navigator.of(context).pop(f)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
