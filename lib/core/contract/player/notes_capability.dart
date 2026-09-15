// 笔记能力:视频笔记列表查看入口。

import 'package:flutter/widgets.dart';

/// 笔记能力宿主。
abstract class NotesCapability {
  /// 本适配器是否支持笔记。
  bool get supported;

  /// 笔记列表弹层。
  void showNoteList(BuildContext context, String heroTag);
}
