import 'dart:convert';
import 'dart:io';

void main() {
  final english = _readArb('lib/l10n/app_en.arb');
  final arabic = _readArb('lib/l10n/app_ar.arb');
  final keys = english.keys.where(arabic.containsKey).toList()..sort();
  final inputs = <String, String>{};

  for (final key in keys) {
    final englishText = english[key]!;
    final arabicText = arabic[key]!;
    if (englishText.contains('{') || arabicText.contains('{')) continue;
    inputs.putIfAbsent(englishText, () => key);
    inputs.putIfAbsent(arabicText, () => key);
  }

  final buffer = StringBuffer()
    ..writeln("import 'app_localizations_generated.dart';")
    ..writeln()
    ..writeln('String lookupLegacyMessage(')
    ..writeln('  AppLocalizations localizations,')
    ..writeln('  String text,')
    ..writeln(') {')
    ..writeln('  switch (text.trim()) {');
  for (final entry in inputs.entries) {
    buffer
      ..writeln('    case ${jsonEncode(entry.key)}:')
      ..writeln('      return localizations.${entry.value};');
  }
  buffer
    ..writeln('    default:')
    ..writeln('      return text;')
    ..writeln('  }')
    ..writeln('}');

  final output = File('generated/bahya_l10n/lib/legacy_message_lookup.dart');
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(buffer.toString());
}

Map<String, String> _readArb(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final entry in json.entries)
      if (!entry.key.startsWith('@') && entry.value is String)
        entry.key: entry.value as String,
  };
}
