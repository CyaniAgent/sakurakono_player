import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:get/get.dart';
import 'package:skf/core/models/download_types.dart';

/// download 域页面动作契约（页面通用，动作由适配器注入）。
///
/// download 页渲染通用下载管理 UI（列表/正在下载/详情/搜索）；下载服务
/// （[CoreDownloadEntryInfo] 队列与文件操作）与本地文件播放导航来自
/// [DownloadActions.of()] 的实现：
/// - Bilibili: `BiliDownloadActions`（bridge `register()` 注入，委托 DownloadService）
/// - OttoHub: `OttoDownloadActions`（stub，空状态防崩溃）
abstract class DownloadActions {
  static DownloadActions of() => Get.find<DownloadActions>();

  /// 初始化完成信号（Bilibili: `DownloadService.waitForInitialization`）。
  Future<void> get waitForInitialization;

  /// 已下载条目列表。
  List<CoreDownloadEntryInfo> get downloadList;

  /// 正在下载队列（响应式，页面 Obx 订阅）。
  RxList<CoreDownloadEntryInfo> get waitDownloadQueue;

  /// 当前下载 cid。
  int? get curCid;

  /// 当前下载条目（响应式，页面 Obx 订阅）。
  Rxn<CoreDownloadEntryInfo> get curDownload;

  /// 列表刷新通知（Bilibili: `DownloadService.flagNotifier`）。
  void addFlagListener(VoidCallback listener);

  void removeFlagListener(VoidCallback listener);

  void refreshFlagListeners();

  /// 下载弹幕（返回是否成功）。
  Future<bool> downloadDanmaku({
    required CoreDownloadEntryInfo entry,
    bool isUpdate = false,
  });

  /// 删除单个下载（含文件）。
  Future<void> deleteDownload({
    required CoreDownloadEntryInfo entry,
    bool removeList = false,
    bool removeQueue = false,
    bool refresh = true,
    bool downloadNext = true,
  });

  /// 删除整个页面目录（含文件）。
  Future<void> deletePage({
    required String pageDirPath,
    bool refresh = true,
  });

  /// 取消当前下载。
  Future<void> cancelDownload({
    required bool isDelete,
    bool downloadNext = true,
  });

  /// 开始下载队列中的条目。
  Future<void> startDownload(CoreDownloadEntryInfo entry);

  /// 队列中的下一个。
  void nextDownload();

  /// 从等待队列移除条目（多选删除时同步服务端队列）。
  void removeFromQueue(Iterable<CoreDownloadEntryInfo> entries);

  /// 播放本地缓存文件（Bilibili: `PageUtils.toVideoPage` + `SourceType.file`）。
  Future<void>? playLocal(CoreDownloadEntryInfo entry);

  /// 打开条目详情页（Bilibili: `PageUtils.viewPgc/viewPugv/toVideoPage`）。
  void viewDetail(CoreDownloadEntryInfo entry);

  /// 画质短描述（Bilibili: `VideoQuality.fromCode(code).shortDesc`；未知 code 返回 null）。
  String? qualityShortDesc(int? videoQualityCode);
}
