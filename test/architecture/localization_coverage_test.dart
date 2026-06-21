import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('visible literal arguments are represented in both ARB catalogs', () {
    final english = _arbValues('lib/l10n/app_en.arb');
    final arabic = _arbValues('lib/l10n/app_ar.arb');
    final catalog = {...english, ...arabic};
    final pattern = RegExp(
      r'''(?:text|title|subtitle|label|hint|labelText|hintText|tooltip|semanticLabel)\s*:\s*(['"])(.*?)\1''',
      multiLine: true,
    );
    const ignored = {'#', '●', 'RANGE', 'SUM', 'patient@example.com'};
    final missing = <String, Set<String>>{};

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final match in pattern.allMatches(source)) {
        final value = match.group(2)!.trim();
        if (value.isEmpty ||
            ignored.contains(value) ||
            value.contains(r'$') ||
            RegExp(r'^[0-9.,/@_-]+$').hasMatch(value) ||
            catalog.contains(value)) {
          continue;
        }
        missing.putIfAbsent(value, () => <String>{}).add(entity.path);
      }
    }

    expect(
      missing,
      isEmpty,
      reason: missing.entries
          .map((entry) => '${entry.key}: ${entry.value.join(', ')}')
          .join('\n'),
    );
  });
}

Set<String> _arbValues(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return json.entries
      .where((entry) => !entry.key.startsWith('@'))
      .map((entry) => entry.value)
      .whereType<String>()
      .toSet();
}
