// 自发弹幕上屏事件总线(发送面板投递,弹幕层监听)。

import 'dart:async';

import 'package:canvas_danmaku/canvas_danmaku.dart';

class OttoDanmakuBus {
  OttoDanmakuBus._();
  static final _controller =
      StreamController<DanmakuContentItem<int>>.broadcast();
  static Stream<DanmakuContentItem<int>> get stream => _controller.stream;
  static void send(DanmakuContentItem<int> item) => _controller.add(item);
}
