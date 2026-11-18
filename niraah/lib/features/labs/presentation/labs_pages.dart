import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/labs.dart';

String _num(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

/// Lab tests (spec 010 §9): her reports with results against the range printed on the report, marked in neutral
/// words when outside it and never interpreted (AC34); home collection when her plan includes it.
class LabsPage extends StatefulWidget {
  const LabsPage({super.key, this.repository});

  final LabsRepository? repository;

  @override
  State<LabsPage> createState() => _LabsPageState();
}

class _LabsData {
  const _LabsData(this.reports, this.collection, this.orders);

  final List<LabReport> reports;
  final LabCollection? collection;
  final List<LabOrder> orders;
}

class _LabsPageState extends State<LabsPage> {
  late final LabsRepository _repo = widget.repository ?? getIt<LabsRepository>();
  late Future<_LabsData> _data = _load();

  Future<_LabsData> _load() async {
    final List<LabReport> reports = await _repo.reports();
    LabCollection? c;
    List<LabOrder> orders = const <LabOrder>[];
    try {
      c = await _repo.collection();
      orders = await _repo.orders();
    } on AreaLocked {
      c = null;
    }
    return _LabsData(reports, c, orders);
  }

  void _reload() => setState(() => _data = _load());

  Future<void> _add() async {
    final bool? added = await Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => AddLabReportPage(repository: _repo)));
    if (added ?? false) _reload();
  }

  Future<void> _order(LabCollection c) async {
    final bool? ordered = await Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => LabOrderPage(repository: _repo, collection: c)));
    if (ordered ?? false) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.labsTitle,
      floatingActionButton: FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add_rounded), label: Text(s.labsAdd)),
      body: AsyncBody<_LabsData>(
        future: _data,
        onRetry: _reload,
        builder: (BuildContext context, _LabsData d) => ListView(
          padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, 96),
          children: <Widget>[
            NSectionTitle(s.labsReports),
            if (d.reports.isEmpty) EmptyNote(text: s.labsEmpty, actionLabel: s.labsAdd, onAction: _add),
            for (final LabReport r in d.reports) ...<Widget>[
              NCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(r.testDate == null ? s.labsReport : s.labsTestedOn(shortDate(context, r.testDate!)), style: NType.h4.copyWith(color: NColors.inkPrimary)),
                    for (final LabResult x in r.results)
                      Padding(
                        padding: const EdgeInsets.only(top: NSpace.xs),
                        child: MergeSemantics(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('${x.name}: ${_num(x.value)} ${x.unit}', style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                              if (x.low != null || x.high != null)
                                Text(s.labsRange(x.low == null ? '–' : _num(x.low!), x.high == null ? '–' : _num(x.high!)), style: NType.caption.copyWith(color: NColors.inkSecondary)),
                              if (x.outsideRange) Text(x.label ?? s.labsOutside, style: NType.caption.copyWith(color: NColors.inkPrimary, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      ),
                    if (r.clinicianComment != null) ...<Widget>[
                      const SizedBox(height: NSpace.xs),
                      Text(r.clinicianComment!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                    ],
                    const SizedBox(height: NSpace.xs),
                    Text(r.note, style: NType.caption.copyWith(color: NColors.inkMuted)),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.sm),
            ],
            NSectionTitle(s.labsCollection),
            if (d.collection case final LabCollection c)
              switch (c.access) {
                'included' => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (final LabOrder o in d.orders)
                        Padding(
                          padding: const EdgeInsets.only(bottom: NSpace.xs),
                          child: NCard(
                            child: Text(
                              <String>[o.statusText, if (o.partner != null) o.partner!, if (o.slotStart != null) shortDate(context, o.slotStart!)].join(' · '),
                              style: NType.body.copyWith(color: NColors.inkPrimary),
                            ),
                          ),
                        ),
                      NSecondaryButton(label: s.labsOrder, onPressed: c.tests.isEmpty || c.partners.isEmpty ? null : () => _order(c)),
                    ],
                  ),
                'after_trial' => EmptyNote(text: s.labsAfterTrial),
                'unavailable' => EmptyNote(text: s.labsCollectionUnavailable),
                _ => EmptyNote(text: s.labsNotIncluded),
              }
            else
              EmptyNote(text: s.labsNotIncluded),
          ],
        ),
      ),
    );
  }
}

class _ResultRow {
  final TextEditingController name = TextEditingController();
  final TextEditingController value = TextEditingController();
  final TextEditingController unit = TextEditingController();
  final TextEditingController low = TextEditingController();
  final TextEditingController high = TextEditingController();

  void dispose() {
    for (final TextEditingController c in <TextEditingController>[name, value, unit, low, high]) {
      c.dispose();
    }
  }
}

/// Adds a report with its test date and the results she copies from it, each with the range the report prints
/// (spec 010 §9 rules 1 to 3). Reading reports automatically is out of scope.
class AddLabReportPage extends StatefulWidget {
  const AddLabReportPage({required this.repository, super.key});

  final LabsRepository repository;

  @override
  State<AddLabReportPage> createState() => _AddLabReportPageState();
}

class _AddLabReportPageState extends State<AddLabReportPage> {
  DateTime? _date;
  final List<_ResultRow> _rows = <_ResultRow>[_ResultRow()];
  bool _saving = false;

