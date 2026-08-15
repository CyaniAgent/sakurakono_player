import '../base_api.dart';
import '../models/channel/channel_blacklist_entry.dart';
import '../models/channel/channel_content_item.dart';
import '../models/channel/channel_detail.dart';
import '../models/channel/channel_history_item.dart';
import '../models/channel/channel_member.dart';
import '../models/channel/channel_notice.dart';
import '../models/channel/channel_responses.dart';
import '../models/channel/channel_section.dart';
import '../models/channel/channel_stats.dart';
import '../models/channel/channel_summary.dart';
import '../models/channel/channel_timeline_item.dart';

/// 频道模块接口。
///
/// 提供频道 CRUD、成员管理、内容管理、关注、统计、历史、搜索、
/// 黑名单、分区管理、时间线、公告、验证码等 40+ 个功能。
abstract class IChannelApi {
  /// 创建频道。
  Future<ChannelDetail> createChannel({
    required String channelName,
    required String channelTitle,
    String? description,
    String? coverUrl,
    int? joinPermission,
  });

  /// 获取频道详情。
  Future<ChannelDetail> getChannelDetail(int channelId);

  /// 更新频道信息。
  Future<UpdateChannelResponse> updateChannel(int channelId, {String? channelTitle, String? description, String? coverUrl, int? joinPermission});

  /// 删除频道（需验证码）。
  Future<DeleteChannelResponse> deleteChannel(int channelId, String verificationCode);

  /// 搜索频道。
  Future<Map<String, dynamic>> getChannelList({int? page, int? limit, String? sort, String? order, String? keyword});

  /// 加入频道。
  Future<MemberActionResponse> joinChannel(int channelId);

  /// 获取频道成员列表。
  Future<Map<String, dynamic>> getMemberList(int channelId, {int? page, int? limit, int? role, int? status});

  /// 审批/拒绝成员申请。
  ///
  /// [action]: `"approve"` 或 `"reject"`。
  Future<MemberActionResponse> approveMember(int channelId, int uid, String action, {String? reason});

  /// 踢出频道成员。
  Future<void> kickMember(int channelId, int uid, {String? reason});

  /// 退出频道。
  Future<void> leaveChannel(int channelId);

  /// 设置成员角色。
  Future<RoleChangeResponse> setMemberRole(int channelId, int uid, int role, {String? verificationCode});

  /// 获取待审批的成员申请列表。
  Future<Map<String, dynamic>> getPendingApplications(int channelId, {int? page, int? limit});

  /// 获取频道内容。
  Future<Map<String, dynamic>> getChannelContent(int channelId, {String? type, int? page, int? limit, String? sort, String? order, int? channelSectionId, bool? random});

  /// 向频道添加内容。
  Future<ContentAddResponse> addContentToChannel(int channelId, {required String type, required int contentId, int? channelSectionId});

  /// 从频道移除内容。
  Future<void> removeContentFromChannel(int channelId, String type, int contentId);

  /// 关注频道。
  Future<void> followChannel(int channelId);

  /// 取消关注频道。
  Future<void> unfollowChannel(int channelId);

  /// 获取关注的频道列表。
  Future<Map<String, dynamic>> getFollowedChannels({int? page, int? limit});

  /// 获取频道统计信息。
  Future<ChannelStats> getChannelStats(int channelId);

  /// 获取频道操作历史。
  Future<Map<String, dynamic>> getChannelHistory(int channelId, {int? uid, int? operationType, int? page, int? limit});

  /// 获取我管理的频道列表。
  Future<Map<String, dynamic>> getMyChannels({int? page, int? limit, int? role});

  /// 搜索频道。
  Future<Map<String, dynamic>> searchChannels(String keyword, {int? offset, int? num, int? page, int? limit, int? channelIdDesc, int? memberCountDesc, int? followerCountDesc, int? createdAtDesc, int? creatorUid, int? ownerUid, int? joinPermission, int? minMemberCount, int? maxMemberCount, int? minFollowerCount, int? maxFollowerCount});

  /// 将用户加入频道黑名单。
  Future<void> blockUser(int channelId, int uid, {String? reason});

