import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the layer rules documented in the README by scanning imports.
void main() {
  final features = Directory(
    'lib/features',
  ).listSync().whereType<Directory>().toList();

  List<String> importsOf(File file) {
    return file
        .readAsLinesSync()
        .map((line) => line.trim())
        .where(
          (line) => line.startsWith('import ') || line.startsWith('export '),
        )
        .toList();
  }

  List<String> violations(String layer, List<Pattern> forbidden) {
    final result = <String>[];
    for (final feature in features) {
      final dir = Directory('${feature.path}/$layer');
      if (!dir.existsSync()) continue;
      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      for (final file in files) {
        for (final directive in importsOf(file)) {
          if (forbidden.any(directive.contains)) {
            result.add('${file.path}: $directive');
          }
        }
      }
    }
    return result;
  }

  test('there is at least one feature to check', () {
    expect(features, isNotEmpty);
  });

  test('domain is pure Dart and depends on no other layer', () {
    expect(
      violations('domain', [
        'package:flutter/',
        'package:flutter_bloc/',
        'package:firebase',
        'package:cloud_firestore',
        '/data/',
        '/presentation/',
        'core/di/',
        'core/router/',
      ]),
      isEmpty,
    );
  });

  test('data does not depend on presentation', () {
    expect(violations('data', ['/presentation/']), isEmpty);
  });

  test('presentation never depends on data', () {
    expect(violations('presentation', ['/data/']), isEmpty);
  });
}
