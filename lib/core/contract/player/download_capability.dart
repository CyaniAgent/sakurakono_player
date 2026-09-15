// 下载面板能力:发起视频离线下载。

import 'package:flutter/widgets.dart';

/// 下载面板能力宿主。
abstract class DownloadPanelCapability {
  /// 本适配器是否支持下载。
  bool get supported;

  /// 打开下载面板。
  Future<void> showDownloadPanel(BuildContext context, String heroTag);
}
