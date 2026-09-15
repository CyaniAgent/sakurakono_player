// 播放契约的通用值类型。

import 'package:skf/pages/video/video_models.dart';

/// 播放地址选择结果。
class CorePlaybackConfig {
  final String videoUrl;
  final String audioUrl;
  final int videoQaCode;
  final int? audioQaCode;
  final VideoDecodeFormatType decodeFormat;
  final int? width;
  final int? height;

  const CorePlaybackConfig({
    required this.videoUrl,
    required this.audioUrl,
    required this.videoQaCode,
    required this.decodeFormat,
    this.audioQaCode,
    this.width,
    this.height,
  });
}

/// 本地文件条目(B站 BiliDownloadEntryInfo 的页域镜像)。
class CoreFileEntryInfo {
  final int preferedVideoQuality;
  final int? width;
  final int? height;
  final int totalTimeMilli;
  final String? typeTag;
  final int mediaType;
  final bool hasDashAudio;

  const CoreFileEntryInfo({
    required this.preferedVideoQuality,
    this.width,
    this.height,
    required this.totalTimeMilli,
    this.typeTag,
    required this.mediaType,
    required this.hasDashAudio,
  });
}
