import 'dart:io';

import 'package:skf/common/widgets/pair.dart';
import 'package:skf/adapters/bilibili/http/constants.dart';
import 'package:skf/utils/device_utils.dart';
import 'package:skf/utils/global_data.dart';
import 'package:skf/adapters/bilibili/utils/login_utils.dart';
import 'package:skf/adapters/bilibili/utils/bili_storage_key.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import 'package:skf/pages/common/bar_hide_type.dart';
import 'package:skf/pages/common/dynamic_badge_mode.dart';
import 'package:skf/adapters/bilibili/models/common/dynamic/dynamics_type.dart';
import 'package:skf/core/models/ui/up_panel_position.dart';
import 'package:skf/adapters/bilibili/models/common/follow_order_type.dart';
import 'package:skf/adapters/bilibili/models/common/member/tab_type.dart';
import 'package:skf/pages/common/msg_unread_type.dart';
import 'package:skf/adapters/bilibili/models/common/nav_bar_config.dart';
import 'package:skf/adapters/bilibili/models/common/reply/reply_sort_type.dart';
import 'package:skf/adapters/bilibili/models/common/sponsor_block/segment_type.dart';
import 'package:skf/adapters/bilibili/models/common/sponsor_block/skip_type.dart';
import 'package:skf/adapters/bilibili/models/common/super_chat_type.dart';
import 'package:skf/adapters/bilibili/models/common/super_resolution_type.dart';
import 'package:skf/pages/mine/theme_type.dart';
import 'package:skf/pages/video/video_models.dart';
import 'package:skf/adapters/bilibili/models/common/video/cdn_type.dart';
import 'package:skf/adapters/bilibili/models/common/video/live_quality.dart';
import 'package:skf/adapters/bilibili/models/user/danmaku_rule.dart';
import 'package:skf/adapters/bilibili/models/user/info.dart';
import 'package:skf/adapters/bilibili/pages/setting/pages/fullscreen_sc_size.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/models/audio_output_type.dart';
import 'package:skf/player/models/bottom_progress_behavior.dart';
import 'package:skf/player/models/fullscreen_mode.dart';
import 'package:skf/player/models/hwdec_type.dart';
import 'package:skf/player/models/play_repeat.dart';

export 'package:skf/pages/common/bar_hide_type.dart';
export 'package:skf/pages/common/dynamic_badge_mode.dart';
export 'package:skf/adapters/bilibili/models/common/dynamic/dynamics_type.dart';
export 'package:skf/core/models/ui/up_panel_position.dart';
export 'package:skf/adapters/bilibili/models/common/follow_order_type.dart';
export 'package:skf/adapters/bilibili/models/common/member/tab_type.dart';
export 'package:skf/pages/common/msg_unread_type.dart';
export 'package:skf/adapters/bilibili/models/common/nav_bar_config.dart';
export 'package:skf/adapters/bilibili/models/common/reply/reply_sort_type.dart';
export 'package:skf/adapters/bilibili/models/common/sponsor_block/segment_type.dart';
export 'package:skf/adapters/bilibili/models/common/sponsor_block/skip_type.dart';
export 'package:skf/adapters/bilibili/models/common/super_chat_type.dart';
export 'package:skf/adapters/bilibili/models/common/super_resolution_type.dart';
export 'package:skf/pages/mine/theme_type.dart';
export 'package:skf/pages/video/video_models.dart';
export 'package:skf/adapters/bilibili/models/common/video/cdn_type.dart';
export 'package:skf/adapters/bilibili/models/common/video/live_quality.dart';
export 'package:skf/adapters/bilibili/models/user/danmaku_rule.dart';
export 'package:skf/adapters/bilibili/models/user/info.dart';
export 'package:skf/adapters/bilibili/pages/setting/pages/fullscreen_sc_size.dart';
export 'package:skf/adapters/bilibili/plugin/pl_player/models/audio_output_type.dart';
export 'package:skf/player/models/bottom_progress_behavior.dart';
export 'package:skf/player/models/fullscreen_mode.dart';
export 'package:skf/player/models/hwdec_type.dart';
export 'package:skf/player/models/play_repeat.dart';

abstract final class BiliPref {
  static final Box _setting = GStorage.setting;
  static final Box _video = GStorage.video;
  static final Box _localCache = GStorage.localCache;

  static UserInfoData? get userInfoCache =>
      GStorage.userInfo.get('userInfoCache');

  static RuleFilter get danmakuFilterRule => _localCache.get(
    LocalCacheKey.danmakuFilterRules,
    defaultValue: RuleFilter.empty(),
  );

  static void setBlackMid(int mid) => _localCache.put(
    LocalCacheKey.blackMids,
    GlobalData().blackMids..add(mid),
  );

