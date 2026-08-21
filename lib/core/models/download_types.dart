/// Core data types for the download repository.
///
/// These are pure data classes (no UI, no adapter dependencies) with
/// JSON serialization. They mirror the adapter-level models in
/// `lib/adapters/bilibili/models_new/download/` but are free of
/// Bilibili-specific UI and platform code.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skf/core/models/ui/multi_select_data.dart';

part 'download_types.freezed.dart';
part 'download_types.g.dart';

// ---------------------------------------------------------------------------
// CoreDownloadEntryInfo
// ---------------------------------------------------------------------------

class CoreDownloadEntryInfo with MultiSelectData {
  int mediaType;
  bool hasDashAudio;
  bool isCompleted;
  int totalBytes;
  int downloadedBytes;
  final String title;
  String? typeTag;
  final String cover;
  int? videoQuality;
  int preferedVideoQuality;
  String qualityPithyDescription;
  final int guessedTotalBytes;
  int totalTimeMilli;
  final int danmakuCount;
  final int timeUpdateStamp;
  final int timeCreateStamp;
  final bool canPlayInAdvance;
  bool interruptTransformTempFile;
  final int avid;
  final int? spid;
  final String bvid;
  final int? ownerId;
  final String? ownerName;
  CorePageInfo? pageData;
  final String? seasonId;
  final CoreSourceInfo? source;
  CoreEpInfo? ep;

  String pageDirPath = '';
  String entryDirPath = '';
  CoreDownloadStatus status = CoreDownloadStatus.wait;

  int get cid => source?.cid ?? pageData!.cid;

  String get pageId => seasonId ?? avid.toString();

  int get sortKey => ep?.sortIndex ?? pageData!.cid;

  String get showTitle {
    if (pageData case CorePageInfo(:final part)) {
      return part != null && part.isNotEmpty ? part : title;
    }
    if (ep case final ep?) {
      return ep.showTitle ?? '${ep.index} ${ep.indexTitle}';
    }
    return title;
  }

  CoreDownloadEntryInfo({
    this.mediaType = 1,
    this.hasDashAudio = false,
    required this.isCompleted,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.title,
    this.typeTag,
    required this.cover,
    this.videoQuality,
    required this.preferedVideoQuality,
    this.qualityPithyDescription = '',
    required this.guessedTotalBytes,
    required this.totalTimeMilli,
    required this.danmakuCount,
    this.timeUpdateStamp = 0,
    this.timeCreateStamp = 0,
    this.canPlayInAdvance = false,
    this.interruptTransformTempFile = false,
    required this.avid,
    this.spid,
    required this.bvid,
    this.ownerId,
    this.ownerName,
    this.pageData,
    this.seasonId,
    this.source,
    this.ep,
  });