  @override
  void dispose() {
    for (final _ResultRow r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final S s = S.of(context);
    final DateTime? d = _date;
    if (d == null) return;
    final List<ResultInput> results = <ResultInput>[];
    for (final _ResultRow r in _rows) {
      final String name = r.name.text.trim();
      final double? value = double.tryParse(r.value.text.trim());
      if (name.isEmpty && r.value.text.trim().isEmpty) continue;
      if (name.isEmpty || value == null) {
        showNote(context, s.labsResultIncomplete);
        return;
      }
      results.add(ResultInput(name: name, value: value, unit: r.unit.text.trim(), low: double.tryParse(r.low.text.trim()), high: double.tryParse(r.high.text.trim())));
    }
    String two(int v) => v.toString().padLeft(2, '0');
    setState(() => _saving = true);
    try {
      await widget.repository.addReport(testDate: '${d.year}-${two(d.month)}-${two(d.day)}', results: results);
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.labsAdd,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          OutlinedButton.icon(
            icon: const Icon(Icons.event_rounded),
            label: Text(_date == null ? s.labsPickDate : s.labsTestedOn(MaterialLocalizations.of(context).formatMediumDate(_date!))),
            onPressed: () async {
              final DateTime now = DateTime.now();
              final DateTime? d = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(now.year - 20), lastDate: now);
              if (d != null) setState(() => _date = d);
            },
          ),
          NSectionTitle(s.labsResults),
          Text(s.labsResultsHelp, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          for (final _ResultRow r in _rows) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            NCard(
              child: Column(
                children: <Widget>[
                  TextField(controller: r.name, maxLength: 80, decoration: InputDecoration(labelText: s.labsMarker)),
                  Row(
                    children: <Widget>[
                      Expanded(child: TextField(controller: r.value, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: InputDecoration(labelText: s.labsValue))),
                      const SizedBox(width: NSpace.sm),
                      Expanded(child: TextField(controller: r.unit, maxLength: 20, decoration: InputDecoration(labelText: s.labsUnit))),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: TextField(controller: r.low, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: InputDecoration(labelText: s.labsLow))),
                      const SizedBox(width: NSpace.sm),
                      Expanded(child: TextField(controller: r.high, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: InputDecoration(labelText: s.labsHigh))),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: NSpace.sm),
          TextButton.icon(onPressed: _rows.length >= 60 ? null : () => setState(() => _rows.add(_ResultRow())), icon: const Icon(Icons.add_rounded), label: Text(s.labsAddResult)),
          const SizedBox(height: NSpace.md),
          NPrimaryButton(label: s.labsSave, loading: _saving, inactiveHint: s.labsPickDateFirst, onPressed: _date == null ? null : _save),
        ],
      ),
    );
  }
}

/// Orders home collection (spec 010 §9 rule 4): tests, the lab, her address and a time.
class LabOrderPage extends StatefulWidget {
  const LabOrderPage({required this.repository, required this.collection, super.key});

  final LabsRepository repository;
  final LabCollection collection;

  @override
  State<LabOrderPage> createState() => _LabOrderPageState();
}

class _LabOrderPageState extends State<LabOrderPage> {
  final Set<String> _tests = <String>{};
  late String _partner = widget.collection.partners.first.id;
  final TextEditingController _line = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _pin = TextEditingController();
  DateTime? _start;
  bool _saving = false;

  @override
  void dispose() {
    _line.dispose();
    _city.dispose();
    _pin.dispose();
    super.dispose();
  }

  bool get _ready => _tests.isNotEmpty && _start != null && _line.text.trim().isNotEmpty && _city.text.trim().isNotEmpty && _pin.text.trim().isNotEmpty;

  Future<void> _pickTime() async {
    final DateTime now = DateTime.now();
    final DateTime? d = await showDatePicker(context: context, initialDate: now.add(const Duration(days: 1)), firstDate: now, lastDate: now.add(const Duration(days: 30)));
    if (d == null || !mounted) return;
    final TimeOfDay? t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
    if (t == null) return;
    setState(() => _start = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await widget.repository.order(
        partnerId: _partner,
        testIds: _tests.toList(),
        address: <String, String>{'line1': _line.text.trim(), 'city': _city.text.trim(), 'pincode': _pin.text.trim()},
        start: _start!,
        end: _start!.add(const Duration(hours: 1)),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.labsOrder,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          NSectionTitle(s.labsChooseTests),
          for (final LabTest t in widget.collection.tests)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _tests.contains(t.id),
              onChanged: (bool? on) => setState(() => (on ?? false) ? _tests.add(t.id) : _tests.remove(t.id)),
              title: Text(t.name),
              subtitle: t.fasting ? Text(s.labsFasting) : null,
            ),
          if (widget.collection.partners.length > 1) ...<Widget>[
            NSectionTitle(s.labsPartner),
            for (final ({String id, String name}) p in widget.collection.partners)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(p.name),
                leading: Icon(_partner == p.id ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded),
                onTap: () => setState(() => _partner = p.id),
              ),
          ],
          NSectionTitle(s.labsAddress),
          TextField(controller: _line, maxLength: 200, decoration: InputDecoration(labelText: s.labsAddressLine), onChanged: (_) => setState(() {})),
          TextField(controller: _city, maxLength: 80, decoration: InputDecoration(labelText: s.labsCity), onChanged: (_) => setState(() {})),
          TextField(controller: _pin, maxLength: 6, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: s.labsPincode), onChanged: (_) => setState(() {})),
          NSectionTitle(s.labsTime),
          OutlinedButton.icon(
            icon: const Icon(Icons.schedule_rounded),
            onPressed: _pickTime,
            label: Text(_start == null ? s.labsPickTime : '${MaterialLocalizations.of(context).formatMediumDate(_start!)}, ${TimeOfDay.fromDateTime(_start!).format(context)}'),
          ),
          Text(s.labsTimeNote, style: NType.caption.copyWith(color: NColors.inkMuted)),
          const SizedBox(height: NSpace.lg),
          NPrimaryButton(label: s.labsOrderSubmit, loading: _saving, inactiveHint: s.labsOrderIncomplete, onPressed: _ready ? _submit : null),
        ],
      ),
    );
  }
}
