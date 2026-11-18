import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../provider_work/domain/provider_work.dart';
import '../application_repository.dart';

const int _maxBytes = 3 * 1024 * 1024;

/// Her application on the status page (spec 006 "Completing the application"; AC9, AC45, AC46), mirroring
/// apps/web/src/app/provider/status/application-form.tsx: status, what the team asked for, details, references,
/// documents, terms and Submit. Read-only while the application is with the team.
class ApplicationForm extends StatefulWidget {
  const ApplicationForm({this.onChanged, this.picker, this.repository, super.key});

  /// Called with each fresh application, so the page can move on once she is approved.
  final void Function(Json app)? onChanged;
  final ImagePicker? picker;
  final ProviderApplicationRepository? repository;

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  late final ProviderApplicationRepository _repo = widget.repository ?? getIt<ProviderApplicationRepository>();
  late final ImagePicker _picker = widget.picker ?? ImagePicker();
  Json? _app;
  Object? _error;
  String? _busy;
  bool _terms = false;

  final Map<String, TextEditingController> _f = <String, TextEditingController>{
    for (final String k in <String>['name', 'contactPhone', 'bio', 'specialities', 'languages', 'years', 'regNumber', 'regCouncil']) k: TextEditingController(),
  };
  final List<List<TextEditingController>> _refs = <List<TextEditingController>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final TextEditingController c in _f.values) {
      c.dispose();
    }
    for (final List<TextEditingController> r in _refs) {
      for (final TextEditingController c in r) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      _take(await _repo.get());
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _take(Json a) {
    final Json p = a.obj('profile');
    _f['name']!.text = p.str('name') ?? '';
    _f['contactPhone']!.text = p.str('contactPhone') ?? '';
    _f['bio']!.text = p.str('bio') ?? '';
    _f['specialities']!.text = p.strs('specialities').join(', ');
    _f['languages']!.text = p.strs('languages').join(', ');
    _f['years']!.text = p['yearsExperience'] == null ? '' : '${p.integer('yearsExperience')}';
    _f['regNumber']!.text = p.str('registrationNumber') ?? '';
    _f['regCouncil']!.text = p.str('registrationCouncil') ?? '';
    final List<Json> refs = a.objs('referees');
    while (_refs.length < (refs.length < 2 ? 2 : refs.length)) {
      _refs.add(<TextEditingController>[TextEditingController(), TextEditingController(), TextEditingController()]);
    }
    for (int i = 0; i < _refs.length; i++) {
      final Json? r = i < refs.length ? refs[i] : null;
      _refs[i][0].text = r?.str('name') ?? '';
      _refs[i][1].text = r?.str('role') ?? '';
      _refs[i][2].text = r?.str('contact') ?? '';
    }
    if (mounted) setState(() => _app = a);
    widget.onChanged?.call(a);
  }

  static List<String> _list(String s) => s.split(',').map((String x) => x.trim()).where((String x) => x.isNotEmpty).toList();

  Future<void> _run(String key, Future<void> Function() f) async {
    setState(() => _busy = key);
    try {
      await f();
    } catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _save() => _run('save', () async {
        final String years = _f['years']!.text.trim();
        _take(await _repo.save(<String, dynamic>{
          'name': _f['name']!.text,
          'contactPhone': _f['contactPhone']!.text,
          'bio': _f['bio']!.text,
          'specialities': _list(_f['specialities']!.text),
          'languages': _list(_f['languages']!.text),
          'yearsExperience': years.isEmpty ? null : int.tryParse(years),
          'registrationNumber': _f['regNumber']!.text.trim().isEmpty ? null : _f['regNumber']!.text,
          'registrationCouncil': _f['regCouncil']!.text.trim().isEmpty ? null : _f['regCouncil']!.text,
          'referees': <Json>[
            for (final List<TextEditingController> r in _refs)
              if (r[0].text.trim().isNotEmpty || r[2].text.trim().isNotEmpty) <String, dynamic>{'name': r[0].text, 'role': r[1].text, 'contact': r[2].text},
          ],
        }));
        if (mounted) showNote(context, S.of(context).paSaved);
      });

  Future<void> _upload(String kind) async {
    final S s = S.of(context);
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 2400, imageQuality: 85);
    if (file == null || !mounted) return;
    final List<int> bytes = await file.readAsBytes();
    if (bytes.length > _maxBytes) {
      if (mounted) showNote(context, s.paTooBig);
      return;
    }
    final bool png = bytes.length > 3 && bytes[0] == 0x89 && bytes[1] == 0x50;
    await _run('upload-$kind', () async {
      await _repo.upload(kind: kind, fileName: file.name, contentType: png ? 'image/png' : 'image/jpeg', bytes: bytes);
      _take(await _repo.get());
    });
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    if (_error != null) return EmptyNote(text: failureText(_error!, s.commonLoadError));
    final Json? app = _app;
    if (app == null) return LoadingView(label: s.loading);

    final bool editable = app.flag('editable');
    final String status = app.str('status') ?? '';
    final List<String> missing = app.strs('missing');
    final String type = app.str('providerType') ?? '';
    final String? canReapplyAt = app.str('canReapplyAt');
    final bool reapplyOpen = status == 'rejected' && (canReapplyAt == null || DateTime.parse(canReapplyAt).isBefore(DateTime.now()));
    final List<Json> documents = app.objs('documents');
    final List<(String, String)> kinds = <(String, String)>[
      ('photo', s.paKindPhoto),
      ('identity', s.paKindIdentity),
      ('qualification', s.paKindQualification),
      if (type == 'doctor' || _f['regNumber']!.text.trim().isNotEmpty) ('registration_certificate', s.paKindRegistration),
    ];

    Widget field(String key, String label, {String? hint, TextInputType? keyboard, int lines = 1}) => Padding(
          padding: const EdgeInsets.only(bottom: NSpace.sm),
          child: TextField(
            controller: _f[key],
            readOnly: !editable,
            keyboardType: keyboard,
            minLines: lines,
            maxLines: lines == 1 ? 1 : lines + 2,
            decoration: InputDecoration(labelText: label, helperText: hint),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        NCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(s.paStatus, style: NType.label.copyWith(color: NColors.inkMuted)),
              Text(app.str('statusWords') ?? status, style: NType.h4.copyWith(color: NColors.inkPrimary)),
              if (app.str('informationRequested') != null) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                Text('${s.paAsked}: ${app.str('informationRequested')}', style: NType.body.copyWith(color: NColors.inkSecondary)),
              ],
              if (app.str('decisionReason') != null) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                Text('${s.paReason}: ${app.str('decisionReason')}', style: NType.body.copyWith(color: NColors.inkSecondary)),
              ],
              if (missing.isNotEmpty && editable) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                Text('${s.paMissing}: ${missing.join(', ')}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              ],
              if (!editable && status != 'rejected' && status != 'approved') ...<Widget>[
                const SizedBox(height: NSpace.xs),
                Text(s.paReadOnly, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
              ],
              if (status == 'rejected') ...<Widget>[
                const SizedBox(height: NSpace.sm),
                if (reapplyOpen)
                  NSecondaryButton(label: s.paReapply, onPressed: _busy != null ? null : () => _run('reapply', () async => _take(await _repo.reapply())))
                else
                  Text(s.paReapplyFrom(shortDate(context, canReapplyAt!)), style: NType.bodySm.copyWith(color: NColors.inkMuted)),
              ],
            ],
          ),
        ),
        const SizedBox(height: NSpace.lg),
        NSectionTitle(s.paDetails),
        field('name', s.paName),
        field('contactPhone', s.paPhone, keyboard: TextInputType.phone),
        field('bio', s.paBio, lines: 3),
        field('specialities', s.paSpecialities, hint: s.paCommaHint),
        field('languages', s.paLanguages, hint: s.paCommaHint),
        field('years', s.paYears, keyboard: TextInputType.number),
        field('regNumber', s.paRegNumber, hint: s.paRegHint),
        field('regCouncil', s.paRegCouncil),
        if (type != 'instructor' || app.objs('referees').isNotEmpty) ...<Widget>[
          const SizedBox(height: NSpace.sm),
          NSectionTitle(s.paReferences),
          Text(s.paReferencesHint, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
          for (final List<TextEditingController> r in _refs)
            Padding(
              padding: const EdgeInsets.only(top: NSpace.sm),
              child: Column(
                children: <Widget>[
                  TextField(controller: r[0], readOnly: !editable, decoration: InputDecoration(labelText: s.paRefName)),
                  TextField(controller: r[1], readOnly: !editable, decoration: InputDecoration(labelText: s.paRefRole)),
                  TextField(controller: r[2], readOnly: !editable, decoration: InputDecoration(labelText: s.paRefContact)),
                ],
              ),
            ),
        ],
        if (editable) ...<Widget>[
          const SizedBox(height: NSpace.md),
          NSecondaryButton(label: _busy == 'save' ? '…' : s.paSave, onPressed: _busy != null ? null : _save),
        ],
        const SizedBox(height: NSpace.lg),
        NSectionTitle(s.paDocuments),
        Text(s.paDocumentsHint, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
        for (final (String kind, String label) in kinds)
          Padding(
            padding: const EdgeInsets.only(top: NSpace.sm),
            child: NCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: NType.label.copyWith(color: NColors.inkPrimary)),
                  for (final Json d in documents.where((Json d) => d.str('kind') == kind))
                    Row(
                      children: <Widget>[
                        Expanded(child: Text(d.str('name') ?? '', style: NType.bodySm.copyWith(color: NColors.inkSecondary))),
                        if (editable)
                          TextButton(
                            onPressed: _busy != null ? null : () => _run('rm', () async => _take(await _repo.removeDocument(d.str('fileId')!))),
                            child: Text(s.paRemove),
                          ),
                      ],
                    ),
                  if (editable)
                    TextButton.icon(
                      onPressed: _busy != null ? null : () => _upload(kind),
                      icon: const Icon(Icons.upload_file_rounded),
                      label: Text(_busy == 'upload-$kind' ? '…' : s.paUpload),
                    ),
                ],
              ),
            ),
          ),
        if (editable) ...<Widget>[
          const SizedBox(height: NSpace.lg),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _terms,
            onChanged: (bool? v) => setState(() => _terms = v ?? false),
            title: Text(s.paTerms(app.str('termsVersion') ?? ''), style: NType.body.copyWith(color: NColors.inkSecondary)),
          ),
          NPrimaryButton(
            label: status == 'more_information_requested' ? s.paResubmit : s.paSubmit,
            inactiveHint: s.paSubmitInactive,
            loading: _busy == 'submit',
            onPressed: !_terms || missing.isNotEmpty || _busy != null
                ? null
                : () {
                    final String sent = s.paSubmitted;
                    _run('submit', () async {
                      _take(await _repo.submit(acceptTerms: true));
                      if (mounted) showNote(this.context, sent);
                    });
                  },
          ),
        ],
      ],
    );
  }
}
