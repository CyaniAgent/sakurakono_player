// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'old_im_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IMNewMessageNum _$IMNewMessageNumFromJson(Map<String, dynamic> json) =>
    IMNewMessageNum(newMessageNum: (json['new_message_num'] as num).toInt());

Map<String, dynamic> _$IMNewMessageNumToJson(IMNewMessageNum instance) =>
    <String, dynamic>{'new_message_num': instance.newMessageNum};

IMMessage _$IMMessageFromJson(Map<String, dynamic> json) => IMMessage(
  msgId: (json['msg_id'] as num).toInt(),
  sender: (json['sender'] as num).toInt(),
  receiver: (json['receiver'] as num).toInt(),
  content: json['content'] as String,
  time: json['time'] as String,
  senderName: json['sender_name'] as String?,
  receiverName: json['receiver_name'] as String?,
  senderAvatarUrl: json['sender_avatar_url'] as String?,
  receiverAvatarUrl: json['receiver_avatar_url'] as String?,
  isRead: (json['is_read'] as num?)?.toInt(),
);

Map<String, dynamic> _$IMMessageToJson(IMMessage instance) => <String, dynamic>{
  'msg_id': instance.msgId,
  'sender': instance.sender,
  'receiver': instance.receiver,
  'content': instance.content,
  'time': instance.time,
  'sender_name': ?instance.senderName,
  'receiver_name': ?instance.receiverName,
  'sender_avatar_url': ?instance.senderAvatarUrl,
  'receiver_avatar_url': ?instance.receiverAvatarUrl,
  'is_read': ?instance.isRead,
};

IMFriend _$IMFriendFromJson(Map<String, dynamic> json) => IMFriend(
  uid: (json['uid'] as num).toInt(),
  username: json['username'] as String,
  intro: json['intro'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  lastTime: json['last_time'] as String?,
  lastMessage: json['last_message'] as String?,
  newMessageNum: (json['new_message_num'] as num?)?.toInt(),
);

Map<String, dynamic> _$IMFriendToJson(IMFriend instance) => <String, dynamic>{
  'uid': instance.uid,
  'username': instance.username,
  'intro': ?instance.intro,
  'avatar_url': ?instance.avatarUrl,
  'last_time': ?instance.lastTime,
  'last_message': ?instance.lastMessage,
  'new_message_num': ?instance.newMessageNum,
};

IMReadMessage _$IMReadMessageFromJson(Map<String, dynamic> json) =>
    IMReadMessage(
      sender: (json['sender'] as num).toInt(),
      receiver: (json['receiver'] as num).toInt(),
      content: json['content'] as String,
      senderName: json['sender_name'] as String?,
      receiverName: json['receiver_name'] as String?,
    );

Map<String, dynamic> _$IMReadMessageToJson(IMReadMessage instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'receiver': instance.receiver,
      'content': instance.content,
      'sender_name': ?instance.senderName,
      'receiver_name': ?instance.receiverName,
    };
