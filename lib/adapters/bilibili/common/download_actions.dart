import 'dart:async';

import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/common/setting_providers.dart';
import 'package:skf/adapters/bilibili/models/common/video/source_type.dart';
import 'package:skf/pages/video/video_models.dart';
import 'package:skf/adapters/bilibili/models/common/video/video_type.dart';
import 'package:skf/adapters/bilibili/models_new/download/bili_download_entry_info.dart';
import 'package:skf/adapters/bilibili/services/download/download_service.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/download_types.dart';
import 'package:skf/pages/download/download_actions.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

/// download 域动作契约的 B站 实现（bridge `register()` 注入）。
///
/// 委托 [DownloadService]（留在 adapter，管理 B站 下载队列/文件），在
/// core 模型与 adapter DTO 之间做 JSON round-trip 转换（字段 1:1）。
class BiliDownloadActions implements DownloadActions {
  BiliDownloadActions() {
    _service = appRead(downloadServiceProvider);
    _syncQueue();
    _service.waitDownloadQueue.listen((_) => _syncQueue());
    _service.curDownload.listen((_) => _syncCur());
  }

  late final DownloadService _service;

  /// core 镜像队列（与 service.waitDownloadQueue 同步，按 cid 复用实例，
  /// 保留多选 checked 状态与页面持有的 entry 引用）。
  final _coreQueue = RxList<CoreDownloadEntryInfo>();
  final _coreCur = Rxn<CoreDownloadEntryInfo>();
  final _coreByCid = <int, CoreDownloadEntryInfo>{};

  @override
  Future<void> get waitForInitialization => _service.waitForInitialization;

  @override
  List<CoreDownloadEntryInfo> get downloadList => [
    for (final e in _service.downloadList) _toCore(e),
  ];

  @override
  RxList<CoreDownloadEntryInfo> get waitDownloadQueue => _coreQueue;

  @override
  int? get curCid => _service.curCid;

  @override
  Rxn<CoreDownloadEntryInfo> get curDownload => _coreCur;

  @override
  void addFlagListener(VoidCallback listener) {
    _service.flagNotifier.add(listener);
  }

  @override
  void removeFlagListener(VoidCallback listener) {
    _service.flagNotifier.remove(listener);
  }

  @override
  void refreshFlagListeners() {
    _service.flagNotifier.refresh();
  }

  @override
  Future<bool> downloadDanmaku({
    required CoreDownloadEntryInfo entry,
    bool isUpdate = false,
  }) =>
      _service.downloadDanmaku(entry: _toAdapter(entry), isUpdate: isUpdate);

  @override
  Future<void> deleteDownload({
    required CoreDownloadEntryInfo entry,
    bool removeList = false,
    bool removeQueue = false,
    bool refresh = true,
    bool downloadNext = true,
  }) =>
      _service.deleteDownload(
        entry: _toAdapter(entry),
        removeList: removeList,
        removeQueue: removeQueue,
        refresh: refresh,
        downloadNext: downloadNext,
      );

  @override
  Future<void> deletePage({
    required String pageDirPath,
    bool refresh = true,
  }) =>
      _service.deletePage(pageDirPath: pageDirPath, refresh: refresh);

  @override
  Future<void> cancelDownload({
    required bool isDelete,
    bool downloadNext = true,
  }) =>
      _service.cancelDownload(isDelete: isDelete, downloadNext: downloadNext);

  @override
  Future<void> startDownload(CoreDownloadEntryInfo entry) =>
      _service.startDownload(_toAdapter(entry));

  @override
  void nextDownload() {
    _service.nextDownload();
  }

  @override
  void removeFromQueue(Iterable<CoreDownloadEntryInfo> entries) {
    final cids = entries.map((e) => e.cid).toSet();
    _service.waitDownloadQueue.removeWhere((e) => cids.contains(e.cid));
    _syncQueue();
  }

  @override
  Future<void>? playLocal(CoreDownloadEntryInfo entry) {
    final adapter = _toAdapter(entry);
    return PageUtils.toVideoPage(
      aid: adapter.avid,
      cid: adapter.cid,
      cover: adapter.cover,
      title: adapter.showTitle,
      isVertical: adapter.pageData?.isVertical ?? false,
      extraArguments: {
        'sourceType': SourceType.file,
        'entry': adapter,
        'dirPath': adapter.entryDirPath,
      },
    );
  }

  @override
  void viewDetail(CoreDownloadEntryInfo entry) {
    if (entry.ep case final ep?) {
      if (ep.from == VideoType.pugv.name) {
        PageUtils.viewPugv(seasonId: entry.seasonId, epId: ep.episodeId);
      } else {
        PageUtils.viewPgc(seasonId: entry.seasonId, epId: ep.episodeId);
      }
      return;
    }
    PageUtils.toVideoPage(
      aid: entry.avid,
      bvid: entry.bvid,
      cid: entry.cid,
      epId: entry.ep?.episodeId,
      title: entry.title,
      cover: entry.cover,
      isVertical: entry.pageData?.isVertical ?? false,
    );
  }

  @override
  String? qualityShortDesc(int? videoQualityCode) {
    if (videoQualityCode == null) {
      return null;
    }
    for (final q in VideoQuality.values) {
      if (q.code == videoQualityCode) {
        return q.shortDesc;
      }
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // Core ↔ adapter 转换（字段 1:1，JSON round-trip；status/路径不在 JSON 中需手动拷贝）
  // -------------------------------------------------------------------------

  void _syncQueue() {
    final wanted = <CoreDownloadEntryInfo>[
      for (final e in _service.waitDownloadQueue) _toCore(e),
    ];
    _coreQueue.value = wanted;
    _coreQueue.refresh();
  }

  void _syncCur() {
    final cur = _service.curDownload.value;
    _coreCur.value = cur == null ? null : _toCore(cur);
    _coreCur.refresh();
  }

  CoreDownloadEntryInfo _toCore(BiliDownloadEntryInfo e) {
    final cached = _coreByCid[e.cid];
    if (cached != null) {
      cached
        ..status = CoreDownloadStatus.values.byName(e.status.name)
        ..downloadedBytes = e.downloadedBytes
        ..totalBytes = e.totalBytes
        ..isCompleted = e.isCompleted
        ..pageDirPath = e.pageDirPath
        ..entryDirPath = e.entryDirPath;
      final pageData = e.pageData;
      if (pageData != null && cached.pageData != null) {
        cached.pageData!
          ..width = pageData.width
          ..height = pageData.height;
      }
      final ep = e.ep;
      if (ep != null && cached.ep != null) {
        cached.ep!
          ..width = ep.width
          ..height = ep.height;
      }
      return cached;
    }
    final core = CoreDownloadEntryInfo.fromJson(e.toJson())
      ..status = CoreDownloadStatus.values.byName(e.status.name)
      ..pageDirPath = e.pageDirPath
      ..entryDirPath = e.entryDirPath;
    _coreByCid[e.cid] = core;
    return core;
  }

  BiliDownloadEntryInfo _toAdapter(CoreDownloadEntryInfo entry) =>
      BiliDownloadEntryInfo.fromJson(entry.toJson())
        ..status = DownloadStatus.values.byName(entry.status.name)
        ..pageDirPath = entry.pageDirPath
        ..entryDirPath = entry.entryDirPath;
}
