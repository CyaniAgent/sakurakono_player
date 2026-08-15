import '../base_api.dart';
import '../models/block/block_list_data.dart';
import '../models/block/block_response.dart';
import '../models/block/block_status_response.dart';

/// 屏蔽模块接口。
///
/// 提供用户屏蔽/取消屏蔽、屏蔽列表查询、屏蔽状态查询功能。
abstract class IBlockApi {
  /// 屏蔽指定用户。
  ///
  /// [blockedId]: 被屏蔽的用户 UID。
  /// [reason]: 屏蔽原因。
  /// [reasonVisible]: 原因是否公开（1=是，0=否）。
  Future<BlockResponse> blockUser(int blockedId, {String? reason, int? reasonVisible});

  /// 取消屏蔽指定用户。
  Future<BlockResponse> unblockUser(int blockedId);

  /// 获取我的屏蔽列表。
  Future<BlockListData> getBlockList({int? page, int? pageSize});

  /// 获取屏蔽我的用户列表。
  Future<BlockListData> getBlockedByList({int? page, int? pageSize});

  /// 查询与指定用户的屏蔽状态。
  Future<BlockStatusResponse> getBlockStatus(int userId);
}

class BlockApi extends BaseApi implements IBlockApi {
  BlockApi(super.dio, super.getToken, {super.config});

  @override
  Future<BlockResponse> blockUser(
    int blockedId, {
    String? reason,
    int? reasonVisible,
  }) async {
    final data = <String, dynamic>{
      'blocked_id': blockedId,
      'reason': ?reason,
      'reason_visible': ?reasonVisible,
    };
    final response = await post('/block', auth: true, data: data);
    return BlockResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<BlockResponse> unblockUser(int blockedId) async {
    final response = await delete('/block/$blockedId', auth: true);
    return BlockResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<BlockListData> getBlockList({
    int? page,
    int? pageSize,
  }) async {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (pageSize != null) params['page_size'] = pageSize;
    final response = await get('/block/list', auth: true, queryParameters: params);
    return BlockListData.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<BlockListData> getBlockedByList({
    int? page,
    int? pageSize,
  }) async {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (pageSize != null) params['page_size'] = pageSize;
    final response = await get('/block/blocked/list', auth: true, queryParameters: params);
    return BlockListData.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<BlockStatusResponse> getBlockStatus(int userId) async {
    final response = await get('/block/status/$userId', auth: true);
    return BlockStatusResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }
}
