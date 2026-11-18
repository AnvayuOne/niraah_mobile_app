import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Constitution §2 rule 6: sample data is never in a release build. Release
/// builds use lib/main.dart, so nothing it can reach may import lib/sample/.
void main() {
  final RegExp import = RegExp(r'''^\s*(import|export)\s+['"]([^'"]+)['"]''', multiLine: true);

  test('lib/main.dart does not import sample data', () {
    final String main = File('lib/main.dart').readAsStringSync();
    final Iterable<String> imports = import.allMatches(main).map((RegExpMatch m) => m.group(2)!);
    expect(imports.where((String i) => i.contains('sample')), isEmpty);
  });

  test('only lib/main_sample.dart and lib/sample/ import lib/sample/', () {
    final List<String> offenders = <String>[];
    for (final FileSystemEntity f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final String p = f.path.replaceAll(r'\', '/');
      if (p == 'lib/main_sample.dart' || p.startsWith('lib/sample/')) continue;
      final String src = f.readAsStringSync();
      for (final RegExpMatch m in import.allMatches(src)) {
        final String target = m.group(2)!;
        if (target.contains('/sample/') || target.startsWith('sample/') || target.contains('package:niraah/sample')) offenders.add('$p -> $target');
      }
    }
    expect(offenders, isEmpty);
  });
}
