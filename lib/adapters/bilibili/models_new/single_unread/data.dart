class SingleUnreadData {
  int unfollowUnread;
  int followUnread;
  int unfollowPushMsg;
  int dustbinPushMsg;
  int dustbinUnread;
  int bizMsgUnfollowUnread;
  int bizMsgFollowUnread;
  int customUnread;

  SingleUnreadData({
    required this.unfollowUnread,
    required this.followUnread,
    required this.unfollowPushMsg,
    required this.dustbinPushMsg,
    required this.dustbinUnread,
    required this.bizMsgUnfollowUnread,
    required this.bizMsgFollowUnread,
    required this.customUnread,
  });

  factory SingleUnreadData.fromJson(Map<String, dynamic> json) =>
      SingleUnreadData(
        unfollowUnread: json['unfollow_unread'] ?? 0,
        followUnread: json['follow_unread'] ?? 0,
        unfollowPushMsg: json['unfollow_push_msg'] ?? 0,
        dustbinPushMsg: json['dustbin_push_msg'] ?? 0,
        dustbinUnread: json['dustbin_unread'] ?? 0,
        bizMsgUnfollowUnread: json['biz_msg_unfollow_unread'] ?? 0,
        bizMsgFollowUnread: json['biz_msg_follow_unread'] ?? 0,
        customUnread: json['custom_unread'] ?? 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'unfollow_unread': unfollowUnread,
    'follow_unread': followUnread,
    'unfollow_push_msg': unfollowPushMsg,
    'dustbin_push_msg': dustbinPushMsg,
    'dustbin_unread': dustbinUnread,
    'biz_msg_unfollow_unread': bizMsgUnfollowUnread,
    'biz_msg_follow_unread': bizMsgFollowUnread,
    'custom_unread': customUnread,
  };
}
