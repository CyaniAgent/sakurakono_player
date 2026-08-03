import 'package:json_annotation/json_annotation.dart';

part 'old_im_models.g.dart';

/// IM 新消息数。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class IMNewMessageNum {
  final int newMessageNum;

  const IMNewMessageNum({required this.newMessageNum});

  factory IMNewMessageNum.fromJson(Map<String, dynamic> json) =>
      _$IMNewMessageNumFromJson(json);

  Map<String, dynamic> toJson() => _$IMNewMessageNumToJson(this);
}

/// IM 私信消息。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class IMMessage {
  final int msgId;
  final int sender;
  final int receiver;
  final String content;
  final String time;
  final String? senderName;
  final String? receiverName;
  final String? senderAvatarUrl;
  final String? receiverAvatarUrl;
  final int? isRead;

  const IMMessage({
    required this.msgId,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.time,
    this.senderName,
    this.receiverName,
    this.senderAvatarUrl,
    this.receiverAvatarUrl,
    this.isRead,
  });

  factory IMMessage.fromJson(Map<String, dynamic> json) =>
      _$IMMessageFromJson(json);

  Map<String, dynamic> toJson() => _$IMMessageToJson(this);
}

/// IM 好友（私信联系人）。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class IMFriend {
  final int uid;
  final String username;
  final String? intro;
  final String? avatarUrl;
  final String? lastTime;
  final String? lastMessage;
  final int? newMessageNum;

  const IMFriend({
    required this.uid,
    required this.username,
    this.intro,
    this.avatarUrl,
    this.lastTime,
    this.lastMessage,
    this.newMessageNum,
  });

  factory IMFriend.fromJson(Map<String, dynamic> json) =>
      _$IMFriendFromJson(json);

  Map<String, dynamic> toJson() => _$IMFriendToJson(this);
}

/// IM 已读消息标记请求体。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class IMReadMessage {
  final int sender;
  final int receiver;
  final String content;
  final String? senderName;
  final String? receiverName;

  const IMReadMessage({
    required this.sender,
    required this.receiver,
    required this.content,
    this.senderName,
    this.receiverName,
  });

  factory IMReadMessage.fromJson(Map<String, dynamic> json) =>
      _$IMReadMessageFromJson(json);

  Map<String, dynamic> toJson() => _$IMReadMessageToJson(this);
}
