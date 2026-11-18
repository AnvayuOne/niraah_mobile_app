import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/code_boxes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../domain/me.dart';

/// The fresh sign-in check before a sensitive action (spec 003 "Sensitive actions"; spec 010 §13 rules 5 and 6):
/// a code to her current number, which returns a 10-minute proof. Null when she closes it.
Future<String?> freshCheck(BuildContext context, MeRepository repo) async {
  final S s = S.of(context);
  try {
    await repo.requestFreshCode();
  } on Object catch (e) {
    if (context.mounted) _note(context, failureText(e, s.commonLoadError));
    return null;
  }
  if (!context.mounted) return null;
  return showDialog<String>(context: context, builder: (_) => _FreshCheckDialog(repo: repo));
}

void _note(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class _FreshCheckDialog extends StatefulWidget {
  const _FreshCheckDialog({required this.repo});

  final MeRepository repo;

  @override
  State<_FreshCheckDialog> createState() => _FreshCheckDialogState();
}

class _FreshCheckDialogState extends State<_FreshCheckDialog> {
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final String proof = await widget.repo.verifyFreshCode(_code.text);
      if (mounted) Navigator.of(context).pop(proof);
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AlertDialog(
      title: Text(s.freshTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.freshBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.md),
          CodeBoxes(controller: _code, focus: _focus, label: s.codeFieldLabel),
          if (_error != null) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            Text(_error!, style: NType.bodySm.copyWith(color: NColors.statusAttention)),
          ],
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.commonCancel)),
        FilledButton(onPressed: _code.text.length == 6 && !_busy ? _verify : null, child: Text(s.freshConfirm)),
      ],
    );
  }
}
