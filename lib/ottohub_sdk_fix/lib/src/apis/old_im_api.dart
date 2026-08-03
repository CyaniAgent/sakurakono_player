import '../base_api.dart';
import '../models/old_api/old_im_models.dart';

/// 旧版 IM 消息模块接口。
abstract class IOldImApi {
  /// 获取新消息数量。
  Future<IMNewMessageNum> getNewMessageNum();

  /// 获取已读消息列表。
  Future<List<IMMessage>> getReadMessageList({int? offset, int? num});

  /// 获取未读消息列表。
  Future<List<IMMessage>> getUnreadMessageList({int? offset, int? num});

  /// 获取已发送消息列表。
  Future<List<IMMessage>> getSentMessageList({int? offset, int? num});

  /// 发送消息。
  Future<void> sendMessage({required int receiver, required String message});

  /// 将消息标记为已读。
  Future<IMReadMessage> readMessage(int msgId);

  /// 一键已读全部系统消息。
  Future<void> readAllSystemMessage();

  /// 删除消息。
  Future<void> deleteMessage(int msgId);

  /// 获取好友列表。
  Future<List<IMFriend>> getFriendList({int? offset, int? num, int? ifTimeDesc});

  /// 获取好友消息列表。
  Future<List<IMMessage>> getFriendMessages({required int friendUid, int? offset, int? num, int? ifTimeDesc});
}

class OldImApi extends BaseApi implements IOldImApi {
  OldImApi(super.dio, super.getToken, {super.config});

  @override
  Future<IMNewMessageNum> getNewMessageNum() async {
    final response = await get('/im/new_message_num');
    return IMNewMessageNum.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<IMMessage>> getReadMessageList({int? offset, int? num}) async {
    final response = await get('/im/read_message_list', queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final list = (response['data'] as Map<String, dynamic>)['read_message_list']
        as List<dynamic>;
    return list.map((e) => IMMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<IMMessage>> getUnreadMessageList({int? offset, int? num}) async {
    final response = await get('/im/unread_message_list', queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final list =
        (response['data'] as Map<String, dynamic>)['unread_message_list']
            as List<dynamic>;
    return list.map((e) => IMMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<IMMessage>> getSentMessageList({int? offset, int? num}) async {
    final response = await get('/im/sent_message_list', queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final list = (response['data'] as Map<String, dynamic>)['sent_message_list']
        as List<dynamic>;
    return list.map((e) => IMMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> sendMessage({
    required int receiver,
    required String message,
  }) async {
    await post('/im/send_message', data: {
      'receiver': receiver,
      'message': message,
    });
  }

  @override
  Future<IMReadMessage> readMessage(int msgId) async {
    final response =
        await post('/im/read_message', data: {'msg_id': msgId});
    return IMReadMessage.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> readAllSystemMessage() async {
    await post('/im/read_all_system_message');
  }

  @override
  Future<void> deleteMessage(int msgId) async {
    await post('/im/delete_message', data: {'msg_id': msgId});
  }

  @override
  Future<List<IMFriend>> getFriendList({
    int? offset,
    int? num,
    int? ifTimeDesc,
  }) async {
    final response = await get('/im/friend_list', queryParameters: {
      'offset': ?offset,
      'num': ?num,
      'if_time_desc': ?ifTimeDesc,
    });
    final list =
        (response['data'] as Map<String, dynamic>)['user_list'] as List<dynamic>;
    return list.map((e) => IMFriend.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<IMMessage>> getFriendMessages({
    required int friendUid,
    int? offset,
    int? num,
    int? ifTimeDesc,
  }) async {
    final response = await get('/im/friend_message', queryParameters: {
      'friend_uid': friendUid,
      'offset': ?offset,
      'num': ?num,
      'if_time_desc': ?ifTimeDesc,
    });
    final list = (response['data'] as Map<String, dynamic>)['message_list']
        as List<dynamic>;
    return list.map((e) => IMMessage.fromJson(e as Map<String, dynamic>)).toList();
  }
}
