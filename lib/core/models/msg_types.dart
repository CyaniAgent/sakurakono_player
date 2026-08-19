/// Messaging / notification types used by [MsgRepository].
///
/// These are core data classes decoupled from any adapter implementation.
library;

import 'dart:convert';

// ---------------------------------------------------------------------------
// Shared value types
// ---------------------------------------------------------------------------

/// Pagination cursor used across multiple message feeds.
class CoreCursor {
  bool? isEnd;
  int? id;
  int? time;

  CoreCursor({this.isEnd, this.id, this.time});

  factory CoreCursor.fromJson(Map<String, dynamic> json) => CoreCursor(
        isEnd: json['is_end'] as bool?,
        id: json['id'] as int?,
        time: json['time'] as int?,
      );
}

/// Minimal user info used in message items.
class CoreUser {
  int? mid;
  String? nickname;
  String? avatar;

CoreUser({this.mid, this.nickname, this.avatar});

  factory CoreUser.fromJson(Map<String, dynamic> json) => CoreUser(
        mid: json['mid'] as int?,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Avatar sub-types (CoreVip / CorePendant / OfficialVerify)
// ---------------------------------------------------------------------------

class CorePendant {
  String? image;

  CorePendant({this.image});

  factory CorePendant.fromJson(Map<String, dynamic> json) {
    return CorePendant(image: json['image'] as String?);
  }
}

class CoreBaseOfficialVerify {
  int? type;
  String? desc;

  CoreBaseOfficialVerify({this.type, this.desc});

  factory CoreBaseOfficialVerify.fromJson(Map<String, dynamic> json) {
    return CoreBaseOfficialVerify(
      type: json['type'] as int?,
      desc: json['desc'] as String?,
    );
  }
}

class CoreLabel {
  String? text;

  CoreLabel({this.text});

  factory CoreLabel.fromJson(Map<String, dynamic> json) {
    return CoreLabel(text: json['text'] as String?);
  }
}

class CoreVip {
  int? type;
  int status;
  CoreLabel? label;

  CoreVip({this.type, this.status = 0, this.label});

  factory CoreVip.fromJson(Map<String, dynamic> json) {
    return CoreVip(
      type: json['type'] as int? ?? json['vipType'] as int?,
      status: json['status'] as int? ?? json['vipStatus'] as int? ?? 0,
      label: json['label'] == null
          ? null
          : CoreLabel.fromJson(json['label'] as Map<String, dynamic>),
    );
  }
}

// ---------------------------------------------------------------------------
// ImUserInfos
// ---------------------------------------------------------------------------

class CoreImUserInfosData {
  int? mid;
  String? name;
  String? face;
  String? sign;
  CoreVip? vip;
  CorePendant? pendant;
  CoreBaseOfficialVerify? official;

  CoreImUserInfosData({
    this.mid,
    this.name,
    this.face,
    this.sign,
    this.vip,
    this.pendant,
    this.official,
  });

  factory CoreImUserInfosData.fromJson(Map<String, dynamic> json) =>
      CoreImUserInfosData(
        mid: json['mid'] as int?,
        name: json['name'] as String?,
        face: json['face'] as String?,
        sign: json['sign'] as String?,
        vip: json['vip'] == null
            ? null
            : CoreVip.fromJson(json['vip'] as Map<String, dynamic>),
        pendant: json['pendant'] == null
            ? null
            : CorePendant.fromJson(json['pendant'] as Map<String, dynamic>),
        official: json['official'] == null
            ? null
            : CoreBaseOfficialVerify.fromJson(
                json['official'] as Map<String, dynamic>,
              ),
      );
}

// ---------------------------------------------------------------------------
// MsgReply
// ---------------------------------------------------------------------------

class CoreMsgReplyContent {
  int? subjectId;
  int? businessId;
  String? business;
  String? nativeUri;
  String? rootReplyContent;
  String? sourceContent;
  String? targetReplyContent;

  CoreMsgReplyContent({
    this.subjectId,
    this.businessId,
    this.business,
    this.nativeUri,
    this.rootReplyContent,
    this.sourceContent,
    this.targetReplyContent,
  });

  factory CoreMsgReplyContent.fromJson(Map<String, dynamic> json) {
    return CoreMsgReplyContent(
      subjectId: json['subject_id'] as int?,
      businessId: json['business_id'] as int?,
      business: json['business'] as String?,
      nativeUri: json['native_uri'] as String?,
      rootReplyContent: json['root_reply_content'] as String?,
      sourceContent: json['source_content'] as String?,
      targetReplyContent: json['target_reply_content'] as String?,
    );
  }
}

class CoreMsgReplyItem {
  int? id;
  CoreUser? user;
  CoreMsgReplyContent? item;
  int? counts;
  int? isMulti;
  int? replyTime;

  CoreMsgReplyItem({
    this.id,
    this.user,
    this.item,
    this.counts,
    this.isMulti,
    this.replyTime,
  });

  factory CoreMsgReplyItem.fromJson(Map<String, dynamic> json) => CoreMsgReplyItem(
        id: json['id'] as int?,
        user: json['user'] == null
            ? null
            : CoreUser.fromJson(json['user'] as Map<String, dynamic>),
        item: json['item'] == null
            ? null
            : CoreMsgReplyContent.fromJson(json['item'] as Map<String, dynamic>),
        counts: json['counts'] as int?,
        isMulti: json['is_multi'] as int?,
        replyTime: json['reply_time'] as int?,
      );
}

class CoreMsgReplyData {
  CoreCursor? cursor;
  List<CoreMsgReplyItem>? items;
  int? lastViewAt;

  CoreMsgReplyData({this.cursor, this.items, this.lastViewAt});

  factory CoreMsgReplyData.fromJson(Map<String, dynamic> json) => CoreMsgReplyData(
        cursor: json['cursor'] == null
            ? null
            : CoreCursor.fromJson(json['cursor'] as Map<String, dynamic>),
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => CoreMsgReplyItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastViewAt: json['last_view_at'] as int?,
      );
}

// ---------------------------------------------------------------------------
// MsgAt
// ---------------------------------------------------------------------------

class CoreMsgAtContent {
  String? business;
  String? image;
  String? sourceContent;
  String? nativeUri;

  CoreMsgAtContent({
    this.business,
    this.image,
    this.sourceContent,
    this.nativeUri,
  });

  factory CoreMsgAtContent.fromJson(Map<String, dynamic> json) => CoreMsgAtContent(
        business: json['business'] as String?,
        image: json['image'] as String?,
        sourceContent: json['source_content'] as String?,
        nativeUri: json['native_uri'] as String?,
      );
}

class CoreMsgAtItem {
  int? id;
  CoreUser? user;
  CoreMsgAtContent? item;
  int? atTime;

  CoreMsgAtItem({this.id, this.user, this.item, this.atTime});

  factory CoreMsgAtItem.fromJson(Map<String, dynamic> json) => CoreMsgAtItem(
        id: json['id'] as int?,
        user: json['user'] == null
            ? null
            : CoreUser.fromJson(json['user'] as Map<String, dynamic>),
        item: json['item'] == null
            ? null
            : CoreMsgAtContent.fromJson(json['item'] as Map<String, dynamic>),
        atTime: json['at_time'] as int?,
      );
}

class CoreMsgAtData {
  CoreCursor? cursor;
  List<CoreMsgAtItem>? items;

  CoreMsgAtData({this.cursor, this.items});

  factory CoreMsgAtData.fromJson(Map<String, dynamic> json) => CoreMsgAtData(
        cursor: json['cursor'] == null
            ? null
            : CoreCursor.fromJson(json['cursor'] as Map<String, dynamic>),
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => CoreMsgAtItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// MsgLike
// ---------------------------------------------------------------------------

class CoreMsgLikeContent {
  String? business;
  String? title;
  String? image;
  String? nativeUri;

  CoreMsgLikeContent({
    this.business,
    this.title,
    this.image,
    this.nativeUri,
  });

  factory CoreMsgLikeContent.fromJson(Map<String, dynamic> json) {
    return CoreMsgLikeContent(
      business: json['business'] as String?,
      title: json['title'] as String?,
      image: json['image'] as String?,
      nativeUri: json['native_uri'] as String?,
    );
  }
}

class CoreMsgLikeItem {
  int? id;
  List<CoreUser>? users;
  CoreMsgLikeContent? item;
  int? counts;
  int? likeTime;
  int? noticeState;

  CoreMsgLikeItem({
    this.id,
    this.users,
    this.item,
    this.counts,
    this.likeTime,
    this.noticeState,
  });

  factory CoreMsgLikeItem.fromJson(Map<String, dynamic> json) => CoreMsgLikeItem(
        id: json['id'] as int?,
        users: (json['users'] as List<dynamic>?)
            ?.map((e) => CoreUser.fromJson(e as Map<String, dynamic>))
            .toList(),
        item: json['item'] == null
            ? null
            : CoreMsgLikeContent.fromJson(json['item'] as Map<String, dynamic>),
        counts: json['counts'] as int?,
        likeTime: json['like_time'] as int?,
        noticeState: json['notice_state'] as int?,
      );
}

class CoreLatest {
  List<CoreMsgLikeItem>? items;
  int? lastViewAt;

  CoreLatest({this.items, this.lastViewAt});

  factory CoreLatest.fromJson(Map<String, dynamic> json) => CoreLatest(
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => CoreMsgLikeItem.fromJson(e))
            .toList(),
        lastViewAt: json['last_view_at'] as int?,
      );
}

class CoreTotal {
  CoreCursor? cursor;
  List<CoreMsgLikeItem>? items;

  CoreTotal({this.cursor, this.items});

  factory CoreTotal.fromJson(Map<String, dynamic> json) => CoreTotal(
        cursor: json['cursor'] == null
            ? null
            : CoreCursor.fromJson(json['cursor'] as Map<String, dynamic>),
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => CoreMsgLikeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreMsgLikeData {
  CoreLatest? latest;
  CoreTotal? total;

  CoreMsgLikeData({this.latest, this.total});

  factory CoreMsgLikeData.fromJson(Map<String, dynamic> json) => CoreMsgLikeData(
        latest: json['latest'] == null
            ? null
            : CoreLatest.fromJson(json['latest'] as Map<String, dynamic>),
        total: json['total'] == null
            ? null
            : CoreTotal.fromJson(json['total'] as Map<String, dynamic>),
      );
}

// ---------------------------------------------------------------------------
// MsgLikeDetail
// ---------------------------------------------------------------------------

class CoreMsgLikeDetailUser {
  int? mid;
  String? nickname;
  String? avatar;

  CoreMsgLikeDetailUser({this.mid, this.nickname, this.avatar});

  factory CoreMsgLikeDetailUser.fromJson(Map<String, dynamic> json) =>
      CoreMsgLikeDetailUser(
        mid: json['mid'] as int?,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
      );
}

class CoreMsgLikeDetailItem {
  CoreMsgLikeDetailUser? user;
  int? likeTime;

  CoreMsgLikeDetailItem({this.user, this.likeTime});

  factory CoreMsgLikeDetailItem.fromJson(Map<String, dynamic> json) =>
      CoreMsgLikeDetailItem(
        user: json['user'] == null
            ? null
            : CoreMsgLikeDetailUser.fromJson(json['user'] as Map<String, dynamic>),
        likeTime: json['like_time'] as int?,
      );
}

class CoreMsgLikeDetailPage {
  bool? isEnd;

  CoreMsgLikeDetailPage({this.isEnd});

  factory CoreMsgLikeDetailPage.fromJson(Map<String, dynamic> json) =>
      CoreMsgLikeDetailPage(
        isEnd: json['is_end'] as bool?,
      );
}

class CoreMsgLikeDetailCard {
  String? business;
  String? title;

  CoreMsgLikeDetailCard({this.business, this.title});

  factory CoreMsgLikeDetailCard.fromJson(Map<String, dynamic> json) =>
      CoreMsgLikeDetailCard(
        business: json['business'] as String?,
        title: json['title'] as String?,
      );
}

class CoreMsgLikeDetailData {
  CoreMsgLikeDetailPage? page;
  CoreMsgLikeDetailCard? card;
  List<CoreMsgLikeDetailItem>? items;

  CoreMsgLikeDetailData({this.page, this.card, this.items});

  factory CoreMsgLikeDetailData.fromJson(Map<String, dynamic> json) =>
      CoreMsgLikeDetailData(
        page: json['page'] == null
            ? null
            : CoreMsgLikeDetailPage.fromJson(json['page'] as Map<String, dynamic>),
        card: json['card'] == null
            ? null
            : CoreMsgLikeDetailCard.fromJson(json['card'] as Map<String, dynamic>),
        items: (json['items'] as List<dynamic>?)
            ?.map(
                (e) => CoreMsgLikeDetailItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// MsgSys
// ---------------------------------------------------------------------------

class CoreMsgSysItem {
  int? id;
  int? cursor;
  String? title;
  String? content;
  String? timeAt;

  CoreMsgSysItem({
    this.id,
    this.cursor,
    this.title,
    this.content,
    this.timeAt,
  });

  factory CoreMsgSysItem.fromJson(Map<String, dynamic> json) {
    var content = json['content'] as String?;
    if (content != null) {
      try {
        final decoded = const JsonDecoder().convert(content);
        if (decoded is Map && decoded['web'] != null) {
          content = decoded['web'] as String?;
        }
      } catch (_) {}
    }
    return CoreMsgSysItem(
      id: json['id'] as int?,
      cursor: json['cursor'] as int?,
      title: json['title'] as String?,
      content: content,
      timeAt: json['time_at'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// SessionSs
// ---------------------------------------------------------------------------

class CoreSessionSsData {
  int? followStatus;
  int? pushSetting;
  int? showPushSetting;

  CoreSessionSsData({
    this.followStatus,
    this.pushSetting,
    this.showPushSetting,
  });

  factory CoreSessionSsData.fromJson(Map<String, dynamic> json) => CoreSessionSsData(
        followStatus: json['follow_status'] as int?,
        pushSetting: json['push_setting'] as int?,
        showPushSetting: json['show_push_setting'] as int?,
      );
}

// ---------------------------------------------------------------------------
// CoreUidSetting (DND)
// ---------------------------------------------------------------------------

class CoreUidSetting {
  int? setting;

  CoreUidSetting({this.setting});

  factory CoreUidSetting.fromJson(Map<String, dynamic> json) => CoreUidSetting(
        setting: json['setting'] as int?,
      );
}

// ---------------------------------------------------------------------------
// UploadBfs
// ---------------------------------------------------------------------------

class CoreUploadBfsResData {
  String? imageUrl;
  int? imageWidth;
  int? imageHeight;
  double? imgSize;

  CoreUploadBfsResData({
    this.imageUrl,
    this.imageWidth,
    this.imageHeight,
    this.imgSize,
  });

  factory CoreUploadBfsResData.fromJson(Map<String, dynamic> json) =>
      CoreUploadBfsResData(
        imageUrl: json['image_url'] as String?,
        imageWidth: json['image_width'] as int?,
        imageHeight: json['image_height'] as int?,
        imgSize: (json['img_size'] as num?)?.toDouble(),
      );
}

// ---------------------------------------------------------------------------
// Unread counts
// ---------------------------------------------------------------------------

class CoreSingleUnreadData {
  int unfollowUnread;
  int followUnread;
  int unfollowPushMsg;
  int dustbinPushMsg;
  int dustbinUnread;
  int bizMsgUnfollowUnread;
  int bizMsgFollowUnread;
  int customUnread;

  CoreSingleUnreadData({
    required this.unfollowUnread,
    required this.followUnread,
    required this.unfollowPushMsg,
    required this.dustbinPushMsg,
    required this.dustbinUnread,
    required this.bizMsgUnfollowUnread,
    required this.bizMsgFollowUnread,
    required this.customUnread,
  });

  factory CoreSingleUnreadData.fromJson(Map<String, dynamic> json) =>
      CoreSingleUnreadData(
        unfollowUnread: json['unfollow_unread'] ?? 0,
        followUnread: json['follow_unread'] ?? 0,
        unfollowPushMsg: json['unfollow_push_msg'] ?? 0,
        dustbinPushMsg: json['dustbin_push_msg'] ?? 0,
        dustbinUnread: json['dustbin_unread'] ?? 0,
        bizMsgUnfollowUnread: json['biz_msg_unfollow_unread'] ?? 0,
        bizMsgFollowUnread: json['biz_msg_follow_unread'] ?? 0,
        customUnread: json['custom_unread'] ?? 0,
      );
}

class CoreMsgFeedUnreadData {
  int at;
  int like;
  int reply;
  int sysMsg;

  CoreMsgFeedUnreadData({
    required this.at,
    required this.like,
    required this.reply,
    required this.sysMsg,
  });

  factory CoreMsgFeedUnreadData.fromJson(Map<String, dynamic> json) =>
      CoreMsgFeedUnreadData(
        at: (json['at'] as int?) ?? 0,
        like: (json['like'] as int?) ?? 0,
        reply: (json['reply'] as int?) ?? 0,
        sysMsg: (json['sys_msg'] as int?) ?? 0,
      );
}