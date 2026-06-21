import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every Dart file under lib stays below 600 lines', () {
    final oversizedFiles =
        Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .map(
              (file) => (path: file.path, lines: file.readAsLinesSync().length),
            )
            .where((entry) => entry.lines >= 600)
            .toList()
          ..sort((a, b) => b.lines.compareTo(a.lines));

    expect(
      oversizedFiles,
      isEmpty,
      reason: oversizedFiles
          .map((entry) => '${entry.path}: ${entry.lines} lines')
          .join('\n'),
    );
  });
}