  static void removeBlackMid(int mid) => _localCache.put(
    LocalCacheKey.blackMids,
    GlobalData().blackMids..remove(mid),
  );

  static MemberTabType get memberTab =>
      MemberTabType.values[_setting.get(
        SettingBoxKey.memberTab,
        defaultValue: 0,
      )];

  static int get _themeTypeInt => _setting.get(
    SettingBoxKey.themeMode,
    defaultValue: ThemeType.system.index,
  );

  static ThemeType get themeType => ThemeType.values[_themeTypeInt];

  static List<Pair<SegmentType, SkipType>> get blockSettings {
    final list = _setting.get(SettingBoxKey.blockSettings) as List?;
    if (list == null || list.length != SegmentType.values.length) {
      return SegmentType.values
          .map((i) => Pair(first: i, second: SkipType.skipOnce))
          .toList();
    }
    return SegmentType.values
        .map(
          (item) => Pair(
            first: item,
            second: SkipType.values[list[item.index]],
          ),
        )
        .toList();
  }

  static List<Color> get blockColor {
    final list = _setting.get(SettingBoxKey.blockColor) as List?;
    if (list == null || list.length != SegmentType.values.length) {
      return SegmentType.values.map((i) => i.color).toList();
    }
    return SegmentType.values.map(
      (item) {
        final String e = list[item.index];
        final color = e.isNotEmpty ? int.tryParse('FF$e', radix: 16) : null;
        return color != null ? Color(color) : item.color;
      },
    ).toList();
  }

  static DynamicBadgeMode get dynamicBadgeType =>
      DynamicBadgeMode.values[_setting.get(
        SettingBoxKey.dynamicBadgeMode,
        defaultValue: DynamicBadgeMode.number.index,
      )];

  static DynamicBadgeMode get msgBadgeMode =>
      DynamicBadgeMode.values[_setting.get(
        SettingBoxKey.msgBadgeMode,
        defaultValue: DynamicBadgeMode.number.index,
      )];

  static Set<MsgUnReadType> get msgUnReadTypeV2 =>
      (_setting.get(SettingBoxKey.msgUnReadTypeV2) as List?)
          ?.map((index) => MsgUnReadType.values[index])
          .toSet() ??
      MsgUnReadType.values.toSet();

  static NavigationBarType get defaultHomePage =>
      NavigationBarType.values[defaultHomePageIndex];

  static int get defaultHomePageIndex => _setting.get(
    SettingBoxKey.defaultHomePage,
    defaultValue: NavigationBarType.home.index,
  );

  static UpPanelPosition get upPanelPosition =>
      UpPanelPosition.values[_setting.get(
        SettingBoxKey.upPanelPosition,
        defaultValue: UpPanelPosition.leftFixed.index,
      )];

  static FullScreenMode get fullScreenMode {
    int? index = _setting.get(SettingBoxKey.fullScreenMode);
    if (index == null) {
      bool? horizontalScreen = _setting.get(SettingBoxKey.horizontalScreen);
      if (horizontalScreen == null) {
        final isTablet = DeviceUtils.isTablet;
        _setting.put(SettingBoxKey.horizontalScreen, isTablet);
        horizontalScreen = isTablet;
      }
      final FullScreenMode mode = horizontalScreen && DeviceUtils.isTablet
          ? FullScreenMode.none
          : FullScreenMode.auto;
      _setting.put(SettingBoxKey.fullScreenMode, mode.index);
      return mode;
    }
    return FullScreenMode.values[index];
  }

  static BtmProgressBehavior get btmProgressBehavior =>
      BtmProgressBehavior.values[_setting.get(
        SettingBoxKey.btmProgressBehavior,
        defaultValue: BtmProgressBehavior.alwaysShow.index,
      )];

  static SubtitlePrefType get subtitlePreferenceV2 =>
      SubtitlePrefType.values[_setting.get(
        SettingBoxKey.subtitlePreferenceV2,
        defaultValue: SubtitlePrefType.off.index,
      )];

  static int get defaultVideoQa => _setting.get(
    SettingBoxKey.defaultVideoQa,
    defaultValue: VideoQuality.super8k.code,
  );

  static int get defaultVideoQaCellular => _setting.get(
    SettingBoxKey.defaultVideoQaCellular,
    defaultValue: VideoQuality.high1080.code,
  );

  static int get defaultAudioQa => _setting.get(
    SettingBoxKey.defaultAudioQa,
    defaultValue: AudioQuality.hiRes.code,
  );

  static int get defaultAudioQaCellular => _setting.get(
    SettingBoxKey.defaultAudioQaCellular,
    defaultValue: AudioQuality.k192.code,
  );

