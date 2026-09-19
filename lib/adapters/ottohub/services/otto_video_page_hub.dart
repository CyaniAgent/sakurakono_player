// OttoHub 视频页跨面板共享状态。
//
// OttoVideoHost 持有每 heroTag 一份 [OttoVideoPageState];简介面板拉取
// 成功后回写标题/评论数,评论 tab 标签与播放器头部经 ChangeNotifier
// 监听刷新。回复面板把自己的滚动控制器登记到 hub,供 tab 点击回顶。

import 'package:flutter/widgets.dart'
    show ChangeNotifier, ScrollController;

/// 单个视频页的共享数据(标题 / 评论数 / UP主)。
class OttoVideoPageState extends ChangeNotifier {
  String _title = '';
  String get title => _title;
  set title(String value) {
    if (_title != value) {
      _title = value;
      notifyListeners();
    }
  }

  int _commentCount = 0;
  int get commentCount => _commentCount;
  set commentCount(int value) {
    if (_commentCount != value) {
      _commentCount = value;
      notifyListeners();
    }
  }

  /// UP主 mid(评论区 UP 徽章),简介拉取后回填;-1 表示未知。
  int upMid = -1;
}

/// heroTag → 页面状态 / 回复滚动控制器的注册表。
class OttoVideoPageHub {
  final Map<String, OttoVideoPageState> _states = {};

  /// 回复面板登记的滚动控制器(仅引用;控制器由面板自己 dispose)。
  final Map<String, ScrollController> replyScrollCtrs = {};

  OttoVideoPageState state(String heroTag) =>
      _states.putIfAbsent(heroTag, OttoVideoPageState.new);

  /// 页面销毁时清理(滚动控制器归面板所有,这里只清引用)。
  void dispose(String heroTag) {
    _states.remove(heroTag)?.dispose();
    replyScrollCtrs.remove(heroTag);
  }
}
