/// Core data types for the SponsorBlock repository.
///
/// These are pure data classes (no UI, no adapter dependencies) with
/// JSON serialization. They mirror the adapter-level models in
/// `lib/adapters/bilibili/models/common/sponsor_block/` and
/// `lib/adapters/bilibili/models_new/sponsor_block/` but are free of
/// Bilibili-specific UI and platform code.
library;

// ---------------------------------------------------------------------------
// CoreActionType
// ---------------------------------------------------------------------------

enum CoreActionType {
  skip('跳过'),
  mute('静音'),
  full('整个视频'),
  poi('精彩时刻'),
  ;

  final String title;
  const CoreActionType(this.title);
}

// ---------------------------------------------------------------------------
// CoreSegmentType
// ---------------------------------------------------------------------------

// ignore_for_file: constant_identifier_names

enum CoreSegmentType {
  sponsor('赞助/恰饭', '赞助',
      '付费推广、推荐和直接广告。不是自我推广或免费提及他们喜欢的商品/创作者/网站/产品。'),
  selfpromo('无偿/自我推广', '推广',
      '类似于 "赞助广告" ，但无报酬或是自我推广。包括有关商品、捐赠的部分或合作者的信息。'),
  exclusive_access('独家访问/抢先体验', '品牌合作',
      '仅用于对整个视频进行标记。适用于展示UP主免费或获得补贴后使用的产品、服务或场地的视频。'),
  interaction('三连/互动提醒', '三连提醒',
      '视频中间简短提醒观众来一键三连或关注。 如果片段较长，或是有具体内容，则应分类为自我推广。'),
  poi_highlight('精彩时刻/重点', '精彩时刻',
      '大部分人都在寻找的空降时间。类似于"封面在12:34"的评论。'),
  intro('过场/开场动画', '开场动画',
      '没有实际内容的间隔片段。可以是暂停、静态帧或重复动画。不适用于包含内容的过场。'),
  outro('鸣谢/结束画面', '片尾', '致谢画面或片尾画面。不包含内容的结尾。'),
  preview('回顾/概要', '预览',
      '展示此视频或同系列视频将出现的画面集锦，片段中所有内容都将在之后的正片中再次出现。'),
  padding('填充内容/前黑/后黑', '填充内容',
      '搬运视频片头片尾的纯粹填充内容，如黑屏或无关画面，与视频主体内容无实际意义和关联。'),
  filler('离题闲聊/玩笑', '离题',
      "仅作为填充内容或增添趣味而添加的离题片段，这些内容对理解视频的主要内容并非必需。这不包括提供背景信息或上下文的片段。这是一个非常激进的分类，适用于当你不想看'娱乐性'内容的时候。"),
  music_offtopic('音乐:非音乐部分', '非音乐',
      '仅用于音乐视频。此分类只能用于音乐视频中未包括于其他分类的部分。'),
  ;

  final String title;
  final String shortTitle;
  final String description;

  const CoreSegmentType(this.title, this.shortTitle, this.description);
}

// ---------------------------------------------------------------------------
// CoreDoublePair (replaces Pair<double, double> to avoid naming conflicts)
// ---------------------------------------------------------------------------

class CoreDoublePair {
  double first;
  double second;

  CoreDoublePair({required this.first, required this.second});
}

// ---------------------------------------------------------------------------
// CorePostSegmentModel
// ---------------------------------------------------------------------------

class CorePostSegmentModel {
  CorePostSegmentModel({
    required this.segment,
    required this.category,
    required this.actionType,
  });
  CoreDoublePair segment;
  CoreSegmentType category;
  CoreActionType actionType;
}

// ---------------------------------------------------------------------------
// CoreSegmentItemModel
// ---------------------------------------------------------------------------

class CoreSegmentItemModel {
  String? cid;
  String category;
  String? actionType;
  List<int> segment;
  String uuid;
  num? videoDuration;
  int? votes;

  CoreSegmentItemModel({
    this.cid,
    required this.category,
    this.actionType,
    required this.segment,
    required this.uuid,
    this.videoDuration,
    this.votes,
  });

  factory CoreSegmentItemModel.fromJson(Map<String, dynamic> json) =>
      CoreSegmentItemModel(
        cid: json["cid"],
        category: json["category"],
        actionType: json["actionType"],
        segment: (json["segment"] as List)
            .map((e) => ((e as num) * 1000).round())
            .toList(),
        uuid: json["UUID"],
        videoDuration: json["videoDuration"] == null
            ? null
            : (json["videoDuration"] as num) * 1000,
        votes: json["votes"],
      );

  factory CoreSegmentItemModel.fromPgcJson(
    Map<String, dynamic> json,
    num? videoDuration,
  ) =>
      CoreSegmentItemModel(
        category: switch (json['clipType']) {
          'CLIP_TYPE_OP' => CoreSegmentType.intro.name,
          'CLIP_TYPE_ED' => CoreSegmentType.outro.name,
          _ => CoreSegmentType.sponsor.name,
        },
        segment: [
          ((json['start'] as num) * 1000).round(),
          ((json['end'] as num) * 1000).round(),
        ],
        uuid: '',
        videoDuration: videoDuration,
      );
}

// ---------------------------------------------------------------------------
// CoreUserInfo
// ---------------------------------------------------------------------------

class CoreUserInfo {
  final int viewCount;
  final double minutesSaved;
  final int segmentCount;

  const CoreUserInfo({
    required this.viewCount,
    required this.minutesSaved,
    required this.segmentCount,
  });

  factory CoreUserInfo.fromJson(Map<String, dynamic> json) => CoreUserInfo(
    viewCount: json['viewCount'],
    minutesSaved: (json['minutesSaved'] as num).toDouble(),
    segmentCount: json['segmentCount'],
  );
}