  static List<VideoDecodeFormatType> get preferCodecs {
    // TODO: remove next 2 version
    if (_setting.get('defaultDecode') case String codecStr) {
      String? codecStr2 = _setting.get('secondDecode');
      _setting.deleteAll(const ['defaultDecode', 'secondDecode']);
      final codecs = [
        VideoDecodeFormatType.values.firstWhere(
          (i) => i.codes.contains(codecStr),
        ),
        if (codecStr2 != null && codecStr2 != codecStr)
          VideoDecodeFormatType.values.firstWhere(
            (i) => i.codes.contains(codecStr2),
          ),
      ];
      _setting.put(
        SettingBoxKey.preferCodecs,
        codecs.map((i) => i.name).toList(),
      );
      return codecs;
    }

    final codecs = _setting.get(SettingBoxKey.preferCodecs);
    if (codecs is List) {
      return codecs.map((i) => VideoDecodeFormatType.values.byName(i)).toList();
    }
    return const <VideoDecodeFormatType>[.AVC, .AV1];
  }

  static String get hardwareDecoding => _setting.get(
    SettingBoxKey.hardwareDecoding,
    defaultValue: Platform.isAndroid
        ? HwDecType.androidDefault
        : HwDecType.auto.hwdec,
  );

  static CDNService get defaultCDNService {
    if (_setting.get(SettingBoxKey.CDNService) case final String cdnName) {
      return CDNService.values.byName(cdnName);
    }
    return CDNService.backupUrl;
  }

  static DynamicsTabType get defaultDynamicType =>
      DynamicsTabType.values[defaultDynamicTypeIndex];

  static int get defaultDynamicTypeIndex => _setting.get(
    SettingBoxKey.defaultDynamicType,
    defaultValue: DynamicsTabType.all.index,
  );

  static String get blockServer => _setting.get(
    SettingBoxKey.blockServer,
    defaultValue: HttpString.sponsorBlockBaseUrl,
  );

  static SuperResolutionType get superResolutionType {
    SuperResolutionType? superResolutionType;
    final index = _setting.get(SettingBoxKey.superResolutionType);
    if (index != null) {
      superResolutionType = SuperResolutionType.values.elementAtOrNull(index);
    }
    return superResolutionType ?? SuperResolutionType.disable;
  }

  static bool get biliSendCommAntifraud =>
      Platform.isAndroid &&
      _setting.get(BiliSettingBoxKey.biliSendCommAntifraud, defaultValue: false);

  static int get liveQuality => _setting.get(
    SettingBoxKey.liveQuality,
    defaultValue: LiveQuality.origin.code,
  );

  static int get liveQualityCellular => _setting.get(
    SettingBoxKey.liveQualityCellular,
    defaultValue: LiveQuality.superHD.code,
  );

  static BarHideType get barHideType =>
      BarHideType.values[_setting.get(
        SettingBoxKey.barHideType,
        defaultValue: BarHideType.sync.index,
      )];

  static ReplySortType get replySortType =>
      ReplySortType.values[_setting.get(
        SettingBoxKey.replySortType,
        defaultValue: ReplySortType.hot.index,
      )];

  static DynamicBadgeMode get dynamicBadgeMode =>
      DynamicBadgeMode.values[_setting.get(
        SettingBoxKey.dynamicBadgeMode,
        defaultValue: DynamicBadgeMode.number.index,
      )];

  static String get audioOutput => _setting.get(
    SettingBoxKey.audioOutput,
    defaultValue: AudioOutput.defaultValue,
  );

  static PlayRepeat get playRepeat =>
      PlayRepeat.values[_video.get(
        VideoBoxKey.playRepeat,
        defaultValue: PlayRepeat.pause.index,
      )];

  static String get buvid {
    String? buvid = _localCache.get(BiliLocalCacheKey.buvid);
    if (buvid == null) {
      buvid = LoginUtils.generateBuvid();
      _localCache.put(BiliLocalCacheKey.buvid, buvid);
    }
    return buvid;
  }

  static SuperChatType get superChatType =>
      SuperChatType.values[_setting.get(
        SettingBoxKey.superChatType,
        defaultValue: SuperChatType.valid.index,
      )];

  static double get fullScreenSCWidth => _setting.get(
    SettingBoxKey.fullScreenSCWidth,
    defaultValue: kFullScreenSCWidth,
  );

  static SkipType get pgcSkipType =>
      SkipType.values[_setting.get(SettingBoxKey.pgcSkipType) ??
          SkipType.skipOnce.index];

  static PlayRepeat get audioPlayMode =>
      PlayRepeat.values[_setting.get(SettingBoxKey.audioPlayMode) ??
          PlayRepeat.listOrder.index];

  static FollowOrderType get followOrderType =>
      FollowOrderType.values[_setting.get(
        SettingBoxKey.followOrderType,
        defaultValue: FollowOrderType.def.index,
      )];
}
