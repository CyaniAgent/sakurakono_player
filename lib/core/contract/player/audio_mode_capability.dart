// 听音频能力:将当前视频切换到后台音频播放页。

/// 听音频能力宿主。
abstract class AudioModeCapability {
  /// 本适配器是否支持听音频。
  bool get supported;

  /// 打开音频播放页。
  void openAudioPage(String heroTag);
}