  factory CoreDownloadEntryInfo.fromJson(Map<String, dynamic> json) =>
      CoreDownloadEntryInfo(
        mediaType: json['media_type'] as int,
        hasDashAudio: json['has_dash_audio'] as bool,
        isCompleted: json['is_completed'] as bool,
        totalBytes: json['total_bytes'] as int,
        downloadedBytes: json['downloaded_bytes'] as int,
        title: json['title'] as String,
        typeTag: json['type_tag'] as String?,
        cover: json['cover'] as String,
        videoQuality: json['video_quality'] as int?,
        preferedVideoQuality: json['prefered_video_quality'] as int,
        qualityPithyDescription: json['quality_pithy_description'] as String,
        guessedTotalBytes: json['guessed_total_bytes'] as int,
        totalTimeMilli: json['total_time_milli'] as int,
        danmakuCount: json['danmaku_count'] as int,
        timeUpdateStamp: json['time_update_stamp'] as int,
        timeCreateStamp: json['time_create_stamp'] as int,
        canPlayInAdvance: json['can_play_in_advance'] as bool,
        interruptTransformTempFile:
            json['interrupt_transform_temp_file'] as bool,
        avid: json['avid'] as int,
        spid: json['spid'] as int?,
        bvid: json['bvid'] as String,
        ownerId: json['owner_id'] as int?,
        ownerName: json['owner_name'] as String?,
        pageData: json['page_data'] != null
            ? CorePageInfo.fromJson(json['page_data'] as Map<String, dynamic>)
            : null,
        seasonId: json['season_id'] as String?,
        source: json['source'] != null
            ? CoreSourceInfo.fromJson(json['source'] as Map<String, dynamic>)
            : null,
        ep: json['ep'] != null
            ? CoreEpInfo.fromJson(json['ep'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'media_type': mediaType,
    'has_dash_audio': hasDashAudio,
    'is_completed': isCompleted,
    'total_bytes': totalBytes,
    'downloaded_bytes': downloadedBytes,
    'title': title,
    'type_tag': typeTag,
    'cover': cover,
    'video_quality': videoQuality,
    'prefered_video_quality': preferedVideoQuality,
    'quality_pithy_description': qualityPithyDescription,
    'guessed_total_bytes': guessedTotalBytes,
    'total_time_milli': totalTimeMilli,
    'danmaku_count': danmakuCount,
    'time_update_stamp': timeUpdateStamp,
    'time_create_stamp': timeCreateStamp,
    'can_play_in_advance': canPlayInAdvance,
    'interrupt_transform_temp_file': interruptTransformTempFile,
    'avid': avid,
    'spid': spid,
    'bvid': bvid,
    'owner_id': ownerId,
    'owner_name': ownerName,
    'page_data': pageData?.toJson(),
    'season_id': seasonId,
    'source': source?.toJson(),
    'ep': ep?.toJson(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is CoreDownloadEntryInfo) {
      return cid == other.cid;
    }
    return false;
  }

  @override
  int get hashCode => cid.hashCode;
}

// ---------------------------------------------------------------------------
// CorePageInfo
// ---------------------------------------------------------------------------

class CorePageInfo {
  final int cid;
  final int page;
  final String? from;
  final String? part;
  final String? vid;
  final bool hasAlias;
  final int tid;
  int width;
  int height;
  final int rotate;
  final String? downloadTitle;
  final String? downloadSubtitle;

  bool get cacheWidth => width <= height;

  bool get isVertical => rotate == 1 ? width > height : height > width;

  CorePageInfo({
    required this.cid,
    required this.page,
    this.from,
    this.part,
    this.vid,
    required this.hasAlias,
    required this.tid,
    this.width = 0,
    this.height = 0,
    this.rotate = 0,
    this.downloadTitle,
    this.downloadSubtitle,
  });

  factory CorePageInfo.fromJson(Map<String, dynamic> json) => CorePageInfo(
    cid: json['cid'] as int,
    page: json['page'] as int,
    from: json['from'] as String?,
    part: json['part'] as String?,
    vid: json['vid'] as String?,
    hasAlias: json['has_alias'] as bool,
    tid: json['tid'] as int,
    width: json['width'] as int,
    height: json['height'] as int,
    rotate: json['rotate'] as int,
    downloadTitle: json['download_title'] as String?,
    downloadSubtitle: json['download_subtitle'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'cid': cid,
    'page': page,
    'from': from,
    'part': part,
    'vid': vid,
    'has_alias': hasAlias,
    'tid': tid,
    'width': width,
    'height': height,
    'rotate': rotate,
    'download_title': downloadTitle,
    'download_subtitle': downloadSubtitle,
  };
}

// ---------------------------------------------------------------------------
// CoreSourceInfo
// ---------------------------------------------------------------------------

@freezed
abstract class CoreSourceInfo with _$CoreSourceInfo {
  const factory CoreSourceInfo({
    required int avId,
    required int cid,
  }) = _CoreSourceInfo;

  factory CoreSourceInfo.fromJson(Map<String, dynamic> json) =>
      _$CoreSourceInfoFromJson(json);
}

// ---------------------------------------------------------------------------
// CoreEpInfo
// ---------------------------------------------------------------------------

class CoreEpInfo {
  final int avId;
  final int page;
  final int danmaku;
  final String cover;
  final int episodeId;
  final String index;
  final String indexTitle;
  final String? showTitle;
  final String from;
  final int seasonType;
  int width;
  int height;
  final int rotate;
  final String link;
  final String bvid;
  final int sortIndex;

  CoreEpInfo({
    required this.avId,
    required this.page,
    required this.danmaku,
    required this.cover,
    required this.episodeId,
    required this.index,
    required this.indexTitle,
    this.showTitle,
    required this.from,
    required this.seasonType,
    required this.width,
    required this.height,
    required this.rotate,
    this.link = '',
    this.bvid = '',
    this.sortIndex = 0,
  });

  factory CoreEpInfo.fromJson(Map<String, dynamic> json) => CoreEpInfo(
    avId: json['av_id'] as int,
    page: json['page'] as int,
    danmaku: json['danmaku'] as int,
    cover: json['cover'] as String,
    episodeId: json['episode_id'] as int,
    index: json['index'] as String,
    indexTitle: json['index_title'] as String,
    showTitle: json['show_title'] as String?,
    from: json['from'] as String,
    seasonType: json['season_type'] as int,
    width: json['width'] as int,
    height: json['height'] as int,
    rotate: json['rotate'] as int,
    link: json['link'] as String,
    bvid: json['bvid'] as String,
    sortIndex: json['sort_index'] as int,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'av_id': avId,
    'page': page,
    'danmaku': danmaku,
    'cover': cover,
    'episode_id': episodeId,
    'index': index,
    'index_title': indexTitle,
    'show_title': showTitle,
    'from': from,
    'season_type': seasonType,
    'width': width,
    'height': height,
    'rotate': rotate,
    'link': link,
    'bvid': bvid,
    'sort_index': sortIndex,
  };
}

// ---------------------------------------------------------------------------
// CoreDownloadStatus
// ---------------------------------------------------------------------------

enum CoreDownloadStatus {
  downloading('正在下载'),
  audioDownloading('正在下载音频'),
  getDanmaku('获取弹幕'),
  getPlayUrl('获取播放地址'),
  completed('下载完成'),
  failDownload('下载失败'),
  failDownloadAudio('音频下载失败'),
  failDanmaku('获取弹幕失败'),
  failPlayUrl('获取播放地址失败'),
  pause('暂停中'),
  wait('等待中'),
  ;

  final String message;
  const CoreDownloadStatus(this.message);

  bool get isDownloading => index <= 3;
}

// ---------------------------------------------------------------------------
// CoreDownloadMediaInfo (sealed class hierarchy)
// ---------------------------------------------------------------------------

sealed class CoreDownloadMediaInfo {
  const CoreDownloadMediaInfo();

  Map<String, String> get httpHeader => {};

  Map<String, dynamic> toJson();
}

class CoreType1 extends CoreDownloadMediaInfo {
  final int availablePeriodMilli;
  final String description;
  final String format;
  final String? from;
  final bool intact;
  final bool isDownloaded;
  final bool isResolved;
  final String marlinToken;
  final bool needLogin;
  final bool needVip;
  final int parseTimestampMilli;
  final List<CoreType1PlayerCodecConfig> playerCodecConfigList;
  final int playerError;
  final int quality;
  final List<CoreType1Segment> segmentList;
  final int timeLength;
  final String? typeTag;
  final String? userAgent;
  final String? referer;
  final int videoCodecId;
  final bool videoProject;

  @override
  Map<String, String> get httpHeader => {
    if (referer?.isNotEmpty ?? false) 'referer': referer!,
    if (userAgent?.isNotEmpty ?? false) 'user-agent': userAgent!,
  };

  CoreType1({
    required this.availablePeriodMilli,
    required this.description,
    required this.format,
    this.from,
    required this.intact,
    required this.isDownloaded,
    required this.isResolved,
    required this.marlinToken,
    required this.needLogin,
    required this.needVip,
    required this.parseTimestampMilli,
    required this.playerCodecConfigList,
    required this.playerError,
    required this.quality,
    required this.segmentList,
    required this.timeLength,
    this.typeTag,
    this.userAgent,
    this.referer,
    required this.videoCodecId,
    required this.videoProject,
  });

  factory CoreType1.fromJson(Map<String, dynamic> json) => CoreType1(
    availablePeriodMilli: json['available_period_milli'] as int,
    description: json['description'] as String,
    format: json['format'] as String,
    from: json['from'] as String?,
    intact: json['intact'] as bool,
    isDownloaded: json['is_downloaded'] as bool,
    isResolved: json['is_resolved'] as bool,
    marlinToken: json['marlin_token'] as String,
    needLogin: json['need_login'] as bool,
    needVip: json['need_vip'] as bool,
    parseTimestampMilli: json['parse_timestamp_milli'] as int,
    playerCodecConfigList: (json['player_codec_config_list'] as List<dynamic>)
        .map((e) => CoreType1PlayerCodecConfig.fromJson(e as Map<String, dynamic>))
        .toList(),
    playerError: json['player_error'] as int,
    quality: json['quality'] as int,
    segmentList: (json['segment_list'] as List<dynamic>)
        .map((e) => CoreType1Segment.fromJson(e as Map<String, dynamic>))
        .toList(),
    timeLength: json['time_length'] as int,
    typeTag: json['type_tag'] as String?,
    userAgent: json['user_agent'] as String?,
    referer: json['referer'] as String?,
    videoCodecId: json['video_codec_id'] as int,
    videoProject: json['video_project'] as bool,
  );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'available_period_milli': availablePeriodMilli,
    'description': description,
    'format': format,
    'from': from,
    'intact': intact,
    'is_downloaded': isDownloaded,
    'is_resolved': isResolved,
    'marlin_token': marlinToken,
    'need_login': needLogin,
    'need_vip': needVip,
    'parse_timestamp_milli': parseTimestampMilli,
    'player_codec_config_list': playerCodecConfigList
        .map((e) => e.toJson())
        .toList(),
    'player_error': playerError,
    'quality': quality,
    'segment_list': segmentList.map((e) => e.toJson()).toList(),
    'time_length': timeLength,
    'type_tag': typeTag,
    'user_agent': userAgent,
    'referer': referer,
    'video_codec_id': videoCodecId,
    'video_project': videoProject,
  };
}

@freezed
abstract class CoreType1PlayerCodecConfig with _$CoreType1PlayerCodecConfig {
  const factory CoreType1PlayerCodecConfig({
    required String player,
    required bool useIjkMediaCodec,
  }) = _CoreType1PlayerCodecConfig;

  factory CoreType1PlayerCodecConfig.fromJson(Map<String, dynamic> json) =>
      _$CoreType1PlayerCodecConfigFromJson(json);
}

@freezed
abstract class CoreType1Segment with _$CoreType1Segment {
  const factory CoreType1Segment({
    required List<String> backupUrls,
    required int bytes,
    @Default(0) int duration,
    required String md5,
    required String metaUrl,
    required int order,
    required String url,
  }) = _CoreType1Segment;

  factory CoreType1Segment.fromJson(Map<String, dynamic> json) =>
      _$CoreType1SegmentFromJson(json);
}

class CoreType2 extends CoreDownloadMediaInfo {
  final int duration;
  final List<CoreType2File> video;
  final List<CoreType2File>? audio;
  final String? userAgent;
  final String? referer;

  CoreType2({
    this.duration = 0,
    required this.video,
    this.audio,
    this.userAgent,
    this.referer,
  });

  @override
  Map<String, String> get httpHeader => {
    if (referer?.isNotEmpty ?? false) 'referer': referer!,
    if (userAgent?.isNotEmpty ?? false) 'user-agent': userAgent!,
  };

  factory CoreType2.fromJson(Map<String, dynamic> json) => CoreType2(
    duration: json['duration'] as int,
    video: (json['video'] as List<dynamic>)
        .map((e) => CoreType2File.fromJson(e as Map<String, dynamic>))
        .toList(),
    audio: (json['audio'] as List<dynamic>?)
        ?.map((e) => CoreType2File.fromJson(e as Map<String, dynamic>))
        .toList(),
    userAgent: json['user_agent'] as String?,
    referer: json['referer'] as String?,
  );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'duration': duration,
    'video': video.map((e) => e.toJson()).toList(),
    'audio': audio?.map((e) => e.toJson()).toList(),
    'user_agent': userAgent,
    'referer': referer,
  };
}

class CoreType2File {
  final int id;
  final String baseUrl;
  final List<String>? backupUrl;
  final int bandwidth;
  final int codecid;
  int size;
  final String md5;
  final bool noRexcode;
  final String frameRate;
  final int width;
  final int height;
  final int dashDrmType;

