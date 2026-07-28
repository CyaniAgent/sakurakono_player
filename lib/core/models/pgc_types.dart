/// Core data types for the PGC (番剧/bangumi/anime) repository.
///
/// These are pure data classes (no UI, no adapter dependencies) with
/// JSON serialization. They mirror the adapter-level models in
/// `lib/adapters/bilibili/models_new/pgc/` but are free of
/// Bilibili-specific API and platform code.
library;

// ---------------------------------------------------------------------------
// CorePgcReviewType
// ---------------------------------------------------------------------------

enum CorePgcReviewType {
  long('长评'),
  short('短评'),
  ;

  final String label;
  const CorePgcReviewType(this.label);
}

// ---------------------------------------------------------------------------
// CorePgcConditionValue
// ---------------------------------------------------------------------------

class CorePgcConditionValue {
  String? keyword;
  String? name;

  CorePgcConditionValue({this.keyword, this.name});

  factory CorePgcConditionValue.fromJson(Map<String, dynamic> json) =>
      CorePgcConditionValue(
        keyword: json['keyword'] as String?,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (keyword != null) 'keyword': keyword,
    if (name != null) 'name': name,
  };
}

// ---------------------------------------------------------------------------
// CorePgcCondition (base)
// ---------------------------------------------------------------------------

class CorePgcCondition {
  String? field;
  String? name;

  CorePgcCondition({this.field, this.name});
}

// ---------------------------------------------------------------------------
// CorePgcConditionFilter
// ---------------------------------------------------------------------------

class CorePgcConditionFilter extends CorePgcCondition {
  List<CorePgcConditionValue>? values;

  CorePgcConditionFilter({super.field, super.name, this.values});

