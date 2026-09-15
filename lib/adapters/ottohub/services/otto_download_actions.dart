import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:skf/core/models/download_types.dart';
import 'package:skf/pages/download/download_actions.dart';

/// OttoHub stub for [DownloadActions].
///
/// OttoHub 不支持下载（测试用适配器）：队列/列表恒为空、动作 no-op，
/// 防止共享 Bilibili 下载页打开时读取未注入的动作实现崩溃。
class OttoDownloadActions extends DownloadActions {

  @override
  Future<void> get waitForInitialization => Future.value();

  @override
  List<CoreDownloadEntryInfo> get downloadList => const [];

  @override
  List<CoreDownloadEntryInfo> get waitDownloadQueue => const [];

  @override
  int? get curCid => null;

  @override
  CoreDownloadEntryInfo? get curDownload => null;

  @override
  void addFlagListener(VoidCallback listener) {}

  @override
  void removeFlagListener(VoidCallback listener) {}

  @override
  void refreshFlagListeners() {}

  @override
  Future<bool> downloadDanmaku({
    required CoreDownloadEntryInfo entry,
    bool isUpdate = false,
  }) async =>
      false;

  @override
  Future<void> deleteDownload({
    required CoreDownloadEntryInfo entry,
    bool removeList = false,
    bool removeQueue = false,
    bool refresh = true,
    bool downloadNext = true,
  }) async {}

  @override
  Future<void> deletePage({
    required String pageDirPath,
    bool refresh = true,
  }) async {}

  @override
  Future<void> cancelDownload({
    required bool isDelete,
    bool downloadNext = true,
  }) async {}

  @override
  Future<void> startDownload(CoreDownloadEntryInfo entry) async {}

  @override
  void nextDownload() {}

  @override
  void removeFromQueue(Iterable<CoreDownloadEntryInfo> entries) {}

  @override
  Future<void>? playLocal(CoreDownloadEntryInfo entry) => null;

  @override
  void viewDetail(CoreDownloadEntryInfo entry) {}

  @override
  String? qualityShortDesc(int? videoQualityCode) => null;
}
