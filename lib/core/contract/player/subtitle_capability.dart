// 字幕能力:获取视频字幕轨道数据。

import 'package:skf/pages/video/video_models.dart';

/// 字幕能力宿主。
abstract class SubtitleCapability {
  /// 本适配器是否支持字幕。
  bool get supported;

  /// 获取字幕数据;无字幕返回 null。
  Future<List<VideoSubtitleItem>?> fetchSubtitles({
    required int aid,
    required int cid,
  });
}
