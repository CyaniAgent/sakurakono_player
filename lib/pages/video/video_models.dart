// 视频播放详情页（lib/pages/video/）页域模型。
//
// 本文件归属通用页面层（零适配器依赖）。播放画质/音质/解码格式等枚举
// 原为 B站 适配器 `models/common/video/` 下的纯值枚举，随 video 域迁移
// 而成为页面层模型；字幕/语言/音量小模型为适配器 DTO 的页域镜像，
// 由适配器侧（video_parts/）负责与 B站 DTO 互转。

/// 视频画质（B站 画质码，页面层持有，适配器侧从 JSON 解析后按码值使用）。
enum VideoQuality {
  hdrVivid(129, 'HDR Vivid', 'HDR Vivid'),
  super8k(127, '8K 超高清', '8K'),
  dolbyVision(126, '杜比视界', '杜比'),
  hdr(125, 'HDR 真彩', 'HDR'),
  super4K(120, '4K 超清', '4K'),
  high108060(116, '1080P 60帧', '1080P60'),
  high1080plus(112, '1080P 高码率', '1080P+'),
  high1080(80, '1080P 高清', '1080P'),
  high72060(74, '720P 60帧', '720P60'),
  high720(64, '720P 准高清', '720P'),
  clear480(32, '480P 清晰', '480P'),
  fluent360(16, '360P 流畅', '360P'),
  speed240(6, '240P 极速', '240P'),
  ;

  final int code;
  final String desc;
  final String shortDesc;

  const VideoQuality(this.code, this.desc, this.shortDesc);

  static final _codeMap = {for (final i in values) i.code: i};

  static VideoQuality fromCode(int code) =>
      _codeMap[code] ?? VideoQuality.fluent360;
}

/// 音频质量（B站 音质码，页面层持有）。
enum AudioQuality {
  u_100010(100010, '100010'),
  u_100009(100009, '100009'),
  u_100008(100008, '100008'),
  hiRes(30251, 'Hi-Res无损'),
  dolby_30250(30250, '杜比全景声'),
  dolby_30255(30255, '杜比全景声'),
  k192(30280, '192K'),
  k132(30232, '132K'),
  k64(30216, '64K'),
  ;

  final int code;
  final String desc;

  const AudioQuality(this.code, this.desc);

  static final _codeMap = {for (final i in values) i.code: i};

  static AudioQuality fromCode(int code) => _codeMap[code] ?? AudioQuality.values.first;
}

// ignore_for_file: constant_identifier_names

/// 视频解码格式。
enum VideoDecodeFormatType {
  DVH1(['dvh1']),
  AV1(['av01']),
  HEVC(['hev1', 'hvc1']),
  AVC(['avc1']),
  ;

  String get description => name;
  final List<String> codes;

  const VideoDecodeFormatType(this.codes);

  static VideoDecodeFormatType fromString(String val) =>
      values.firstWhere((i) => i.codes.any(val.startsWith));
}

/// 字幕偏好（自动选择字幕轨策略）。
enum SubtitlePrefType {
  off('默认不显示字幕'),
  on('优先选择（含自动生成(ai)字幕）'),
  withoutAi('优先选择（不含自动生成(ai)字幕）'),
  auto('播放时用同步到，非播放时用同步到'),
  ;

  final String desc;
  const SubtitlePrefType(this.desc);
}

/// 字幕轨条目（适配器 Subtitle DTO 的页域镜像，字段一致以便互转）。
class VideoSubtitleItem implements Comparable<VideoSubtitleItem> {
  final String lan;
  final String? lanDoc;
  final String? subtitleUrl;
  final bool isAi;

  const VideoSubtitleItem({
    required this.lan,
    this.lanDoc,
    this.subtitleUrl,
    this.isAi = false,
  });

  factory VideoSubtitleItem.fromMap(Map<String, dynamic> json) {
    final isAi = json['type'] == 1;
    return VideoSubtitleItem(
      lan: json['lan'] as String? ?? '',
      lanDoc: '${json['lan_doc']}${isAi ? '（AI）' : ''}',
      subtitleUrl: json['subtitle_url'] as String?,
      isAi: isAi,
    );
  }

  @override
  int compareTo(VideoSubtitleItem other) {
    final thisHasZh = lan.contains('zh');
    final otherHasZh = other.lan.contains('zh');
    if (thisHasZh != otherHasZh) return thisHasZh ? -1 : 1;
    if (isAi != other.isAi) return isAi ? 1 : -1;
    return 0;
  }
}

/// 多语言轨道条目（适配器 LanguageItem DTO 的页域镜像）。
class VideoLanguageItem {
  final String? lang;
  final String? title;
  final String? subtitleLang;
  final bool isAi;

  const VideoLanguageItem({
    this.lang,
    this.title,
    this.subtitleLang,
    this.isAi = false,
  });

  factory VideoLanguageItem.fromMap(Map<String, dynamic> json) {
    final isAi = json['production_type'] == 2;
    return VideoLanguageItem(
      lang: json['lang'] as String?,
      isAi: isAi,
      title: '${json['title']}${isAi ? '（AI）' : ''}',
      subtitleLang: json['subtitle_lang'] as String?,
    );
  }
}

/// 响度音量（适配器 Volume DTO 的页域镜像，供播放器初始化使用）。
class VideoVolume {
  final num? measuredI;
  final num? measuredLra;
  final num? measuredTp;
  final num? measuredThreshold;
  final num? targetOffset;
  final num? targetI;
  final num? targetTp;

  const VideoVolume({
    this.measuredI,
    this.measuredLra,
    this.measuredTp,
    this.measuredThreshold,
    this.targetOffset,
    this.targetI,
    this.targetTp,
  });

  factory VideoVolume.fromMap(Map<String, dynamic> json) {
    num? read(String key) {
      final v = json[key];
      return v is num ? v : null;
    }

    return VideoVolume(
      measuredI: read('measured_i'),
      measuredLra: read('measured_lra'),
      measuredTp: read('measured_tp'),
      measuredThreshold: read('measured_threshold'),
      targetOffset: read('target_offset'),
      targetI: read('target_i'),
      targetTp: read('target_tp'),
    );
  }

  Map<String, dynamic> toMap() => {
    'measured_i': measuredI,
    'measured_lra': measuredLra,
    'measured_tp': measuredTp,
    'measured_threshold': measuredThreshold,
    'target_offset': targetOffset,
    'target_i': targetI,
    'target_tp': targetTp,
  };
}
