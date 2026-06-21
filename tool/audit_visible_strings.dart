import 'dart:convert';
import 'dart:io';

void main() {
  final english = _arbValues('lib/l10n/app_en.arb');
  final arabic = _arbValues('lib/l10n/app_ar.arb');
  final catalog = {...english, ...arabic};
  final pattern = RegExp(
    r'''(?:text|title|subtitle|label|hint|labelText|hintText|tooltip|semanticLabel)\s*:\s*(['"])(.*?)\1''',
    multiLine: true,
  );
  final missing = <String, Set<String>>{};
  const ignored = {'#', '●', 'RANGE', 'SUM', 'patient@example.com'};

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

  final entries = missing.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  for (final entry in entries) {
    stdout.writeln('${jsonEncode(entry.key)}: ${entry.value.join(', ')}');
  }
  if (entries.isNotEmpty) exitCode = 1;
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