  CoreType2File({
    required this.id,
    required this.baseUrl,
    this.backupUrl,
    required this.bandwidth,
    required this.codecid,
    required this.size,
    required this.md5,
    required this.noRexcode,
    this.frameRate = '',
    this.width = 1,
    this.height = 1,
    this.dashDrmType = 0,
  });

  factory CoreType2File.fromJson(Map<String, dynamic> json) => CoreType2File(
    id: json['id'] as int,
    baseUrl: json['base_url'] as String,
    backupUrl: (json['backup_url'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    bandwidth: json['bandwidth'] as int,
    codecid: json['codecid'] as int,
    size: json['size'] as int,
    md5: json['md5'] as String,
    noRexcode: json['no_rexcode'] as bool,
    frameRate: json['frame_rate'] as String? ?? '',
    width: json['width'] as int,
    height: json['height'] as int,
    dashDrmType: json['dash_drm_type'] as int,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'base_url': baseUrl,
    'backup_url': backupUrl,
    'bandwidth': bandwidth,
    'codecid': codecid,
    'size': size,
    'md5': md5,
    'no_rexcode': noRexcode,
    'frame_rate': frameRate,
    'width': width,
    'height': height,
    'dash_drm_type': dashDrmType,
  };
}

class CoreNone extends CoreDownloadMediaInfo {
  final String message;

  const CoreNone({
    required this.message,
  });

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}