  factory CorePgcConditionFilter.fromJson(Map<String, dynamic> json) =>
      CorePgcConditionFilter(
        field: json['field'] as String?,
        name: json['name'] as String?,
        values: (json['values'] as List<dynamic>?)
            ?.map(
                (e) => CorePgcConditionValue.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (field != null) 'field': field,
    if (name != null) 'name': name,
    if (values != null)
      'values': values!.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// CorePgcConditionOrder
// ---------------------------------------------------------------------------

class CorePgcConditionOrder extends CorePgcCondition {
  String? sort;

  CorePgcConditionOrder({super.field, super.name, this.sort});

  factory CorePgcConditionOrder.fromJson(Map<String, dynamic> json) =>
      CorePgcConditionOrder(
        field: json['field'] as String?,
        name: json['name'] as String?,
        sort: json['sort'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (field != null) 'field': field,
    if (name != null) 'name': name,
    if (sort != null) 'sort': sort,
  };
}

// ---------------------------------------------------------------------------
// CorePgcIndexConditionData
// ---------------------------------------------------------------------------

class CorePgcIndexConditionData {
  List<CorePgcConditionFilter>? filter;
  List<CorePgcConditionOrder>? order;

  CorePgcIndexConditionData({this.filter, this.order});

  factory CorePgcIndexConditionData.fromJson(Map<String, dynamic> json) =>
      CorePgcIndexConditionData(
        filter: (json['filter'] as List<dynamic>?)
            ?.map((e) =>
                CorePgcConditionFilter.fromJson(e as Map<String, dynamic>))
            .toList(),
        order: (json['order'] as List<dynamic>?)
            ?.map(
                (e) => CorePgcConditionOrder.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (filter != null)
      'filter': filter!.map((e) => e.toJson()).toList(),
    if (order != null) 'order': order!.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// CorePgcIndexItem
// ---------------------------------------------------------------------------

class CorePgcIndexItem {
  String? badge;
  String? cover;
  String? indexShow;
  String? order;
  int? seasonId;
  String? title;

  CorePgcIndexItem({
    this.badge,
    this.cover,
    this.indexShow,
    this.order,
    this.seasonId,
    this.title,
  });

  factory CorePgcIndexItem.fromJson(Map<String, dynamic> json) => CorePgcIndexItem(
    badge: json['badge'] as String?,
    cover: json['cover'] as String?,
    indexShow: json['index_show'] as String?,
    order: json['order'] as String?,
    seasonId: json['season_id'] as int?,
    title: json['title'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (badge != null) 'badge': badge,
    if (cover != null) 'cover': cover,
    if (indexShow != null) 'index_show': indexShow,
    if (order != null) 'order': order,
    if (seasonId != null) 'season_id': seasonId,
    if (title != null) 'title': title,
  };
}

// ---------------------------------------------------------------------------
// CorePgcIndexResult
// ---------------------------------------------------------------------------

class CorePgcIndexResult {
  int? hasNext;
  List<CorePgcIndexItem>? list;

  CorePgcIndexResult({this.hasNext, this.list});

  factory CorePgcIndexResult.fromJson(Map<String, dynamic> json) =>
      CorePgcIndexResult(
        hasNext: json['has_next'] as int?,
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => CorePgcIndexItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (hasNext != null) 'has_next': hasNext,
    if (list != null) 'list': list!.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// CoreEpisode
// ---------------------------------------------------------------------------

class CoreEpisode {
  String? cover;
  int? episodeId;
  int? follow;
  String? pubIndex;
  String? pubTime;
  int? seasonId;
  String? title;

  CoreEpisode({
    this.cover,
    this.episodeId,
    this.follow,
    this.pubIndex,
    this.pubTime,
    this.seasonId,
    this.title,
  });

  factory CoreEpisode.fromJson(Map<String, dynamic> json) => CoreEpisode(
    cover: json['cover'] as String?,
    episodeId: json['episode_id'] as int?,
    follow: json['follow'] as int?,
    pubIndex: json['pub_index'] as String?,
    pubTime: json['pub_time'] as String?,
    seasonId: json['season_id'] as int?,
    title: json['title'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (cover != null) 'cover': cover,
    if (episodeId != null) 'episode_id': episodeId,
    if (follow != null) 'follow': follow,
    if (pubIndex != null) 'pub_index': pubIndex,
    if (pubTime != null) 'pub_time': pubTime,
    if (seasonId != null) 'season_id': seasonId,
    if (title != null) 'title': title,
  };
}

// ---------------------------------------------------------------------------
// CoreTimelineResult
// ---------------------------------------------------------------------------

class CoreTimelineResult {
  String? date;
  int? dateTs;
  int? dayOfWeek;
  List<CoreEpisode>? episodes;
  int? isToday;

  CoreTimelineResult({
    this.date,
    this.dateTs,
    this.dayOfWeek,
    this.episodes,
    this.isToday,
  });

  factory CoreTimelineResult.fromJson(Map<String, dynamic> json) =>
      CoreTimelineResult(
        date: json['date'] as String?,
        dateTs: json['date_ts'] as int?,
        dayOfWeek: json['day_of_week'] as int?,
        episodes: (json['episodes'] as List<dynamic>?)
            ?.map((e) => CoreEpisode.fromJson(e as Map<String, dynamic>))
            .toList(),
        isToday: json['is_today'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (date != null) 'date': date,
    if (dateTs != null) 'date_ts': dateTs,
    if (dayOfWeek != null) 'day_of_week': dayOfWeek,
    if (episodes != null)
      'episodes': episodes!.map((e) => e.toJson()).toList(),
    if (isToday != null) 'is_today': isToday,
  };

  void addAll(CoreTimelineResult other) {
    if (dateTs == other.dateTs) {
      if (other.episodes case final list?) {
        (episodes ??= <CoreEpisode>[]).addAll(list);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// CoreStat
// ---------------------------------------------------------------------------

class CoreStat {
  int? disliked;
  int? liked;
  int? likes;

  CoreStat({this.disliked, this.liked, this.likes});

  factory CoreStat.fromJson(Map<String, dynamic> json) => CoreStat(
    disliked: json['disliked'] as int?,
    liked: json['liked'] as int?,
    likes: json['likes'] as int?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (disliked != null) 'disliked': disliked,
    if (liked != null) 'liked': liked,
    if (likes != null) 'likes': likes,
  };
}

// ---------------------------------------------------------------------------
// CoreVip / CoreLabel (simplified, no Hive dependency)
// ---------------------------------------------------------------------------

class CoreLabel {
  String? text;

  CoreLabel({this.text});

  factory CoreLabel.fromJson(Map<String, dynamic> json) => CoreLabel(
    text: json['text'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (text != null) 'text': text,
  };
}

class CoreVip {
  int? type;
  late int status;
  CoreLabel? label;

  CoreVip({this.type, required this.status, this.label});

  factory CoreVip.fromJson(Map<String, dynamic> json) => CoreVip(
    type: json['type'] ?? json['vipType'],
    status: json['status'] ?? json['vipStatus'] ?? 0,
    label: json['label'] != null
        ? CoreLabel.fromJson(json['label'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (type != null) 'type': type,
    'status': status,
    if (label != null) 'label': label!.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreAuthor
// ---------------------------------------------------------------------------

class CoreAuthor {
  String? avatar;
  int? level;
  int? mid;
  String? uname;
  CoreVip? vip;

  CoreAuthor({
    this.avatar,
    this.level,
    this.mid,
    this.uname,
    this.vip,
  });

  factory CoreAuthor.fromJson(Map<String, dynamic> json) => CoreAuthor(
    avatar: json['avatar'] as String?,
    level: json['level'] as int?,
    mid: json['mid'] as int?,
    uname: json['uname'] as String?,
    vip: json['vip'] != null
        ? CoreVip.fromJson(json['vip'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (avatar != null) 'avatar': avatar,
    if (level != null) 'level': level,
    if (mid != null) 'mid': mid,
    if (uname != null) 'uname': uname,
    if (vip != null) 'vip': vip!.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CorePgcReviewItemModel
// ---------------------------------------------------------------------------

class CorePgcReviewItemModel {
  CoreAuthor? author;
  String? title;
  String? content;
  String? pushTimeStr;
  int? reviewId;
  late int score;
  CoreStat? stat;
  int? articleId;

  CorePgcReviewItemModel({
    this.author,
    this.title,
    this.content,
    this.pushTimeStr,
    this.reviewId,
    required this.score,
    this.stat,
    this.articleId,
  });

  factory CorePgcReviewItemModel.fromJson(Map<String, dynamic> json) =>
      CorePgcReviewItemModel(
        articleId: json['article_id'] as int?,
        author: json['author'] != null
            ? CoreAuthor.fromJson(json['author'] as Map<String, dynamic>)
            : null,
        title: json['title'] as String?,
        content: json['content'] as String?,
        pushTimeStr: json['push_time_str'] as String?,
        reviewId: json['review_id'] as int?,
        score: json['score'] == null ? 0 : json['score'] ~/ 2,
        stat: json['stat'] != null
            ? CoreStat.fromJson(json['stat'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (articleId != null) 'article_id': articleId,
    if (author != null) 'author': author!.toJson(),
    if (title != null) 'title': title,
    if (content != null) 'content': content,
    if (pushTimeStr != null) 'push_time_str': pushTimeStr,
    if (reviewId != null) 'review_id': reviewId,
    'score': score * 2,
    if (stat != null) 'stat': stat!.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CorePgcReviewData
// ---------------------------------------------------------------------------

class CorePgcReviewData {
  List<CorePgcReviewItemModel>? list;
  String? next;
  int? count;

  CorePgcReviewData({this.list, this.next, this.count});

  factory CorePgcReviewData.fromJson(Map<String, dynamic> json) => CorePgcReviewData(
    list: (json['list'] as List<dynamic>?)
        ?.map(
            (e) => CorePgcReviewItemModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    next: json['next'] as String?,
    count: json['count'] ?? json['total'],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (list != null) 'list': list!.map((e) => e.toJson()).toList(),
    if (next != null) 'next': next,
    if (count != null) 'count': count,
  };
}
