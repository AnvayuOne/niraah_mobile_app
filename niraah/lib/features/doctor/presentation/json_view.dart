import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../../provider_work/domain/provider_work.dart';

/// "dimensionScores" → "Dimension scores".
String humanise(String key) {
  final String spaced = key.replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (Match m) => '${m[1]} ${m[2]}').replaceAll('_', ' ');
  return spaced.isEmpty ? key : '${spaced[0].toUpperCase()}${spaced.substring(1).toLowerCase()}';
}

String _iso(String v) {
  final DateTime? d = RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(v) ? DateTime.tryParse(v) : null;
  if (d == null) return v;
  final DateTime l = d.toLocal();
  String two(int x) => x.toString().padLeft(2, '0');
  return v.length > 10 ? '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}' : v;
}

String scalarText(Object? v) => switch (v) {
  null => '—',
  true => 'Yes',
  false => 'No',
  String s => _iso(s),
  final num n => n == n.roundToDouble() ? n.toInt().toString() : n.toString(),
  List<dynamic> l when l.every((Object? x) => x is! Map) => l.isEmpty ? '—' : l.map(scalarText).join(', '),
  _ => '$v',
};

/// Reads an open record from the server as labelled lines, nested lists as cards. Used where the server's
/// response is an open record and the screen has no designed layout yet (spec 011 "Design").
class JsonView extends StatelessWidget {
  const JsonView({required this.data, super.key, this.skip = const <String>{}});

  final Json data;
  final Set<String> skip;

  @override
  Widget build(BuildContext context) {
    final List<Widget> out = <Widget>[];
    for (MapEntry<String, dynamic> e in data.entries) {
      if (skip.contains(e.key)) continue;
      final Object? v = e.value;
      if (v is Map) {
        out
          ..add(
            Padding(
              padding: const EdgeInsets.only(top: NSpace.sm),
              child: Text(
                humanise(e.key),
                style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          )
          ..add(
            Padding(
              padding: const EdgeInsets.only(left: NSpace.sm),
              child: JsonView(data: Map<String, dynamic>.from(v)),
            ),
          );
      } else if (v is List && v.any((Object? x) => x is Map)) {
        out.add(
          Padding(
            padding: const EdgeInsets.only(top: NSpace.sm, bottom: NSpace.xxs),
            child: Text(
              humanise(e.key),
              style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
            ),
          ),
        );
        for (Object? x in v) {
          if (x is! Map) continue;
          out.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: NSpace.xs),
              padding: const EdgeInsets.all(NSpace.sm),
              decoration: BoxDecoration(
                color: NColors.surfaceCard,
                borderRadius: BorderRadius.circular(NRadius.lg),
                border: Border.all(color: NColors.lineDefault),
              ),
              child: JsonView(data: Map<String, dynamic>.from(x), skip: const <String>{'id'}),
            ),
          );
        }
      } else {
        out.add(
          Padding(
            padding: const EdgeInsets.only(bottom: NSpace.xxs),
            child: MergeSemantics(
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '${humanise(e.key)}: ',
                      style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                    ),
                    TextSpan(
                      text: scalarText(v),
                      style: NType.bodySm.copyWith(color: NColors.inkPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: out);
  }
}
