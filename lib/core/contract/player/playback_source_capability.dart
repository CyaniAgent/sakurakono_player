// 播放地址/来源能力:清晰度音质选择、解码偏好与分P尺寸回退。

import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/contract/player/playback_models.dart';
import 'package:skf/pages/video/video_models.dart';

/// 播放地址能力宿主。
abstract class PlaybackSourceCapability {
  /// 本适配器是否支持在线播放地址选择。
  bool get supported;

  /// 预设解码格式列表(AVC/HEV/AV01 等)。
  List<VideoDecodeFormatType> get preferCodecs;

  /// 根据播放数据 + 缓存画质/音质选择实际播放地址与解码格式。
  CorePlaybackConfig selectPlayback({
    required CorePlayUrlModel data,
    required int? cacheVideoQa,
    required int cacheAudioQa,
  });

  /// 分P尺寸回退查询。
  ({int width, int height})? partDimension(String heroTag, int cid);
}
