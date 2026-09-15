import 'dart:convert';
import 'dart:io';

/// Loads a JSON fixture as a raw string.
///
/// `[name]` encodes the adapter directory, so the same loader serves every
/// adapter: `fixture('ottohub/video_detail')` reads
/// `test/adapters/ottohub/fixtures/video_detail.json`, and
/// 适配器 fixtures 存放于各适配器 test 目录
///
/// `flutter test` runs with the package root as the working directory, so
/// relative paths resolve from there.
String fixture(String name) {
  final parts = name.split('/');
  if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
    throw ArgumentError.value(
      name,
      'name',
      'expected "<adapter>/<fixture>" (e.g. "ottohub/video_detail")',
    );
  }
  final file = File('test/adapters/${parts[0]}/fixtures/${parts[1]}.json');
  if (!file.existsSync()) {
    throw FileSystemException('fixture not found', file.absolute.path);
  }
  return file.readAsStringSync();
}

/// Loads and JSON-decodes a fixture (see [fixture] for the path convention).
Map<String, dynamic> fixtureJson(String name) {
  return jsonDecode(fixture(name)) as Map<String, dynamic>;
}