  /// 将用户移出频道黑名单。
  Future<void> unblockUser(int channelId, int uid);

  /// 获取频道黑名单列表。
  Future<Map<String, dynamic>> getBlacklist(int channelId, {int? page, int? limit});

  /// 获取频道分区列表。
  Future<Map<String, dynamic>> getSections(int channelId, {bool? includeDeleted});

  /// 获取分区详情。
  Future<ChannelSection> getSectionDetail(int channelId, int sectionId);

  /// 获取分区统计信息。
  Future<SectionStats> getSectionStats(int channelId, int sectionId);

  /// 创建分区。
  Future<ChannelSection> createSection(int channelId, {required String sectionName, String? description, String? iconUrl});

  /// 更新分区。
  Future<ChannelSection> updateSection(int channelId, int sectionId, {String? description, String? iconUrl, int? sortOrder});

  /// 删除分区。
  Future<DeleteSectionResponse> deleteSection(int channelId, int sectionId, {int? transferToSectionId});

  /// 修改内容所属分区。
  Future<SectionContentChangeResponse> changeContentSection(int channelId, String type, int contentId, {required int channelSectionId});

  /// 发送删除频道验证码。
  Future<void> sendDeleteVerificationCode(int channelId);

  /// 发送转让频道验证码。
  Future<void> sendTransferVerificationCode(int channelId);

  /// 获取关注频道的动态时间线。
  Future<Map<String, dynamic>> getFollowingTimeline({int? page, int? limit});

  /// 获取频道动态时间线。
  Future<Map<String, dynamic>> getChannelTimeline(int channelId, {int? page, int? limit});

  /// 创建公告。
  Future<NoticeCreateResponse> createNotice(int channelId, {String? title, required String content});

  /// 删除公告。
  Future<NoticeDeleteResponse> deleteNotice(int channelId, int noticeId);

  /// 排序公告。
  Future<NoticeSortResponse> sortNotice(int channelId, int noticeId, int sortOrder);

  /// 获取公告列表。
  Future<Map<String, dynamic>> getNotices(int channelId, {bool? includeDeleted});
}

class ChannelApi extends BaseApi implements IChannelApi {
  ChannelApi(super.dio, super.getToken, {super.config});

  // ── Channel Management ──

