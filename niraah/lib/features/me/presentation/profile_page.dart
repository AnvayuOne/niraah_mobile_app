import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/me.dart';

/// Profile (spec 010 §13 "Profile"): display name, height and goals she can change; date of birth read-only
/// after the assessment; mobile number, language and time zone as the server holds them.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.repository});

  final MeRepository? repository;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final MeRepository _repo = widget.repository ?? getIt<MeRepository>();
  late Future<Profile> _profile = _repo.profile();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _goal = TextEditingController();
  List<String> _goals = <String>[];
  bool _filled = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _goal.dispose();
    super.dispose();
  }

  void _fill(Profile p) {
    if (_filled) return;
    _filled = true;
    _name.text = p.displayName ?? '';
    _height.text = p.heightCm == null ? '' : p.heightCm!.toStringAsFixed(0);
    _goals = List<String>.of(p.goals);
  }

  Future<void> _save() async {
    final S s = S.of(context);
    final double? height = double.tryParse(_height.text.trim());
    if (_height.text.trim().isNotEmpty && (height == null || height < 50 || height > 250)) {
      showNote(context, s.profileHeightRange);
      return;
    }
    setState(() => _saving = true);
    try {
      final Profile p = await _repo.updateProfile(displayName: _name.text.trim().isEmpty ? null : _name.text.trim(), heightCm: height, goals: _goals);
      if (!mounted) return;
      setState(() {
        _filled = false;
        _profile = Future<Profile>.value(p);
      });
      showNote(context, s.profileSaved);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _change(String route, [String? extra]) async {
    await context.push(route, extra: extra);
    if (mounted) setState(() => _profile = _repo.profile());
  }

  void _addGoal() {
    final String g = _goal.text.trim();
    if (g.isEmpty || g.length > 60 || _goals.length >= 10 || _goals.contains(g)) return;
    setState(() {
      _goals.add(g);
      _goal.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.profileTitle,
      body: AsyncBody<Profile>(
        future: _profile,
        onRetry: () => setState(() => _profile = _repo.profile()),
        builder: (BuildContext context, Profile p) {
          _fill(p);
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              TextField(controller: _name, maxLength: 60, decoration: InputDecoration(labelText: s.profileName)),
              const SizedBox(height: NSpace.sm),
              TextField(controller: _height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: s.profileHeight)),
              NSectionTitle(s.profileGoals),
              Wrap(
                spacing: NSpace.xs,
                runSpacing: NSpace.xs,
                children: <Widget>[
                  for (final String g in _goals) InputChip(label: Text(g), onDeleted: () => setState(() => _goals.remove(g)), deleteButtonTooltipMessage: s.profileRemoveGoal(g)),
                ],
              ),
              const SizedBox(height: NSpace.xs),
              Row(
                children: <Widget>[
                  Expanded(child: TextField(controller: _goal, maxLength: 60, decoration: InputDecoration(labelText: s.profileAddGoal), onSubmitted: (_) => _addGoal())),
                  IconButton(tooltip: s.profileAddGoal, onPressed: _addGoal, icon: const Icon(Icons.add_rounded)),
                ],
              ),
              const SizedBox(height: NSpace.md),
              NPrimaryButton(label: s.profileSave, loading: _saving, onPressed: _save),
              NSectionTitle(s.profileAccount),
              // Changed through spec 003's flows, each behind a fresh code (spec 010 §13 "Profile" 2).
              _Fact(label: s.profilePhone, value: p.phone ?? s.profileNotSet),
              _ChangeLink(label: s.acctChangeNumber, onTap: () => _change(RouteConstants.changeNumber)),
              _Fact(label: s.profileRecoveryEmail, value: p.recoveryEmail ?? s.profileNotSet),
              _ChangeLink(label: p.recoveryEmail == null ? s.acctEmailAdd : s.acctEmailChange, onTap: () => _change(RouteConstants.recoveryEmail, p.recoveryEmail)),
              _Fact(label: s.profileDob, value: p.dateOfBirth == null ? s.profileNotSet : shortDate(context, p.dateOfBirth!), note: p.dateOfBirth == null ? null : s.profileDobNote),
              _Fact(label: s.profileLanguage, value: p.language),
              _Fact(label: s.profileTimeZone, value: p.timeZone),
            ],
          );
        },
      ),
    );
  }
}

class _ChangeLink extends StatelessWidget {
  const _ChangeLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(padding: const EdgeInsets.only(bottom: NSpace.xs), child: TextButton(onPressed: onTap, child: Text(label))),
      );
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: NSpace.sm),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: NType.caption.copyWith(color: NColors.inkMuted)),
              Text(value, style: NType.body.copyWith(color: NColors.inkPrimary)),
              if (note != null) Text(note!, style: NType.caption.copyWith(color: NColors.inkSecondary)),
            ],
          ),
        ),
      );
}
