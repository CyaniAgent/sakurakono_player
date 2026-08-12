import 'dart:io';

import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/utils/path_utils.dart';
import 'package:skf/utils/storage.dart';

import 'fake_http_adapter.dart';

/// Bootstraps the global Bili [Request] singleton for implementation-level
/// tests: a real Hive store in a throwaway temp dir, with [fake] installed on
/// the singleton's dio so no network is touched.
///
/// Order is load-bearing (AGENTS.md storage init):
/// 1. `tmpDirPath`/`appSupportDirPath` late finals MUST be assigned before any
///    GStorage access — `GStorage.init()` calls `Hive.init(appSupportDirPath)`;
/// 2. `GStorage.init()` opens the 7 Hive boxes under that dir (incl. the
///    `localCache` box WbiSign writes its mixin key into);
/// 3. `Request()` runs the singleton constructor, which reads Pref settings
///    (enableHttp2, retryCount, ...) from those boxes — it would throw on an
///    uninitialized Hive, hence the ordering;
/// 4. `Request.dio.httpClientAdapter = fake` replaces the real HTTP adapter.
///
/// Returns the temp dir; pair with [teardownBiliRequest] (or close GStorage
/// and delete the dir yourself) in `tearDownAll`. Each test file runs in its
/// own isolate, so the singleton, WbiSign's static cache, and the Hive store
/// are all fresh per file.
Future<Directory> bootstrapBiliRequest(FakeHttpAdapter fake) async {
  final tempDir = await Directory.systemTemp.createTemp('skf_bili_test');
  tmpDirPath = tempDir.path;
  appSupportDirPath = tempDir.path;
  await GStorage.init();
  Request();
  Request.dio.httpClientAdapter = fake;
  return tempDir;
}

/// Swaps the singleton's dio adapter for a fresh [FakeHttpAdapter] carrying a
/// per-test route map.
void installBiliFakeHttpAdapter(FakeHttpAdapter fake) {
  Request.dio.httpClientAdapter = fake;
}

/// Closes the Hive boxes and deletes the temp dir created by
/// [bootstrapBiliRequest]. Must run in `tearDownAll`.
Future<void> teardownBiliRequest(Directory tempDir) async {
  await GStorage.close();
  await tempDir.delete(recursive: true);
}