  @override
  Future<ChannelDetail> createChannel({
    required String channelName,
    required String channelTitle,
    String? description,
    String? coverUrl,
    int? joinPermission,
  }) async {
    final response = await post('/channel/create', auth: true, data: {
      'channel_name': channelName,
      'channel_title': channelTitle,
      'description': ?description,
      'cover_url': ?coverUrl,
      'join_permission': ?joinPermission,
    });
    return ChannelDetail.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<ChannelDetail> getChannelDetail(int channelId) async {
    final response = await get('/channel/$channelId');
    return ChannelDetail.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<UpdateChannelResponse> updateChannel(
    int channelId, {
    String? channelTitle,
    String? description,
    String? coverUrl,
    int? joinPermission,
  }) async {
    final response = await put('/channel/$channelId', auth: true, data: {
      'channel_title': ?channelTitle,
      'description': ?description,
      'cover_url': ?coverUrl,
      'join_permission': ?joinPermission,
    });
    return UpdateChannelResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<DeleteChannelResponse> deleteChannel(
      int channelId, String verificationCode) async {
    final response = await delete('/channel/$channelId', auth: true, data: {
      'verification_code': verificationCode,
    });
    return DeleteChannelResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getChannelList({
    int? page,
    int? limit,
    String? sort,
    String? order,
    String? keyword,
  }) async {
    final response = await get('/channel', queryParameters: {
      'page': ?page,
      'limit': ?limit,
      'sort': ?sort,
      'order': ?order,
      'keyword': ?keyword,
    });
    final data = response['data'] as Map<String, dynamic>;
    final channels = (data['channels'] as List<dynamic>)
        .map((e) => ChannelSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return {
      'channels': channels,
      'pagination': pagination,
    };
  }

  // ── Member Management ──

  @override
  Future<MemberActionResponse> joinChannel(int channelId) async {
    final response = await post('/channel/$channelId/members', auth: true);
    return MemberActionResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getMemberList(
    int channelId, {
    int? page,
    int? limit,
    int? role,
    int? status,
  }) async {
    final response = await get('/channel/$channelId/members',
        queryParameters: {
          'page': ?page,
          'limit': ?limit,
          'role': ?role,
          'status': ?status,
        });
    final data = response['data'] as Map<String, dynamic>;
    final members = (data['members'] as List<dynamic>)
        .map((e) => ChannelMember.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return {'members': members, 'pagination': pagination};
  }

  @override
  Future<MemberActionResponse> approveMember(
      int channelId, int uid, String action,
      {String? reason}) async {
    final response = await put('/channel/$channelId/members/$uid', auth: true, data: {
      'action': action,
      'reason': ?reason,
    });
    return MemberActionResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> kickMember(int channelId, int uid, {String? reason}) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;
    await delete('/channel/$channelId/members/$uid', auth: true, data: data);
  }

  @override
  Future<void> leaveChannel(int channelId) async {
    await delete('/channel/$channelId/members/me', auth: true);
  }

  @override
  Future<RoleChangeResponse> setMemberRole(
    int channelId,
    int uid,
    int role, {
    String? verificationCode,
  }) async {
    final response = await put('/channel/$channelId/members/$uid/role', auth: true, data: {
      'role': role,
      'verification_code': ?verificationCode,
    });
    return RoleChangeResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getPendingApplications(
    int channelId, {
    int? page,
    int? limit,
  }) async {
    final response = await get('/channel/$channelId/members/pending', auth: true,
        queryParameters: {
          'page': ?page,
          'limit': ?limit,
        });
    final data = response['data'] as Map<String, dynamic>;
    final applications = (data['applications'] as List<dynamic>)
        .map((e) =>
            ChannelMemberApplication.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return {'applications': applications, 'pagination': pagination};
  }

  // ── Content Management ──

  @override
  Future<Map<String, dynamic>> getChannelContent(
    int channelId, {
    String? type,
    int? page,
    int? limit,
    String? sort,
    String? order,
    int? channelSectionId,
    bool? random,
  }) async {
    final response = await get('/channel/$channelId/content',
        queryParameters: {
          'type': ?type,
          'page': ?page,
          'limit': ?limit,
          'sort': ?sort,
          'order': ?order,
          'channel_section_id': ?channelSectionId,
          'random': ?random,
        });
    final data = response['data'] as Map<String, dynamic>;
    final content = (data['content'] as List<dynamic>)
        .map((e) => ChannelContentItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return {'content': content, 'pagination': pagination};
  }

  @override
  Future<ContentAddResponse> addContentToChannel(
    int channelId, {
    required String type,
    required int contentId,
    int? channelSectionId,
  }) async {
    final response = await post('/channel/$channelId/content', auth: true, data: {
      'type': type,
      'content_id': contentId,
      'channel_section_id': ?channelSectionId,
    });
    return ContentAddResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> removeContentFromChannel(
      int channelId, String type, int contentId) async {
    await delete('/channel/$channelId/content/$type/$contentId', auth: true);
  }

  // ── Follow Management ──

  @override
  Future<void> followChannel(int channelId) async {
    await post('/channel/$channelId/follow', auth: true);
  }

  @override
  Future<void> unfollowChannel(int channelId) async {
    await delete('/channel/$channelId/follow', auth: true);
  }

  @override
  Future<Map<String, dynamic>> getFollowedChannels({
    int? page,
    int? limit,
  }) async {
    final response = await get('/channel/following', auth: true, queryParameters: {
      'page': ?page,
      'limit': ?limit,
    });
    final data = response['data'] as Map<String, dynamic>;
    final channels = (data['channels'] as List<dynamic>)
        .map((e) => ChannelSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return {'channels': channels, 'pagination': pagination};
  }

  // ── Query ──

  @override
  Future<ChannelStats> getChannelStats(int channelId) async {
    final response = await get('/channel/$channelId/stats');
    return ChannelStats.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getChannelHistory(
    int channelId, {
    int? uid,
    int? operationType,
    int? page,
    int? limit,
  }) async {
    final response = await get('/channel/$channelId/history', auth: true,
        queryParameters: {
          'uid': ?uid,
          'operation_type': ?operationType,
          'page': ?page,
          'limit': ?limit,
        });
    final data = response['data'] as Map<String, dynamic>;
    final history = (data['history'] as List<dynamic>)
        .map((e) => ChannelHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return {'history': history, 'pagination': pagination};
  }

  @override
  Future<Map<String, dynamic>> getMyChannels({
    int? page,
    int? limit,
    int? role,
  }) async {
    final response = await get('/channel/my/channels', auth: true, queryParameters: {
      'page': ?page,
      'limit': ?limit,
      'role': ?role,
    });
    final data = response['data'] as Map<String, dynamic>;
    final channels = (data['channels'] as List<dynamic>)
        .map((e) => ChannelSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return {'channels': channels, 'pagination': pagination};
  }

  @override
  Future<Map<String, dynamic>> searchChannels(
    String keyword, {
    int? offset,
    int? num,
    int? page,
    int? limit,
    int? channelIdDesc,
    int? memberCountDesc,
    int? followerCountDesc,
    int? createdAtDesc,
    int? creatorUid,
    int? ownerUid,
    int? joinPermission,
    int? minMemberCount,
    int? maxMemberCount,
    int? minFollowerCount,
    int? maxFollowerCount,
  }) async {
    final response = await get('/channel/search', queryParameters: {
      'keyword': keyword,
      'offset': ?offset,
      'num': ?num,
      'page': ?page,
      'limit': ?limit,
      'channel_id_desc': ?channelIdDesc,
      'member_count_desc': ?memberCountDesc,
      'follower_count_desc': ?followerCountDesc,
      'created_at_desc': ?createdAtDesc,
      'creator_uid': ?creatorUid,
      'owner_uid': ?ownerUid,
      'join_permission': ?joinPermission,
      'min_member_count': ?minMemberCount,
      'max_member_count': ?maxMemberCount,
      'min_follower_count': ?minFollowerCount,
      'max_follower_count': ?maxFollowerCount,
    });
    final data = response['data'] as Map<String, dynamic>;
    final channels = (data['channels'] as List<dynamic>)
        .map((e) => ChannelSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    final totalCount = data['total_count'] as int?;
    return {
      'channels': channels,
      'pagination': pagination,
      'total_count': ?totalCount,
    };
  }

  // ── Blacklist ──

  @override
  Future<void> blockUser(int channelId, int uid, {String? reason}) async {
    await post('/channel/$channelId/blacklist', auth: true, data: {
      'uid': uid,
      'reason': ?reason,
    });
  }

  @override
  Future<void> unblockUser(int channelId, int uid) async {
    await delete('/channel/$channelId/blacklist/$uid', auth: true);
  }

  @override
  Future<Map<String, dynamic>> getBlacklist(
    int channelId, {
    int? page,
    int? limit,
  }) async {
    final response = await get('/channel/$channelId/blacklist', auth: true,
        queryParameters: {
          'page': ?page,
          'limit': ?limit,
        });
    final data = response['data'] as Map<String, dynamic>;
    final blacklist = (data['blacklist'] as List<dynamic>)
        .map((e) =>
            ChannelBlacklistEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return {'blacklist': blacklist, 'pagination': pagination};
  }

  // ── Section Management ──

  @override
  Future<Map<String, dynamic>> getSections(
    int channelId, {
    bool? includeDeleted,
  }) async {
    final response = await get('/channel/$channelId/sections',
        queryParameters: {
          'include_deleted': ?includeDeleted,
        });
    final data = response['data'] as Map<String, dynamic>;
    final sections = (data['sections'] as List<dynamic>)
        .map((e) => ChannelSection.fromJson(e as Map<String, dynamic>))
        .toList();
    final totalCount = data['total_count'] as int?;
    return {
      'sections': sections,
      'total_count': ?totalCount,
    };
  }

  @override
  Future<ChannelSection> getSectionDetail(
      int channelId, int sectionId) async {
    final response = await get('/channel/$channelId/sections/$sectionId');
    return ChannelSection.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<SectionStats> getSectionStats(int channelId, int sectionId) async {
    final response =
        await get('/channel/$channelId/sections/$sectionId/stats');
    return SectionStats.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<ChannelSection> createSection(
    int channelId, {
    required String sectionName,
    String? description,
    String? iconUrl,
  }) async {
    final response = await post('/channel/$channelId/sections', auth: true, data: {
      'section_name': sectionName,
      'description': ?description,
      'icon_url': ?iconUrl,
    });
    return ChannelSection.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<ChannelSection> updateSection(
    int channelId,
    int sectionId, {
    String? description,
    String? iconUrl,
    int? sortOrder,
  }) async {
    final response = await put('/channel/$channelId/sections/$sectionId', auth: true,
        data: {
          'description': ?description,
          'icon_url': ?iconUrl,
          'sort_order': ?sortOrder,
        });
    return ChannelSection.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<DeleteSectionResponse> deleteSection(
    int channelId,
    int sectionId, {
    int? transferToSectionId,
  }) async {
    final response = await delete('/channel/$channelId/sections/$sectionId', auth: true,
        data: {
          'transfer_to_section_id': ?transferToSectionId,
        });
    return DeleteSectionResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<SectionContentChangeResponse> changeContentSection(
    int channelId,
    String type,
    int contentId, {
    required int channelSectionId,
  }) async {
    final response = await put(
        '/channel/$channelId/content/$type/$contentId/section',
        auth: true,
        data: {
          'channel_section_id': channelSectionId,
        });
    return SectionContentChangeResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  // ── Verification Codes ──

  @override
  Future<void> sendDeleteVerificationCode(int channelId) async {
    await post('/channel/$channelId/delete_verification_code', auth: true);
  }

  @override
  Future<void> sendTransferVerificationCode(int channelId) async {
    await post('/channel/$channelId/transfer_verification_code', auth: true);
  }

  // ── Timeline ──

  @override
  Future<Map<String, dynamic>> getFollowingTimeline({
    int? page,
    int? limit,
  }) async {
    final response = await get('/channel/following/timeline', auth: true,
        queryParameters: {
          'page': ?page,
          'limit': ?limit,
        });
    final data = response['data'] as Map<String, dynamic>;
    final timeline = (data['timeline'] as List<dynamic>)
        .map((e) => ChannelTimelineWithChannelItem.fromJson(
            e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return {'timeline': timeline, 'pagination': pagination};
  }

  @override
  Future<Map<String, dynamic>> getChannelTimeline(
    int channelId, {
    int? page,
    int? limit,
  }) async {
    final response = await get('/channel/$channelId/timeline',
        queryParameters: {
          'page': ?page,
          'limit': ?limit,
        });
    final data = response['data'] as Map<String, dynamic>;
    final timeline = (data['timeline'] as List<dynamic>)
        .map((e) =>
            ChannelTimelineItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>;
    return {'timeline': timeline, 'pagination': pagination};
  }

  // ── Notices ──

  @override
  Future<NoticeCreateResponse> createNotice(
    int channelId, {
    String? title,
    required String content,
  }) async {
    final response = await post('/channel/$channelId/notices', auth: true, data: {
      'title': ?title,
      'content': content,
    });
    return NoticeCreateResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<NoticeDeleteResponse> deleteNotice(
      int channelId, int noticeId) async {
    final response =
        await delete('/channel/$channelId/notices/$noticeId', auth: true);
    return NoticeDeleteResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<NoticeSortResponse> sortNotice(
      int channelId, int noticeId, int sortOrder) async {
    final response = await put(
        '/channel/$channelId/notices/$noticeId/sort',
        auth: true,
        data: {'sort_order': sortOrder});
    return NoticeSortResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getNotices(
    int channelId, {
    bool? includeDeleted,
  }) async {
    final response = await get('/channel/$channelId/notices',
        queryParameters: {
          'include_deleted': ?includeDeleted,
        });
    final data = response['data'] as Map<String, dynamic>;
    final notices = (data['notices'] as List<dynamic>)
        .map((e) => ChannelNotice.fromJson(e as Map<String, dynamic>))
        .toList();
    final totalCount = data['total_count'] as int?;
    return {
      'notices': notices,
      'total_count': ?totalCount,
    };
  }
}
